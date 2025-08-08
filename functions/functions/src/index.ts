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

admin.initializeApp();

// Define secrets
const openaiKey = defineSecret("OPENAI_KEY");
const pexelsKey = defineSecret("PEXELS_KEY");

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// OpenAI API proxy
export const openaiProxyCallable = functions.https.onRequest(
  {
    secrets: [openaiKey],
    cors: true,
    invoker: 'public'
  },
  async (req, res) => {
    // Handle CORS preflight
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    res.set('Access-Control-Max-Age', '3600');

    if (req.method === 'OPTIONS') {
      res.status(204).send('');
      return;
    }

    // Only allow POST requests
    if (req.method !== 'POST') {
      res.status(405).send({ error: 'Method not allowed. Use POST.' });
      return;
    }

    const openaiKeyValue = openaiKey.value();
    if (!openaiKeyValue) {
      res.status(500).send({ error: 'OpenAI API key not set in secrets.' });
      return;
    }
    
    console.log('OpenAI key configured:', openaiKeyValue ? 'Yes' : 'No');
    console.log('Request method:', req.method);
    console.log('Request headers:', JSON.stringify(req.headers));
    console.log('Incoming data:', JSON.stringify(req.body));
    
    // Validate request body
    if (!req.body || !req.body.model || !req.body.messages) {
      res.status(400).send({ 
        error: 'Invalid request body. Required fields: model, messages',
        received: req.body 
      });
      return;
    }

    try {
      // Clean the request body - only send valid OpenAI fields
      const cleanBody = {
        model: req.body.model,
        messages: req.body.messages,
        max_tokens: req.body.max_tokens,
        temperature: req.body.temperature,
        stream: req.body.stream,
        stop: req.body.stop,
        presence_penalty: req.body.presence_penalty,
        frequency_penalty: req.body.frequency_penalty,
        logit_bias: req.body.logit_bias,
        user: req.body.user
      };
      
      // Remove undefined fields
      Object.keys(cleanBody).forEach(key => {
        if ((cleanBody as any)[key] === undefined) {
          delete (cleanBody as any)[key];
        }
      });
      
      console.log('Sending clean request to OpenAI:', JSON.stringify(cleanBody, null, 2));
      
      const response = await axios.post(
        "https://api.openai.com/v1/chat/completions",
        cleanBody,
        {
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${openaiKeyValue}`,
          },
          timeout: 30000, // 30 second timeout
        }
      );
      
      console.log('OpenAI response status:', response.status);
      res.status(200).send(response.data);
    } catch (error) {
      console.error("OpenAI API error details:", error);
      
      if (axios.isAxiosError(error)) {
        const statusCode = error.response?.status || 500;
        const errorData = error.response?.data || { message: error.message };
        
        console.error("OpenAI API error response:", {
          status: statusCode,
          data: errorData,
          config: {
            url: error.config?.url,
            method: error.config?.method,
            headers: error.config?.headers
          }
        });
        
        res.status(statusCode).send({ 
          error: errorData,
          details: `OpenAI API request failed with status ${statusCode}`
        });
      } else {
        console.error("Non-axios error:", error);
        res.status(500).send({ error: "Internal server error while calling OpenAI API" });
      }
    }
  }
);

// Pexels API proxy
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

// iOS Receipt Validation - Updated
export const validateIOSReceipt = functions.https.onCall(async (data: any, context) => {
  try {
    const { receiptData, productId, transactionId } = data;
    
    if (!receiptData || !productId || !transactionId) {
      throw new functions.https.HttpsError('invalid-argument', 'Receipt data, product ID, and transaction ID are required');
    }

    // For production, you should validate with Apple's servers
    // This is a simplified validation for demo purposes
    const response = await axios.post(
      'https://buy.itunes.apple.com/verifyReceipt',
      {
        'receipt-data': receiptData,
                 'password': functions.config().apple?.shared_secret || 'your_shared_secret_here',
        'exclude-old-transactions': true
      }
    );

    const result = response.data;
    
    if (result.status === 0) {
      // Valid receipt
      const latestReceiptInfo = result.latest_receipt_info;
      const isValid = latestReceiptInfo.some((transaction: any) => 
        transaction.product_id === productId && 
        transaction.transaction_id === transactionId &&
        transaction.expires_date_ms && 
        parseInt(transaction.expires_date_ms) > Date.now()
      );
      
      return { isValid };
    } else {
      // Invalid receipt
      return { isValid: false };
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

    // For production, you should validate with Google Play Developer API
    // This is a simplified validation for demo purposes
    const response = await axios.get(
              `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${functions.config().android?.package_name || 'com.yumie.healthai'}/purchases/subscriptions/${productId}/tokens/${purchaseToken}`,
      {
        headers: {
          'Authorization': `Bearer ${process.env.GOOGLE_PLAY_API_KEY || 'your_service_account_key_here'}`
        }
      }
    );

    const result = response.data;
    
    // Check if subscription is active
    const isValid = result.paymentState === 1 && // Payment received
                   result.expiryTimeMillis && 
                   parseInt(result.expiryTimeMillis) > Date.now();
    
    return { isValid };
  } catch (error) {
    console.error('Android receipt validation error:', error);
    throw new functions.https.HttpsError('internal', 'Failed to validate Android receipt');
  }
});
