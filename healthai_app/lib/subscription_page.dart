import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:io';
import 'services/receipt_validation_service.dart';
import 'utils/constants.dart';
import 'subscription_success_page.dart';
import 'l10n/app_localizations.dart';

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
  late Stream<List<PurchaseDetails>> _purchaseStream;

  @override
  void initState() {
    super.initState();
    _initializeIAP();
    _purchaseStream = _iap.purchaseStream;
    _purchaseStream.listen(_onPurchaseUpdated);
  }

  Future<void> _initializeIAP() async {
    try {
      final bool available = await _iap.isAvailable();
      print('IAP Available: $available');
      
      if (!available) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'In-app purchases are not available on this device';
        });
        return;
      }

      final ProductDetailsResponse response = await _iap.queryProductDetails(_kProductIds);
      print('Loaded products: ${response.productDetails.map((p) => '${p.id}: ${p.title} - ${p.price}').toList()}');
      
      if (response.notFoundIDs.isNotEmpty) {
        print('Products not found: ${response.notFoundIDs}');
        print('Make sure these products are configured in Google Play Console and the app is published to internal testing');
        setState(() {
          _errorMessage = 'Subscription products not found. Please ensure the app is published to internal testing.';
        });
      }

      if (response.error != null) {
        print('Error loading products: ${response.error}');
        setState(() {
          _errorMessage = 'Failed to load subscription products. Please try again.';
        });
      }

      // If no products are loaded, use mock data for testing
      if (response.productDetails.isEmpty) {
        print('No products loaded from App Store, using mock data for testing');
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
      print('Error initializing IAP: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to initialize subscription system';
      });
    }
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      print('Purchase status: ${purchase.status} for product: ${purchase.productID}');
      
      if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
        try {
          // Validate receipt with backend
          final isValid = await ReceiptValidationService.validateReceipt(purchase);
          
          if (isValid) {
            // Save validated subscription
            await ReceiptValidationService.saveValidatedSubscription(purchase);
            
            print('Subscription validated and activated: ${purchase.productID}');
            
            if (mounted) {
              // Show beautiful success animation
              SubscriptionSuccessPage.show(
                context,
                purchase.productID,
                onComplete: () {
                  Navigator.of(context).pop(); // Close success animation
                  Navigator.of(context).pop(); // Close subscription page
                },
              );
            }
          } else {
            print('Receipt validation failed for: ${purchase.productID}');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Subscription validation failed. Please try again.'),
                  backgroundColor: kWarningRed,
                  duration: Duration(seconds: 5),
                ),
              );
            }
          }
        } catch (e) {
          print('Error processing subscription: $e');
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
        print('Purchase error: ${purchase.error}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Purchase failed: ${purchase.error?.message ?? 'Unknown error'}'),
              backgroundColor: kWarningRed,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else if (purchase.status == PurchaseStatus.canceled) {
        print('Purchase canceled');
        // Don't show any message when user cancels - they know they canceled
      }
      
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
    setState(() => _isProcessingPayment = false);
  }

  void _buy(ProductDetails product) async {
    print('Attempting to purchase: ${product.id} on ${Platform.isIOS ? 'iOS' : 'Android'}');
    setState(() => _isProcessingPayment = true);
    
    try {
      final purchaseParam = PurchaseParam(productDetails: product);
      
      // Production purchase flow - always use real in-app purchases
      _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      print('Error initiating purchase: $e');
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

  void _restore() {
    print('Restoring purchases...');
    _iap.restorePurchases();
  }

  Widget _buildPlanCard(ProductDetails product) {
    final isYearly = product.id == 'premium_yearly';
    final price = product.id == 'premium_monthly' ? '7.99' : '49.99';
    final description = isYearly ? AppLocalizations.of(context)!.save37 : '';
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
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryGreen,
                  ),
                ),
                if (isYearly)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: kSecondaryBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.save37,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8),
                         Text(
               '\$$price',
               style: TextStyle(
                 fontSize: 32,
                 fontWeight: FontWeight.bold,
                 color: Colors.black87,
               ),
             ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
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
        title: Text(AppLocalizations.of(context)!.upgradeToPremium),
        backgroundColor: kPrimaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.restore),
            tooltip: AppLocalizations.of(context)!.restorePurchases,
            onPressed: _restore,
          ),
        ],
      ),
      body: _isLoading
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
              'Subscription Error',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An unknown error occurred',
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
              child: Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
} 