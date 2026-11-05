import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../models/habit_stats.dart';
import '../utils/constants.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;
  final HabitStats? stats;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.isCompleted,
    this.stats,
    required this.onToggle,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final habitColor = habit.color;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Material(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        elevation: isCompleted ? 0 : 2,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isCompleted
                    ? habitColor.withValues(alpha: 0.35)
                    : (isDark ? AppColors.borderDark : AppColors.borderLight),
                width: isCompleted ? 1.5 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Icon with habit background color
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: habitColor.withValues(alpha: isCompleted ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    habit.icon,
                    color: habitColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),

                // Middle: Title, Description, and Badges
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Habit Title
                      Text(
                        habit.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: isCompleted
                              ? (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight)
                              : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),

                      // Habit Description (if any)
                      if (habit.description.isNotEmpty)
                        Text(
                          habit.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 6),

                      // Badges Row: Frequency, Reminder, Streak
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          // Category badge
                          _buildBadge(
                            context: context,
                            label: habit.category,
                            color: habitColor,
                            isOutlined: true,
                          ),

                          // Frequency badge
                          _buildBadge(
                            context: context,
                            label: habit.frequencyDescription,
                            icon: Icons.repeat_rounded,
                          ),

                          // Reminder time badge
                          if (habit.reminderTime != null &&
                              habit.isReminderEnabled)
                            _buildBadge(
                              context: context,
                              label: habit.reminderTime!,
                              icon: Icons.alarm_rounded,
                              color: AppColors.warning,
                            ),

                          // Streak badge
                          if (stats != null && stats!.currentStreak > 0)
                            _buildBadge(
                              context: context,
                              label: '${stats!.currentStreak} ngày',
                              icon: Icons.local_fire_department_rounded,
                              color: Colors.deepOrange,
                              isHighlight: true,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Right: Checkbox toggle button & Popup menu
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: onToggle,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isCompleted ? habitColor : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: habitColor,
                            width: 2.2,
                          ),
                          boxShadow: isCompleted
                              ? [
                                  BoxShadow(
                                    color: habitColor.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 22,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Popup menu for quick actions
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_horiz_rounded,
                        size: 20,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'detail':
                            onTap();
                            break;
                          case 'edit':
                            onEdit();
                            break;
                          case 'delete':
                            onDelete();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'detail',
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('Chi tiết'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Chỉnh sửa'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded,
                                  size: 18, color: AppColors.danger),
                              SizedBox(width: 8),
                              Text('Xóa thói quen',
                                  style: TextStyle(color: AppColors.danger)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({
    required BuildContext context,
    required String label,
    IconData? icon,
    Color? color,
    bool isOutlined = false,
    bool isHighlight = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final badgeColor = color ??
        (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: isHighlight
            ? badgeColor.withValues(alpha: 0.15)
            : isOutlined
                ? badgeColor.withValues(alpha: 0.08)
                : (isDark ? AppColors.surfaceLightDark : AppColors.bgLight),
        borderRadius: BorderRadius.circular(8),
        border: isOutlined
            ? Border.all(color: badgeColor.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: badgeColor,
            ),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
              color: isHighlight || isOutlined
                  ? badgeColor
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            ),
          ),
        ],
      ),
    );
  }
}

