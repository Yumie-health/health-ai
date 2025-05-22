import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../main.dart';
class SettingsPage extends StatelessWidget {
  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@healthai.com',
      queryParameters: {
        'subject': 'HealthAI Support',
        'body': 'Hello, I need help with...',
      },
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      throw 'Could not launch email';
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferencesProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ProfileScreen()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Settings')),
        body: ListView(
          children: [
            SwitchListTile(
              title: Text('Dark Mode'),
              subtitle: Text('Enable dark theme'),
              value: prefs.darkMode,
              onChanged: (v) => prefs.setDarkMode(v),
              secondary: Icon(Icons.dark_mode),
            ),
            SwitchListTile(
              title: Text('Use Metric Units'),
              subtitle: Text('kg/cm or lb/ft'),
              value: prefs.useMetric,
              onChanged: (v) => prefs.setUnits(v),
              secondary: Icon(Icons.straighten),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.email),
              title: Text('Contact Support'),
              subtitle: Text('Email us for help'),
              onTap: _launchEmail,
            ),
            // Add more settings options here
          ],
        ),
      ),
    );
  }
} 