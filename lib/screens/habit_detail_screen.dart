import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../models/habit_stats.dart';
import '../providers/habit_provider.dart';
import '../services/database_helper.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart';
import 'add_edit_habit_screen.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late Habit _habit;
  List<HabitLog> _logs = [];
  HabitStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _habit = widget.habit;
    _loadHabitData();
  }

  Future<void> _loadHabitData() async {
    setState(() => _isLoading = true);
    final db = DatabaseHelper.instance;

    // Reload habit in case updated
    final latestHabit = await db.getHabitById(_habit.id!);
    if (latestHabit != null) {
      _habit = latestHabit;
    }

    final logs = await db.getLogsForHabit(_habit.id!);
    final stats = await db.calculateHabitStats(_habit);

    if (mounted) {
      setState(() {
        _logs = logs;
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleToday() async {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    await habitProvider.toggleHabit(_habit.id!);
    await _loadHabitData();
  }

  void _navigateToEdit() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditHabitScreen(habit: _habit),
      ),
    );
    if (mounted) {
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);
      final exists = habitProvider.allHabits.any((h) => h.id == _habit.id);
      if (!exists) {
        Navigator.of(context).pop();
      } else {
        await _loadHabitData();
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
            'Bạn có chắc muốn xóa thói quen "${_habit.title}" cùng toàn bộ lịch sử?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);
      await habitProvider.deleteHabit(_habit.id!);
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final habitColor = _habit.color;

    final habitProvider = Provider.of<HabitProvider>(context);
    final isTodayCompleted = habitProvider.isHabitCompleted(_habit.id!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Thói Quen',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Chỉnh sửa',
            onPressed: _navigateToEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.danger),
            tooltip: 'Xóa',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              children: [
                // Top Header Card
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: habitColor.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: habitColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _habit.icon,
                          color: habitColor,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _habit.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_habit.description.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          _habit.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Quick Toggle Button for Today
                      OutlinedButton.icon(
                        onPressed: _toggleToday,
                        icon: Icon(
                          isTodayCompleted
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: isTodayCompleted
                              ? AppColors.success
                              : habitColor,
                        ),
                        label: Text(
                          isTodayCompleted
                              ? 'Đã hoàn thành hôm nay'
                              : 'Đánh dấu hoàn thành hôm nay',
                          style: TextStyle(
                            color: isTodayCompleted
                                ? AppColors.success
                                : habitColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isTodayCompleted
                                ? AppColors.success
                                : habitColor,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Metrics Grid (4 items)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _buildMetricItem(
                      title: 'Chuỗi hiện tại',
                      value: '${_stats?.currentStreak ?? 0} ngày',
                      icon: Icons.local_fire_department_rounded,
                      color: Colors.deepOrange,
                    ),
                    _buildMetricItem(
                      title: 'Chuỗi kỷ lục',
                      value: '${_stats?.bestStreak ?? 0} ngày',
                      icon: Icons.emoji_events_rounded,
                      color: Colors.amber,
                    ),
                    _buildMetricItem(
                      title: 'Tỷ lệ hoàn thành',
                      value: '${_stats?.completionRate.round() ?? 0}%',
                      icon: Icons.pie_chart_rounded,
                      color: AppColors.primary,
                    ),
                    _buildMetricItem(
                      title: 'Tổng lần hoàn thành',
                      value: '${_stats?.totalCompletions ?? 0} lần',
                      icon: Icons.done_all_rounded,
                      color: AppColors.success,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Details Specs Card
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông tin cấu hình',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSpecRow(
                        icon: Icons.category_rounded,
                        label: 'Danh mục',
                        value: _habit.category,
                      ),
                      const Divider(height: 18),
                      _buildSpecRow(
                        icon: Icons.repeat_rounded,
                        label: 'Tần suất',
                        value: _habit.frequencyDescription,
                      ),
                      const Divider(height: 18),
                      _buildSpecRow(
                        icon: Icons.alarm_rounded,
                        label: 'Nhắc nhở',
                        value: _habit.isReminderEnabled &&
                                _habit.reminderTime != null
                            ? 'Lúc ${_habit.reminderTime}'
                            : 'Không nhắc nhở',
                      ),
                      const Divider(height: 18),
                      _buildSpecRow(
                        icon: Icons.flag_rounded,
                        label: 'Mục tiêu',
                        value: '${_habit.targetCount} ${_habit.unit} / lần',
                      ),
                      const Divider(height: 18),
                      _buildSpecRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Ngày bắt đầu',
                        value: DateFormat('dd/MM/yyyy')
                            .format(_habit.createdAt),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // History Logs
                Text(
                  'Lịch sử rèn luyện (${_logs.length} bản ghi)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                if (_logs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Text(
                        'Chưa có lịch sử hoàn thành nào.',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  )
                else
                  ..._logs.map((log) {
                    final date = AppDateUtils.parseDateIso(log.date);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                log.isCompleted
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                                color: log.isCompleted
                                    ? AppColors.success
                                    : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                AppDateUtils.formatDisplayHeader(date),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: log.isCompleted
                                  ? AppColors.success.withValues(alpha: 0.12)
                                  : Colors.grey.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              log.isCompleted ? 'Hoàn thành' : 'Chưa xong',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: log.isCompleted
                                    ? AppColors.success
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 20),
              ],
            ),
    );
  }

  Widget _buildMetricItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

