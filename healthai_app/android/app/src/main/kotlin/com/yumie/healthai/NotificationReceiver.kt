package com.yumie.healthai

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat

class NotificationReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val title = intent.getStringExtra("title") ?: "Yumie Reminder"
        val message = intent.getStringExtra("message") ?: "Don't forget your health goals!"
        val notificationId = intent.getIntExtra("notificationId", 0)
        val notificationType = intent.getStringExtra("notificationType") ?: "meal"

        android.util.Log.d("NotificationReceiver", "Received broadcast for notification ID: $notificationId, Title: $title")

        val channelId = when (notificationType) {
            "meal" -> "meal_channel"
            "water" -> "water_channel" 
            "walk" -> "walk_channel"
            else -> "meal_channel"
        }

        val channelName = when (notificationType) {
            "meal" -> "Meal Logging"
            "water" -> "Water Intake"
            "walk" -> "Mindful Walks" 
            else -> "Meal Logging"
        }

        val channelDescription = when (notificationType) {
            "meal" -> "Notifications for meal logging reminders"
            "water" -> "Notifications for water intake reminders"
            "walk" -> "Notifications for mindful walk reminders"
            else -> "Notifications for meal logging reminders"
        }

        createNotificationChannel(context, channelId, channelName, channelDescription)
        showNotification(context, title, message, channelId, notificationId)
    }

    private fun createNotificationChannel(context: Context, channelId: String, channelName: String, channelDescription: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                channelName,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = channelDescription
                enableLights(true)
                enableVibration(true)
            }
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun showNotification(context: Context, title: String, message: String, channelId: String, notificationId: Int) {
        // Create an explicit intent for an Activity in your app
        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        val pendingIntent: PendingIntent = PendingIntent.getActivity(
            context, 0, launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.drawable.ic_notification) // Use Yumie notification icon
            .setContentTitle(title)
            .setContentText(message)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true) // Dismiss notification when tapped
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)

        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(notificationId, builder.build())
        android.util.Log.d("NotificationReceiver", "Notification shown: ID $notificationId on channel $channelId")
    }
}