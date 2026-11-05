import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/habit_stats.dart';
import '../providers/habit_provider.dart';
import '../providers/stats_provider.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart';
import '../widgets/stat_metric_card.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Refresh stats upon entering screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StatsProvider>(context, listen: false).refreshStats();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statsProvider = Provider.of<StatsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thống Kê Tiến Độ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm mới thống kê',
            onPressed: () => statsProvider.refreshStats(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Theo Ngày'),
            Tab(text: 'Theo Tuần'),
            Tab(text: 'Theo Tháng'),
            Tab(text: 'Tổng Quan'),
          ],
        ),
      ),
      body: statsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDayTab(context, statsProvider),
                _buildWeekTab(context, statsProvider),
                _buildMonthTab(context, statsProvider),
                _buildOverviewTab(context, statsProvider),
              ],
            ),
    );
  }

  // ================= 1. TAB THEO NGÀY =================
  Widget _buildDayTab(BuildContext context, StatsProvider statsProvider) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final selectedDate = habitProvider.selectedDate;
    final scheduled = habitProvider.scheduledHabits;
    final completed = habitProvider.completedCount;
    final total = habitProvider.totalScheduledCount;
    final rate = habitProvider.completionRate;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Date navigator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: () {
                habitProvider.setSelectedDate(
                    selectedDate.subtract(const Duration(days: 1)));
              },
            ),
            Text(
              AppDateUtils.formatDisplayHeader(selectedDate),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: () {
                habitProvider.setSelectedDate(
                    selectedDate.add(const Duration(days: 1)));
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Big Circular Gauge Card
        Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: total == 0 ? 0 : rate / 100.0,
                      strokeWidth: 12,
                      backgroundColor: isDark
                          ? AppColors.surfaceLightDark
                          : AppColors.primaryLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        rate >= 100
                            ? AppColors.success
                            : rate >= 50
                                ? AppColors.primary
                                : AppColors.warning,
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${rate.round()}%',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Tỷ lệ hoàn thành',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                rate >= 100
                    ? '🌟 Xuất sắc! Toàn bộ thói quen đã hoàn thành!'
                    : rate >= 50
                        ? '💪 Rất tốt! Bạn đã hoàn thành hơn một nửa mục tiêu.'
                        : '🎯 Hãy tiếp tục cố gắng hoàn thành các mục tiêu còn lại!',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3 mini metric cards
        Row(
          children: [
            Expanded(
              child: StatMetricCard(
                title: 'Hoàn thành',
                value: '$completed',
                subtitle: 'thói quen',
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatMetricCard(
                title: 'Còn lại',
                value: '${total - completed}',
                subtitle: 'cần làm',
                icon: Icons.pending_actions_rounded,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatMetricCard(
                title: 'Tổng mục tiêu',
                value: '$total',
                subtitle: 'kế hoạch',
                icon: Icons.flag_rounded,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Breakdown list for this day
        Text(
          'Chi tiết thói quen trong ngày (${scheduled.length})',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        if (scheduled.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(
              child: Text('Không có thói quen nào được lên lịch cho ngày này.'),
            ),
          )
        else
          ...scheduled.map((habit) {
            final isDone = habitProvider.isHabitCompleted(habit.id!);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: habit.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(habit.icon, color: habit.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            decoration: isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        Text(
                          habit.category,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppColors.success.withValues(alpha: 0.14)
                          : Colors.orange.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isDone ? 'Đạt' : 'Chưa',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: isDone ? AppColors.success : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        const SizedBox(height: 20),
      ],
    );
  }

  // ================= 2. TAB THEO TUẦN =================
  Widget _buildWeekTab(BuildContext context, StatsProvider statsProvider) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final weekProgress = statsProvider.weekDayProgressList;

    final startOfWeek = AppDateUtils.getStartOfWeek(statsProvider.selectedDate);
    final endOfWeek = AppDateUtils.getEndOfWeek(statsProvider.selectedDate);
    final weekRangeStr =
        '${DateFormat('dd/MM').format(startOfWeek)} - ${DateFormat('dd/MM/yyyy').format(endOfWeek)}';

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Week Navigator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              tooltip: 'Tuần trước',
              onPressed: () => statsProvider.previousWeek(),
            ),
            Column(
              children: [
                const Text(
                  'Báo Cáo Tiến Độ Tuần',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                Text(
                  weekRangeStr,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              tooltip: 'Tuần sau',
              onPressed: () => statsProvider.nextWeek(),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Summary Metric Cards
        Row(
          children: [
            Expanded(
              child: StatMetricCard(
                title: 'Tỷ lệ trung bình',
                value: '${statsProvider.weeklyAverageRate.round()}%',
                subtitle: 'trong tuần này',
                icon: Icons.trending_up_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatMetricCard(
                title: 'Tổng hoàn thành',
                value: '${statsProvider.weeklyTotalCompletions}',
                subtitle: 'lượt thói quen',
                icon: Icons.task_alt_rounded,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Weekly Bar Chart Container
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Biểu đồ hoàn thành 7 ngày (%)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Mục tiêu: 100%',
                    style: TextStyle(fontSize: 11, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // FL Chart Bar Chart
              SizedBox(
                height: 190,
                child: BarChart(
                  BarChartData(
                    maxY: 100,
                    minY: 0,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => AppColors.primaryDark,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final day = weekProgress[group.x.toInt()];
                          return BarTooltipItem(
                            '${AppDateUtils.getWeekdayShort(day.date.weekday)}: ${rod.toY.round()}%\n(${day.completed}/${day.totalScheduled})',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          interval: 25,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}%',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx >= 0 && idx < weekProgress.length) {
                              final weekday = weekProgress[idx].date.weekday;
                              return Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  AppDateUtils.getWeekdayShort(weekday),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      horizontalInterval: 25,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(weekProgress.length, (index) {
                      final day = weekProgress[index];
                      final isToday = AppDateUtils.isToday(day.date);

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: day.rate,
                            color: isToday
                                ? AppColors.accent
                                : day.rate >= 80
                                    ? AppColors.success
                                    : AppColors.primary,
                            width: 18,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(6),
                              topRight: Radius.circular(6),
                            ),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: 100,
                              color: isDark
                                  ? AppColors.surfaceLightDark
                                  : AppColors.bgLight,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Day by day details list
        Text(
          'Chi tiết từng ngày trong tuần',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        ...weekProgress.map((day) {
          final isToday = AppDateUtils.isToday(day.date);
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isToday
                    ? AppColors.primary
                    : (isDark ? AppColors.borderDark : AppColors.borderLight),
                width: isToday ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppDateUtils.getWeekdayFull(day.date.weekday),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                          color: isToday ? AppColors.primary : null,
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM').format(day.date),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: day.totalScheduled == 0
                          ? 0.0
                          : (day.rate / 100).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: isDark
                          ? AppColors.surfaceLightDark
                          : AppColors.borderLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        day.rate >= 80 ? AppColors.success : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                SizedBox(
                  width: 60,
                  child: Text(
                    '${day.completed}/${day.totalScheduled} (${day.rate.round()}%)',
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 20),
      ],
    );
  }

  // ================= 3. TAB THEO THÁNG =================
  Widget _buildMonthTab(BuildContext context, StatsProvider statsProvider) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final monthProgress = statsProvider.monthDayProgressList;

    final monthStr =
        'Tháng ${statsProvider.selectedDate.month} / ${statsProvider.selectedDate.year}';

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Month navigator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              tooltip: 'Tháng trước',
              onPressed: () => statsProvider.previousMonth(),
            ),
            Column(
              children: [
                const Text(
                  'Báo Cáo Tiến Độ Tháng',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                Text(
                  monthStr,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              tooltip: 'Tháng sau',
              onPressed: () => statsProvider.nextMonth(),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Month metric cards
        Row(
          children: [
            Expanded(
              child: StatMetricCard(
                title: 'Tỷ lệ trung bình',
                value: '${statsProvider.monthlyAverageRate.round()}%',
                subtitle: 'trong tháng',
                icon: Icons.calendar_month_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatMetricCard(
                title: 'Tổng tích lũy',
                value: '${statsProvider.monthlyTotalCompletions}',
                subtitle: 'lượt hoàn thành',
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Monthly Heatmap / Calendar Grid
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lưới nhiệt độ hoàn thành thói quen (Heatmap)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Màu càng đậm thể hiện tỷ lệ hoàn thành thói quen càng cao trong ngày.',
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 16),

              // Weekday labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('T2', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  Text('T3', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  Text('T4', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  Text('T5', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  Text('T6', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  Text('T7', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  Text('CN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                ],
              ),
              const SizedBox(height: 8),

              // Calendar Grid with offset for first day of month
              _buildMonthHeatmapGrid(monthProgress, isDark),
              const SizedBox(height: 16),

              // Heatmap legend
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('Ít ', style: TextStyle(fontSize: 10)),
                  _buildLegendBlock(AppColors.primary.withValues(alpha: 0.1)),
                  const SizedBox(width: 4),
                  _buildLegendBlock(AppColors.primary.withValues(alpha: 0.35)),
                  const SizedBox(width: 4),
                  _buildLegendBlock(AppColors.primary.withValues(alpha: 0.65)),
                  const SizedBox(width: 4),
                  _buildLegendBlock(AppColors.primary),
                  const SizedBox(width: 4),
                  _buildLegendBlock(AppColors.success),
                  const Text(' Nhiều (100%)', style: TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMonthHeatmapGrid(List<DayProgress> days, bool isDark) {
    if (days.isEmpty) return const SizedBox();

    final firstDayWeekday = days.first.date.weekday; // 1 = Mon
    final leadingEmptyCount = firstDayWeekday - 1;

    final totalCells = leadingEmptyCount + days.length;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        if (index < leadingEmptyCount) {
          return const SizedBox();
        }

        final dayIndex = index - leadingEmptyCount;
        final dayProgress = days[dayIndex];
        final rate = dayProgress.rate;
        final isToday = AppDateUtils.isToday(dayProgress.date);

        Color cellColor;
        Color textColor = isDark ? Colors.white : Colors.black87;

        if (dayProgress.totalScheduled == 0) {
          cellColor = isDark ? AppColors.surfaceLightDark : AppColors.bgLight;
        } else if (rate == 0) {
          cellColor = isDark
              ? Colors.red.withValues(alpha: 0.15)
              : Colors.red.withValues(alpha: 0.1);
        } else if (rate < 40) {
          cellColor = AppColors.primary.withValues(alpha: 0.3);
        } else if (rate < 80) {
          cellColor = AppColors.primary.withValues(alpha: 0.65);
          textColor = Colors.white;
        } else {
          cellColor = AppColors.success;
          textColor = Colors.white;
        }

        return Container(
          decoration: BoxDecoration(
            color: cellColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isToday
                  ? AppColors.accent
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
              width: isToday ? 2 : 0.8,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${dayProgress.date.day}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isToday ? FontWeight.w900 : FontWeight.bold,
                    color: textColor,
                  ),
                ),
                if (dayProgress.totalScheduled > 0)
                  Text(
                    '${rate.round()}%',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: textColor.withValues(alpha: 0.85),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendBlock(Color color) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  // ================= 4. TAB TỔNG QUAN =================
  Widget _buildOverviewTab(BuildContext context, StatsProvider statsProvider) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final level = statsProvider.disciplineLevel;
    final habits = statsProvider.habits;
    final statsMap = statsProvider.habitStats;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Discipline Level Card
        Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
                  : [const Color(0xFF4F46E5), const Color(0xFF6366F1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    level.badge,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cấp độ kỷ luật hiện tại',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          level.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          level.description,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Discipline Score Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Điểm kỷ luật',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '${statsProvider.disciplineScore.round()} / 100',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (statsProvider.disciplineScore / 100.0).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.amberAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Key Lifetime Metrics Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            StatMetricCard(
              title: 'Chuỗi hiện tại',
              value: '${statsProvider.currentOverallStreak} ngày',
              subtitle: 'đang tiếp diễn',
              icon: Icons.local_fire_department_rounded,
              color: Colors.deepOrange,
            ),
            StatMetricCard(
              title: 'Chuỗi kỷ lục',
              value: '${statsProvider.bestOverallStreak} ngày',
              subtitle: 'thành tích cao nhất',
              icon: Icons.emoji_events_rounded,
              color: Colors.amber,
            ),
            StatMetricCard(
              title: 'Tổng tích lũy',
              value: '${statsProvider.allTimeCompletions}',
              subtitle: 'lượt hoàn thành',
              icon: Icons.done_all_rounded,
              color: AppColors.success,
            ),
            StatMetricCard(
              title: 'Tổng thói quen',
              value: '${habits.length}',
              subtitle: 'đang duy trì',
              icon: Icons.checklist_rounded,
              color: AppColors.primary,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Leaderboard / Per-habit breakdown
        Text(
          'Bảng xếp hạng hiệu suất thói quen',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        if (habits.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(child: Text('Chưa có thói quen nào.')),
          )
        else
          ...habits.map((h) {
            final stat = statsMap[h.id];
            final rate = stat?.completionRate ?? 0.0;
            final currentStreak = stat?.currentStreak ?? 0;
            final totalCompletions = stat?.totalCompletions ?? 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: h.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(h.icon, color: h.color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              h.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                            ),
                            Text(
                              'Đã làm $totalCompletions lần • Chuỗi: $currentStreak ngày',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${rate.round()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: h.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (rate / 100.0).clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: isDark
                          ? AppColors.surfaceLightDark
                          : AppColors.bgLight,
                      valueColor: AlwaysStoppedAnimation<Color>(h.color),
                    ),
                  ),
                ],
              ),
            );
          }),
        const SizedBox(height: 20),
      ],
    );
  }
}

