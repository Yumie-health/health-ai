import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io' show Platform;
import '../services/native_notification_service.dart';

// Initialize FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// Preferences Provider
class PreferencesProvider extends ChangeNotifier {
  bool _useMetric = true;
  bool _mealLoggingPrompts = false;
  bool _waterIntakeReminders = false;
  bool _mindfulWalksReminders = false;
  bool _momentOfCalmReminders = false;
  String _language = 'en';

  // Getters
  bool get useMetric => _useMetric;
  bool get mealLoggingPrompts => _mealLoggingPrompts;
  bool get waterIntakeReminders => _waterIntakeReminders;
  bool get mindfulWalksReminders => _mindfulWalksReminders;
  bool get momentOfCalmReminders => _momentOfCalmReminders;
  String get language => _language;

  // Load preferences from SharedPreferences and sync with Firestore
  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load basic preferences from SharedPreferences
    _useMetric = prefs.getBool('useMetric') ?? true;
    _language = prefs.getString('language') ?? 'en';
    
    // Load notification preferences from SharedPreferences first (as fallback)
    _mealLoggingPrompts = prefs.getBool('mealLoggingPrompts') ?? false;
    _waterIntakeReminders = prefs.getBool('waterIntakeReminders') ?? false;
    _mindfulWalksReminders = prefs.getBool('mindfulWalksReminders') ?? false;
    _momentOfCalmReminders = prefs.getBool('momentOfCalmReminders') ?? false;
    
    // Try to sync with Firestore (onboarding may have saved there)
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final data = doc.data();
        if (data != null) {
          // Sync unit preference from Firestore if available
          if (data.containsKey('useMetric')) {
            _useMetric = data['useMetric'] ?? _useMetric;
            await prefs.setBool('useMetric', _useMetric);
          }
          
          // Sync reminders if available
          if (data['reminders'] != null) {
            final reminders = data['reminders'] as Map<String, dynamic>;
            
            // Update values from Firestore and save to SharedPreferences
            _mealLoggingPrompts = reminders['mealLoggingPrompts'] ?? _mealLoggingPrompts;
            _waterIntakeReminders = reminders['waterIntakeReminders'] ?? _waterIntakeReminders;
            _mindfulWalksReminders = reminders['mindfulWalksReminders'] ?? _mindfulWalksReminders;
            _momentOfCalmReminders = reminders['momentOfCalmReminders'] ?? _momentOfCalmReminders;
            
            // Sync SharedPreferences with Firestore values
            await prefs.setBool('mealLoggingPrompts', _mealLoggingPrompts);
            await prefs.setBool('waterIntakeReminders', _waterIntakeReminders);
            await prefs.setBool('mindfulWalksReminders', _mindfulWalksReminders);
            await prefs.setBool('momentOfCalmReminders', _momentOfCalmReminders);
          }
                // Preferences synced from Firestore
          
          // Schedule notifications for enabled preferences
          if (_mealLoggingPrompts) {
            await _scheduleMealLoggingPrompts();
          }
          if (_waterIntakeReminders) {
            await _scheduleWaterIntakeReminders();
          }
          if (_mindfulWalksReminders) {
            await _scheduleMindfulWalksReminders();
          }
        }
      }
    } catch (e) {
              // Failed to sync preferences
      // If Firestore fails, use SharedPreferences values (already loaded above)
    }
    
    notifyListeners();
  }

  // Setters
  Future<void> setUseMetric(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _useMetric = value;
    await prefs.setBool('useMetric', value);
    
    // Also save to Firestore
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'useMetric': value,
          'lastUpdated': DateTime.now(),
        });
      }
    } catch (e) {
      print('Error saving useMetric to Firestore: $e');
    }
    
    notifyListeners();
  }

  Future<void> setMealLoggingPrompts(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _mealLoggingPrompts = value;
    await prefs.setBool('mealLoggingPrompts', value);
    
    // Also save to Firestore
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'reminders.mealLoggingPrompts': value,
          'lastUpdated': DateTime.now(),
        });
      }
    } catch (e) {
      print('Error saving to Firestore: $e');
    }
    
    notifyListeners();
    if (value) {
      // Request permissions first before scheduling
      final hasPermission = await requestNotificationPermissions();
      if (hasPermission) {
        await _scheduleMealLoggingPrompts();
      } else {
        // Notification permission denied
      }
    } else {
      await _cancelMealLoggingPrompts();
    }
  }

  Future<void> setWaterIntakeReminders(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _waterIntakeReminders = value;
    await prefs.setBool('waterIntakeReminders', value);
    
    // Also save to Firestore
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'reminders.waterIntakeReminders': value,
          'lastUpdated': DateTime.now(),
        });
      }
    } catch (e) {
      print('Error saving to Firestore: $e');
    }
    
    notifyListeners();
    if (value) {
      // Request permissions first before scheduling
      final hasPermission = await requestNotificationPermissions();
      if (hasPermission) {
        await _scheduleWaterIntakeReminders();
      } else {
        // Notification permission denied
      }
    } else {
      await _cancelWaterIntakeReminders();
    }
  }

  Future<void> setMindfulWalksReminders(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _mindfulWalksReminders = value;
    await prefs.setBool('mindfulWalksReminders', value);
    
    // Also save to Firestore
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'reminders.mindfulWalksReminders': value,
          'lastUpdated': DateTime.now(),
        });
      }
    } catch (e) {
      print('Error saving to Firestore: $e');
    }
    
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
    
    // Also save to Firestore
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'reminders.momentOfCalmReminders': value,
          'lastUpdated': DateTime.now(),
        });
      }
    } catch (e) {
      print('Error saving to Firestore: $e');
    }
    
    notifyListeners();
    // Note: Moment of Calm notifications are triggered after meal logging
    // No immediate scheduling needed - they are contextual
  }

  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    _language = language;
    await prefs.setString('language', language);
    notifyListeners();
  }

  // --- MEAL SCHEDULING (iOS + Native Android) ---
  Future<void> _scheduleMealLoggingPrompts() async {
    print('📱 Setting up meal reminders...');
    
    if (Platform.isAndroid) {
      // Android: Use NATIVE notifications (like the test that worked!)
      print('🤖 Using NATIVE Android meal reminders...');
      final success = await NativeNotificationService.scheduleMealReminders();
      if (success) {
        print('✅ Native Android meal reminders scheduled for: 8AM, 1PM, 7PM, 10PM');
      } else {
        print('❌ Failed to schedule native Android meal reminders');
      }
    } else {
      // iOS: Keep existing Flutter system (works perfectly!)
      print('🍎 Using Flutter notifications for iOS (unchanged)...');
      
      final times = [
        [8, 0],   // Breakfast
        [13, 0],  // Lunch
        [19, 0],  // Dinner
        [22, 0],  // Night/Snack
      ];
      final mealLabels = [
        'Breakfast Time! 🌅',
        'Lunch Time! ☀️',
        'Dinner Time! 🌅',
        'Snack Time! 🌙',
      ];
      
      for (int i = 0; i < times.length; i++) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          2000 + i,
          mealLabels[i],
          'Time to log your meal and track your nutrition! 🍽️',
          _nextInstanceOfTime(times[i][0], times[i][1]),
          NotificationDetails(
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          matchDateTimeComponents: DateTimeComponents.time,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Required parameter
        );
      }
      
      print('✅ iOS meal reminders scheduled for: 8AM, 1PM, 7PM, 10PM');
    }
  }
  
  Future<void> _cancelMealLoggingPrompts() async {
    if (Platform.isAndroid) {
      // Android: Cancel native notifications
      print('🤖 Canceling native Android meal reminders...');
      await NativeNotificationService.cancelAllNotifications();
    } else {
      // iOS: Cancel Flutter notifications (unchanged)
      print('🍎 Canceling iOS meal reminders...');
      for (int i = 0; i < 4; i++) {
        await flutterLocalNotificationsPlugin.cancel(2000 + i);
      }
    }
  }

  Future<void> _scheduleWaterIntakeReminders() async {
    print('💧 Setting up water reminders...');
    
    if (Platform.isAndroid) {
      // Android: Use NATIVE notifications (same as meal reminders)
      print('🤖 Using NATIVE Android water reminders...');
      final success = await NativeNotificationService.scheduleWaterReminders();
      if (success) {
        print('✅ Native Android water reminders scheduled for: 9AM, 12PM, 3PM, 6PM, 9PM');
      } else {
        print('❌ Failed to schedule native Android water reminders');
      }
    } else {
      // iOS: Keep existing Flutter system (works perfectly!)
      print('🍎 Using Flutter notifications for iOS (unchanged)...');
      
      final times = [9, 12, 15, 18, 21];
      for (int i = 0; i < times.length; i++) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          3000 + i,
          'Hydration Reminder',
          'Drink some water! 💧',
          _nextInstanceOfTime(times[i], 0),
          const NotificationDetails(
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          matchDateTimeComponents: DateTimeComponents.time,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
      
      print('✅ iOS water reminders scheduled for: 9AM, 12PM, 3PM, 6PM, 9PM');
    }
  }
  
  Future<void> _cancelWaterIntakeReminders() async {
    if (Platform.isAndroid) {
      // Android: Cancel native notifications
      print('🤖 Canceling native Android water reminders...');
      await NativeNotificationService.cancelWaterReminders();
    } else {
      // iOS: Cancel Flutter notifications (unchanged)
      print('🍎 Canceling iOS water reminders...');
      for (int i = 0; i < 5; i++) {
        await flutterLocalNotificationsPlugin.cancel(3000 + i);
      }
    }
  }

  Future<void> _scheduleMindfulWalksReminders() async {
    print('🚶‍♀️ Setting up walk reminders...');
    
    if (Platform.isAndroid) {
      // Android: Use NATIVE notifications (same as meal reminders)
      print('🤖 Using NATIVE Android walk reminders...');
      final success = await NativeNotificationService.scheduleWalkReminders();
      if (success) {
        print('✅ Native Android walk reminders scheduled for: 10AM, 2PM, 5PM');
      } else {
        print('❌ Failed to schedule native Android walk reminders');
      }
    } else {
      // iOS: Keep existing Flutter system (works perfectly!)
      print('🍎 Using Flutter notifications for iOS (unchanged)...');
      
      await flutterLocalNotificationsPlugin.zonedSchedule(
        4001,
        'Mindful Walk',
        'Take a mindful walk today!',
        _nextInstanceOfTime(18, 0),
        const NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      
      print('✅ iOS walk reminder scheduled for: 6PM');
    }
  }
  
  Future<void> _cancelMindfulWalksReminders() async {
    if (Platform.isAndroid) {
      // Android: Cancel native notifications
      print('🤖 Canceling native Android walk reminders...');
      await NativeNotificationService.cancelWalkReminders();
    } else {
      // iOS: Cancel Flutter notifications (unchanged)
      print('🍎 Canceling iOS walk reminders...');
      await flutterLocalNotificationsPlugin.cancel(4001);
    }
  }

  // --- Helper functions for scheduling ---
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    
    return scheduled;
  }

  // Schedule a water reminder after a meal is logged if the toggle is on
  Future<void> scheduleWaterReminderAfterMeal() async {
    if (!_waterIntakeReminders) return;
    
    // Cancel any existing water reminder
    await flutterLocalNotificationsPlugin.cancel(7000);
    
    // Schedule a water reminder for 30 minutes after the meal
    await flutterLocalNotificationsPlugin.zonedSchedule(
      7000,
      'Hydration Reminder',
      'Great job logging your meal! Now drink some water to aid digestion. 💧',
      tz.TZDateTime.now(tz.local).add(Duration(minutes: 30)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'water_channel', 
          'Water Intake',
          channelDescription: 'Notifications for water intake reminders',
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
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Moment of Calm: Call this after a meal is logged if toggle is on
  bool get momentOfCalmEnabled => _momentOfCalmReminders;

  // Request notification permissions for Android 13+
  Future<bool> requestNotificationPermissions() async {
    print('🔔 Requesting notification permissions...');
    
    final androidPlugin = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      // Request notification permission (Android 13+)
      final bool? granted = await androidPlugin.requestNotificationsPermission();
      print('🔔 Notification permission granted: $granted');
      
      // Request exact alarm permission (Android 12+)
      final bool? exactAlarmGranted = await androidPlugin.requestExactAlarmsPermission();
      print('⏰ Exact alarm permission granted: $exactAlarmGranted');
      
      return granted == true;
    }
    
    return true; // Assume granted for older Android versions
  }

  // Request battery optimization exemption for reliable background notifications
  Future<void> requestBatteryOptimizationExemption() async {
    print('🔋 Requesting battery optimization exemption...');
    
    final androidPlugin = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      // This would need a custom Android implementation
      // For now, we'll guide users manually
      print('🔋 Please disable battery optimization for Yumie in Android settings');
      print('📱 Go to Settings > Apps > Yumie > Battery > Not optimized');
    }
  }
}
