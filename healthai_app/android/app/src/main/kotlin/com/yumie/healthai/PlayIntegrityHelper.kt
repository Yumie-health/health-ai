package com.yumie.healthai

import android.content.Context
import com.google.android.play.core.integrity.IntegrityManager
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.IntegrityTokenRequest
import com.google.android.play.core.integrity.IntegrityTokenResponse
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.tasks.await
import kotlinx.coroutines.withContext

class PlayIntegrityHelper(private val context: Context) {
    
    private val integrityManager: IntegrityManager = IntegrityManagerFactory.create(context)
    
    /**
     * Get an integrity token from Google Play
     * @return The integrity token as a string, or null if failed
     */
    suspend fun getIntegrityToken(): String? = withContext(Dispatchers.IO) {
        try {
            val request = IntegrityTokenRequest.builder()
                .setNonce("your-nonce-here") // You can customize this
                .build()
            
            val response: IntegrityTokenResponse = integrityManager.requestIntegrityToken(request).await()
            response.token()
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }
    
    /**
     * Check if the device meets basic integrity requirements
     * @return true if the device meets integrity requirements
     */
    suspend fun checkDeviceIntegrity(): Boolean = withContext(Dispatchers.IO) {
        try {
            val token = getIntegrityToken()
            token != null
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
}
