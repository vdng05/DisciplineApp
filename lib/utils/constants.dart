import 'package:flutter/material.dart';

class AppColors {
  // Primary brand palette
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFFEEF2FF);
  
  static const Color secondary = Color(0xFF06B6D4); // Cyan
  static const Color accent = Color(0xFFF59E0B); // Amber
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color danger = Color(0xFFEF4444); // Red
  static const Color warning = Color(0xFFF97316); // Orange

  // Habit color options for custom tagging
  static const List<Color> habitColors = [
    Color(0xFF3B82F6), // Blue
    Color(0xFF8B5CF6), // Purple
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Rose/Red
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEC4899), // Pink
    Color(0xFF14B8A6), // Teal
    Color(0xFFF97316), // Orange
    Color(0xFF6366F1), // Indigo
  ];

  // Neutral Colors - Light
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Neutral Colors - Dark
  static const Color bgDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceLightDark = Color(0xFF334155);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF334155);
}

class AppConstants {
  static const String appName = 'Discipline';
  static const String appSubtitle = 'Rèn Luyện Kỷ Luật Bản Thân';

  static const List<String> categories = [
    'Tất cả',
    'Sức khỏe',
    'Học tập',
    'Kỷ luật',
    'Thể thao',
    'Tinh thần',
    'Năng suất',
    'Tài chính',
  ];

  static const List<String> habitCategories = [
    'Sức khỏe',
    'Học tập',
    'Kỷ luật',
    'Thể thao',
    'Tinh thần',
    'Năng suất',
    'Tài chính',
  ];

  // Icons available for habits
  static const Map<String, IconData> habitIcons = {
    'water_drop': Icons.water_drop_rounded,
    'fitness_center': Icons.fitness_center_rounded,
    'menu_book': Icons.menu_book_rounded,
    'bedtime': Icons.bedtime_rounded,
    'directions_run': Icons.directions_run_rounded,
    'self_improvement': Icons.self_improvement_rounded,
    'code': Icons.code_rounded,
    'alarm': Icons.alarm_rounded,
    'check_circle': Icons.check_circle_rounded,
    'savings': Icons.savings_rounded,
    'laptop_mac': Icons.laptop_mac_rounded,
    'brush': Icons.brush_rounded,
    'music_note': Icons.music_note_rounded,
    'eco': Icons.eco_rounded,
    'clean_hands': Icons.clean_hands_rounded,
    'favorite': Icons.favorite_rounded,
    'restaurant': Icons.restaurant_rounded,
    'wb_sunny': Icons.wb_sunny_rounded,
  };

  static IconData getIconData(String name) {
    return habitIcons[name] ?? Icons.check_circle_outline_rounded;
  }

  // Inspirational discipline quotes
  static const List<Map<String, String>> disciplineQuotes = [
    {
      'quote': 'Kỷ luật là cầu nối giữa mục tiêu và thành tựu.',
      'author': 'Jim Rohn'
    },
    {
      'quote': 'Chúng ta là những gì chúng ta lặp đi lặp lại. Sự xuất sắc là thói quen.',
      'author': 'Aristotle'
    },
    {
      'quote': 'Động lực giúp bạn bắt đầu. Thói quen giúp bạn tiếp tục.',
      'author': 'Jim Ryun'
    },
    {
      'quote': 'Chỉ cần tốt hơn 1% mỗi ngày, sau một năm bạn sẽ tiến bộ gấp 37 lần.',
      'author': 'Atomic Habits'
    },
    {
      'quote': 'Kỷ luật tự giác chính là sự tự do đích thực.',
      'author': 'Jocko Willink'
    },
    {
      'quote': 'Chiến thắng vĩ đại nhất là chiến thắng chính bản thân mình.',
      'author': 'Plato'
    },
    {
      'quote': 'Gieo suy nghĩ gặt hành vi, gieo hành vi gặt thói quen, gieo thói quen gặt tính cách, gieo tính cách gặt số phận.',
      'author': 'Tục ngữ'
    },
  ];
}

