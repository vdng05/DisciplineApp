class HabitStats {
  final int habitId;
  final int currentStreak;
  final int bestStreak;
  final int totalCompletions;
  final int totalScheduledDays;
  final double completionRate; // 0.0 to 100.0

  HabitStats({
    required this.habitId,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalCompletions = 0,
    this.totalScheduledDays = 0,
    this.completionRate = 0.0,
  });
}

class DayProgress {
  final DateTime date;
  final int totalScheduled;
  final int completed;
  
  DayProgress({
    required this.date,
    required this.totalScheduled,
    required this.completed,
  });

  double get rate =>
      totalScheduled == 0 ? 0.0 : (completed / totalScheduled) * 100.0;
  
  bool get isFullComplete => totalScheduled > 0 && completed >= totalScheduled;
}

class DisciplineLevel {
  final String title;
  final String badge;
  final String description;
  final double minScore;

  const DisciplineLevel({
    required this.title,
    required this.badge,
    required this.description,
    required this.minScore,
  });

  static const List<DisciplineLevel> levels = [
    DisciplineLevel(
      title: 'Tân Binh Khởi Đầu',
      badge: '🌱',
      description: 'Đang từng bước xây dựng thói quen đầu tiên.',
      minScore: 0,
    ),
    DisciplineLevel(
      title: 'Chiến Binh Kiên Trì',
      badge: '⚡',
      description: 'Duy trì kỷ luật ổn định và đều đặn mỗi ngày.',
      minScore: 40,
    ),
    DisciplineLevel(
      title: 'Hiệp Sĩ Kỷ Luật',
      badge: '🛡️',
      description: 'Khả năng kiểm soát bản thân xuất sắc.',
      minScore: 70,
    ),
    DisciplineLevel(
      title: 'Bậc Thầy Tự Chủ',
      badge: '👑',
      description: 'Kỷ luật tự giác đã trở thành phong cách sống.',
      minScore: 90,
    ),
  ];

  static DisciplineLevel getLevelForScore(double score) {
    for (int i = levels.length - 1; i >= 0; i--) {
      if (score >= levels[i].minScore) {
        return levels[i];
      }
    }
    return levels.first;
  }
}

