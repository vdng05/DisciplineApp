class HabitLog {
  final int? id;
  final int habitId;
  final String date; // "yyyy-MM-dd"
  final bool isCompleted;
  final DateTime? completedAt;
  final int count;
  final String? notes;

  HabitLog({
    this.id,
    required this.habitId,
    required this.date,
    this.isCompleted = false,
    this.completedAt,
    this.count = 0,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'date': date,
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAt?.toIso8601String(),
      'count': count,
      'notes': notes,
    };
  }

  factory HabitLog.fromMap(Map<String, dynamic> map) {
    return HabitLog(
      id: map['id'] as int?,
      habitId: map['habit_id'] as int,
      date: map['date'] as String,
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      completedAt: map['completed_at'] != null
          ? DateTime.tryParse(map['completed_at'].toString())
          : null,
      count: map['count'] as int? ?? 0,
      notes: map['notes'] as String?,
    );
  }

  HabitLog copyWith({
    int? id,
    int? habitId,
    String? date,
    bool? isCompleted,
    DateTime? completedAt,
    int? count,
    String? notes,
  }) {
    return HabitLog(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      count: count ?? this.count,
      notes: notes ?? this.notes,
    );
  }
}

