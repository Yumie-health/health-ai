const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');

admin.initializeApp();

// OpenAI API proxy
exports.openaiProxyCallable = functions.https.onCall({
  memory: '256MiB',
  region: 'us-central1'
}, async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  try {
    const response = await axios.post(
      'https://api.openai.com/v1/chat/completions',
      data.body,
      {
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
        },
      }
    );
    return response.data;
  } catch (error) {
    console.error('OpenAI API error:', error.response?.data || error.message);
    throw new functions.https.HttpsError('internal', 'Error calling OpenAI API');
  }
});

// Pexels API proxy
exports.pexelsProxyCallable = functions.https.onCall({
  memory: '256MiB',
  region: 'us-central1'
}, async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  try {
    const response = await axios.get(
      `https://api.pexels.com/v1/search?query=${encodeURIComponent(data.query)}&per_page=1`,
      {
        headers: {
          'Authorization': process.env.PEXELS_API_KEY,
        },
      }
    );
    return response.data;
  } catch (error) {
    console.error('Pexels API error:', error.response?.data || error.message);
    throw new functions.https.HttpsError('internal', 'Error calling Pexels API');
  }
});

// Play Integrity API verification
exports.verifyPlayIntegrityCallable = functions.https.onCall({
  memory: '256MiB',
  region: 'us-central1'
}, async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  try {
    const { integrityToken } = data;
    
    if (!integrityToken) {
      throw new functions.https.HttpsError('invalid-argument', 'Integrity token is required');
    }

    // Get the API key from environment variables
    const apiKey = process.env.GOOGLE_PLAY_API_KEY;
    if (!apiKey) {
      console.error('Google Play API key not configured');
      throw new functions.https.HttpsError('internal', 'Google Play API key not configured');
    }

    // Verify the token with Google's servers
    const response = await axios.post(
      'https://playintegrity.googleapis.com/v1/com.yumie.healthai:decodeIntegrityToken',
      {
        integrityToken: integrityToken,
      },
      {
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${apiKey}`,
        },
      }
    );

    const responseData = response.data;
    const tokenPayload = responseData.tokenPayloadExternal;
    
    if (!tokenPayload) {
      return {
        isGenuine: false,
        isInstalledFromGooglePlay: false,
        error: 'Invalid token payload',
      };
    }

    const appIntegrity = tokenPayload.appIntegrity || {};
    const deviceIntegrity = tokenPayload.deviceIntegrity || {};
    const accountDetails = tokenPayload.accountDetails || {};

    const appRecognitionVerdict = appIntegrity.appRecognitionVerdict;
    const deviceRecognitionVerdict = deviceIntegrity.deviceRecognitionVerdict;
    const appLicensingVerdict = accountDetails.appLicensingVerdict;

    const isGenuine = appRecognitionVerdict === 'PLAY_STORE';
    const isInstalledFromGooglePlay = appRecognitionVerdict === 'PLAY_STORE';

    console.log('Play Integrity verification result:', {
      isGenuine,
      isInstalledFromGooglePlay,
      appIntegrity: appRecognitionVerdict,
      deviceIntegrity: deviceRecognitionVerdict,
      accountDetails: appLicensingVerdict,
    });

    return {
      isGenuine,
      isInstalledFromGooglePlay,
      appIntegrity: appRecognitionVerdict,
      deviceIntegrity: deviceRecognitionVerdict,
      accountDetails: appLicensingVerdict,
      timestamp: new Date().toISOString(),
    };
  } catch (error) {
    console.error('Play Integrity API error:', error.response?.data || error.message);
    throw new functions.https.HttpsError('internal', 'Error verifying Play Integrity');
  }
}); 