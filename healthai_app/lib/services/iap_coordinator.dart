import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'receipt_validation_service.dart';
import 'subscription_service.dart';

/// Global IAP coordinator to automatically reflect entitlements on app start
/// and handle restored purchases without requiring the subscription page.
class IapCoordinator {
  IapCoordinator._internal();
  static final IapCoordinator instance = IapCoordinator._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  bool _initialized = false;
  bool _restoreAttemptedThisSession = false;

  Future<void> initialize(BuildContext context) async {
    if (_initialized) return;
    _initialized = true;

    // Listen globally for purchase updates only to complete pending purchases.
    // Do NOT auto-apply restored entitlements here to avoid cross-account leaks
    // or granting premium without explicit user action.
    _purchaseSub = _iap.purchaseStream.listen((purchases) async {
      for (final purchase in purchases) {
        try {
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
        } catch (_) {
          // best-effort
        }
      }
    });

    // Silent restore disabled to avoid cross-account entitlements. Users can restore manually.
  }

  Future<void> dispose() async {
    await _purchaseSub?.cancel();
    _initialized = false;
  }
}
