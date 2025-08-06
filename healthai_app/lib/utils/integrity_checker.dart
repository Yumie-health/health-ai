import 'package:flutter/foundation.dart';
import '../services/production_integrity_service.dart';

class IntegrityChecker {

  /// Perform a complete integrity check
  static Future<bool> performIntegrityCheck() async {
    return await ProductionIntegrityService.performIntegrityCheck();
  }

  /// Check integrity before sensitive operations
  static Future<bool> checkBeforeSensitiveOperation() async {
    return await ProductionIntegrityService.checkBeforeSensitiveOperation();
  }

  /// Check integrity before in-app purchases
  static Future<bool> checkBeforePurchase() async {
    return await ProductionIntegrityService.checkBeforePurchase();
  }

  /// Check integrity before accessing premium features
  static Future<bool> checkBeforePremiumAccess() async {
    return await ProductionIntegrityService.checkBeforePremiumAccess();
  }

  /// Check integrity before user authentication
  static Future<bool> checkBeforeAuthentication() async {
    return await ProductionIntegrityService.checkBeforeAuthentication();
  }
}
