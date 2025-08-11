import 'dart:io';

class AdConfig {
  // Production ad unit IDs (use only after app is published on stores)
  static const String _rewardedAndroid = 'ca-app-pub-6978915708810799/8277465670';
  static const String _rewardedIOS = 'ca-app-pub-6978915708810799/8197574623';

  // Google official test rewarded ad units (required for non-published apps)
  static const String _testRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedIOS = 'ca-app-pub-3940256099942544/1712485313';

  // Set to true when app is published on stores
  static const bool _isAppPublished = false;

  static String get rewardedAdUnitId {
    // Use test ads until app is published on stores (Google policy requirement)
    if (!_isAppPublished) {
      if (Platform.isAndroid) {
        return _testRewardedAndroid;
      }
      if (Platform.isIOS) {
        return _testRewardedIOS;
      }
      return _testRewardedAndroid; // Default to Android test ad unit
    }
    
    // Use production ads only after app is published
    if (Platform.isAndroid) {
      return _rewardedAndroid;
    }
    if (Platform.isIOS) {
      return _rewardedIOS;
    }
    return _rewardedAndroid; // Default to Android ad unit
  }

  static bool get isUsingTestIds {
    return !_isAppPublished || 
           (Platform.isAndroid && (rewardedAdUnitId == _testRewardedAndroid)) ||
           (Platform.isIOS && (rewardedAdUnitId == _testRewardedIOS));
  }
}


