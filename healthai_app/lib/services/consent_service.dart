import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


class ConsentService {
  ConsentService._();
  static final ConsentService instance = ConsentService._();

  bool _consentFlowCompleted = false;
  DebugRegion? _debugRegion; // debug helper
  bool _lastCanRequestAds = false;
  bool _isConsentFormAvailable = false;

  Future<void> initializeAndObtainConsent() async {
    // Request/update consent status using UMP via Google Mobile Ads SDK

    debugPrint('Looking for Google Mobile Ads test device ID in logs...');
    
    // Force reset consent info to ensure clean state
    try {
      await ConsentInformation.instance.reset();
      debugPrint('UMP: Consent information reset successfully');
    } catch (e) {
      debugPrint('UMP: Failed to reset consent information: $e');
    }
    
    ConsentRequestParameters params;
    if (kDebugMode && _debugRegion != null && _debugRegion != DebugRegion.none) {
      params = ConsentRequestParameters(
        tagForUnderAgeOfConsent: false,
        consentDebugSettings: ConsentDebugSettings(
          // Current SDK exposes EEA vs NotEEA. Use NotEEA for USA debugging; pair with a US VPN if needed.
          debugGeography: _debugRegion == DebugRegion.eea
              ? DebugGeography.debugGeographyEea
              : DebugGeography.debugGeographyNotEea,
          // Common Android emulator test device IDs for UMP
          testIdentifiers: [
            '33BE2250B43518CCDA7DE426D04EE231', // Generic test ID
            'ABCDEF012345678901234567890ABCDEF', // Another common test ID
            'TEST_DEVICE_ID_FOR_UMP_DEBUGGING',   // UMP placeholder
            // Add your actual device ID when you find it in logs
          ]
        ),
      );
    } else {
      params = ConsentRequestParameters(tagForUnderAgeOfConsent: false);
    }

    final completer = Completer<void>();
    try {
      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () async {
          _lastCanRequestAds = await ConsentInformation.instance.canRequestAds();
          final available = await ConsentInformation.instance.isConsentFormAvailable();
          _isConsentFormAvailable = available;
          
          // Debug logging
          debugPrint('UMP: canRequestAds = $_lastCanRequestAds');
          debugPrint('UMP: isConsentFormAvailable = $available');
          if (available) {
            debugPrint('UMP Consent form is available - loading and showing...');
            ConsentForm.loadConsentForm((form) async {
              debugPrint('UMP Consent form loaded - showing to user...');
              form.show((_) async {
                _lastCanRequestAds = await ConsentInformation.instance.canRequestAds();
                _consentFlowCompleted = true;
                debugPrint('UMP Consent form completed - canRequestAds: $_lastCanRequestAds');
                if (!completer.isCompleted) completer.complete();
              });
            }, (error) {
              debugPrint('UMP Consent form failed to load: $error');
              _consentFlowCompleted = true;
              if (!completer.isCompleted) completer.complete();
            });
          } else {
            debugPrint('UMP Consent form NOT available - no form to show');
            debugPrint('UMP: This might be expected for emulator/debug builds');
            debugPrint('UMP: For production, ensure AdMob console has EEA message published');
            
            // For debugging: assume consent is obtained (non-personalized ads)
            // In production, this should be handled properly through UMP
            _lastCanRequestAds = false; // Force non-personalized ads for safety
            _consentFlowCompleted = true;
            if (!completer.isCompleted) completer.complete();
          }
        },
        (error) {
          _consentFlowCompleted = true;
          if (!completer.isCompleted) completer.complete();
        },
      );
    } catch (_) {
      _consentFlowCompleted = true;
      if (!completer.isCompleted) completer.complete();
    }
    await completer.future;
  }

  Future<void> configureMobileAds() async {
    // Initialize first to trigger device ID logging
    await MobileAds.instance.initialize();
    
    // Then update configuration to force test device ID logs
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        testDeviceIds: [
          'INVALID_DEVICE_ID_TO_FORCE_LOG_OUTPUT',
          'ANOTHER_INVALID_ID_TO_TRIGGER_REAL_ID',
        ],
      ),
    );
    
    // Print debug info
    debugPrint('=== GOOGLE MOBILE ADS INITIALIZED & CONFIGURED ===');
    debugPrint('🔍 LOOKING FOR TEST DEVICE ID IN LOGS...');
    debugPrint('📱 Your actual device test ID should appear in a message like:');
    debugPrint('   "Use RequestConfiguration.Builder().setTestDeviceIds(Arrays.asList(\\"YOUR_DEVICE_ID\\"))"');
    debugPrint('📋 Copy YOUR_DEVICE_ID and replace the placeholder in ConsentService');
    
    // Force load a test ad immediately to trigger test device ID logs
    debugPrint('🎯 Forcing test ad load to trigger device ID logs...');
    await _forceTestAdLoad();
    
    debugPrint('=====================================');
  }

  Future<void> _forceTestAdLoad() async {
    try {
      // Use the test rewarded ad unit ID to force the device ID log
      const testAdUnitId = 'ca-app-pub-6978915708810799/8277465670';
      
      debugPrint('Loading test ad with unit ID: $testAdUnitId');
      
      RewardedAd.load(
        adUnitId: testAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('✅ Test ad loaded successfully! Check logs above for device ID.');
            ad.dispose();
          },
          onAdFailedToLoad: (error) {
            debugPrint('❌ Test ad failed to load: $error');
            debugPrint('   This is expected - check logs above for your device test ID!');
          },
        ),
      );
    } catch (e) {
      debugPrint('Exception during test ad load: $e');
    }
  }

  bool get consentFlowCompleted => _consentFlowCompleted;

  bool get userConsentedPersonalizedAds => _lastCanRequestAds;

  // Analytics is allowed if consent is obtained OR not required in the region
  bool get analyticsAllowed => _lastCanRequestAds;

  // Whether privacy options (consent form) should be shown to users (e.g., UK/EEA/US states)
  bool get isPrivacyOptionsAvailable => _isConsentFormAvailable;



  // Opens the privacy options (consent form) so users can change preferences
  /// Attempts to show the privacy options (consent form). Returns true if shown.
  Future<bool> showPrivacyOptions() async {
    // Refresh consent info first so the SDK can re-evaluate availability
    final refresh = Completer<void>();
    final params = (kDebugMode && _debugRegion != null && _debugRegion != DebugRegion.none)
        ? ConsentRequestParameters(
            tagForUnderAgeOfConsent: false,
            consentDebugSettings: ConsentDebugSettings(
              debugGeography: _debugRegion == DebugRegion.eea
                  ? DebugGeography.debugGeographyEea
                  : DebugGeography.debugGeographyNotEea,
            ),
          )
        : ConsentRequestParameters(tagForUnderAgeOfConsent: false);

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        _lastCanRequestAds = await ConsentInformation.instance.canRequestAds();
        _isConsentFormAvailable = await ConsentInformation.instance.isConsentFormAvailable();
        refresh.complete();
      },
      (error) async {
        _isConsentFormAvailable = await ConsentInformation.instance.isConsentFormAvailable();
        refresh.complete();
      },
    );
    await refresh.future;

    if (!_isConsentFormAvailable) {
      return false;
    }

    final completed = Completer<bool>();
    ConsentForm.loadConsentForm((form) async {
      form.show((_) async {
        _lastCanRequestAds = await ConsentInformation.instance.canRequestAds();
        _isConsentFormAvailable = await ConsentInformation.instance.isConsentFormAvailable();
        if (!completed.isCompleted) completed.complete(true);
      });
    }, (error) async {
      _isConsentFormAvailable = await ConsentInformation.instance.isConsentFormAvailable();
      if (!completed.isCompleted) completed.complete(false);
    });
    return completed.future;
  }

  AdRequest buildAdRequest() {
    final nonPersonalized = !_lastCanRequestAds;
    return AdRequest(
      nonPersonalizedAds: nonPersonalized,
    );
  }

  // Debug setter for region override
  void setDebugRegion(DebugRegion? region) {
    _debugRegion = region;
  }
}

enum DebugRegion { none, eea, usa }


