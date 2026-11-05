import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../utils/constants.dart';
import '../widgets/habit_card.dart';

class AddEditHabitScreen extends StatefulWidget {
  final Habit? habit;

  const AddEditHabitScreen({super.key, this.habit});

  @override
  State<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends State<AddEditHabitScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _targetCountController;
  late TextEditingController _unitController;

  late String _selectedCategory;
  late int _selectedColorValue;
  late String _selectedIconName;
  late String _frequencyType; // 'daily' or 'specific_days'
  late List<int> _selectedDays;
  TimeOfDay? _reminderTime;
  late bool _isReminderEnabled;

  bool get isEditing => widget.habit != null;

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    _titleController = TextEditingController(text: h?.title ?? '');
    _descriptionController = TextEditingController(text: h?.description ?? '');
    _targetCountController =
        TextEditingController(text: '${h?.targetCount ?? 1}');
    _unitController = TextEditingController(text: h?.unit ?? 'lần');

    _selectedCategory = h?.category ?? 'Kỷ luật';
    _selectedColorValue =
        h?.colorValue ?? AppColors.habitColors.first.toARGB32();
    _selectedIconName = h?.iconName ?? 'check_circle';
    _frequencyType = h?.frequencyType ?? 'daily';
    _selectedDays = List<int>.from(h?.frequencyDays ?? [1, 2, 3, 4, 5, 6, 7]);
    _isReminderEnabled = h?.isReminderEnabled ?? false;

    if (h?.reminderTime != null) {
      final parts = h!.reminderTime!.split(':');
      if (parts.length >= 2) {
        _reminderTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 8,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    } else {
      _reminderTime = const TimeOfDay(hour: 7, minute: 30);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetCountController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? const TimeOfDay(hour: 7, minute: 30),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _reminderTime = picked;
        _isReminderEnabled = true;
      });
    }
  }

  String? _formatReminderTime() {
    if (_reminderTime == null) return null;
    final h = _reminderTime!.hour.toString().padLeft(2, '0');
    final m = _reminderTime!.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Habit _buildHabitPreview() {
    return Habit(
      id: widget.habit?.id,
      title: _titleController.text.trim().isEmpty
          ? 'Tên thói quen của bạn'
          : _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      colorValue: _selectedColorValue,
      iconName: _selectedIconName,
      frequencyType: _frequencyType,
      frequencyDays: _frequencyType == 'daily' ? [1, 2, 3, 4, 5, 6, 7] : _selectedDays,
      reminderTime: _isReminderEnabled ? _formatReminderTime() : null,
      isReminderEnabled: _isReminderEnabled,
      targetCount: int.tryParse(_targetCountController.text) ?? 1,
      unit: _unitController.text.trim().isEmpty ? 'lần' : _unitController.text.trim(),
    );
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_frequencyType == 'specific_days' && _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất 1 ngày trong tuần!'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final habit = _buildHabitPreview();

    bool success;
    if (isEditing) {
      success = await habitProvider.updateHabit(habit);
    } else {
      success = await habitProvider.addHabit(habit);
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing
              ? 'Đã cập nhật thói quen "${habit.title}"'
              : 'Đã tạo thói quen mới "${habit.title}"!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Có lỗi xảy ra khi lưu thói quen!'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Xác nhận xóa'),
        content: Text(
            'Bạn có chắc chắn muốn xóa thói quen "${widget.habit!.title}"? Toàn bộ lịch sử rèn luyện sẽ bị xóa vĩnh viễn.'),
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
      await habitProvider.deleteHabit(widget.habit!.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa thói quen "${widget.habit!.title}"'),
          backgroundColor: AppColors.danger,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Chỉnh Sửa Thói Quen' : 'Thêm Thói Quen Mới',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.danger),
              tooltip: 'Xóa thói quen',
              onPressed: _confirmDelete,
            ),
          IconButton(
            icon: const Icon(Icons.check_rounded, color: AppColors.primary),
            tooltip: 'Lưu',
            onPressed: _saveHabit,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          children: [
            // Section: Live Preview
            _buildSectionHeader('Xem trước thẻ thói quen'),
            HabitCard(
              habit: _buildHabitPreview(),
              isCompleted: false,
              onToggle: () {},
              onTap: () {},
              onEdit: () {},
              onDelete: () {},
            ),
            const SizedBox(height: 16),

            // Section: Basic Info
            _buildSectionHeader('Thông tin cơ bản'),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Tên thói quen *',
                hintText: 'Ví dụ: Đọc sách 30 phút, Chạy bộ 2km...',
                prefixIcon: const Icon(Icons.edit_note_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onChanged: (_) => setState(() {}),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên thói quen';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Mô tả / Động lực duy trì (tùy chọn)',
                hintText: 'Lý do thói quen này quan trọng với bạn...',
                prefixIcon: const Icon(Icons.notes_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),

            // Section: Category
            _buildSectionHeader('Danh mục thói quen'),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: AppConstants.habitCategories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Section: Color Selector
            _buildSectionHeader('Màu sắc chủ đề'),
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: AppColors.habitColors.length,
                itemBuilder: (context, index) {
                  final color = AppColors.habitColors[index];
                  final isSelected = _selectedColorValue == color.toARGB32();

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColorValue = color.toARGB32();
                      });
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.6),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Section: Icon Selector
            _buildSectionHeader('Biểu tượng'),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: AppConstants.habitIcons.length,
              itemBuilder: (context, index) {
                final iconKey = AppConstants.habitIcons.keys.elementAt(index);
                final iconData = AppConstants.habitIcons[iconKey]!;
                final isSelected = _selectedIconName == iconKey;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIconName = iconKey;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(_selectedColorValue).withValues(alpha: 0.2)
                          : (isDark
                              ? AppColors.surfaceLightDark
                              : AppColors.bgLight),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Color(_selectedColorValue)
                            : (isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Icon(
                      iconData,
                      color: isSelected
                          ? Color(_selectedColorValue)
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                      size: 24,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Section: Frequency
            _buildSectionHeader('Tần suất lặp lại'),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _frequencyType = 'daily';
                      });
                    },
                    icon: Icon(
                      Icons.repeat_rounded,
                      color: _frequencyType == 'daily' ? Colors.white : AppColors.primary,
                    ),
                    label: Text(
                      'Hàng ngày',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _frequencyType == 'daily' ? Colors.white : null,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _frequencyType == 'daily'
                          ? AppColors.primary
                          : Colors.transparent,
                      side: BorderSide(
                        color: _frequencyType == 'daily'
                            ? AppColors.primary
                            : Theme.of(context).dividerColor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _frequencyType = 'specific_days';
                      });
                    },
                    icon: Icon(
                      Icons.calendar_today_rounded,
                      color: _frequencyType == 'specific_days'
                          ? Colors.white
                          : AppColors.primary,
                    ),
                    label: Text(
                      'Tùy chọn ngày',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _frequencyType == 'specific_days' ? Colors.white : null,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _frequencyType == 'specific_days'
                          ? AppColors.primary
                          : Colors.transparent,
                      side: BorderSide(
                        color: _frequencyType == 'specific_days'
                            ? AppColors.primary
                            : Theme.of(context).dividerColor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            if (_frequencyType == 'specific_days') ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (int day = 1; day <= 7; day++)
                    _buildDayToggleButton(
                      day: day,
                      label: day == 7 ? 'CN' : 'T${day + 1}',
                      isSelected: _selectedDays.contains(day),
                      onTap: () {
                        setState(() {
                          if (_selectedDays.contains(day)) {
                            _selectedDays.remove(day);
                          } else {
                            _selectedDays.add(day);
                          }
                        });
                      },
                    ),
                ],
              ),
            ],
            const SizedBox(height: 20),

            // Section: Reminder
            _buildSectionHeader('Nhắc nhở hàng ngày'),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: SwitchListTile(
                title: const Text('Bật thông báo nhắc nhở'),
                subtitle: Text(
                  _isReminderEnabled && _reminderTime != null
                      ? 'Nhắc nhở lúc ${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
                      : 'Không nhận nhắc nhở',
                  style: TextStyle(
                    color: _isReminderEnabled ? AppColors.primary : null,
                    fontWeight: _isReminderEnabled ? FontWeight.bold : null,
                  ),
                ),
                value: _isReminderEnabled,
                onChanged: (val) {
                  setState(() {
                    _isReminderEnabled = val;
                  });
                },
                secondary: const Icon(Icons.alarm_rounded),
              ),
            ),
            if (_isReminderEnabled) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pickReminderTime,
                icon: const Icon(Icons.schedule_rounded),
                label: Text(
                  'Chọn giờ nhắc nhở (${_reminderTime?.hour.toString().padLeft(2, '0')}:${_reminderTime?.minute.toString().padLeft(2, '0')})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Section: Target & Unit
            _buildSectionHeader('Mục tiêu mỗi lần'),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _targetCountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Số lượng mục tiêu',
                      prefixIcon: const Icon(Icons.flag_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _unitController,
                    decoration: InputDecoration(
                      labelText: 'Đơn vị',
                      hintText: 'lần, phút, trang, ly...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saveHabit,
                icon: const Icon(Icons.save_rounded),
                label: Text(
                  isEditing ? 'Lưu Thay Đổi' : 'Tạo Thói Quen',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color:
              isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
    );
  }

  Widget _buildDayToggleButton({
    required int day,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : null,
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
            ),
          ),
        ),
      ),
    );
  }
}
