import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../utils/constants.dart';
import '../widgets/calendar_strip.dart';
import '../widgets/completion_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/habit_card.dart';
import '../widgets/progress_card.dart';
import 'add_edit_habit_screen.dart';
import 'habit_detail_screen.dart';

class HabitListScreen extends StatefulWidget {
  const HabitListScreen({super.key});

  @override
  State<HabitListScreen> createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen> {
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToAddHabit() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditHabitScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final habitProvider = Provider.of<HabitProvider>(context);

    // Trigger celebration dialog if 100% just completed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (habitProvider.showCelebration && mounted) {
        CompletionDialog.show(
          context,
          onDismiss: () => habitProvider.dismissCelebration(),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: _isSearchOpen
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm thói quen...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
                onChanged: (val) => habitProvider.setSearchQuery(val),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      letterSpacing: 0.5,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    AppConstants.appSubtitle,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearchOpen ? Icons.close_rounded : Icons.search_rounded,
            ),
            tooltip: _isSearchOpen ? 'Đóng tìm kiếm' : 'Tìm kiếm',
            onPressed: () {
              setState(() {
                if (_isSearchOpen) {
                  _searchController.clear();
                  habitProvider.setSearchQuery('');
                  _isSearchOpen = false;
                } else {
                  _isSearchOpen = true;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Tải lại',
            onPressed: () => habitProvider.loadData(),
          ),
        ],
      ),
      body: habitProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => habitProvider.loadData(),
              child: CustomScrollView(
                slivers: [
                  // 1. Horizontal Calendar Strip
                  SliverToBoxAdapter(
                    child: CalendarStrip(
                      selectedDate: habitProvider.selectedDate,
                      onDateSelected: (date) {
                        habitProvider.setSelectedDate(date);
                      },
                    ),
                  ),

                  // 2. Daily Progress Summary Card
                  SliverToBoxAdapter(
                    child: ProgressCard(
                      completedCount: habitProvider.completedCount,
                      totalCount: habitProvider.totalScheduledCount,
                      completionRate: habitProvider.completionRate,
                    ),
                  ),

                  // 3. Status Filters (Tất cả, Cần làm, Đã xong)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 4.0),
                      child: Row(
                        children: [
                          _buildFilterTab(
                            context: context,
                            label: 'Tất cả (${habitProvider.scheduledHabits.length})',
                            isSelected: habitProvider.statusFilter == 'all',
                            onTap: () => habitProvider.setStatusFilter('all'),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterTab(
                            context: context,
                            label:
                                'Cần làm (${habitProvider.totalScheduledCount - habitProvider.completedCount})',
                            isSelected: habitProvider.statusFilter == 'pending',
                            onTap: () =>
                                habitProvider.setStatusFilter('pending'),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterTab(
                            context: context,
                            label:
                                'Đã xong (${habitProvider.completedCount})',
                            isSelected:
                                habitProvider.statusFilter == 'completed',
                            onTap: () =>
                                habitProvider.setStatusFilter('completed'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 4. Categories horizontal scroll
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 44,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: AppConstants.categories.length,
                        itemBuilder: (context, index) {
                          final cat = AppConstants.categories[index];
                          final isSelected =
                              habitProvider.selectedCategory == cat;

                          return Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: ChoiceChip(
                              label: Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected ? Colors.white : null,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: AppColors.primary,
                              onSelected: (selected) {
                                if (selected) {
                                  habitProvider.setSelectedCategory(cat);
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 8),
                  ),

                  // 5. Habits List or Empty State
                  if (habitProvider.filteredHabits.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyHabitsState(
                        title: habitProvider.allHabits.isEmpty
                            ? 'Chưa có thói quen nào'
                            : 'Không có thói quen phù hợp',
                        message: habitProvider.allHabits.isEmpty
                            ? 'Hãy thêm thói quen đầu tiên để bắt đầu hành trình rèn luyện kỷ luật!'
                            : 'Thử chọn ngày khác hoặc xóa bộ lọc để xem các thói quen.',
                        actionLabel: habitProvider.allHabits.isEmpty
                            ? 'Tạo thói quen ngay'
                            : 'Tạo thói quen mới',
                        onAction: _navigateToAddHabit,
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final habit = habitProvider.filteredHabits[index];
                          final isDone =
                              habitProvider.isHabitCompleted(habit.id!);
                          final stats =
                              habitProvider.getStatsForHabit(habit.id!);

                          return HabitCard(
                            key: ValueKey(habit.id),
                            habit: habit,
                            isCompleted: isDone,
                            stats: stats,
                            onToggle: () =>
                                habitProvider.toggleHabit(habit.id!),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HabitDetailScreen(habit: habit),
                                ),
                              );
                            },
                            onEdit: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddEditHabitScreen(habit: habit),
                                ),
                              );
                            },
                            onDelete: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Xóa thói quen?'),
                                  content: Text(
                                      'Bạn có muốn xóa thói quen "${habit.title}" không?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Hủy'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.danger,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Xóa'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await habitProvider.deleteHabit(habit.id!);
                              }
                            },
                          );
                        },
                        childCount: habitProvider.filteredHabits.length,
                      ),
                    ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 80), // spacing for bottom bar
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFilterTab({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? AppColors.primary
                : (isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight),
          ),
        ),
      ),
    );
  }
}
