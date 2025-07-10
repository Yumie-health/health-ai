import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

// Initialize FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// Preferences Provider
class PreferencesProvider extends ChangeNotifier {
  bool _darkMode = false;
  bool _useMetric = true;
  bool _mealLoggingPrompts = false;
  bool _waterIntakeReminders = false;
  bool _mindfulWalksReminders = false;
  bool _momentOfCalmReminders = false;
  String _language = 'en';

  bool get darkMode => _darkMode;
  bool get useMetric => _useMetric;
  bool get mealLoggingPrompts => _mealLoggingPrompts;
  bool get waterIntakeReminders => _waterIntakeReminders;
  bool get mindfulWalksReminders => _mindfulWalksReminders;
  bool get momentOfCalmReminders => _momentOfCalmReminders;
  String get language => _language;

  PreferencesProvider() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool('darkMode') ?? false;
    _useMetric = prefs.getBool('useMetric') ?? true;
    _mealLoggingPrompts = prefs.getBool('mealLoggingPrompts') ?? false;
    _waterIntakeReminders = prefs.getBool('waterIntakeReminders') ?? false;
    _mindfulWalksReminders = prefs.getBool('mindfulWalksReminders') ?? false;
    _momentOfCalmReminders = prefs.getBool('momentOfCalmReminders') ?? false;
    _language = prefs.getString('language') ?? 'en';
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = value;
    await prefs.setBool('darkMode', value);
    notifyListeners();
  }

  Future<void> setUnits(bool useMetric) async {
    final prefs = await SharedPreferences.getInstance();
    _useMetric = useMetric;
    await prefs.setBool('useMetric', useMetric);
    notifyListeners();
  }

  Future<void> setMealLoggingPrompts(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _mealLoggingPrompts = value;
    await prefs.setBool('mealLoggingPrompts', value);
    notifyListeners();
    if (value) {
      await _scheduleMealLoggingPrompts();
    } else {
      await _cancelMealLoggingPrompts();
    }
  }

  Future<void> setWaterIntakeReminders(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _waterIntakeReminders = value;
    await prefs.setBool('waterIntakeReminders', value);
    notifyListeners();
    if (value) {
      await _scheduleWaterIntakeReminders();
    } else {
      await _cancelWaterIntakeReminders();
    }
  }

  Future<void> setMindfulWalksReminders(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _mindfulWalksReminders = value;
    await prefs.setBool('mindfulWalksReminders', value);
    notifyListeners();
    if (value) {
      await _scheduleMindfulWalksReminders();
    } else {
      await _cancelMindfulWalksReminders();
    }
  }

  Future<void> setMomentOfCalmReminders(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _momentOfCalmReminders = value;
    await prefs.setBool('momentOfCalmReminders', value);
    notifyListeners();
    // Placeholder: actual popup logic should be triggered before meal logging
  }

  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    _language = language;
    await prefs.setString('language', language);
    notifyListeners();
  }

  // --- Notification scheduling helpers ---
  Future<void> _scheduleMealLoggingPrompts() async {
    final times = [
      [8, 0],   // Breakfast
      [13, 0],  // Lunch
      [19, 0],  // Dinner
      [22, 0],  // Night/Snack
    ];
    final mealLabels = [
      'Breakfast Time!',
      'Lunch Time!',
      'Dinner Time!',
      'Snack Time!',
    ];
    for (int i = 0; i < times.length; i++) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        2000 + i,
        mealLabels[i],
        'Remember to log your meal!',
        _nextInstanceOfTime(times[i][0], times[i][1]),
        const NotificationDetails(
          android: AndroidNotificationDetails('meal_channel', 'Meal Logging', importance: Importance.max, priority: Priority.high),
          iOS: DarwinNotificationDetails(),
        ),
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }
  Future<void> _cancelMealLoggingPrompts() async {
    for (int i = 0; i < 4; i++) {
      await flutterLocalNotificationsPlugin.cancel(2000 + i);
    }
  }

  Future<void> _scheduleWaterIntakeReminders() async {
    final times = [9, 12, 15, 18, 21];
    for (int i = 0; i < times.length; i++) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        3000 + i,
        'Hydration Reminder',
        'Drink some water! 💧',
        _nextInstanceOfTime(times[i], 0),
        const NotificationDetails(
          android: AndroidNotificationDetails('water_channel', 'Water Intake', importance: Importance.max, priority: Priority.high),
          iOS: DarwinNotificationDetails(),
        ),
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }
  Future<void> _cancelWaterIntakeReminders() async {
    for (int i = 0; i < 5; i++) {
      await flutterLocalNotificationsPlugin.cancel(3000 + i);
    }
  }

  Future<void> _scheduleMindfulWalksReminders() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      4001,
      'Mindful Walk',
      'Take a mindful walk today!',
      _nextInstanceOfTime(18, 0),
      const NotificationDetails(
        android: AndroidNotificationDetails('walk_channel', 'Mindful Walks', importance: Importance.max, priority: Priority.high),
        iOS: DarwinNotificationDetails(),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
  Future<void> _cancelMindfulWalksReminders() async {
    await flutterLocalNotificationsPlugin.cancel(4001);
  }

  // --- Helper functions for scheduling ---
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _nextInstanceOfWeekday(int hour, int minute, int weekday) {
    tz.TZDateTime scheduled = _nextInstanceOfTime(hour, minute);
    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(Duration(days: 1));
    }
    return scheduled;
  }

  // Water Intake Reminders: Call this after a meal is logged
  Future<void> scheduleWaterReminderAfterMeal({required DateTime mealTime, required bool waterGoalReached}) async {
    if (!_waterIntakeReminders || waterGoalReached) return;
    final scheduledTime = mealTime.add(Duration(minutes: 20));
    final id = scheduledTime.millisecondsSinceEpoch % 1000000 + 3000; // unique id
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Drink Water',
      'Don\'t forget to drink water and log your intake!',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails('water_channel', 'Water Intake', importance: Importance.max, priority: Priority.high),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Moment of Calm: Call this after a meal is logged if toggle is on
  bool get momentOfCalmEnabled => _momentOfCalmReminders;
} 