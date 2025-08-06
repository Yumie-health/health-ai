import 'package:cloud_functions/cloud_functions.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlayIntegrityVerification {
  static const String _baseUrl = 'https://playintegrity.googleapis.com/v1';
  static const String _packageName = 'com.yumie.healthai';

  /// Firebase Cloud Function to verify Play Integrity token
  static Future<Map<String, dynamic>> verifyPlayIntegrity(
    Map<String, dynamic> data,
    FirebaseFunctions functions,
  ) async {
    try {
      final integrityToken = data['integrityToken'] as String?;
      if (integrityToken == null) {
        throw FirebaseFunctionsException(
          'Invalid request: integrityToken is required',
          'INVALID_ARGUMENT',
        );
      }

      // Get the API key from environment variables
      final apiKey = functions.config.get('google_play_api_key');
      if (apiKey == null) {
        throw FirebaseFunctionsException(
          'Google Play API key not configured',
          'INTERNAL',
        );
      }

      // Verify the token with Google's servers
      final response = await http.post(
        Uri.parse('$_baseUrl/$_packageName:decodeIntegrityToken'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'integrityToken': integrityToken,
        }),
      );

      if (response.statusCode != 200) {
        throw FirebaseFunctionsException(
          'Failed to verify integrity token: ${response.statusCode}',
          'INTERNAL',
        );
      }

      final responseData = jsonDecode(response.body);
      final tokenPayload = responseData['tokenPayloadExternal'] as Map<String, dynamic>?;
      
      if (tokenPayload == null) {
        return {
          'isGenuine': false,
          'isInstalledFromGooglePlay': false,
          'error': 'Invalid token payload',
        };
      }

      final appIntegrity = tokenPayload['appIntegrity'] as Map<String, dynamic>?;
      final deviceIntegrity = tokenPayload['deviceIntegrity'] as Map<String, dynamic>?;
      final accountDetails = tokenPayload['accountDetails'] as Map<String, dynamic>?;

      final appRecognitionVerdict = appIntegrity?['appRecognitionVerdict'] as String?;
      final deviceRecognitionVerdict = deviceIntegrity?['deviceRecognitionVerdict'] as String?;
      final appLicensingVerdict = accountDetails?['appLicensingVerdict'] as String?;

      final isGenuine = appRecognitionVerdict == 'PLAY_STORE';
      final isInstalledFromGooglePlay = appRecognitionVerdict == 'PLAY_STORE';

      return {
        'isGenuine': isGenuine,
        'isInstalledFromGooglePlay': isInstalledFromGooglePlay,
        'appIntegrity': appRecognitionVerdict,
        'deviceIntegrity': deviceRecognitionVerdict,
        'accountDetails': appLicensingVerdict,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw FirebaseFunctionsException(
        'Error verifying Play Integrity: $e',
        'INTERNAL',
      );
    }
  }
}
