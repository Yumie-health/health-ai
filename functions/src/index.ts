
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
      latestVersion: "1.0.5",
      latestBuildNumber: 35,
      title: "Update Available",
      description: "A new version of Yumie is available with bug fixes and improvements.",
      isForceUpdate: false,
      releaseNotes: "• Fixed weight logging bug\n• Improved app performance\n• Enhanced user interface\n• Better error handling",
      published: true // Set to false when update is not yet available in stores
    };

    // You can customize this based on platform or other factors
    res.status(200).json(updateInfo);
  } catch (error) {
    console.error('Error in checkAppUpdate:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

