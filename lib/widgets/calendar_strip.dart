import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart';

class CalendarStrip extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const CalendarStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<CalendarStrip> createState() => _CalendarStripState();
}

class _CalendarStripState extends State<CalendarStrip> {
  late final ScrollController _scrollController;
  final int _pastDays = 30;
  final int _futureDays = 14;
  final double _itemWidth = 58.0;

  @override
  void initState() {
    super.initState();
    // Start scrolled near today
    final initialOffset = (_pastDays - 2) * _itemWidth;
    _scrollController =
        ScrollController(initialScrollOffset: initialOffset > 0 ? initialOffset : 0);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToToday() {
    final todayOffset = (_pastDays - 2) * _itemWidth;
    _scrollController.animateTo(
      todayOffset > 0 ? todayOffset : 0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    widget.onDateSelected(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final today = DateTime.now();

    final totalDays = _pastDays + _futureDays + 1;
    final startDate = today.subtract(Duration(days: _pastDays));

    return Column(
      children: [
        // Top header showing current selected date and "Hôm nay" quick button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppDateUtils.formatDisplayHeader(widget.selectedDate),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              if (!AppDateUtils.isToday(widget.selectedDate))
                InkWell(
                  onTap: _scrollToToday,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.today_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Hôm nay',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Horizontal strip of date buttons
        SizedBox(
          height: 74,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: totalDays,
            itemBuilder: (context, index) {
              final date = startDate.add(Duration(days: index));
              final isSelected =
                  AppDateUtils.isSameDay(date, widget.selectedDate);
              final isCurrentDay = AppDateUtils.isToday(date);

              return GestureDetector(
                onTap: () => widget.onDateSelected(date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _itemWidth - 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : isCurrentDay
                            ? (isDark
                                ? AppColors.surfaceLightDark
                                : AppColors.primaryLight)
                            : (isDark
                                ? AppColors.surfaceDark
                                : AppColors.surfaceLight),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : isCurrentDay
                              ? AppColors.primary.withValues(alpha: 0.5)
                              : (isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight),
                      width: isCurrentDay && !isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppDateUtils.getWeekdayShort(date.weekday),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.85)
                              : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? Colors.white
                              : isCurrentDay
                                  ? AppColors.primary
                                  : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

