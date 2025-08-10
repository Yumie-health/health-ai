package com.yumie.healthai

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.net.Uri
import java.util.*

class NotificationScheduler(private val context: Context) {
    
    /**
     * Check if the app is whitelisted from battery optimizations
     */
    fun isBatteryOptimizationIgnored(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
            powerManager.isIgnoringBatteryOptimizations(context.packageName)
        } else {
            true // Not applicable for older versions
        }
    }
    
    /**
     * Request the user to disable battery optimization for the app
     */
    fun requestBatteryOptimizationExemption() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                data = Uri.parse("package:${context.packageName}")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            try {
                context.startActivity(intent)
                android.util.Log.d("NotificationScheduler", "Requesting battery optimization exemption")
            } catch (e: Exception) {
                android.util.Log.e("NotificationScheduler", "Failed to request battery optimization exemption", e)
            }
        }
    }
    
    fun scheduleTestNotification() {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        
        // Schedule notification for 5 seconds from now
        val intent = Intent(context, NotificationReceiver::class.java).apply {
            putExtra("title", "🔔 Native Android Test SUCCESS!")
            putExtra("message", "This notification works when app is closed! 🎉")
            putExtra("notificationType", "meal") // Use meal channel for test
            putExtra("notificationId", 1000)
        }
        
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            9999, // Request code
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val triggerTime = System.currentTimeMillis() + 5000 // 5 seconds
        
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerTime,
                    pendingIntent
                )
            } else {
                alarmManager.setExact(
                    AlarmManager.RTC_WAKEUP,
                    triggerTime,
                    pendingIntent
                )
            }
            android.util.Log.d("NotificationScheduler", "Native test notification scheduled for 5 seconds")
        } catch (e: SecurityException) {
            android.util.Log.e("NotificationScheduler", "Permission denied for exact alarm", e)
        }
    }
    
    fun scheduleMealReminders() {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val calendar = Calendar.getInstance()
        
        val mealTimes = arrayOf(
            Pair(8, 0),   // Breakfast 8:00 AM
            Pair(13, 0),  // Lunch 1:00 PM
            Pair(19, 0),  // Dinner 7:00 PM
            Pair(22, 0)   // Snack 10:00 PM
        )
        
        val mealLabels = arrayOf(
            "🌅 Breakfast Time!",
            "☀️ Lunch Time!",
            "🌅 Dinner Time!",
            "🌙 Snack Time!"
        )
        
        for (i in mealTimes.indices) {
            val (hour, minute) = mealTimes[i]
            val label = mealLabels[i]
            
            val intent = Intent(context, NotificationReceiver::class.java).apply {
                putExtra("title", label)
                putExtra("message", "Time to log your meal and track your nutrition! 🍽️")
                putExtra("notificationType", "meal")
                putExtra("notificationId", 2000 + i)
            }
            
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                3000 + i, // Unique request code for each meal
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            // Set up calendar for next occurrence of this time
            calendar.set(Calendar.HOUR_OF_DAY, hour)
            calendar.set(Calendar.MINUTE, minute)
            calendar.set(Calendar.SECOND, 0)
            
            // If time has passed today, schedule for tomorrow
            if (calendar.timeInMillis <= System.currentTimeMillis()) {
                calendar.add(Calendar.DAY_OF_MONTH, 1)
            }
            
            try {
                // Use setExactAndAllowWhileIdle for better delivery during doze mode
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        calendar.timeInMillis,
                        pendingIntent
                    )
                } else {
                    alarmManager.setExact(
                        AlarmManager.RTC_WAKEUP,
                        calendar.timeInMillis,
                        pendingIntent
                    )
                }
                
                // Schedule the next occurrence (for tomorrow) to simulate repeating
                calendar.add(Calendar.DAY_OF_MONTH, 1)
                scheduleNextMealReminder(hour, minute, label, 2000 + i, 3000 + i)
                
                android.util.Log.d("NotificationScheduler", "✅ Scheduled meal reminder: $label at $hour:$minute")
                android.util.Log.d("NotificationScheduler", "⏰ Trigger time: ${calendar.time}")
                android.util.Log.d("NotificationScheduler", "📱 Current time: ${java.util.Date(System.currentTimeMillis())}")
            } catch (e: SecurityException) {
                android.util.Log.e("NotificationScheduler", "Permission denied for exact alarm", e)
            }
        }
    }
    
    /**
     * Schedule next meal reminder (used for repeating daily notifications)
     */
    fun scheduleNextMealReminder(hour: Int, minute: Int, label: String, notificationId: Int, requestCode: Int) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val calendar = Calendar.getInstance()
        
        val intent = Intent(context, NotificationReceiver::class.java).apply {
            putExtra("title", label)
            putExtra("message", "Time to log your meal and track your nutrition! 🍽️")
            putExtra("notificationType", "meal")
            putExtra("notificationId", notificationId)
            putExtra("scheduleNext", true) // Flag to schedule the next occurrence
            putExtra("hour", hour)
            putExtra("minute", minute)
            putExtra("label", label)
        }
        
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            requestCode + 1000, // Different request code for next occurrence
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        // Set up calendar for next occurrence (tomorrow at the same time)
        calendar.set(Calendar.HOUR_OF_DAY, hour)
        calendar.set(Calendar.MINUTE, minute)
        calendar.set(Calendar.SECOND, 0)
        calendar.add(Calendar.DAY_OF_MONTH, 1) // Tomorrow
        
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    pendingIntent
                )
            } else {
                alarmManager.setExact(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    pendingIntent
                )
            }
            android.util.Log.d("NotificationScheduler", "Scheduled next meal reminder for $label at ${calendar.time}")
        } catch (e: SecurityException) {
            android.util.Log.e("NotificationScheduler", "Permission denied for next meal reminder", e)
        }
    }
    
    fun cancelAllNotifications() {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        
        // Cancel test notification
        val testIntent = Intent(context, NotificationReceiver::class.java)
        val testPendingIntent = PendingIntent.getBroadcast(
            context, 9999, testIntent, PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
        )
        testPendingIntent?.let { alarmManager.cancel(it) }
        
        // Cancel meal reminders
        for (i in 0..3) {
            val mealIntent = Intent(context, NotificationReceiver::class.java)
            val mealPendingIntent = PendingIntent.getBroadcast(
                context, 3000 + i, mealIntent, PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
            )
            mealPendingIntent?.let { alarmManager.cancel(it) }
        }
        
        android.util.Log.d("NotificationScheduler", "All native notifications canceled")
    }
    
    fun scheduleWaterReminders() {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val calendar = Calendar.getInstance()
        
        val waterTimes = arrayOf(9, 12, 15, 18, 21) // 9AM, 12PM, 3PM, 6PM, 9PM
        
        for (i in waterTimes.indices) {
            val hour = waterTimes[i]
            
            val intent = Intent(context, NotificationReceiver::class.java).apply {
                putExtra("title", "💧 Hydration Time!")
                putExtra("message", "Time to drink some water and stay hydrated! 💧")
                putExtra("notificationType", "water")
                putExtra("notificationId", 4000 + i)
            }
            
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                4000 + i, // Unique request code for each water reminder
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            // Set up calendar for next occurrence of this time
            calendar.set(Calendar.HOUR_OF_DAY, hour)
            calendar.set(Calendar.MINUTE, 0)
            calendar.set(Calendar.SECOND, 0)
            
            // If time has passed today, schedule for tomorrow
            if (calendar.timeInMillis <= System.currentTimeMillis()) {
                calendar.add(Calendar.DAY_OF_MONTH, 1)
            }
            
            try {
                // Use setExactAndAllowWhileIdle for better delivery during doze mode
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        calendar.timeInMillis,
                        pendingIntent
                    )
                } else {
                    alarmManager.setExact(
                        AlarmManager.RTC_WAKEUP,
                        calendar.timeInMillis,
                        pendingIntent
                    )
                }
                
                // Schedule the next occurrence for tomorrow
                scheduleNextWaterReminder(hour, 4000 + i, 4000 + i)
                
                android.util.Log.d("NotificationScheduler", "Scheduled water reminder at $hour:00")
            } catch (e: SecurityException) {
                android.util.Log.e("NotificationScheduler", "Permission denied for water reminder", e)
            }
        }
    }
    
    fun scheduleWalkReminders() {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val calendar = Calendar.getInstance()
        
        val walkTimes = arrayOf(10, 14, 17) // 10AM, 2PM, 5PM
        
        for (i in walkTimes.indices) {
            val hour = walkTimes[i]
            
            val intent = Intent(context, NotificationReceiver::class.java).apply {
                putExtra("title", "🚶‍♀️ Walk Time!")
                putExtra("message", "Time for a mindful walk! Get some fresh air and movement. 🌿")
                putExtra("notificationType", "walk")
                putExtra("notificationId", 5000 + i)
            }
            
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                5000 + i, // Unique request code for each walk reminder
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            // Set up calendar for next occurrence of this time
            calendar.set(Calendar.HOUR_OF_DAY, hour)
            calendar.set(Calendar.MINUTE, 0)
            calendar.set(Calendar.SECOND, 0)
            
            // If time has passed today, schedule for tomorrow
            if (calendar.timeInMillis <= System.currentTimeMillis()) {
                calendar.add(Calendar.DAY_OF_MONTH, 1)
            }
            
            try {
                // Use setExactAndAllowWhileIdle for better delivery during doze mode
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        calendar.timeInMillis,
                        pendingIntent
                    )
                } else {
                    alarmManager.setExact(
                        AlarmManager.RTC_WAKEUP,
                        calendar.timeInMillis,
                        pendingIntent
                    )
                }
                
                // Schedule the next occurrence for tomorrow
                scheduleNextWalkReminder(hour, 5000 + i, 5000 + i)
                
                android.util.Log.d("NotificationScheduler", "Scheduled walk reminder at $hour:00")
            } catch (e: SecurityException) {
                android.util.Log.e("NotificationScheduler", "Permission denied for walk reminder", e)
            }
        }
    }
    
    fun cancelWaterReminders() {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        
        for (i in 0..4) {
            val intent = Intent(context, NotificationReceiver::class.java)
            val pendingIntent = PendingIntent.getBroadcast(
                context, 4000 + i, intent, PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
            )
            pendingIntent?.let { alarmManager.cancel(it) }
        }
        
        android.util.Log.d("NotificationScheduler", "Water reminders canceled")
    }
    
    fun cancelWalkReminders() {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        
        for (i in 0..2) {
            val intent = Intent(context, NotificationReceiver::class.java)
            val pendingIntent = PendingIntent.getBroadcast(
                context, 5000 + i, intent, PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
            )
            pendingIntent?.let { alarmManager.cancel(it) }
        }
        
        android.util.Log.d("NotificationScheduler", "Walk reminders canceled")
    }
    
    /**
     * Schedule next water reminder (used for repeating daily notifications)
     */
    fun scheduleNextWaterReminder(hour: Int, notificationId: Int, requestCode: Int) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val calendar = Calendar.getInstance()
        
        val intent = Intent(context, NotificationReceiver::class.java).apply {
            putExtra("title", "💧 Hydration Time!")
            putExtra("message", "Time to drink some water and stay hydrated! 💧")
            putExtra("notificationType", "water")
            putExtra("notificationId", notificationId)
            putExtra("scheduleNext", true)
            putExtra("hour", hour)
            putExtra("reminderType", "water")
        }
        
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            requestCode + 2000, // Different request code for next occurrence
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        // Set up calendar for next occurrence (tomorrow at the same time)
        calendar.set(Calendar.HOUR_OF_DAY, hour)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.add(Calendar.DAY_OF_MONTH, 1) // Tomorrow
        
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    pendingIntent
                )
            } else {
                alarmManager.setExact(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    pendingIntent
                )
            }
            android.util.Log.d("NotificationScheduler", "Scheduled next water reminder for $hour:00 at ${calendar.time}")
        } catch (e: SecurityException) {
            android.util.Log.e("NotificationScheduler", "Permission denied for next water reminder", e)
        }
    }
    
    /**
     * Schedule next walk reminder (used for repeating daily notifications)
     */
    fun scheduleNextWalkReminder(hour: Int, notificationId: Int, requestCode: Int) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val calendar = Calendar.getInstance()
        
        val intent = Intent(context, NotificationReceiver::class.java).apply {
            putExtra("title", "🚶‍♀️ Walk Time!")
            putExtra("message", "Time for a mindful walk! Get some fresh air and movement. 🌿")
            putExtra("notificationType", "walk")
            putExtra("notificationId", notificationId)
            putExtra("scheduleNext", true)
            putExtra("hour", hour)
            putExtra("reminderType", "walk")
        }
        
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            requestCode + 3000, // Different request code for next occurrence
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        // Set up calendar for next occurrence (tomorrow at the same time)
        calendar.set(Calendar.HOUR_OF_DAY, hour)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.add(Calendar.DAY_OF_MONTH, 1) // Tomorrow
        
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    pendingIntent
                )
            } else {
                alarmManager.setExact(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    pendingIntent
                )
            }
            android.util.Log.d("NotificationScheduler", "Scheduled next walk reminder for $hour:00 at ${calendar.time}")
        } catch (e: SecurityException) {
            android.util.Log.e("NotificationScheduler", "Permission denied for next walk reminder", e)
        }
    }
}
