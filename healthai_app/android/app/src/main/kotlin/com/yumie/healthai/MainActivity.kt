package com.yumie.healthai

import android.os.Bundle
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MainActivity: FlutterActivity() {
    private val CHANNEL = "play_integrity_channel"
    private val BILLING_CHANNEL = "billing_channel"
    private val NOTIFICATION_CHANNEL = "native_notifications"
    private val DEEP_LINK_CHANNEL = "deep_link_channel"
    private lateinit var playIntegrityHelper: PlayIntegrityHelper
    private lateinit var billingService: BillingService
    private lateinit var notificationScheduler: NotificationScheduler
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Enable edge-to-edge for Android 15+ compatibility
        // Configure window for edge-to-edge display
        WindowCompat.setDecorFitsSystemWindows(window, false)
        
        // Set up edge-to-edge display
        val windowInsetsController = WindowInsetsControllerCompat(window, window.decorView)
        windowInsetsController.isAppearanceLightStatusBars = false
        windowInsetsController.isAppearanceLightNavigationBars = false
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Deep link / widget action channel
        val deepLinkChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DEEP_LINK_CHANNEL)
        fun sendActionToFlutter(action: String?) {
            if (action == null) return
            deepLinkChannel.invokeMethod("action", action)
        }
        // Send current intent action if launched via widget
        sendActionToFlutter(intent?.action)
        
        playIntegrityHelper = PlayIntegrityHelper(this)
        billingService = BillingService(this)
        notificationScheduler = NotificationScheduler(this)
        
        // Set up billing callback
        billingService.setCallback(object : BillingService.BillingCallback {
            override fun onProductsLoaded(products: List<com.android.billingclient.api.ProductDetails>) {
                // Handle products loaded
            }
            
            override fun onPurchaseSuccess(purchase: com.android.billingclient.api.Purchase) {
                // Handle successful purchase
            }
            
            override fun onPurchaseError(error: String) {
                // Handle purchase error
            }
            
            override fun onSubscriptionStatusChanged(isActive: Boolean) {
                // Handle subscription status change
            }
        })
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getIntegrityToken" -> {
                    CoroutineScope(Dispatchers.Main).launch {
                        try {
                            val token = playIntegrityHelper.getIntegrityToken()
                            result.success(token)
                        } catch (e: Exception) {
                            result.error("INTEGRITY_ERROR", "Failed to get integrity token", e.message)
                        }
                    }
                }
                "checkDeviceIntegrity" -> {
                    CoroutineScope(Dispatchers.Main).launch {
                        try {
                            val isValid = playIntegrityHelper.checkDeviceIntegrity()
                            result.success(isValid)
                        } catch (e: Exception) {
                            result.error("INTEGRITY_ERROR", "Failed to check device integrity", e.message)
                        }
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BILLING_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initializeBilling" -> {
                    CoroutineScope(Dispatchers.Main).launch {
                        try {
                            billingService.initializeBilling()
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("BILLING_ERROR", "Failed to initialize billing", e.message)
                        }
                    }
                }
                "purchaseSubscription" -> {
                    val productId = call.argument<String>("productId")
                    if (productId != null) {
                        CoroutineScope(Dispatchers.Main).launch {
                            try {
                                // For now, we'll use the Flutter IAP plugin instead of native
                                // The native billing is set up but not fully integrated
                                result.success("Purchase handled by Flutter IAP")
                            } catch (e: Exception) {
                                result.error("BILLING_ERROR", "Failed to purchase subscription", e.message)
                            }
                        }
                    } else {
                        result.error("BILLING_ERROR", "Product ID is required", null)
                    }
                }
                "restorePurchases" -> {
                    CoroutineScope(Dispatchers.Main).launch {
                        try {
                            billingService.restorePurchases()
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("BILLING_ERROR", "Failed to restore purchases", e.message)
                        }
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Native notification channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NOTIFICATION_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleTestNotification" -> {
                    try {
                        notificationScheduler.scheduleTestNotification()
                        result.success("Native test notification scheduled")
                    } catch (e: Exception) {
                        result.error("NOTIFICATION_ERROR", "Failed to schedule test notification", e.message)
                    }
                }
                "scheduleMealReminders" -> {
                    try {
                        notificationScheduler.scheduleMealReminders()
                        result.success("Native meal reminders scheduled")
                    } catch (e: Exception) {
                        result.error("NOTIFICATION_ERROR", "Failed to schedule meal reminders", e.message)
                    }
                }
                "cancelAllNotifications" -> {
                    try {
                        notificationScheduler.cancelAllNotifications()
                        result.success("All native notifications canceled")
                    } catch (e: Exception) {
                        result.error("NOTIFICATION_ERROR", "Failed to cancel notifications", e.message)
                    }
                }
                "scheduleWaterReminders" -> {
                    try {
                        notificationScheduler.scheduleWaterReminders()
                        result.success("Native water reminders scheduled")
                    } catch (e: Exception) {
                        result.error("NOTIFICATION_ERROR", "Failed to schedule water reminders", e.message)
                    }
                }
                "scheduleWalkReminders" -> {
                    try {
                        notificationScheduler.scheduleWalkReminders()
                        result.success("Native walk reminders scheduled")
                    } catch (e: Exception) {
                        result.error("NOTIFICATION_ERROR", "Failed to schedule walk reminders", e.message)
                    }
                }
                "cancelWaterReminders" -> {
                    try {
                        notificationScheduler.cancelWaterReminders()
                        result.success("Native water reminders canceled")
                    } catch (e: Exception) {
                        result.error("NOTIFICATION_ERROR", "Failed to cancel water reminders", e.message)
                    }
                }
                "cancelWalkReminders" -> {
                    try {
                        notificationScheduler.cancelWalkReminders()
                        result.success("Native walk reminders canceled")
                    } catch (e: Exception) {
                        result.error("NOTIFICATION_ERROR", "Failed to cancel walk reminders", e.message)
                    }
                }
                "isBatteryOptimizationIgnored" -> {
                    try {
                        val isIgnored = notificationScheduler.isBatteryOptimizationIgnored()
                        result.success(isIgnored)
                    } catch (e: Exception) {
                        result.error("NOTIFICATION_ERROR", "Failed to check battery optimization", e.message)
                    }
                }
                "requestBatteryOptimizationExemption" -> {
                    try {
                        notificationScheduler.requestBatteryOptimizationExemption()
                        result.success("Battery optimization exemption requested")
                    } catch (e: Exception) {
                        result.error("NOTIFICATION_ERROR", "Failed to request battery optimization exemption", e.message)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onNewIntent(intent: android.content.Intent) {
        super.onNewIntent(intent)
        // Forward new intent action to Flutter
        val engine = flutterEngine ?: return
        val deepLinkChannel = MethodChannel(engine.dartExecutor.binaryMessenger, DEEP_LINK_CHANNEL)
        deepLinkChannel.invokeMethod("action", intent.action)
    }
}
