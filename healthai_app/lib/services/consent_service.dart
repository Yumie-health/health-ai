import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/ad_config.dart';


class ConsentService {
  ConsentService._();
  static final ConsentService instance = ConsentService._();

  bool _consentFlowCompleted = false;
  DebugRegion? _debugRegion; // debug helper
  bool _lastCanRequestAds = false;
  bool _isConsentFormAvailable = false;

  Future<void> initializeAndObtainConsent() async {
    // Request/update consent status using UMP via Google Mobile Ads SDK
    print('ConsentService: Starting consent initialization');

    // Force reset consent info to ensure clean state
    try {
      await ConsentInformation.instance.reset();
      print('ConsentService: Consent info reset successfully');
    } catch (e) {
      print('ConsentService: Error resetting consent info: $e');
      // Handle reset error silently
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
          
          print('ConsentService: Can request ads: $_lastCanRequestAds');
          print('ConsentService: Consent form available: $available');
          
          if (available) {
            print('ConsentService: Loading and showing consent form');
            ConsentForm.loadConsentForm((form) async {
              form.show((_) async {
                _lastCanRequestAds = await ConsentInformation.instance.canRequestAds();
                print('ConsentService: After consent form - can request ads: $_lastCanRequestAds');
                _consentFlowCompleted = true;
                if (!completer.isCompleted) completer.complete();
              });
            }, (error) {
              print('ConsentService: Error loading consent form: $error');
              _consentFlowCompleted = true;
              if (!completer.isCompleted) completer.complete();
            });
          } else {
            print('ConsentService: No consent form available, using non-personalized ads');
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
    
    // Initialize mobile ads
    await _forceTestAdLoad();
  }

  Future<void> _forceTestAdLoad() async {
    try {
      // Use the proper ad unit ID from configuration
      final adUnitId = AdConfig.rewardedAdUnitId;
      
      RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            ad.dispose();
          },
          onAdFailedToLoad: (error) {
            // Expected failure for test device ID logging
          },
        ),
      );
    } catch (e) {
      // Handle exception silently
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
    print('ConsentService: Building ad request - nonPersonalized: $nonPersonalized');
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


