import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../providers/stats_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final statsProvider = Provider.of<StatsProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cài Đặt & Kỷ Luật',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          // Section: Giao diện
          _buildSectionTitle(context, 'Giao diện & Trải nghiệm'),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: AppColors.primary,
                  ),
                  title: const Text('Chế độ tối (Dark Mode)'),
                  subtitle: Text(isDark ? 'Đang bật' : 'Đang tắt'),
                  value: isDark,
                  onChanged: (val) {
                    themeProvider.toggleTheme();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Section: Quản lý dữ liệu
          _buildSectionTitle(context, 'Quản lý dữ liệu'),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.restore_rounded,
                      color: AppColors.primary),
                  title: const Text('Khôi phục dữ liệu mẫu'),
                  subtitle: const Text(
                      'Tải lại 5 thói quen tiêu chuẩn & lịch sử tuần qua'),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Khôi phục dữ liệu mẫu?'),
                        content: const Text(
                            'Hành động này sẽ thiết lập lại cơ sở dữ liệu với 5 thói quen mẫu và lịch sử hoàn thành để trải nghiệm.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Hủy'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Khôi phục'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await habitProvider.resetToDefaults();
                      await statsProvider.refreshStats();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã khôi phục dữ liệu mẫu thành công!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_sweep_rounded,
                      color: AppColors.danger),
                  title: const Text('Xóa tất cả dữ liệu'),
                  subtitle: const Text('Xóa toàn bộ thói quen và lịch sử rèn luyện'),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Xác nhận xóa trắng dữ liệu'),
                        content: const Text(
                            'Bạn có chắc chắn muốn xóa toàn bộ thói quen không? Thao tác này không thể hoàn tác.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Hủy'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.danger,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Xóa hết'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await habitProvider.clearAllData();
                      await statsProvider.refreshStats();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã xóa toàn bộ dữ liệu ứng dụng!'),
                            backgroundColor: AppColors.danger,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Section: Cẩm nang rèn luyện kỷ luật
          _buildSectionTitle(context, 'Bí quyết rèn luyện kỷ luật'),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTipItem(
                    icon: Icons.timer_outlined,
                    title: 'Quy tắc 2 phút',
                    description:
                        'Khi bắt đầu thói quen mới, hãy bắt đầu bằng việc chỉ mất chưa đầy 2 phút để thực hiện.',
                  ),
                  const Divider(height: 20),
                  _buildTipItem(
                    icon: Icons.track_changes_rounded,
                    title: 'Quy tắc không bỏ cuộc 2 ngày liên tiếp',
                    description:
                        'Nếu bạn lỡ quên hoặc bận 1 ngày, hãy làm lại ngay vào ngày tiếp theo để chuỗi kỷ luật không bị gián đoạn.',
                  ),
                  const Divider(height: 20),
                  _buildTipItem(
                    icon: Icons.calendar_month_rounded,
                    title: 'Nguyên lý 21 ngày',
                    description:
                        'Bộ não con người cần trung bình 21 đến 66 ngày lặp lại đều đặn để biến một hành vi thành phản xạ tự nhiên.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildTipItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: AppColors.accent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(fontSize: 12, height: 1.35),
              ),
            ],
          ),
        ),
      ],
    );
  }

}

