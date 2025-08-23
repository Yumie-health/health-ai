import 'dart:io';

class AdConfig {
  // Production ad unit IDs (use only after app is published on stores)
  static const String _rewardedAndroid = 'ca-app-pub-6978915708810799/8277465670';
  static const String _rewardedIOS = 'ca-app-pub-6978915708810799/8197574623';

  // Google official test rewarded ad units (required for non-published apps)
  static const String _testRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedIOS = 'ca-app-pub-3940256099942544/1712485313';

  // Set to true for both platforms (app is now published on both stores)
  static bool get _isAppPublished {
    return true;
  }

  static String get rewardedAdUnitId {
    // Use production ads for both platforms (app is now published on both stores)
    if (Platform.isIOS) {
      return _rewardedIOS;
    }
    
    if (Platform.isAndroid) {
      return _rewardedAndroid;
    }
    
    return _rewardedAndroid; // Default to Android ad unit
  }

  static String get testRewardedAdUnitId {
    // Test ad unit IDs for debugging
    if (Platform.isIOS) {
      return _testRewardedIOS;
    }
    
    if (Platform.isAndroid) {
      return _testRewardedAndroid;
    }
    
    return _testRewardedAndroid; // Default to Android test ad unit
  }

  static bool get isUsingTestIds {
    return false; // Both platforms now use production ads
  }
}


