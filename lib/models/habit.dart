import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class Habit {
  final int? id;
  final String title;
  final String description;
  final String category;
  final int colorValue;
  final String iconName;
  final String frequencyType; // 'daily' or 'specific_days'
  final List<int> frequencyDays; // 1 (Mon) -> 7 (Sun)
  final String? reminderTime; // "07:30"
  final bool isReminderEnabled;
  final int targetCount; // e.g. 1
  final String unit; // 'lần', 'phút', 'ly', 'trang'
  final DateTime createdAt;
  final bool isArchived;

  Habit({
    this.id,
    required this.title,
    this.description = '',
    this.category = 'Kỷ luật',
    int? colorValue,
    this.iconName = 'check_circle',
    this.frequencyType = 'daily',
    List<int>? frequencyDays,
    this.reminderTime,
    this.isReminderEnabled = false,
    this.targetCount = 1,
    this.unit = 'lần',
    DateTime? createdAt,
    this.isArchived = false,
  })  : colorValue = colorValue ?? AppColors.habitColors.first.toARGB32(),
        frequencyDays = frequencyDays ?? [1, 2, 3, 4, 5, 6, 7],
        createdAt = createdAt ?? DateTime.now();

  Color get color => Color(colorValue);

  IconData get icon => AppConstants.getIconData(iconName);

  /// Check if the habit should be performed on [date]
  bool isScheduledFor(DateTime date) {
    if (frequencyType == 'daily') {
      return true;
    }
    // Specific days
    return frequencyDays.contains(date.weekday);
  }

  /// Human-readable frequency string
  String get frequencyDescription {
    if (frequencyType == 'daily' || frequencyDays.length == 7) {
      return 'Hàng ngày';
    }
    if (frequencyDays.length == 5 &&
        frequencyDays.contains(1) &&
        frequencyDays.contains(2) &&
        frequencyDays.contains(3) &&
        frequencyDays.contains(4) &&
        frequencyDays.contains(5)) {
      return 'Thứ 2 - Thứ 6';
    }
    if (frequencyDays.length == 2 &&
        frequencyDays.contains(6) &&
        frequencyDays.contains(7)) {
      return 'Cuối tuần (T7, CN)';
    }

    const dayLabels = {
      1: 'T2',
      2: 'T3',
      3: 'T4',
      4: 'T5',
      5: 'T6',
      6: 'T7',
      7: 'CN'
    };
    final sortedDays = List<int>.from(frequencyDays)..sort();
    return sortedDays.map((d) => dayLabels[d] ?? '').join(', ');
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'color_value': colorValue,
      'icon_name': iconName,
      'frequency_type': frequencyType,
      'frequency_days': jsonEncode(frequencyDays),
      'reminder_time': reminderTime,
      'is_reminder_enabled': isReminderEnabled ? 1 : 0,
      'target_count': targetCount,
      'unit': unit,
      'created_at': createdAt.toIso8601String(),
      'is_archived': isArchived ? 1 : 0,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    List<int> parsedDays = [1, 2, 3, 4, 5, 6, 7];
    if (map['frequency_days'] != null) {
      try {
        final decoded = jsonDecode(map['frequency_days'].toString());
        if (decoded is List) {
          parsedDays = decoded.map((e) => int.parse(e.toString())).toList();
        }
      } catch (_) {
        parsedDays = [1, 2, 3, 4, 5, 6, 7];
      }
    }

    return Habit(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'Kỷ luật',
      colorValue: map['color_value'] as int?,
      iconName: map['icon_name'] as String? ?? 'check_circle',
      frequencyType: map['frequency_type'] as String? ?? 'daily',
      frequencyDays: parsedDays,
      reminderTime: map['reminder_time'] as String?,
      isReminderEnabled: (map['is_reminder_enabled'] as int? ?? 0) == 1,
      targetCount: map['target_count'] as int? ?? 1,
      unit: map['unit'] as String? ?? 'lần',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isArchived: (map['is_archived'] as int? ?? 0) == 1,
    );
  }

  Habit copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    int? colorValue,
    String? iconName,
    String? frequencyType,
    List<int>? frequencyDays,
    String? reminderTime,
    bool? isReminderEnabled,
    int? targetCount,
    String? unit,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      colorValue: colorValue ?? this.colorValue,
      iconName: iconName ?? this.iconName,
      frequencyType: frequencyType ?? this.frequencyType,
      frequencyDays: frequencyDays ?? this.frequencyDays,
      reminderTime: reminderTime ?? this.reminderTime,
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
      targetCount: targetCount ?? this.targetCount,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}

