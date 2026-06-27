import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:io';
import 'dart:async';
import 'services/receipt_validation_service.dart';
import 'services/subscription_service.dart';
import 'utils/constants.dart';
import 'subscription_success_page.dart';
import 'l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage>
    with WidgetsBindingObserver {
  final InAppPurchase _iap = InAppPurchase.instance;
  final Set<String> _kProductIds = {'premium_monthly', 'premium_yearly'};
  List<ProductDetails> _products = [];
  bool _isLoading = true;
  bool _isProcessingPayment = false;
  String? _errorMessage;
  bool _isPremium = false;

  // Stream management
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  // State management
  bool _isInitialized = false;
  Set<String> _pendingPurchases = {};

  // User interaction tracking
  String? _selectedProductId;
  bool _userInitiatedRestore = false;
  Timer? _purchaseTimeoutTimer;

  bool _isUserCancelledError(Object error) {
    final msg = error.toString().toLowerCase();
    return msg.contains('storekit2_purchase_cancelled') ||
        msg.contains('authorizationcanceled') ||
        msg.contains('user canceled') ||
        msg.contains('user cancelled') ||
        msg.contains('purchase_cancelled') ||
        msg.contains('purchase canceled') ||
        msg.contains('canceled') ||
        msg.contains('cancelled');
  }

  Future<void> _openUrl(String url, {String? fallbackError}) async {
    try {
      final uri = Uri.parse(url);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              fallbackError ??
                  AppLocalizations.of(context)!.unknownErrorOccurred,
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              fallbackError ??
                  AppLocalizations.of(context)!.unknownErrorOccurred,
            ),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  Future<void> _initialize() async {
    await _checkPremiumStatus();
    await _initializeIAP();

    // Set up purchase stream listener AFTER initialization
    _purchaseSubscription = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onError: (error) {
        print('Purchase stream error: $error');
        if (mounted && _isProcessingPayment) {
          setState(() => _isProcessingPayment = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Purchase error. Please try again.'),
              backgroundColor: kWarningRed,
            ),
          );
        }
      },
    );

    setState(() => _isInitialized = true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Handle app returning from background during purchase
    if (state == AppLifecycleState.resumed &&
        _isProcessingPayment &&
        _selectedProductId != null) {
      // Don't show cancelled message - let the purchase stream handle the result
      // The purchase could be successful, restored, or cancelled
      print('App resumed while processing payment');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _purchaseSubscription?.cancel();
    _purchaseTimeoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkPremiumStatus() async {
    try {
      final subscriptionService = SubscriptionService();
      final isPremium = await subscriptionService.isPremiumUser();
      if (mounted) {
        setState(() => _isPremium = isPremium);
      }
    } catch (e) {
      print('Error checking premium status: $e');
    }
  }

  Future<void> _initializeIAP() async {
    try {
      final bool available = await _iap.isAvailable();

      if (!available) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'In-app purchases are not available on this device';
        });
        return;
      }

      // Query products
      final ProductDetailsResponse response = await _iap.queryProductDetails(
        _kProductIds,
      );

      if (response.error != null) {
        print('Product query error: ${response.error}');
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Failed to load subscription products. Please try again.';
        });
        return;
      }

      if (response.productDetails.isEmpty) {
        print('No products found');
        setState(() {
          _isLoading = false;
          _errorMessage =
              Platform.isIOS
                  ? 'Subscription products not available. Please ensure the app is properly configured.'
                  : 'Subscription products not available.';
        });
        return;
      }

      setState(() {
        _products = response.productDetails;
        _isLoading = false;
      });

      print('Loaded ${_products.length} products');
    } catch (e) {
      print('IAP initialization error: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to initialize purchases: ${e.toString()}';
      });
    }
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    if (!_isInitialized) return; // Ignore events during initialization

    for (final purchase in purchases) {
      print('Purchase update: ${purchase.productID} - ${purchase.status}');
      print(
        '_isProcessingPayment: $_isProcessingPayment, _selectedProductId: $_selectedProductId',
      );

      // Track pending purchases
      if (purchase.status == PurchaseStatus.pending) {
        _pendingPurchases.add(purchase.productID);
        continue;
      }

      // Remove from pending when resolved
      _pendingPurchases.remove(purchase.productID);

      switch (purchase.status) {
        case PurchaseStatus.purchased:
          await _handlePurchaseSuccess(purchase);
          break;

        case PurchaseStatus.restored:
          if (_userInitiatedRestore) {
            await _handleRestoreSuccess(purchase);
          } else if (_isProcessingPayment) {
            // This is a restored purchase that came from a buy attempt
            print(
              'Purchase attempt returned restored status - BLOCKING automatic restore',
            );
            // DO NOT grant premium for automatic restores to prevent cross-account access
            if (purchase.pendingCompletePurchase) {
              await _iap.completePurchase(purchase);
            }
          } else {
            // Automatic restore (not user-initiated) - just complete it but don't grant premium
            print(
              '⚠️ AUTOMATIC RESTORE BLOCKED - preventing cross-account premium access',
            );
            if (purchase.pendingCompletePurchase) {
              await _iap.completePurchase(purchase);
            }
          }
          break;

        case PurchaseStatus.error:
        case PurchaseStatus.canceled:
          await _handlePurchaseError(purchase);
          break;

        default:
          break;
      }
    }
  }

  Future<void> _handlePurchaseSuccess(
    PurchaseDetails purchase, {
    bool isFromRestore = false,
  }) async {
    try {
      // Cancel timeout timer since purchase succeeded
      _purchaseTimeoutTimer?.cancel();

      // Validate receipt if on iOS
      if (Platform.isIOS) {
        final isValid = await ReceiptValidationService.validateReceipt(
          purchase,
        );
        if (!isValid) {
          print('Receipt validation failed but allowing purchase to proceed');
        }
      }

      // Save subscription - passing isRestore flag to prevent cross-account issues
      await ReceiptValidationService.saveValidatedSubscription(
        purchase,
        isRestore: isFromRestore,
      );

      // Complete purchase
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }

      // Update UI
      setState(() {
        _isProcessingPayment = false;
        _selectedProductId = null;
      });

      // Show success ONLY for actual purchases, not restores
      if (mounted && !isFromRestore) {
        SubscriptionSuccessPage.show(
          context,
          purchase.productID,
          onComplete: () {
            Navigator.of(context).pop(); // Close success
            Navigator.of(context).pop(); // Close subscription page
          },
        );
      } else if (mounted && isFromRestore) {
        // For blocked restores, show appropriate message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot restore purchases from a different account'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Error handling purchase success: $e');
      setState(() => _isProcessingPayment = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing purchase. Please contact support.'),
            backgroundColor: kWarningRed,
          ),
        );
      }
    }
  }

  Future<void> _handleRestoreSuccess(PurchaseDetails purchase) async {
    try {
      // CRITICAL: Pass isRestore=true to prevent cross-account premium access
      await ReceiptValidationService.saveValidatedSubscription(
        purchase,
        isRestore: true,
      );

      // Complete purchase
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }

      // Check if premium was actually restored
      await _checkPremiumStatus();

      // Since restore is now blocked, show appropriate message
      if (mounted) {
        setState(() => _isProcessingPayment = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cannot restore purchases from a different account. Please use the account that originally purchased.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('Error handling restore: $e');
    }
  }

  Future<void> _handlePurchaseError(PurchaseDetails purchase) async {
    // Cancel timeout timer
    _purchaseTimeoutTimer?.cancel();

    // Complete the purchase to clear it
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }

    setState(() {
      _isProcessingPayment = false;
      _selectedProductId = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Purchase cancelled'),
          backgroundColor: kWarningRed,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _buy(ProductDetails product) async {
    setState(() {
      _isProcessingPayment = true;
      _selectedProductId = product.id;
    });

    // Cancel any existing timer
    _purchaseTimeoutTimer?.cancel();

    // Set a timeout to stop spinning if nothing happens
    _purchaseTimeoutTimer = Timer(Duration(seconds: 30), () {
      if (_isProcessingPayment && mounted) {
        setState(() {
          _isProcessingPayment = false;
          _selectedProductId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase timed out. Please try again.'),
            backgroundColor: kWarningRed,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });

    try {
      // For iOS: First clear ALL pending transactions
      if (Platform.isIOS) {
        print('Clearing pending transactions before purchase...');

        // Create a temporary subscription to drain the queue
        final tempSub = _iap.purchaseStream.listen((purchases) {
          for (final purchase in purchases) {
            if (purchase.pendingCompletePurchase) {
              _iap.completePurchase(purchase);
            }
          }
        });

        // Give it a moment to process
        await Future.delayed(Duration(milliseconds: 500));
        tempSub.cancel();
      }

      print('Attempting to purchase: ${product.id}');
      final purchaseParam = PurchaseParam(productDetails: product);

      // For subscriptions, use buyNonConsumable
      final result = await _iap.buyNonConsumable(purchaseParam: purchaseParam);

      print('Purchase initiation result: $result');

      if (!result) {
        // Purchase initiation failed
        setState(() {
          _isProcessingPayment = false;
          _selectedProductId = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unable to start purchase. Please try again.'),
              backgroundColor: kWarningRed,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
      // If result is true, wait for purchase update callback
    } catch (e) {
      print('Purchase error: $e');
      setState(() {
        _isProcessingPayment = false;
        _selectedProductId = null;
      });
      if (!mounted) return;
      final friendly =
          _isUserCancelledError(e)
              ? 'Purchase cancelled'
              : 'Purchase error. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendly), backgroundColor: kWarningRed),
      );
    }
  }

  void _restore() async {
    setState(() {
      _isProcessingPayment = true;
      _userInitiatedRestore = true;
    });

    try {
      await _iap.restorePurchases();

      // Wait for restore to complete
      Future.delayed(Duration(seconds: 3), () async {
        if (mounted) {
          // Check if we're premium now
          await _checkPremiumStatus();

          setState(() {
            _isProcessingPayment = false;
            _userInitiatedRestore = false;
          });

          if (!_isPremium) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.noPurchasesFound),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      });
    } catch (e) {
      print('Restore error: $e');
      setState(() {
        _isProcessingPayment = false;
        _userInitiatedRestore = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.restoreFailed),
            backgroundColor: kWarningRed,
          ),
        );
      }
    }
  }

  Widget _buildPlanCard(ProductDetails product) {
    final isYearly = product.id == 'premium_yearly';
    // Use actual product price instead of hardcoded values
    final price = product.price;
    final lengthLabel = isYearly ? '1 year' : '1 month';
    final perUnit = isYearly ? '/year' : '/month';

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: kPrimaryGreen, width: 2),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  product.id == 'premium_monthly'
                      ? AppLocalizations.of(context)!.yumiePremiumMonthly
                      : AppLocalizations.of(context)!.yumiePremiumYearly,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryGreen,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  perUnit,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Subscription length: $lengthLabel',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (_isProcessingPayment || _selectedProductId == product.id)
                        ? null
                        : () => _buy(product),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    (_isProcessingPayment && _selectedProductId == product.id)
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                          AppLocalizations.of(context)!.subscribe,
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isPremium
              ? AppLocalizations.of(context)!.premiumStatus
              : AppLocalizations.of(context)!.upgradeToPremium,
        ),
        backgroundColor: kPrimaryGreen,
        foregroundColor: Colors.white,
        actions: [
          if (!_isPremium && !_isLoading)
            IconButton(
              icon: Icon(Icons.restore),
              tooltip: AppLocalizations.of(context)!.restorePurchases,
              onPressed: _isProcessingPayment ? null : _restore,
            ),
        ],
      ),
      body:
          _isPremium
              ? _buildPremiumStatusView()
              : _isLoading
              ? Center(child: CircularProgressIndicator(color: kPrimaryGreen))
              : _errorMessage != null
              ? _buildErrorView()
              : _buildSubscriptionOptions(),
    );
  }

  Widget _buildSubscriptionOptions() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimaryGreen, kSecondaryBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.workspace_premium, size: 64, color: Colors.white),
                SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.unlockPremiumFeatures,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.upgradeDescription,
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          // Features list
          Text(
            '${AppLocalizations.of(context)!.premiumFeatures}:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          _buildFeatureItem(
            Icons.camera_alt,
            AppLocalizations.of(context)!.unlimitedFoodScans,
          ),
          _buildFeatureItem(
            Icons.search,
            AppLocalizations.of(context)!.unlimitedFoodSearches,
          ),
          _buildFeatureItem(
            Icons.chat,
            AppLocalizations.of(context)!.unlimitedAICoachMessages,
          ),
          _buildFeatureItem(
            Icons.insights,
            AppLocalizations.of(context)!.dailyHealthInsights,
          ),
          _buildFeatureItem(
            Icons.workspace_premium,
            AppLocalizations.of(context)!.noAdvertisements,
          ),
          SizedBox(height: 24),
          // Subscription plans
          Text(
            '${AppLocalizations.of(context)!.chooseYourPlan}:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          ..._products.map(_buildPlanCard).toList(),
          SizedBox(height: 24),
          // Terms and conditions
          Text(
            AppLocalizations.of(context)!.bySubscribing,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 4,
              children: [
                TextButton(
                  onPressed:
                      () => _openUrl(
                        Platform.isIOS
                            ? 'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'
                            : 'https://yumie.me/terms',
                        fallbackError:
                            AppLocalizations.of(
                              context,
                            )!.couldNotOpenTermsOfService,
                      ),
                  child: Text(AppLocalizations.of(context)!.termsOfUseEula),
                ),
                TextButton(
                  onPressed:
                      () => _openUrl(
                        'https://yumie.me/privacy',
                        fallbackError:
                            AppLocalizations.of(
                              context,
                            )!.couldNotOpenPrivacyPolicy,
                      ),
                  child: Text(AppLocalizations.of(context)!.privacyPolicy),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: kPrimaryGreen, size: 20),
          SizedBox(width: 12),
          Text(text, style: TextStyle(fontSize: 16, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildPremiumStatusView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kPrimaryGreen, kSecondaryBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.workspace_premium,
                size: 60,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 32),
            Text(
              AppLocalizations.of(context)!.youArePremium,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.thankYouForSupport,
              style: TextStyle(
                fontSize: 18,
                color: kPrimaryGreen,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kPrimaryGreen.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.yourPremiumFeatures,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildFeatureItem(
                    Icons.camera_alt,
                    AppLocalizations.of(context)!.unlimitedFoodScans,
                  ),
                  _buildFeatureItem(
                    Icons.search,
                    AppLocalizations.of(context)!.unlimitedFoodSearches,
                  ),
                  _buildFeatureItem(
                    Icons.chat,
                    AppLocalizations.of(context)!.unlimitedAICoachMessages,
                  ),
                  _buildFeatureItem(
                    Icons.insights,
                    AppLocalizations.of(context)!.dailyHealthInsights,
                  ),
                  _buildFeatureItem(
                    Icons.workspace_premium,
                    AppLocalizations.of(context)!.noAdvertisements,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: kWarningRed),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.subscriptionError,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage ??
                  AppLocalizations.of(context)!.unknownErrorOccurred,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _initializeIAP();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                AppLocalizations.of(context)!.retry,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
