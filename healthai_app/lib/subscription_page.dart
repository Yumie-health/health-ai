import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:io';
import 'services/subscription_service.dart';
import 'l10n/app_localizations.dart';
import 'utils/constants.dart';
import 'services/logging_service.dart';
import 'config/payment_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        print('Make sure these products are configured in App Store Connect');
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
            description: 'No ads',
            price: '\$7.99',
            rawPrice: 7.99,
            currencyCode: 'USD',
          ),
          ProductDetails(
            id: 'premium_yearly',
            title: 'Yearly Premium',
            description: 'No ads (Save 37%)',
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
          // Unlock premium
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isPremium', true);
          await prefs.setString('subscriptionType', purchase.productID);
          await prefs.setString('purchaseDate', DateTime.now().toIso8601String());
          
          print('Subscription activated: ${purchase.productID}');
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Subscription activated!'),
                backgroundColor: kPrimaryGreen,
                duration: Duration(seconds: 3),
              ),
            );
            Navigator.of(context).pop();
          }
        } catch (e) {
          print('Error saving subscription: $e');
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Purchase was canceled'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
      
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
    setState(() => _isProcessingPayment = false);
  }

  void _buy(ProductDetails product) {
    print('Attempting to purchase: ${product.id} on ${Platform.isIOS ? 'iOS' : 'Android'}');
    setState(() => _isProcessingPayment = true);
    final purchaseParam = PurchaseParam(productDetails: product);
    
    // The same code works for both iOS and Android
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _restore() {
    print('Restoring purchases...');
    _iap.restorePurchases();
  }

  Widget _buildPlanCard(ProductDetails product) {
    final isYearly = product.id == 'premium_yearly';
    final price = product.id == 'premium_monthly' ? '7.99' : '49.99';
    final description = isYearly ? 'No ads (Save 37%)' : 'No ads';
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
                  product.title,
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
                      'SAVE 37%',
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
              ' 24$price',
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
                    : Text('Subscribe', style: TextStyle(fontSize: 18, color: Colors.white)),
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
        title: Text('Upgrade to Premium'),
        backgroundColor: kPrimaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.restore),
            tooltip: 'Restore Purchases',
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
                          'Unlock Premium Features',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Get unlimited scans and premium nutrition insights',
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
                    'Premium Features:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildFeatureItem(Icons.camera_alt, 'Unlimited Food Scans'),
                  _buildFeatureItem(Icons.analytics, 'Advanced Nutrition Analytics'),
                  _buildFeatureItem(Icons.psychology, 'AI-Powered Meal Suggestions'),
                  _buildFeatureItem(Icons.trending_up, 'Detailed Progress Tracking'),
                  _buildFeatureItem(Icons.notifications, 'Smart Reminders'),
                  SizedBox(height: 24),
                  // Subscription plans
                  Text(
                    'Choose Your Plan:',
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
                    'By subscribing, you agree to our Terms of Service and Privacy Policy. Subscriptions automatically renew unless cancelled.',
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