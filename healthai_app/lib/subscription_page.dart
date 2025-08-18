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

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final InAppPurchase _iap = InAppPurchase.instance;
  final Set<String> _kProductIds = {'premium_monthly', 'premium_yearly'};
  List<ProductDetails> _products = [];
  bool _isLoading = true;
  bool _isProcessingPayment = false;
  String? _errorMessage;
  bool _isPremium = false;
  late Stream<List<PurchaseDetails>> _purchaseStream;
  // Restore/purchase coordination
  Timer? _restoreCheckTimer;
  bool _sawRestoredOrPurchased = false;

  Future<void> _openUrl(String url, {String? fallbackError}) async {
    try {
      final uri = Uri.parse(url);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(fallbackError ?? AppLocalizations.of(context)!.unknownErrorOccurred)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(fallbackError ?? AppLocalizations.of(context)!.unknownErrorOccurred)),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkPremiumStatus();
    _initializeIAP();
    _purchaseStream = _iap.purchaseStream;
    _purchaseStream.listen(_onPurchaseUpdated);
  }

  Future<void> _checkPremiumStatus() async {
    try {
      final subscriptionService = SubscriptionService();
      final isPremium = await subscriptionService.isPremiumUser();
      setState(() {
        _isPremium = isPremium;
      });
    } catch (e) {
      // Continue with normal flow if check fails
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

      final ProductDetailsResponse response = await _iap.queryProductDetails(_kProductIds);
      
      if (response.notFoundIDs.isNotEmpty) {
        setState(() {
          _errorMessage = 'Subscription products not found. Please ensure the app is published to internal testing.';
        });
      }

      if (response.error != null) {
        setState(() {
          _errorMessage = 'Failed to load subscription products. Please try again.';
        });
      }

      // If no products are loaded, use mock data for testing
      if (response.productDetails.isEmpty) {
        _products = [
          ProductDetails(
            id: 'premium_monthly',
            title: 'Monthly Premium',
            description: '',
            price: '\$7.99',
            rawPrice: 7.99,
            currencyCode: 'USD',
          ),
          ProductDetails(
            id: 'premium_yearly',
            title: 'Yearly Premium',
            description: 'Save 37%',
            price: '\$49.99',
            rawPrice: 49.99,
            currencyCode: 'USD',
          ),
        ];
      } else {
        _products = response.productDetails;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to initialize subscription system';
      });
    }
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      
      if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
        try {
          _sawRestoredOrPurchased = true;
          _restoreCheckTimer?.cancel();
          // Google Play/App Store has confirmed the purchase - trust it
          
          // Save the subscription immediately
          await ReceiptValidationService.saveValidatedSubscription(purchase);

          // Ensure app state reflects premium immediately and logs analytics
          try {
            await SubscriptionService().setSubscription(purchase.productID);
          } catch (e) {
            // Non-fatal error
          }
          
          // Acknowledge the purchase to Google Play
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          
          if (mounted) {
            if (purchase.status == PurchaseStatus.restored) {
              // Show success animation for restored purchases too!
              SubscriptionSuccessPage.show(
                context,
                purchase.productID,
                onComplete: () {
                  Navigator.of(context).pop(); // Close success animation
                  Navigator.of(context).pop(); // Close subscription page
                },
              );
            } else {
              // Show beautiful success animation for new purchases
              SubscriptionSuccessPage.show(
                context,
                purchase.productID,
                onComplete: () {
                  Navigator.of(context).pop(); // Close success animation
                  Navigator.of(context).pop(); // Close subscription page
                },
              );
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error processing subscription. Please try again.'),
                backgroundColor: kWarningRed,
                duration: Duration(seconds: 5),
              ),
            );
          }
        }
      } else if (purchase.status == PurchaseStatus.error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You cancelled purchase'),
              backgroundColor: kWarningRed,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else if (purchase.status == PurchaseStatus.canceled) {
        // Don't show any message when user cancels - they know they canceled
      }
      
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
    setState(() => _isProcessingPayment = false);
  }

  void _buy(ProductDetails product) async {
    setState(() => _isProcessingPayment = true);
    
    try {
      final purchaseParam = PurchaseParam(productDetails: product);
      
      // Use the correct method for subscriptions
      if (product.id.contains('premium')) {
        // This is a subscription product
        _iap.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        // This is a one-time purchase
        _iap.buyConsumable(purchaseParam: purchaseParam);
      }
    } catch (e) {
      setState(() => _isProcessingPayment = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting purchase: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _restore() async {
    setState(() => _isProcessingPayment = true);
    _sawRestoredOrPurchased = false;
    
    try {
      // Show initial feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.checkingForPurchases),
            backgroundColor: kPrimaryGreen,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      await _iap.restorePurchases();
      
      // Set a timer to check if any purchases were restored
      // Reduced delay to 2 seconds for faster response
      _restoreCheckTimer?.cancel();
      _restoreCheckTimer = Timer(Duration(seconds: 2), () {
        if (mounted) {
          // Check if any purchases were actually restored by looking at the subscription status
          _checkRestoreResult();
        }
      });
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.restoreFailed),
            backgroundColor: kWarningRed,
            duration: Duration(seconds: 4),
          ),
        );
      }
      setState(() => _isProcessingPayment = false);
    }
  }

  void _checkRestoreResult() async {
    try {
      final subscriptionService = SubscriptionService();
      // Force refresh and check subscription status
      final isPremium = await subscriptionService.forceRefreshAndCheck();
      
      if (mounted) {
        if (isPremium || _sawRestoredOrPurchased) {
          // Purchases were restored successfully - this should be handled by _onPurchaseUpdated
          // But if we get here, it means the purchase stream didn't fire, so we'll show a message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.purchasesRestored),
              backgroundColor: kPrimaryGreen,
              duration: Duration(seconds: 3),
            ),
          );
          
          // Close the subscription page after successful restore
          Timer(Duration(seconds: 2), () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        } else {
          // No purchases were found
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.noPurchasesFound),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.restoreFailed),
            backgroundColor: kWarningRed,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }



  Widget _buildPlanCard(ProductDetails product) {
    final isYearly = product.id == 'premium_yearly';
    final price = product.id == 'premium_monthly' ? '7.99' : '49.99';
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
                  product.id == 'premium_monthly' ? AppLocalizations.of(context)!.yumiePremiumMonthly : AppLocalizations.of(context)!.yumiePremiumYearly,
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
                  '\$$price',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  perUnit,
                  style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w600),
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
                onPressed: _isProcessingPayment ? null : () => _buy(product),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isProcessingPayment
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(AppLocalizations.of(context)!.subscribe, style: TextStyle(fontSize: 18, color: Colors.white)),
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
        title: Text(_isPremium ? AppLocalizations.of(context)!.premiumStatus : AppLocalizations.of(context)!.upgradeToPremium),
        backgroundColor: kPrimaryGreen,
        foregroundColor: Colors.white,
        actions: _isPremium ? [] : [
          IconButton(
            icon: Icon(Icons.restore),
            tooltip: AppLocalizations.of(context)!.restorePurchases,
            onPressed: _restore,
          ),
        ],
      ),
      body: _isPremium
          ? _buildPremiumStatusView()
          : _isLoading
              ? Center(child: CircularProgressIndicator(color: kPrimaryGreen))
              : _errorMessage != null
                  ? _buildErrorView()
                  : SingleChildScrollView(
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
                        Icon(
                          Icons.workspace_premium,
                          size: 64,
                          color: Colors.white,
                        ),
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
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
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
                  _buildFeatureItem(Icons.camera_alt, AppLocalizations.of(context)!.unlimitedFoodScans),
                  _buildFeatureItem(Icons.search, AppLocalizations.of(context)!.unlimitedFoodSearches),
                  _buildFeatureItem(Icons.chat, AppLocalizations.of(context)!.unlimitedAICoachMessages),
                  _buildFeatureItem(Icons.insights, AppLocalizations.of(context)!.dailyHealthInsights),
                  _buildFeatureItem(Icons.workspace_premium, AppLocalizations.of(context)!.noAdvertisements),
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
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
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
                          onPressed: () => _openUrl(
                            Platform.isIOS
                                ? 'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'
                                : 'https://yumie.me/terms',
                            fallbackError: AppLocalizations.of(context)!.couldNotOpenTermsOfService,
                          ),
                          child: Text(AppLocalizations.of(context)!.termsOfUseEula),
                        ),
                        TextButton(
                          onPressed: () => _openUrl(
                            'https://yumie.me/privacy',
                            fallbackError: AppLocalizations.of(context)!.couldNotOpenPrivacyPolicy,
                          ),
                          child: Text(AppLocalizations.of(context)!.privacyPolicy),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            color: kPrimaryGreen,
            size: 20,
          ),
          SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
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
                  _buildFeatureItem(Icons.camera_alt, AppLocalizations.of(context)!.unlimitedFoodScans),
                  _buildFeatureItem(Icons.search, AppLocalizations.of(context)!.unlimitedFoodSearches),
                  _buildFeatureItem(Icons.chat, AppLocalizations.of(context)!.unlimitedAICoachMessages),
                  _buildFeatureItem(Icons.insights, AppLocalizations.of(context)!.dailyHealthInsights),
                  _buildFeatureItem(Icons.workspace_premium, AppLocalizations.of(context)!.noAdvertisements),
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: kWarningRed,
            ),
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
              _errorMessage ?? AppLocalizations.of(context)!.unknownErrorOccurred,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(AppLocalizations.of(context)!.retry, style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
} 