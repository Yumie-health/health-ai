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
    secrets: [openaiKey]
  },
  async (req, res) => {
    const openaiKeyValue = openaiKey.value();
    if (!openaiKeyValue) {
      res.status(500).send({ error: 'OpenAI API key not set in secrets.' });
      return;
    }
    console.log('OpenAI key (partial):', openaiKeyValue ? openaiKeyValue.slice(0, 6) + '...' + openaiKeyValue.slice(-6) : 'undefined');
    console.log('Incoming data:', JSON.stringify(req.body));
    try {
      const response = await axios.post(
        "https://api.openai.com/v1/chat/completions",
        req.body,
        {
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${openaiKeyValue}`,
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
  }
);

// Pexels API proxy
export const pexelsProxyCallable = functions.https.onRequest(
  {
    secrets: [pexelsKey]
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
