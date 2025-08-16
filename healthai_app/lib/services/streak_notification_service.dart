import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class StreakNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static int _todayBaseId() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final doy = now.difference(startOfYear).inDays + 1; // 1..366
    return doy * 10; // reserve 3 consecutive ids (x0,x1,x2)
  }

  static int get _nearEnd6hId => _todayBaseId() + 0; // 18:00 local
  static int get _nearEnd2hId => _todayBaseId() + 1; // 22:00 local
  static int get _streakEndedId => _todayBaseId() + 2; // 00:05 next day

  static tz.TZDateTime _todayAt(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    return tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  }

  static tz.TZDateTime _tomorrowAt(int hour, int minute) {
    final base = _todayAt(0, 0).add(const Duration(days: 1));
    return tz.TZDateTime(tz.local, base.year, base.month, base.day, hour, minute);
  }

  static Future<bool> _hasMealsToday() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final snap = await _firestore
        .collection('meals')
        .where('userId', isEqualTo: user.uid)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
        .limit(1)
        .get();
    final docs = snap.docs.where((d) => (d.data()['isDeleted'] ?? false) == false);
    return docs.isNotEmpty;
  }

  static Future<void> scheduleForTodayLocalized({
    required String near6hTitle,
    required String near6hBody,
    required String near2hTitle,
    required String near2hBody,
    required String endedTitle,
    required String endedBody,
  }) async {
    final hasMeals = await _hasMealsToday();
    if (hasMeals) {
      await cancelForToday();
      return;
    }

    final details = const NotificationDetails(
      android: AndroidNotificationDetails(
        'streak_channel',
        'Streak Alerts',
        channelDescription: 'Notifications to help you maintain your logging streak',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    // 6 hours before midnight → 18:00 local
    await _notifications.zonedSchedule(
      _nearEnd6hId,
      near6hTitle,
      near6hBody,
      _todayAt(18, 0),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    // 2 hours before midnight → 22:00 local
    await _notifications.zonedSchedule(
      _nearEnd2hId,
      near2hTitle,
      near2hBody,
      _todayAt(22, 0),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    // At start of next day (00:05)
    await _notifications.zonedSchedule(
      _streakEndedId,
      endedTitle,
      endedBody,
      _tomorrowAt(0, 5),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Backward-compatible wrapper using English defaults
  static Future<void> scheduleForToday() async {
    return scheduleForTodayLocalized(
      near6hTitle: 'Keep Your Streak 🔥',
      near6hBody: 'Your streak is about to end. Log a meal today to keep it alive!',
      near2hTitle: 'Almost There! 🔥',
      near2hBody: 'Only a couple hours left. Log a meal to save your streak!',
      endedTitle: 'Streak Ended',
      endedBody: 'Your streak ended. Log a meal to restart and build it back up!',
    );
  }

  static Future<void> cancelForToday() async {
    await _notifications.cancel(_nearEnd6hId);
    await _notifications.cancel(_nearEnd2hId);
    await _notifications.cancel(_streakEndedId);
  }

  static Future<void> onMealLoggedToday() async {
    await cancelForToday();
  }
}


