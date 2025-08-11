import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class TrackingService {
  TrackingService._();
  static final TrackingService instance = TrackingService._();

  Future<void> requestATTIfNeeded() async {
    if (!Platform.isIOS) return;
    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } catch (_) {
      // Ignore any iOS-specific errors; we still serve NPA ads if tracking is not authorized.
    }
  }
}


