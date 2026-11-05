import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:discipline_app/models/habit.dart';
import 'package:discipline_app/models/habit_log.dart';
import 'package:discipline_app/models/habit_stats.dart';
import 'package:discipline_app/utils/date_utils.dart';
import 'package:discipline_app/widgets/progress_card.dart';
import 'package:discipline_app/widgets/stat_metric_card.dart';
import 'package:discipline_app/widgets/empty_state.dart';

void main() {
  group('Habit Model Tests', () {
    test('Habit isScheduledFor correctly checks daily and specific days', () {
      final dailyHabit = Habit(
        title: 'Chạy bộ',
        frequencyType: 'daily',
      );
      expect(dailyHabit.isScheduledFor(DateTime(2026, 11, 5)), isTrue);

      final weekdayHabit = Habit(
        title: 'Làm việc',
        frequencyType: 'specific_days',
        frequencyDays: [1, 2, 3, 4, 5], // Mon to Fri
      );
      // 2026-11-05 is a Thursday (weekday 4)
      expect(weekdayHabit.isScheduledFor(DateTime(2026, 11, 5)), isTrue);
      // 2026-11-08 is a Sunday (weekday 7)
      expect(weekdayHabit.isScheduledFor(DateTime(2026, 11, 8)), isFalse);
    });

    test('Habit serialization to and from Map works', () {
      final habit = Habit(
        id: 1,
        title: 'Đọc sách',
        description: '30 trang',
        category: 'Học tập',
        frequencyType: 'daily',
        reminderTime: '21:00',
        isReminderEnabled: true,
      );

      final map = habit.toMap();
      final fromMap = Habit.fromMap(map);

      expect(fromMap.id, 1);
      expect(fromMap.title, 'Đọc sách');
      expect(fromMap.category, 'Học tập');
      expect(fromMap.reminderTime, '21:00');
      expect(fromMap.isReminderEnabled, isTrue);
    });
  });

  group('HabitLog Model Tests', () {
    test('HabitLog serialization works', () {
      final log = HabitLog(
        id: 1,
        habitId: 2,
        date: '2026-11-05',
        isCompleted: true,
      );

      final map = log.toMap();
      final fromMap = HabitLog.fromMap(map);

      expect(fromMap.habitId, 2);
      expect(fromMap.date, '2026-11-05');
      expect(fromMap.isCompleted, isTrue);
    });
  });

  group('AppDateUtils Tests', () {
    test('Date formatting and parsing roundtrips', () {
      final date = DateTime(2026, 11, 5);
      final iso = AppDateUtils.formatDateIso(date);
      expect(iso, '2026-11-05');
      final parsed = AppDateUtils.parseDateIso(iso);
      expect(AppDateUtils.isSameDay(date, parsed), isTrue);
    });

    test('Weekday short label returns correct Vietnamese names', () {
      expect(AppDateUtils.getWeekdayShort(DateTime.monday), 'T2');
      expect(AppDateUtils.getWeekdayShort(DateTime.friday), 'T6');
      expect(AppDateUtils.getWeekdayShort(DateTime.sunday), 'CN');
    });

    test('Days of week returns 7 consecutive days starting from Monday', () {
      final now = DateTime(2026, 11, 5);
      final days = AppDateUtils.getDaysOfWeek(now);
      expect(days.length, 7);
      expect(days.first.weekday, DateTime.monday);
      expect(days.last.weekday, DateTime.sunday);
    });
  });

  group('DisciplineLevel Tests', () {
    test('Level progression based on score', () {
      expect(DisciplineLevel.getLevelForScore(10).title, 'Tân Binh Khởi Đầu');
      expect(DisciplineLevel.getLevelForScore(50).title, 'Chiến Binh Kiên Trì');
      expect(DisciplineLevel.getLevelForScore(80).title, 'Hiệp Sĩ Kỷ Luật');
      expect(DisciplineLevel.getLevelForScore(95).title, 'Bậc Thầy Tự Chủ');
    });
  });

  group('Widget Rendering Tests', () {
    testWidgets('ProgressCard renders with counts and percent',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressCard(
              completedCount: 3,
              totalCount: 4,
              completionRate: 75.0,
            ),
          ),
        ),
      );

      expect(find.text('75%'), findsOneWidget);
      expect(find.text('Đã hoàn thành 3 / 4 thói quen'), findsOneWidget);
    });

    testWidgets('StatMetricCard displays title, value, subtitle',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatMetricCard(
              title: 'Chuỗi hiện tại',
              value: '7 ngày',
              subtitle: 'đang tiếp diễn',
              icon: Icons.local_fire_department,
              color: Colors.orange,
            ),
          ),
        ),
      );

      expect(find.text('Chuỗi hiện tại'), findsOneWidget);
      expect(find.text('7 ngày'), findsOneWidget);
      expect(find.text('đang tiếp diễn'), findsOneWidget);
    });

    testWidgets('EmptyHabitsState renders action button and invokes callback',
        (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyHabitsState(
              title: 'Chưa có thói quen nào',
              actionLabel: 'Tạo thói quen ngay',
              onAction: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Chưa có thói quen nào'), findsOneWidget);
      expect(find.text('Tạo thói quen ngay'), findsOneWidget);

      await tester.tap(find.text('Tạo thói quen ngay'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
