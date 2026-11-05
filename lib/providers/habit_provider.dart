import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../models/habit_stats.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';
import '../utils/date_utils.dart';

class HabitProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final NotificationService _notifications = NotificationService.instance;

  List<Habit> _habits = [];
  Map<int, HabitLog> _currentDateLogs = {};
  Map<int, HabitStats> _habitStats = {};

  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Tất cả';
  String _statusFilter = 'all'; // 'all', 'pending', 'completed'
  String _searchQuery = '';
  bool _isLoading = true;
  bool _showCelebration = false;

  HabitProvider() {
    loadData();
  }

  // Getters
  List<Habit> get allHabits => _habits;
  DateTime get selectedDate => _selectedDate;
  String get selectedCategory => _selectedCategory;
  String get statusFilter => _statusFilter;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get showCelebration => _showCelebration;

  /// Habits that are scheduled to be done on the currently selected date
  List<Habit> get scheduledHabits {
    return _habits.where((h) => h.isScheduledFor(_selectedDate)).toList();
  }

  /// Scheduled habits filtered by category, status, and search query
  List<Habit> get filteredHabits {
    return scheduledHabits.where((h) {
      // 1. Category filter
      if (_selectedCategory != 'Tất cả' && h.category != _selectedCategory) {
        return false;
      }

      // 2. Status filter
      final isCompleted = isHabitCompleted(h.id!);
      if (_statusFilter == 'pending' && isCompleted) {
        return false;
      }
      if (_statusFilter == 'completed' && !isCompleted) {
        return false;
      }

      // 3. Search query
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchTitle = h.title.toLowerCase().contains(query);
        final matchDesc = h.description.toLowerCase().contains(query);
        final matchCategory = h.category.toLowerCase().contains(query);
        if (!matchTitle && !matchDesc && !matchCategory) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Number of habits completed on selected date
  int get completedCount {
    int count = 0;
    for (final h in scheduledHabits) {
      if (isHabitCompleted(h.id!)) {
        count++;
      }
    }
    return count;
  }

  int get totalScheduledCount => scheduledHabits.length;

  double get completionRate {
    if (totalScheduledCount == 0) return 0.0;
    return (completedCount / totalScheduledCount) * 100.0;
  }

  bool isHabitCompleted(int habitId) {
    final log = _currentDateLogs[habitId];
    return log != null && log.isCompleted;
  }

  HabitStats? getStatsForHabit(int habitId) {
    return _habitStats[habitId];
  }

  // Setters & Actions
  void dismissCelebration() {
    _showCelebration = false;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    if (AppDateUtils.isSameDay(_selectedDate, date)) return;
    _selectedDate = DateTime(date.year, date.month, date.day);
    _loadLogsForSelectedDate();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _habits = await _db.getAllHabits();
      await _loadLogsForSelectedDate(shouldNotify: false);
      await _loadAllHabitStats(shouldNotify: false);
    } catch (e) {
      debugPrint('Error loading habits data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadLogsForSelectedDate({bool shouldNotify = true}) async {
    try {
      final dateIso = AppDateUtils.formatDateIso(_selectedDate);
      final logs = await _db.getLogsForDate(dateIso);
      _currentDateLogs = {for (final log in logs) log.habitId: log};
    } catch (e) {
      debugPrint('Error loading logs for date: $e');
    }
    if (shouldNotify) {
      notifyListeners();
    }
  }

  Future<void> _loadAllHabitStats({bool shouldNotify = true}) async {
    final statsMap = <int, HabitStats>{};
    for (final habit in _habits) {
      if (habit.id != null) {
        final stat = await _db.calculateHabitStats(habit);
        statsMap[habit.id!] = stat;
      }
    }
    _habitStats = statsMap;
    if (shouldNotify) {
      notifyListeners();
    }
  }

  /// Toggle habit completion for selected date
  Future<void> toggleHabit(int habitId) async {
    try {
      final wasCompleted = isHabitCompleted(habitId);
      final newStatus = await _db.toggleHabitCompletion(habitId, _selectedDate);

      // Optimistically or accurately update map
      final dateIso = AppDateUtils.formatDateIso(_selectedDate);
      _currentDateLogs[habitId] = HabitLog(
        habitId: habitId,
        date: dateIso,
        isCompleted: newStatus,
        completedAt: newStatus ? DateTime.now() : null,
      );

      // Check if this action made all scheduled habits completed on today
      if (newStatus &&
          !wasCompleted &&
          AppDateUtils.isToday(_selectedDate) &&
          totalScheduledCount > 0 &&
          completedCount == totalScheduledCount) {
        _showCelebration = true;
      }

      // Refresh stats for this habit in background
      final habit = _habits.firstWhere((h) => h.id == habitId);
      final updatedStat = await _db.calculateHabitStats(habit);
      _habitStats[habitId] = updatedStat;

      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling habit: $e');
    }
  }

  /// Add a new habit
  Future<bool> addHabit(Habit habit) async {
    try {
      final id = await _db.insertHabit(habit);
      final createdHabit = habit.copyWith(id: id);
      _habits.add(createdHabit);

      if (createdHabit.isReminderEnabled) {
        await _notifications.scheduleHabitReminder(createdHabit);
      }

      final stat = await _db.calculateHabitStats(createdHabit);
      _habitStats[id] = stat;

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding habit: $e');
      return false;
    }
  }

  /// Update an existing habit
  Future<bool> updateHabit(Habit habit) async {
    try {
      await _db.updateHabit(habit);
      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        _habits[index] = habit;
      }

      if (habit.isReminderEnabled) {
        await _notifications.scheduleHabitReminder(habit);
      } else if (habit.id != null) {
        await _notifications.cancelHabitReminder(habit.id!);
      }

      if (habit.id != null) {
        final stat = await _db.calculateHabitStats(habit);
        _habitStats[habit.id!] = stat;
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating habit: $e');
      return false;
    }
  }

  /// Delete a habit
  Future<bool> deleteHabit(int habitId) async {
    try {
      await _db.deleteHabit(habitId);
      await _notifications.cancelHabitReminder(habitId);

      _habits.removeWhere((h) => h.id == habitId);
      _currentDateLogs.remove(habitId);
      _habitStats.remove(habitId);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting habit: $e');
      return false;
    }
  }

  /// Reset to default habits and sample data
  Future<void> resetToDefaults() async {
    await _db.resetToDefaults();
    await loadData();
  }

  /// Clear all data
  Future<void> clearAllData() async {
    await _db.clearAllData();
    _habits.clear();
    _currentDateLogs.clear();
    _habitStats.clear();
    notifyListeners();
  }
}

