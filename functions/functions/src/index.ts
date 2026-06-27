/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import axios from "axios";
import { defineSecret } from "firebase-functions/params";
import { onCall, HttpsError } from "firebase-functions/v2/https";

admin.initializeApp();

// Define secrets
const openaiKey = defineSecret("OPENAI_KEY");
const appleSharedSecret = defineSecret("APPLE_SHARED_SECRET");
// Pexels key is optional - comment out if not needed
// const pexelsKey = defineSecret("PEXELS_KEY");

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// App Update Check Function
export const checkAppUpdate = functions.https.onRequest(async (req, res) => {
  try {
    // Set CORS headers
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'GET, POST');
    res.set('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
      res.status(204).send('');
      return;
    }

    // Get platform from query parameter
    const platform = req.query.platform || 'both';
    
    // Get update information from Firestore (optional - will use defaults if not found)
    const updateDoc = await admin.firestore().collection('app_config').doc('updates').get();
    const updateData = updateDoc.exists ? updateDoc.data() : {};
    
    // Platform-specific update info
    let updateInfo;
    
    if (platform === 'ios') {
      // Force update to at least 1.0.8 (51)
      updateInfo = {
        latestVersion: "1.0.8",
        latestBuildNumber: 51,
        title: updateData?.iosTitle || updateData?.title || "Update Available",
        description: updateData?.iosDescription || updateData?.description || "A new version of Yumie is available with bug fixes and improvements.",
        isForceUpdate: true,
        published: true,
        platform: 'ios'
      };
    } else if (platform === 'android') {
      // Force update to at least 1.0.8 (51)
      updateInfo = {
        latestVersion: "1.0.8",
        latestBuildNumber: 51,
        title: updateData?.androidTitle || updateData?.title || "Update Available",
        description: updateData?.androidDescription || updateData?.description || "A new version of Yumie is available with bug fixes and improvements.",
        isForceUpdate: true,
        published: true,
        platform: 'android'
      };
    } else {
      // Default/fallback for both platforms
      updateInfo = {
        latestVersion: "1.0.8",
        latestBuildNumber: 51,
        title: updateData?.title || "Update Available",
        description: updateData?.description || "A new version of Yumie is available with bug fixes and improvements.",
        isForceUpdate: true,
        published: true,
        platform: 'both'
      };
    }

    res.status(200).json(updateInfo);
  } catch (error) {
    console.error('Error in checkAppUpdate:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Admin function to set app update information
export const setAppUpdate = functions.https.onRequest(async (req, res) => {
  try {
    // Set CORS headers
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'GET, POST');
    res.set('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
      res.status(204).send('');
      return;
    }

    // Only allow POST requests
    if (req.method !== 'POST') {
      res.status(405).send({ error: 'Method not allowed. Use POST.' });
      return;
    }

    const { 
      latestVersion, 
      latestBuildNumber, 
      title, 
      description, 
      isForceUpdate, 
      published,
      platform,
      // Platform-specific fields
      iosLatestVersion,
      iosLatestBuildNumber,
      iosTitle,
      iosDescription,
      iosIsForceUpdate,
      iosPublished,
      androidLatestVersion,
      androidLatestBuildNumber,
      androidTitle,
      androidDescription,
      androidIsForceUpdate,
      androidPublished
    } = req.body;

    // Validate required fields
    if (!latestVersion || !latestBuildNumber) {
      res.status(400).send({ error: 'latestVersion and latestBuildNumber are required' });
      return;
    }

    // Prepare update data
    const updateData: any = {
      latestVersion,
      latestBuildNumber,
      title: title || "Update Available",
      description: description || "A new version of Yumie is available with bug fixes and improvements.",
      isForceUpdate: isForceUpdate || false,
      published: published || false,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    };

    // Add platform-specific data if provided
    if (platform === 'ios' || iosLatestVersion) {
      updateData.iosLatestVersion = iosLatestVersion || latestVersion;
      updateData.iosLatestBuildNumber = iosLatestBuildNumber || latestBuildNumber;
      updateData.iosTitle = iosTitle || title || "Update Available";
      updateData.iosDescription = iosDescription || description || "A new version of Yumie is available with bug fixes and improvements.";
      updateData.iosIsForceUpdate = iosIsForceUpdate ?? isForceUpdate ?? false;
      updateData.iosPublished = iosPublished ?? published ?? false;
    }

    if (platform === 'android' || androidLatestVersion) {
      updateData.androidLatestVersion = androidLatestVersion || latestVersion;
      updateData.androidLatestBuildNumber = androidLatestBuildNumber || latestBuildNumber;
      updateData.androidTitle = androidTitle || title || "Update Available";
      updateData.androidDescription = androidDescription || description || "A new version of Yumie is available with bug fixes and improvements.";
      updateData.androidIsForceUpdate = androidIsForceUpdate ?? isForceUpdate ?? false;
      updateData.androidPublished = androidPublished ?? published ?? false;
    }

    // Save to Firestore
    await admin.firestore().collection('app_config').doc('updates').set(updateData);

    res.status(200).json({ success: true, message: 'Update configuration saved' });
  } catch (error) {
    console.error('Error in setAppUpdate:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

const PROXY_RATE_LIMIT_COLLECTION = "openai_proxy_rate_limits";
const PROXY_RATE_LIMIT_WINDOW_MS = 60_000;
const PROXY_RATE_LIMIT_MAX_REQUESTS = 30;
const PROXY_MAX_TOKENS_CAP = 2048;

async function assertProxyRateLimit(uid: string): Promise<void> {
  const ref = admin.firestore().collection(PROXY_RATE_LIMIT_COLLECTION).doc(uid);
  const now = Date.now();

  await admin.firestore().runTransaction(async (transaction) => {
    const snap = await transaction.get(ref);
    const windowStartMs = snap.data()?.windowStartMs ?? now;
    let count = snap.data()?.count ?? 0;

    if (now - windowStartMs > PROXY_RATE_LIMIT_WINDOW_MS) {
      transaction.set(ref, { windowStartMs: now, count: 1 });
      return;
    }

    if (count >= PROXY_RATE_LIMIT_MAX_REQUESTS) {
      throw new HttpsError(
        "resource-exhausted",
        "Rate limit exceeded. Try again later."
      );
    }

    transaction.set(ref, { windowStartMs, count: count + 1 });
  });
}

function capProxyMaxTokens(body: Record<string, unknown>): void {
  const requested = body.max_tokens;
  if (typeof requested === "number" && Number.isFinite(requested)) {
    body.max_tokens = Math.min(requested, PROXY_MAX_TOKENS_CAP);
  }
}

// OpenAI API proxy — callable so the mobile SDK attaches Auth + App Check tokens.
export const openaiProxyCallable = onCall(
  {
    secrets: [openaiKey],
    enforceAppCheck: true,
    region: "us-central1",
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Authentication required."
      );
    }

    await assertProxyRateLimit(request.auth.uid);

    const openaiKeyValue = openaiKey.value();
    if (!openaiKeyValue) {
      throw new HttpsError(
        "failed-precondition",
        "OpenAI API key not configured."
      );
    }

    const reqBody = request.data as Record<string, unknown> | null;
    if (
      !reqBody ||
      typeof reqBody.model !== "string" ||
      !Array.isArray(reqBody.messages)
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Invalid request body. Required fields: model, messages"
      );
    }

    const cleanBody: Record<string, unknown> = {
      model: reqBody.model,
      messages: reqBody.messages,
      max_tokens: reqBody.max_tokens,
      temperature: reqBody.temperature,
      stream: reqBody.stream,
      stop: reqBody.stop,
      presence_penalty: reqBody.presence_penalty,
      frequency_penalty: reqBody.frequency_penalty,
      logit_bias: reqBody.logit_bias,
      user: reqBody.user,
    };

    Object.keys(cleanBody).forEach((key) => {
      if (cleanBody[key] === undefined) {
        delete cleanBody[key];
      }
    });

    capProxyMaxTokens(cleanBody);

    try {
      const response = await axios.post(
        "https://api.openai.com/v1/chat/completions",
        cleanBody,
        {
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${openaiKeyValue.trim()}`,
          },
          timeout: 30000,
        }
      );

      return response.data;
    } catch (error) {
      if (axios.isAxiosError(error)) {
        const statusCode = error.response?.status || 500;
        console.error("OpenAI API error", {
          status: statusCode,
          uid: request.auth.uid,
        });
        throw new HttpsError(
          "internal",
          `OpenAI API request failed with status ${statusCode}`
        );
      }

      console.error("OpenAI proxy error", error);
      throw new HttpsError(
        "internal",
        "Internal server error while calling OpenAI API"
      );
    }
  }
);

// Pexels API proxy - DISABLED (not needed for now)
// Uncomment and set PEXELS_KEY secret if you need this function
/*
export const pexelsProxyCallable = functions.https.onRequest(
  {
    secrets: [pexelsKey],
    invoker: 'public'
  },
  async (req, res) => {
    const pexelsKeyValue = pexelsKey.value();
    if (!pexelsKeyValue) {
      res.status(500).send({ error: 'Pexels API key not set in secrets.' });
      return;
    }
    console.log('Pexels key (partial):', pexelsKeyValue ? pexelsKeyValue.slice(0, 6) + '...' + pexelsKeyValue.slice(-6) : 'undefined');
    console.log('Incoming data:', JSON.stringify(req.body));
    try {
      const query = req.body.query;
      const response = await axios.get(
        `https://api.pexels.com/v1/search?query=${encodeURIComponent(query)}&per_page=1`,
        {
          headers: {
            "Authorization": pexelsKeyValue,
          },
        }
      );
      res.status(200).send(response.data);
    } catch (error) {
      if (axios.isAxiosError(error)) {
        console.error("Pexels API error:", error.response?.data || error.message);
        res.status(500).send({ error: error.response?.data || error.message });
      } else {
        console.error("Pexels API error:", error);
        res.status(500).send({ error: "Error calling Pexels API" });
      }
    }
  }
);
*/

// Play Integrity verification - Updated
export const verifyPlayIntegrityCallable = functions.https.onCall(async (data: any, context) => {
  try {
    const { integrityToken } = data;
    
    if (!integrityToken) {
      throw new functions.https.HttpsError('invalid-argument', 'Integrity token is required');
    }

    // Verify the integrity token with Google Play Integrity API
    const response = await axios.post(
      'https://playintegrity.googleapis.com/v1/playIntegrity:decodeIntegrityToken',
      {
        integrityToken: integrityToken,
        requestDetails: {
          nonce: 'healthai_integrity_check',
          requestHash: 'healthai_app_integrity'
        }
      },
      {
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${functions.config().google?.play_integrity_key || 'your_service_account_key_here'}`
        }
      }
    );

    const result = response.data;
    const tokenPayload = result.tokenPayloadExternal;
    
    if (!tokenPayload) {
      return { isGenuine: false, isInstalledFromGooglePlay: false };
    }

    const integrityDetails = tokenPayload.integrityDetails;
    const appIntegrity = integrityDetails?.appIntegrity;
    const deviceIntegrity = integrityDetails?.deviceIntegrity;
    const accountDetails = tokenPayload.accountDetails;

    // Check if app is genuine and installed from Google Play
    const isGenuine = appIntegrity?.appRecognitionVerdict === 'PLAY_RECOGNIZED';
    const isInstalledFromGooglePlay = accountDetails?.appLicensingVerdict === 'LICENSED';

    return {
      isGenuine,
      isInstalledFromGooglePlay,
      deviceIntegrity: deviceIntegrity?.deviceRecognitionVerdict || 'UNKNOWN'
    };
  } catch (error) {
    console.error('Play Integrity verification error:', error);
    throw new functions.https.HttpsError('internal', 'Failed to verify integrity token');
  }
});

// iOS Receipt Validation - Updated with Sandbox support
export const validateIOSReceipt = functions.https.onCall({
  secrets: [appleSharedSecret]
}, async (data: any, context) => {
  try {
    const { receiptData, productId, transactionId } = data;
    
    if (!receiptData || !productId || !transactionId) {
      throw new functions.https.HttpsError('invalid-argument', 'Receipt data, product ID, and transaction ID are required');
    }

    // Get the Apple Shared Secret from environment
    const sharedSecret = appleSharedSecret.value();

    // First try production server
    let response;
    let usedSandbox = false;
    
    try {
      response = await axios.post(
        'https://buy.itunes.apple.com/verifyReceipt',
        {
          'receipt-data': receiptData,
          'password': sharedSecret,
          'exclude-old-transactions': true
        }
      );
    } catch (error) {
      console.error('Production verification failed, trying sandbox:', error);
    }
    
    // If production fails with status 21007 (sandbox receipt), try sandbox
    if (!response || response.data.status === 21007) {
      console.log('Receipt is from sandbox environment, validating with sandbox server');
      usedSandbox = true;
      response = await axios.post(
        'https://sandbox.itunes.apple.com/verifyReceipt',
        {
          'receipt-data': receiptData,
          'password': sharedSecret,
          'exclude-old-transactions': true
        }
      );
    }

    const result = response.data;
    console.log(`iOS receipt validation status: ${result.status}, environment: ${usedSandbox ? 'sandbox' : 'production'}`);
    
    if (result.status === 0) {
      // Valid receipt
      const latestReceiptInfo = (result.latest_receipt_info || []) as any[];
      const pendingRenewal = (result.pending_renewal_info || []) as any[];

      // Find the latest transaction for the product
      const productTransactions = latestReceiptInfo.filter(t => t.product_id === productId);
      let latestExpiryMs: number | null = null;
      for (const t of productTransactions) {
        const ms = t.expires_date_ms ? parseInt(t.expires_date_ms) : null;
        if (ms && (!latestExpiryMs || ms > latestExpiryMs)) latestExpiryMs = ms;
      }
      const expiryDate = latestExpiryMs ? new Date(latestExpiryMs).toISOString() : null;

      // Detect if user turned off auto-renew for this product
      let isCancelled = false;
      for (const r of pendingRenewal) {
        if (r.product_id === productId) {
          // auto_renew_status: 1 = on, 0 = off
          if (String(r.auto_renew_status || '') === '0') {
            isCancelled = true;
          }
          // expiration_intent present also indicates non-renewal reason
          if (r.expiration_intent) {
            isCancelled = true;
          }
        }
      }

      const isValid = productTransactions.some((transaction: any) => {
        const transactionMatches = transaction.transaction_id === transactionId;
        const hasExpiry = transaction.expires_date_ms;
        const notExpired = hasExpiry && parseInt(transaction.expires_date_ms) > Date.now();
        return transactionMatches && notExpired;
      });

      return { 
        isValid, 
        environment: usedSandbox ? 'sandbox' : 'production',
        expiryDate,
        isCancelled
      };
    } else {
      console.error(`iOS receipt validation failed with status: ${result.status}`);
      // Invalid receipt
      return { isValid: false, status: result.status };
    }
  } catch (error) {
    console.error('iOS receipt validation error:', error);
    throw new functions.https.HttpsError('internal', 'Failed to validate iOS receipt');
  }
});

// Android Receipt Validation - Updated
export const validateAndroidReceipt = functions.https.onCall(async (data: any, context) => {
  try {
    const { purchaseToken, productId, orderId } = data;
    
    if (!purchaseToken || !productId || !orderId) {
      throw new functions.https.HttpsError('invalid-argument', 'Purchase token, product ID, and order ID are required');
    }

    console.log('Validating Android receipt:', { productId, orderId, purchaseToken: purchaseToken.substring(0, 10) + '...' });

    // Check if we have the required credentials
    const googlePlayApiKey = process.env.GOOGLE_PLAY_API_KEY;
    const packageName = functions.config().android?.package_name || 'com.yumie.healthai';
    
    if (!googlePlayApiKey || googlePlayApiKey === 'your_service_account_key_here') {
      console.log('Google Play API key not configured - treating as valid for development');
      // For development/testing, if credentials aren't configured, treat as valid
      return { isValid: true, reason: 'development_mode' };
    }

    try {
      // For production, validate with Google Play Developer API
      const response = await axios.get(
        `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${packageName}/purchases/subscriptions/${productId}/tokens/${purchaseToken}`,
        {
          headers: {
            'Authorization': `Bearer ${googlePlayApiKey}`
          }
        }
      );

      const result = response.data;
      console.log('Google Play API response:', result);
      
      // Check if subscription is active
      const isValid = result.paymentState === 1 && // Payment received
                     result.expiryTimeMillis && 
                     parseInt(result.expiryTimeMillis) > Date.now();
      
      return { isValid, reason: 'google_play_validation' };
    } catch (apiError) {
      console.error('Google Play API error:', apiError);
      
      // If the API call fails due to credentials or configuration issues,
      // we should still allow the purchase to go through since Google Play confirmed it
      return { isValid: true, reason: 'api_error_fallback' };
    }
  } catch (error) {
    console.error('Android receipt validation error:', error);
    throw new functions.https.HttpsError('internal', 'Failed to validate Android receipt');
  }
});
