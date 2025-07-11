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
  late Stream<List<PurchaseDetails>> _purchaseStream;

  @override
  void initState() {
    super.initState();
    _initializeIAP();
    _purchaseStream = _iap.purchaseStream;
    _purchaseStream.listen(_onPurchaseUpdated);
  }

  Future<void> _initializeIAP() async {
    final bool available = await _iap.isAvailable();
    if (!available) {
      setState(() => _isLoading = false);
      return;
    }
    final ProductDetailsResponse response = await _iap.queryProductDetails(_kProductIds);
    print('Loaded products: ${response.productDetails.map((p) => p.id).toList()}');
    if (response.notFoundIDs.isNotEmpty) {
      print('Not found: ${response.notFoundIDs}');
    }
    // If no products are loaded, use mock data for screenshot
    if (response.productDetails.isEmpty) {
      _products = [
        ProductDetails(
          id: 'premium_monthly',
          title: 'Monthly Premium',
          description: 'No ads',
          price: ' 47.99',
          rawPrice: 7.99,
          currencyCode: 'USD',
        ),
        ProductDetails(
          id: 'premium_yearly',
          title: 'Yearly Premium',
          description: 'No ads (Save 37%)',
          price: ' 449.99',
          rawPrice: 49.99,
          currencyCode: 'USD',
        ),
      ];
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _products = response.productDetails;
        _isLoading = false;
      });
    }
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
        // Unlock premium
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isPremium', true);
        await prefs.setString('subscriptionType', purchase.productID);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Subscription activated!'), backgroundColor: kPrimaryGreen),
          );
          Navigator.of(context).pop();
        }
      } else if (purchase.status == PurchaseStatus.error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Purchase failed. Please try again.'), backgroundColor: kWarningRed),
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
    setState(() => _isProcessingPayment = true);
    final purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _restore() {
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
          ? Center(child: CircularProgressIndicator())
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
} 