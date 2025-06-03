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

admin.initializeApp();

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// OpenAI API proxy
export const openaiProxyCallable = functions.https.onRequest(async (req, res) => {
  const openaiKey = functions.config().openai.key;
  console.log('OpenAI key (partial):', openaiKey ? openaiKey.slice(0, 6) + '...' + openaiKey.slice(-6) : 'undefined');
  console.log('Incoming data:', JSON.stringify(req.body));
  try {
    const response = await axios.post(
      "https://api.openai.com/v1/chat/completions",
      req.body,
      {
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${openaiKey}`,
        },
      }
    );
    res.status(200).send(response.data);
  } catch (error) {
    if (axios.isAxiosError(error)) {
      console.error("OpenAI API error:", error.response?.data || error.message);
      res.status(500).send({ error: error.response?.data || error.message });
    } else {
      console.error("OpenAI API error:", error);
      res.status(500).send({ error: "Error calling OpenAI API" });
    }
  }
});

// Pexels API proxy
export const pexelsProxyCallable = functions.https.onRequest(async (req, res) => {
  const pexelsKey = functions.config().pexels.key;
  console.log('Pexels key (partial):', pexelsKey ? pexelsKey.slice(0, 6) + '...' + pexelsKey.slice(-6) : 'undefined');
  console.log('Incoming data:', JSON.stringify(req.body));
  try {
    const query = req.body.query;
    const response = await axios.get(
      `https://api.pexels.com/v1/search?query=${encodeURIComponent(query)}&per_page=1`,
      {
        headers: {
          "Authorization": pexelsKey,
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
});
