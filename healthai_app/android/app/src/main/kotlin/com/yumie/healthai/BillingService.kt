package com.yumie.healthai

import android.app.Activity
import android.content.Context
import com.android.billingclient.api.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class BillingService(private val context: Context) {
    
    private var billingClient: BillingClient? = null
    private var isConnected = false
    
    // Product IDs for subscriptions
    private val subscriptionSkus = listOf("premium_monthly", "premium_yearly")
    
    interface BillingCallback {
        fun onProductsLoaded(products: List<ProductDetails>)
        fun onPurchaseSuccess(purchase: Purchase)
        fun onPurchaseError(error: String)
        fun onSubscriptionStatusChanged(isActive: Boolean)
    }
    
    private var callback: BillingCallback? = null
    
    fun setCallback(callback: BillingCallback) {
        this.callback = callback
    }
    
    suspend fun initializeBilling() = withContext(Dispatchers.IO) {
        try {
            billingClient = BillingClient.newBuilder(context)
                .setListener { billingResult, purchases ->
                    if (billingResult.responseCode == BillingClient.BillingResponseCode.OK && purchases != null) {
                        for (purchase in purchases) {
                            handlePurchase(purchase)
                        }
                    }
                }
                .enablePendingPurchases()
                .build()
            
            connectToBilling()
        } catch (e: Exception) {
            callback?.onPurchaseError("Failed to initialize billing: ${e.message}")
        }
    }
    
    private suspend fun connectToBilling() = withContext(Dispatchers.IO) {
        try {
            billingClient?.startConnection(object : BillingClientStateListener {
                override fun onBillingSetupFinished(billingResult: BillingResult) {
                    if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                        isConnected = true
                        CoroutineScope(Dispatchers.IO).launch {
                            queryProducts()
                            queryExistingPurchases()
                        }
                    } else {
                        callback?.onPurchaseError("Failed to connect to billing: ${billingResult.debugMessage}")
                    }
                }
                
                override fun onBillingServiceDisconnected() {
                    isConnected = false
                    callback?.onPurchaseError("Billing service disconnected")
                }
            })
        } catch (e: Exception) {
            callback?.onPurchaseError("Connection error: ${e.message}")
        }
    }
    
    private suspend fun queryProducts() = withContext(Dispatchers.IO) {
        try {
            val productList = subscriptionSkus.map { sku ->
                QueryProductDetailsParams.Product.newBuilder()
                    .setProductId(sku)
                    .setProductType(BillingClient.ProductType.SUBS)
                    .build()
            }
            
            val params = QueryProductDetailsParams.newBuilder()
                .setProductList(productList)
                .build()
            
            billingClient?.queryProductDetailsAsync(params) { result, productDetailsList ->
                if (result.responseCode == BillingClient.BillingResponseCode.OK) {
                    callback?.onProductsLoaded(productDetailsList ?: emptyList())
                } else {
                    callback?.onPurchaseError("Failed to load products: ${result.debugMessage}")
                }
            }
        } catch (e: Exception) {
            callback?.onPurchaseError("Query products error: ${e.message}")
        }
    }
    
    suspend fun purchaseSubscription(activity: Activity, productDetails: ProductDetails) = withContext(Dispatchers.IO) {
        try {
            val offerToken = productDetails.subscriptionOfferDetails?.firstOrNull()?.offerToken
            if (offerToken == null) {
                callback?.onPurchaseError("No offer token available")
                return@withContext
            }
            
            val productDetailsParamsList = listOf(
                BillingFlowParams.ProductDetailsParams.newBuilder()
                    .setProductDetails(productDetails)
                    .setOfferToken(offerToken)
                    .build()
            )
            
            val billingFlowParams = BillingFlowParams.newBuilder()
                .setProductDetailsParamsList(productDetailsParamsList)
                .build()
            
            val billingResult = billingClient?.launchBillingFlow(activity, billingFlowParams)
            if (billingResult?.responseCode != BillingClient.BillingResponseCode.OK) {
                callback?.onPurchaseError("Failed to launch billing flow: ${billingResult?.debugMessage}")
            } else {
                // Billing flow launched successfully
            }
        } catch (e: Exception) {
            callback?.onPurchaseError("Purchase error: ${e.message}")
        }
    }
    
    private suspend fun queryExistingPurchases() = withContext(Dispatchers.IO) {
        try {
            val params = QueryPurchasesParams.newBuilder()
                .setProductType(BillingClient.ProductType.SUBS)
                .build()
            
            billingClient?.queryPurchasesAsync(params) { result, purchases ->
                if (result.responseCode == BillingClient.BillingResponseCode.OK) {
                    val activeSubscription = purchases.any { purchase ->
                        purchase.purchaseState == Purchase.PurchaseState.PURCHASED &&
                        !purchase.isAcknowledged
                    }
                    callback?.onSubscriptionStatusChanged(activeSubscription)
                } else {
                    callback?.onPurchaseError("Failed to query purchases: ${result.debugMessage}")
                }
            }
        } catch (e: Exception) {
            callback?.onPurchaseError("Query purchases error: ${e.message}")
        }
    }
    
    private fun handlePurchase(purchase: Purchase) {
        if (purchase.purchaseState == Purchase.PurchaseState.PURCHASED) {
            if (!purchase.isAcknowledged) {
                CoroutineScope(Dispatchers.IO).launch {
                    acknowledgePurchase(purchase.purchaseToken)
                }
            }
            callback?.onPurchaseSuccess(purchase)
        }
    }
    
    private suspend fun acknowledgePurchase(purchaseToken: String) = withContext(Dispatchers.IO) {
        try {
            val acknowledgePurchaseParams = AcknowledgePurchaseParams.newBuilder()
                .setPurchaseToken(purchaseToken)
                .build()
            
            val billingResult = billingClient?.acknowledgePurchase(acknowledgePurchaseParams)
            if (billingResult?.responseCode != BillingClient.BillingResponseCode.OK) {
                callback?.onPurchaseError("Failed to acknowledge purchase: ${billingResult?.debugMessage}")
            } else {
                // Purchase acknowledged successfully
            }
        } catch (e: Exception) {
            callback?.onPurchaseError("Acknowledge error: ${e.message}")
        }
    }
    
    suspend fun restorePurchases() = withContext(Dispatchers.IO) {
        try {
            queryExistingPurchases()
        } catch (e: Exception) {
            callback?.onPurchaseError("Restore error: ${e.message}")
        }
    }
    
    fun disconnect() {
        billingClient?.endConnection()
        isConnected = false
    }
}
