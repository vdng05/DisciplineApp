import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../models/habit_stats.dart';
import '../services/database_helper.dart';
import '../utils/date_utils.dart';

class StatsProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  DateTime _selectedDate = DateTime.now();
  int _selectedPeriodIndex = 0; // 0: Ngày, 1: Tuần, 2: Tháng, 3: Tổng quan
  bool _isLoading = false;

  // Cached stats data
  List<Habit> _habits = [];
  List<HabitLog> _allLogs = [];
  Map<int, HabitStats> _habitStats = {};

  // Weekly stats
  List<DayProgress> _weekDayProgressList = [];
  double _weeklyAverageRate = 0.0;
  int _weeklyTotalCompletions = 0;

  // Monthly stats
  List<DayProgress> _monthDayProgressList = [];
  double _monthlyAverageRate = 0.0;
  int _monthlyTotalCompletions = 0;

  // Overall stats
  int _allTimeCompletions = 0;
  int _bestOverallStreak = 0;
  int _currentOverallStreak = 0;
  double _disciplineScore = 0.0;
  DisciplineLevel _disciplineLevel = DisciplineLevel.levels.first;

  StatsProvider() {
    refreshStats();
  }

  // Getters
  DateTime get selectedDate => _selectedDate;
  int get selectedPeriodIndex => _selectedPeriodIndex;
  bool get isLoading => _isLoading;

  List<DayProgress> get weekDayProgressList => _weekDayProgressList;
  double get weeklyAverageRate => _weeklyAverageRate;
  int get weeklyTotalCompletions => _weeklyTotalCompletions;

  List<DayProgress> get monthDayProgressList => _monthDayProgressList;
  double get monthlyAverageRate => _monthlyAverageRate;
  int get monthlyTotalCompletions => _monthlyTotalCompletions;

  int get allTimeCompletions => _allTimeCompletions;
  int get bestOverallStreak => _bestOverallStreak;
  int get currentOverallStreak => _currentOverallStreak;
  double get disciplineScore => _disciplineScore;
  DisciplineLevel get disciplineLevel => _disciplineLevel;
  Map<int, HabitStats> get habitStats => _habitStats;
  List<Habit> get habits => _habits;

  void setPeriodIndex(int index) {
    if (_selectedPeriodIndex == index) return;
    _selectedPeriodIndex = index;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    refreshStats();
  }

  void previousWeek() {
    _selectedDate = _selectedDate.subtract(const Duration(days: 7));
    refreshStats();
  }

  void nextWeek() {
    _selectedDate = _selectedDate.add(const Duration(days: 7));
    refreshStats();
  }

  void previousMonth() {
    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
    refreshStats();
  }

  void nextMonth() {
    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    refreshStats();
  }

  /// Recomputes all statistics from SQLite
  Future<void> refreshStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      _habits = await _db.getAllHabits();
      _allLogs = await _db.getAllLogs();

      // Compute habit individual stats
      final statsMap = <int, HabitStats>{};
      int maxBestStreak = 0;
      int maxCurrentStreak = 0;

      for (final habit in _habits) {
        if (habit.id != null) {
          final stat = await _db.calculateHabitStats(habit);
          statsMap[habit.id!] = stat;

          if (stat.bestStreak > maxBestStreak) maxBestStreak = stat.bestStreak;
          if (stat.currentStreak > maxCurrentStreak) {
            maxCurrentStreak = stat.currentStreak;
          }
        }
      }
      _habitStats = statsMap;
      _bestOverallStreak = maxBestStreak;
      _currentOverallStreak = maxCurrentStreak;

      // Filter all completed logs
      final completedLogs = _allLogs.where((l) => l.isCompleted).toList();
      _allTimeCompletions = completedLogs.length;

      // Compute Weekly progress (Mon - Sun of _selectedDate)
      await _calculateWeeklyStats();

      // Compute Monthly progress
      await _calculateMonthlyStats();

      // Compute Overall Discipline Score
      _calculateDisciplineScore();
    } catch (e) {
      debugPrint('Error calculating stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _calculateWeeklyStats() async {
    final daysOfWeek = AppDateUtils.getDaysOfWeek(_selectedDate);
    final weekProgress = <DayProgress>[];
    int totalWeekCompletions = 0;
    double sumRates = 0;
    int daysWithScheduled = 0;

    for (final day in daysOfWeek) {
      final dateIso = AppDateUtils.formatDateIso(day);
      final logs = await _db.getLogsForDate(dateIso);
      final completedMap = {
        for (final l in logs) l.habitId: l.isCompleted,
      };

      int scheduledCount = 0;
      int dayCompleted = 0;

      for (final h in _habits) {
        if (h.isScheduledFor(day)) {
          scheduledCount++;
          if (completedMap[h.id] == true) {
            dayCompleted++;
          }
        }
      }

      totalWeekCompletions += dayCompleted;
      final progress = DayProgress(
        date: day,
        totalScheduled: scheduledCount,
        completed: dayCompleted,
      );
      weekProgress.add(progress);

      if (scheduledCount > 0) {
        sumRates += progress.rate;
        daysWithScheduled++;
      }
    }

    _weekDayProgressList = weekProgress;
    _weeklyTotalCompletions = totalWeekCompletions;
    _weeklyAverageRate =
        daysWithScheduled == 0 ? 0.0 : sumRates / daysWithScheduled;
  }

  Future<void> _calculateMonthlyStats() async {
    final daysInMonth = AppDateUtils.getDaysInMonth(_selectedDate);
    final monthProgress = <DayProgress>[];
    int totalMonthCompletions = 0;
    double sumRates = 0;
    int daysWithScheduled = 0;

    for (final day in daysInMonth) {
      final dateIso = AppDateUtils.formatDateIso(day);
      final logs = await _db.getLogsForDate(dateIso);
      final completedMap = {
        for (final l in logs) l.habitId: l.isCompleted,
      };

      int scheduledCount = 0;
      int dayCompleted = 0;

      for (final h in _habits) {
        if (h.isScheduledFor(day)) {
          scheduledCount++;
          if (completedMap[h.id] == true) {
            dayCompleted++;
          }
        }
      }

      totalMonthCompletions += dayCompleted;
      final progress = DayProgress(
        date: day,
        totalScheduled: scheduledCount,
        completed: dayCompleted,
      );
      monthProgress.add(progress);

      // Only count days up to today or with scheduled habits for fair average
      if (scheduledCount > 0 && !day.isAfter(DateTime.now())) {
        sumRates += progress.rate;
        daysWithScheduled++;
      }
    }

    _monthDayProgressList = monthProgress;
    _monthlyTotalCompletions = totalMonthCompletions;
    _monthlyAverageRate =
        daysWithScheduled == 0 ? 0.0 : sumRates / daysWithScheduled;
  }

  void _calculateDisciplineScore() {
    // Discipline score formula combines weekly rate (40%), monthly rate (30%), and streak bonus (30%)
    final streakScore = (_currentOverallStreak * 10.0).clamp(0.0, 30.0);
    final weeklyPart = (_weeklyAverageRate * 0.4).clamp(0.0, 40.0);
    final monthlyPart = (_monthlyAverageRate * 0.3).clamp(0.0, 30.0);

    _disciplineScore = (weeklyPart + monthlyPart + streakScore).clamp(0.0, 100.0);
    _disciplineLevel = DisciplineLevel.getLevelForScore(_disciplineScore);
  }
}

