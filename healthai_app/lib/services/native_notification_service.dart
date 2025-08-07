import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class NativeNotificationService {
  static const MethodChannel _channel = MethodChannel('native_notifications');
  
  // Schedule a test notification using native Android AlarmManager
  static Future<bool> scheduleTestNotification() async {
    if (!Platform.isAndroid) {
      print('⚠️ Native notifications are Android-only');
      return false;
    }
    
    try {
      final result = await _channel.invokeMethod('scheduleTestNotification');
      print('🔔 Native test notification scheduled: $result');
      return true;
    } catch (e) {
      print('❌ Failed to schedule native test notification: $e');
      return false;
    }
  }
  
  // Schedule meal reminders using native Android AlarmManager
  static Future<bool> scheduleMealReminders() async {
    if (!Platform.isAndroid) {
      print('⚠️ Native notifications are Android-only');
      return false;
    }
    
    try {
      final result = await _channel.invokeMethod('scheduleMealReminders');
      print('🍽️ Native meal reminders scheduled: $result');
      return true;
    } catch (e) {
      print('❌ Failed to schedule native meal reminders: $e');
      return false;
    }
  }
  
  // Schedule water reminders using native Android AlarmManager
  static Future<bool> scheduleWaterReminders() async {
    if (!Platform.isAndroid) {
      print('⚠️ Native notifications are Android-only');
      return false;
    }
    
    try {
      final result = await _channel.invokeMethod('scheduleWaterReminders');
      print('💧 Native water reminders scheduled: $result');
      return true;
    } catch (e) {
      print('❌ Failed to schedule native water reminders: $e');
      return false;
    }
  }
  
  // Schedule walk reminders using native Android AlarmManager
  static Future<bool> scheduleWalkReminders() async {
    if (!Platform.isAndroid) {
      print('⚠️ Native notifications are Android-only');
      return false;
    }
    
    try {
      final result = await _channel.invokeMethod('scheduleWalkReminders');
      print('🚶‍♀️ Native walk reminders scheduled: $result');
      return true;
    } catch (e) {
      print('❌ Failed to schedule native walk reminders: $e');
      return false;
    }
  }
  
  // Cancel water reminders
  static Future<bool> cancelWaterReminders() async {
    if (!Platform.isAndroid) {
      print('⚠️ Native notifications are Android-only');
      return false;
    }
    
    try {
      final result = await _channel.invokeMethod('cancelWaterReminders');
      print('🛑 Native water reminders canceled: $result');
      return true;
    } catch (e) {
      print('❌ Failed to cancel native water reminders: $e');
      return false;
    }
  }
  
  // Cancel walk reminders
  static Future<bool> cancelWalkReminders() async {
    if (!Platform.isAndroid) {
      print('⚠️ Native notifications are Android-only');
      return false;
    }
    
    try {
      final result = await _channel.invokeMethod('cancelWalkReminders');
      print('🛑 Native walk reminders canceled: $result');
      return true;
    } catch (e) {
      print('❌ Failed to cancel native walk reminders: $e');
      return false;
    }
  }

  // Cancel all native notifications
  static Future<bool> cancelAllNotifications() async {
    if (!Platform.isAndroid) {
      print('⚠️ Native notifications are Android-only');
      return false;
    }
    
    try {
      final result = await _channel.invokeMethod('cancelAllNotifications');
      print('🛑 Native notifications canceled: $result');
      return true;
    } catch (e) {
      print('❌ Failed to cancel native notifications: $e');
      return false;
    }
  }
}
