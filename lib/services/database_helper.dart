import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/habit.dart';
import '../models/habit_log.dart';
import '../models/habit_stats.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Windows / Linux desktop support using sqflite_common_ffi
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String dbPath;
    if (kIsWeb) {
      dbPath = 'discipline_app.db';
    } else {
      final docsDir = await getApplicationDocumentsDirectory();
      dbPath = p.join(docsDir.path, 'discipline_app.db');
    }

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create habits table
    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT,
        color_value INTEGER,
        icon_name TEXT,
        frequency_type TEXT,
        frequency_days TEXT,
        reminder_time TEXT,
        is_reminder_enabled INTEGER DEFAULT 0,
        target_count INTEGER DEFAULT 1,
        unit TEXT,
        created_at TEXT,
        is_archived INTEGER DEFAULT 0
      )
    ''');

    // Create habit_logs table
    await db.execute('''
      CREATE TABLE habit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        is_completed INTEGER NOT NULL,
        completed_at TEXT,
        count INTEGER DEFAULT 0,
        notes TEXT,
        UNIQUE(habit_id, date) ON CONFLICT REPLACE,
        FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE
      )
    ''');

    // Seed initial realistic data so the app has content on first run
    await _seedInitialData(db);
  }

  /// Seeds 5 default habits with historical completions for the last 7 days
  Future<void> _seedInitialData(Database db) async {
    final now = DateTime.now();

    final defaultHabits = [
      Habit(
        title: 'Uống 2 lít nước',
        description: 'Bổ sung đủ nước lọc mỗi ngày để thanh lọc cơ thể',
        category: 'Sức khỏe',
        colorValue: AppColors.habitColors[0].toARGB32(), // Blue
        iconName: 'water_drop',
        frequencyType: 'daily',
        frequencyDays: [1, 2, 3, 4, 5, 6, 7],
        reminderTime: '08:00',
        isReminderEnabled: true,
        targetCount: 8,
        unit: 'ly',
        createdAt: now.subtract(const Duration(days: 14)),
      ),
      Habit(
        title: 'Đọc sách 30 phút',
        description: 'Đọc sách phát triển bản thân hoặc chuyên ngành',
        category: 'Học tập',
        colorValue: AppColors.habitColors[3].toARGB32(), // Amber
        iconName: 'menu_book',
        frequencyType: 'daily',
        frequencyDays: [1, 2, 3, 4, 5, 6, 7],
        reminderTime: '21:00',
        isReminderEnabled: true,
        targetCount: 30,
        unit: 'phút',
        createdAt: now.subtract(const Duration(days: 14)),
      ),
      Habit(
        title: 'Tập thể dục buổi sáng',
        description: 'Chạy bộ hoặc hít đất rèn luyện thể lực',
        category: 'Thể thao',
        colorValue: AppColors.habitColors[2].toARGB32(), // Emerald
        iconName: 'fitness_center',
        frequencyType: 'specific_days',
        frequencyDays: [1, 2, 3, 4, 5, 6], // T2 - T7
        reminderTime: '06:30',
        isReminderEnabled: true,
        targetCount: 20,
        unit: 'phút',
        createdAt: now.subtract(const Duration(days: 14)),
      ),
      Habit(
        title: 'Lập kế hoạch ngày mới',
        description: 'Viết ra 3 mục tiêu quan trọng nhất cần hoàn thành',
        category: 'Kỷ luật',
        colorValue: AppColors.habitColors[1].toARGB32(), // Purple
        iconName: 'check_circle',
        frequencyType: 'daily',
        frequencyDays: [1, 2, 3, 4, 5, 6, 7],
        reminderTime: '07:00',
        isReminderEnabled: true,
        targetCount: 1,
        unit: 'lần',
        createdAt: now.subtract(const Duration(days: 14)),
      ),
      Habit(
        title: 'Ngủ trước 23h00',
        description: 'Tắt màn hình thiết bị và đi ngủ đúng giờ để nạp năng lượng',
        category: 'Sức khỏe',
        colorValue: AppColors.habitColors[9].toARGB32(), // Indigo
        iconName: 'bedtime',
        frequencyType: 'daily',
        frequencyDays: [1, 2, 3, 4, 5, 6, 7],
        reminderTime: '22:45',
        isReminderEnabled: true,
        targetCount: 1,
        unit: 'lần',
        createdAt: now.subtract(const Duration(days: 14)),
      ),
    ];

    final insertedHabitIds = <int>[];
    for (final habit in defaultHabits) {
      final id = await db.insert('habits', habit.toMap());
      insertedHabitIds.add(id);
    }

    // Seed completions for the past 6 days
    for (int daysAgo = 6; daysAgo >= 1; daysAgo--) {
      final date = now.subtract(Duration(days: daysAgo));
      final dateStr = AppDateUtils.formatDateIso(date);

      // Simulate completions:
      // Habit 0 (Nước): completed every day
      await db.insert('habit_logs', {
        'habit_id': insertedHabitIds[0],
        'date': dateStr,
        'is_completed': 1,
        'completed_at': date.toIso8601String(),
        'count': 8,
      });

      // Habit 1 (Sách): completed most days
      if (daysAgo != 4) {
        await db.insert('habit_logs', {
          'habit_id': insertedHabitIds[1],
          'date': dateStr,
          'is_completed': 1,
          'completed_at': date.toIso8601String(),
          'count': 30,
        });
      }

      // Habit 2 (Thể dục): completed on scheduled days
      if (date.weekday <= 6 && daysAgo != 2) {
        await db.insert('habit_logs', {
          'habit_id': insertedHabitIds[2],
          'date': dateStr,
          'is_completed': 1,
          'completed_at': date.toIso8601String(),
          'count': 20,
        });
      }

      // Habit 3 (Kế hoạch): completed almost daily
      if (daysAgo != 5) {
        await db.insert('habit_logs', {
          'habit_id': insertedHabitIds[3],
          'date': dateStr,
          'is_completed': 1,
          'completed_at': date.toIso8601String(),
          'count': 1,
        });
      }

      // Habit 4 (Ngủ sớm)
      if (daysAgo % 2 == 0) {
        await db.insert('habit_logs', {
          'habit_id': insertedHabitIds[4],
          'date': dateStr,
          'is_completed': 1,
          'completed_at': date.toIso8601String(),
          'count': 1,
        });
      }
    }
  }

  // ================= HABIT OPERATIONS =================

  Future<int> insertHabit(Habit habit) async {
    final db = await database;
    return await db.insert('habits', habit.toMap());
  }

  Future<int> updateHabit(Habit habit) async {
    final db = await database;
    return await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<int> deleteHabit(int id) async {
    final db = await database;
    // Delete logs first
    await db.delete('habit_logs', where: 'habit_id = ?', whereArgs: [id]);
    return await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Habit>> getAllHabits({bool includeArchived = false}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps;
    if (includeArchived) {
      maps = await db.query('habits', orderBy: 'id ASC');
    } else {
      maps = await db.query(
        'habits',
        where: 'is_archived = ?',
        whereArgs: [0],
        orderBy: 'id ASC',
      );
    }
    return maps.map((m) => Habit.fromMap(m)).toList();
  }

  Future<Habit?> getHabitById(int id) async {
    final db = await database;
    final maps = await db.query(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Habit.fromMap(maps.first);
    }
    return null;
  }

  // ================= HABIT LOG OPERATIONS =================

  /// Toggles habit completion for given date
  Future<bool> toggleHabitCompletion(int habitId, DateTime date) async {
    final db = await database;
    final dateIso = AppDateUtils.formatDateIso(date);

    final existing = await db.query(
      'habit_logs',
      where: 'habit_id = ? AND date = ?',
      whereArgs: [habitId, dateIso],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      final isCurrentlyCompleted = (existing.first['is_completed'] as int) == 1;
      final newStatus = !isCurrentlyCompleted;

      await db.update(
        'habit_logs',
        {
          'is_completed': newStatus ? 1 : 0,
          'completed_at': newStatus ? DateTime.now().toIso8601String() : null,
        },
        where: 'habit_id = ? AND date = ?',
        whereArgs: [habitId, dateIso],
      );
      return newStatus;
    } else {
      // First time completing for this date
      await db.insert('habit_logs', {
        'habit_id': habitId,
        'date': dateIso,
        'is_completed': 1,
        'completed_at': DateTime.now().toIso8601String(),
        'count': 1,
      });
      return true;
    }
  }

  Future<List<HabitLog>> getLogsForDate(String dateIso) async {
    final db = await database;
    final maps = await db.query(
      'habit_logs',
      where: 'date = ?',
      whereArgs: [dateIso],
    );
    return maps.map((m) => HabitLog.fromMap(m)).toList();
  }

  Future<HabitLog?> getLog(int habitId, String dateIso) async {
    final db = await database;
    final maps = await db.query(
      'habit_logs',
      where: 'habit_id = ? AND date = ?',
      whereArgs: [habitId, dateIso],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return HabitLog.fromMap(maps.first);
    }
    return null;
  }

  Future<List<HabitLog>> getLogsForHabit(int habitId) async {
    final db = await database;
    final maps = await db.query(
      'habit_logs',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'date DESC',
    );
    return maps.map((m) => HabitLog.fromMap(m)).toList();
  }

  Future<List<HabitLog>> getLogsBetweenDates(
      String startDateIso, String endDateIso) async {
    final db = await database;
    final maps = await db.query(
      'habit_logs',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDateIso, endDateIso],
      orderBy: 'date ASC',
    );
    return maps.map((m) => HabitLog.fromMap(m)).toList();
  }

  Future<List<HabitLog>> getAllLogs() async {
    final db = await database;
    final maps = await db.query('habit_logs', orderBy: 'date DESC');
    return maps.map((m) => HabitLog.fromMap(m)).toList();
  }

  // ================= STATISTICS & STREAKS =================

  /// Calculate streak for a specific habit
  Future<HabitStats> calculateHabitStats(Habit habit) async {
    final db = await database;
    final logs = await db.query(
      'habit_logs',
      where: 'habit_id = ? AND is_completed = 1',
      whereArgs: [habit.id],
      orderBy: 'date DESC',
    );

    final completedDates = logs
        .map((m) => AppDateUtils.parseDateIso(m['date'] as String))
        .toSet();

    final totalCompletions = completedDates.length;

    // Calculate current streak
    int currentStreak = 0;
    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);

    // If today is scheduled and completed, streak starts today.
    // If today is not completed yet, streak can continue from yesterday without breaking!
    DateTime checkDate = today;
    if (!completedDates.any((d) => AppDateUtils.isSameDay(d, today))) {
      checkDate = today.subtract(const Duration(days: 1));
    }

    while (true) {
      if (habit.isScheduledFor(checkDate)) {
        if (completedDates.any((d) => AppDateUtils.isSameDay(d, checkDate))) {
          currentStreak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      } else {
        // Skip non-scheduled days
        checkDate = checkDate.subtract(const Duration(days: 1));
      }

      // Safeguard break for extreme ranges
      if (today.difference(checkDate).inDays > 365) break;
    }

    // Calculate best streak
    int bestStreak = currentStreak;
    int tempStreak = 0;

    // Scan backwards from today for past 365 days
    DateTime scanDate = today;
    for (int i = 0; i < 365; i++) {
      if (habit.isScheduledFor(scanDate)) {
        if (completedDates.any((d) => AppDateUtils.isSameDay(d, scanDate))) {
          tempStreak++;
          if (tempStreak > bestStreak) bestStreak = tempStreak;
        } else {
          tempStreak = 0;
        }
      }
      scanDate = scanDate.subtract(const Duration(days: 1));
    }

    // Calculate total scheduled days since habit creation
    final created = DateTime(
        habit.createdAt.year, habit.createdAt.month, habit.createdAt.day);
    int scheduledDays = 0;
    DateTime d = created;
    while (!d.isAfter(today)) {
      if (habit.isScheduledFor(d)) {
        scheduledDays++;
      }
      d = d.add(const Duration(days: 1));
    }
    if (scheduledDays == 0) scheduledDays = 1;

    final rate = (totalCompletions / scheduledDays) * 100.0;

    return HabitStats(
      habitId: habit.id ?? 0,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      totalCompletions: totalCompletions,
      totalScheduledDays: scheduledDays,
      completionRate: rate.clamp(0.0, 100.0),
    );
  }

  /// Reset all data and re-seed defaults
  Future<void> resetToDefaults() async {
    final db = await database;
    await db.delete('habit_logs');
    await db.delete('habits');
    await _seedInitialData(db);
  }

  /// Clear everything (empty app state)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('habit_logs');
    await db.delete('habits');
  }
}
