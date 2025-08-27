
import * as functions from 'firebase-functions';

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
    
    // Define update information
    const updateInfo = {
      latestVersion: "1.0.7",
      latestBuildNumber: 50,
      title: "Update Available",
      description: "A new version of Yumie is available with improvements and bug fixes.",
      isForceUpdate: true,
      releaseNotes: "• Fixed subscription pricing for international users\n• Improved loading states for in-app purchases\n• Enhanced app performance\n• Better error handling",
      published: true // Set to false when update is not yet available in stores
    };

    // You can customize this based on platform or other factors
    res.status(200).json(updateInfo);
  } catch (error) {
    console.error('Error in checkAppUpdate:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

