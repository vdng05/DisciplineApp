# 🌟 Discipline App - Rèn Luyện Kỷ Luật Bản Thân

Ứng dụng di động theo dõi và quản lý thói quen hàng ngày nhằm rèn luyện kỷ luật cá nhân được xây dựng bằng **Flutter**, tuân thủ tiêu chuẩn Material 3, kiến trúc phân lớp sạch (Clean Architecture), quản lý trạng thái với **Provider** và lưu trữ dữ liệu cục bộ an toàn với **SQLite**.

---

## 🎯 Kiểm Tra Yêu Cầu Đề Bài (Checklist 5/5 Mục)

| STT | Mục Yêu Cầu | Trạng Thái | Mô Tả Chi Tiết Trong Ứng Dụng |
| :---: | :--- | :---: | :--- |
| **1** | **Thiết kế giao diện người dùng** | ✅ **Hoàn thành xuất sắc** | Giao diện Material 3 hiện đại gồm 3 màn hình chính: Danh sách thói quen với dải lịch ngày trực quan, Màn hình Thêm/Sửa thói quen có xem trước (live preview), và Màn hình Thống kê tiến độ trực quan. |
| **2** | **Tính năng Thêm, Xóa, Sửa thói quen** | ✅ **Hoàn thành xuất sắc** | Form nhập liệu đầy đủ với validation: Tên thói quen, Mô tả, Danh mục, Biểu tượng (18 icons), Màu sắc (10 màu), Tần suất (Hàng ngày / Tùy chọn ngày trong tuần), Giờ nhắc nhở (TimePicker) và Mục tiêu/Đơn vị. |
| **3** | **Đánh dấu hoàn thành thói quen hàng ngày** | ✅ **Hoàn thành xuất sắc** | Nút tick tròn với hoạt ảnh mượt mà, hỗ trợ đánh dấu cho ngày hiện tại hoặc xem/bổ sung ngày trước. Tự động đếm chuỗi kỷ luật (Streak 🔥) và hiển thị hộp thoại vinh danh khi hoàn thành 100% mục tiêu trong ngày. |
| **4** | **Lưu trữ dữ liệu cục bộ SQLite** | ✅ **Hoàn thành xuất sắc** | Sử dụng SQLite (`sqflite` + `sqflite_common_ffi`) với 2 bảng quan hệ: `habits` và `habit_logs`. Dữ liệu được bảo toàn vĩnh viễn khi tắt/mở lại app. Tự động nạp sẵn dữ liệu mẫu (seeder) chất lượng cao để trải nghiệm ngay. |
| **5** | **Thống kê tỷ lệ hoàn thành theo Ngày, Tuần, Tháng** | ✅ **Hoàn thành xuất sắc** | Màn hình thống kê đa năng với 4 tab: **Theo Ngày** (vòng đo gauge % và danh sách chi tiết), **Theo Tuần** (biểu đồ cột 7 ngày `fl_chart`), **Theo Tháng** (lưới bản đồ nhiệt Heatmap đa sắc độ) và **Tổng quan** (Điểm kỷ luật, Cấp bậc và Bảng xếp hạng). |

---

## ✨ Các Tính Năng Nâng Cao Mở Rộng Thêm

1. **Chế độ Sáng / Tối (Dark Mode & Light Mode)**: Tùy chỉnh giao diện theo sở thích, tự động lưu với `shared_preferences`.
2. **Câu trích dẫn truyền cảm hứng kỷ luật mỗi ngày**: Tự động thay đổi để tiếp thêm động lực cho người học.
3. **Bộ lọc & Tìm kiếm thông minh**: Lọc thói quen theo trạng thái (*Tất cả*, *Cần làm*, *Đã hoàn thành*) hoặc theo danh mục (*Sức khỏe*, *Học tập*, *Kỷ luật*, *Thể thao*,...).
4. **Hệ thống Cấp Bậc Kỷ Luật (Discipline Rank)**: Tính điểm kỷ luật (0 - 100) và thăng hạng: *Tân Binh* 🌱 -> *Chiến Binh* ⚡ -> *Hiệp Sĩ* 🛡️ -> *Bậc Thầy* 👑.
5. **Cẩm nang kỷ luật & Bí quyết Atomic Habits**: Tích hợp quy tắc 2 phút, quy tắc 21 ngày và nguyên lý hình thành thói quen.
6. **Khôi phục / Reset dữ liệu**: Cho phép người chấm bài kiểm tra dữ liệu mẫu hoặc bắt đầu lại từ đầu một cách dễ dàng trong phần Cài đặt.

---

## 🏗️ Cấu Trúc Dự Án (Clean Architecture)

```
lib/
├── main.dart                      # Điểm khởi chạy ứng dụng & Thiết lập MultiProvider, Theme
├── models/
│   ├── habit.dart                 # Entity Thói quen (tên, tần suất, nhắc nhở, màu, icon)
│   ├── habit_log.dart             # Entity Lịch sử hoàn thành thói quen theo ngày
│   └── habit_stats.dart           # Model tính toán chuỗi streak, tỷ lệ %, cấp độ kỷ luật
├── services/
│   ├── database_helper.dart       # Quản lý SQLite CRUD, truy vấn ngày/tuần/tháng, seeder
│   ├── notification_service.dart  # Quản lý thông báo nhắc nhở cục bộ
│   └── preference_service.dart    # Quản lý cấu hình SharedPreferences (Theme, User)
├── providers/
│   ├── habit_provider.dart        # State thói quen, lọc, tìm kiếm, đánh dấu hoàn thành
│   ├── stats_provider.dart        # State phân tích tiến độ Ngày / Tuần / Tháng / Tổng quan
│   └── theme_provider.dart        # State chuyển đổi Dark / Light mode
├── screens/
│   ├── home_screen.dart           # Giao diện chính điều hướng NavigationBar
│   ├── habit_list_screen.dart     # Màn hình danh sách thói quen & dải lịch ngày
│   ├── add_edit_habit_screen.dart # Màn hình Thêm / Sửa thói quen có xem trước
│   ├── habit_detail_screen.dart   # Màn hình Chi tiết thói quen & lịch sử từng ngày
│   ├── statistics_screen.dart     # Màn hình Thống kê Ngày, Tuần, Tháng (FL Chart & Heatmap)
│   └── settings_screen.dart       # Cài đặt Theme, quản lý dữ liệu, thông tin đồ án
├── widgets/
│   ├── calendar_strip.dart        # Dải chọn ngày ngang cuộn mượt mà
│   ├── habit_card.dart            # Thẻ thói quen với nút tick hoạt ảnh & menu thao tác
│   ├── progress_card.dart         # Thẻ tiến độ % trong ngày kèm danh ngôn truyền cảm hứng
│   ├── stat_metric_card.dart      # Thẻ hiển thị chỉ số thống kê trực quan
│   ├── completion_dialog.dart     # Hộp thoại chúc mừng khi hoàn thành 100% mục tiêu ngày
│   └── empty_state.dart           # Giao diện thân thiện khi danh sách trống
└── utils/
    ├── constants.dart             # Bảng màu, biểu tượng, danh mục, danh ngôn
    └── date_utils.dart            # Tiện ích định dạng ngày tháng tiếng Việt
```

---

## 🚀 Hướng Dẫn Cài Đặt & Chạy Ứng Dụng

### Yêu cầu môi trường:
- Flutter SDK: `^3.13.0` trở lên
- Dart SDK: `^3.13.0` trở lên

### Các bước chạy:
```bash
# 1. Tải các gói phụ thuộc
flutter pub get

# 2. Kiểm tra chất lượng mã nguồn
flutter analyze

# 3. Chạy toàn bộ các bài kiểm thử tự động
flutter test

# 4. Chạy ứng dụng trên thiết bị (Android Emulator, Windows hoặc Chrome)
flutter run
```
