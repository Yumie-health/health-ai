package com.yumie.healthai

import android.content.Context
import com.google.android.play.core.integrity.IntegrityManager
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.IntegrityTokenRequest
import com.google.android.play.core.integrity.IntegrityTokenResponse
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.tasks.await
import kotlinx.coroutines.withContext
import android.util.Base64
import java.security.SecureRandom

class PlayIntegrityHelper(private val context: Context) {
    
    private val integrityManager: IntegrityManager = IntegrityManagerFactory.create(context)
    
    /**
     * Generate a cryptographically secure nonce of at least 16 bytes
     */
    private fun generateNonce(): String {
        val random = SecureRandom()
        val nonce = ByteArray(24) // Generate 24 bytes (192 bits) for extra security
        random.nextBytes(nonce)
        return Base64.encodeToString(nonce, Base64.URL_SAFE or Base64.NO_WRAP)
    }
    
    /**
     * Get an integrity token from Google Play
     * @return The integrity token as a string, or null if failed
     */
    suspend fun getIntegrityToken(): String? = withContext(Dispatchers.IO) {
        try {
            val request = IntegrityTokenRequest.builder()
                .setNonce(generateNonce()) // Generate secure nonce of 24 bytes before base64 encoding
                .setCloudProjectNumber(390325467547L) // Firebase project number for yumie-maivenx02
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
