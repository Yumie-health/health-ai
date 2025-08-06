package com.yumie.healthai

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MainActivity: FlutterActivity() {
    private val CHANNEL = "play_integrity_channel"
    private val BILLING_CHANNEL = "billing_channel"
    private lateinit var playIntegrityHelper: PlayIntegrityHelper
    private lateinit var billingService: BillingService
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        playIntegrityHelper = PlayIntegrityHelper(this)
        billingService = BillingService(this)
        
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
                        // Handle purchase - you'll need to implement this based on your product details
                        result.success("Purchase initiated")
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
    }
}
