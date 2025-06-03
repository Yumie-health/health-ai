const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');

admin.initializeApp();

// OpenAI API proxy
exports.openaiProxy = functions.https.onCall(async (data, context) => {
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
exports.pexelsProxy = functions.https.onCall(async (data, context) => {
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