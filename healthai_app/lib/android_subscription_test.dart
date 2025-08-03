import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:io';
import 'services/subscription_service.dart';
import 'utils/constants.dart';

class AndroidSubscriptionTest extends StatefulWidget {
  const AndroidSubscriptionTest({Key? key}) : super(key: key);

  @override
  State<AndroidSubscriptionTest> createState() => _AndroidSubscriptionTestState();
}

class _AndroidSubscriptionTestState extends State<AndroidSubscriptionTest> {
  final InAppPurchase _iap = InAppPurchase.instance;
  final SubscriptionService _subscriptionService = SubscriptionService();
  List<ProductDetails> _products = [];
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic> _subscriptionStatus = {};

  @override
  void initState() {
    super.initState();
    _initializeTest();
  }

  Future<void> _initializeTest() async {
    setState(() => _isLoading = true);
    
    try {
      // Check if we're on Android
      if (!Platform.isAndroid) {
        setState(() {
          _errorMessage = 'This test is for Android only. Current platform: ${Platform.operatingSystem}';
          _isLoading = false;
        });
        return;
      }

      // Test IAP availability
      final bool available = await _iap.isAvailable();
      print('Android IAP Available: $available');
      
      if (!available) {
        setState(() {
          _errorMessage = 'In-app purchases are not available on this Android device';
          _isLoading = false;
        });
        return;
      }

      // Test product loading
      final Set<String> productIds = {'premium_monthly', 'premium_yearly'};
      final ProductDetailsResponse response = await _iap.queryProductDetails(productIds);
      
      print('Android products loaded: ${response.productDetails.length}');
      print('Products: ${response.productDetails.map((p) => '${p.id}: ${p.title} - ${p.price}').toList()}');
      
      if (response.notFoundIDs.isNotEmpty) {
        print('Android products not found: ${response.notFoundIDs}');
        print('Make sure these products are configured in Google Play Console');
      }

      setState(() {
        _products = response.productDetails;
        _isLoading = false;
      });

      // Load subscription status
      await _loadSubscriptionStatus();
      
    } catch (e) {
      print('Error in Android subscription test: $e');
      setState(() {
        _errorMessage = 'Error testing Android subscriptions: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSubscriptionStatus() async {
    try {
      final status = await _subscriptionService.getSubscriptionStatus();
      setState(() {
        _subscriptionStatus = status;
      });
    } catch (e) {
      print('Error loading subscription status: $e');
    }
  }

  Future<void> _testAndroidPurchase() async {
    if (_products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No products available for testing'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final product = _products.first;
      print('Testing Android purchase for: ${product.id}');
      
      final purchaseParam = PurchaseParam(productDetails: product);
      _iap.buyNonConsumable(purchaseParam: purchaseParam);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Purchase initiated for ${product.title}'),
          backgroundColor: kPrimaryGreen,
        ),
      );
    } catch (e) {
      print('Error testing Android purchase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error testing purchase: $e'),
          backgroundColor: kWarningRed,
        ),
      );
    }
  }

  Future<void> _testAndroidRestore() async {
    try {
      print('Testing Android purchase restoration...');
      _iap.restorePurchases();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Purchase restoration initiated'),
          backgroundColor: kSecondaryBlue,
        ),
      );
    } catch (e) {
      print('Error testing Android restore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error testing restore: $e'),
          backgroundColor: kWarningRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Android Subscription Test'),
        backgroundColor: kPrimaryGreen,
        foregroundColor: Colors.white,
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
                      Text(
                        'Android Subscription Test',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      // Platform info
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Platform Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              _buildInfoRow('Platform', 'Android'),
                              _buildInfoRow('OS Version', Platform.operatingSystemVersion),
                              _buildInfoRow('Products Loaded', _products.length.toString()),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      // Products list
                      if (_products.isNotEmpty) ...[
                        Text(
                          'Available Products:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        ..._products.map((product) => Card(
                          child: ListTile(
                            title: Text(product.title),
                            subtitle: Text('${product.price} - ${product.description}'),
                            trailing: Text(product.id, style: TextStyle(fontSize: 12)),
                          ),
                        )).toList(),
                        SizedBox(height: 16),
                      ],
                      
                      // Subscription status
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Subscription Status',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              _buildStatusRow('Premium User', _subscriptionStatus['isPremium'] ?? false),
                              _buildStatusRow('Subscription Type', _subscriptionStatus['subscriptionType'] ?? 'None'),
                              _buildStatusRow('Purchase Date', _subscriptionStatus['purchaseDate'] ?? 'None'),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      
                      // Test buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _testAndroidPurchase,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryGreen,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text('Test Purchase', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _testAndroidRestore,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kSecondaryBlue,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text('Test Restore', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      
                      // Instructions
                      Text(
                        'Android Testing Instructions:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '1. Ensure you have Google Play Console set up\n'
                        '2. Create subscription products with IDs: premium_monthly, premium_yearly\n'
                        '3. Add your app to internal testing track\n'
                        '4. Use a test Google account on this device\n'
                        '5. Test purchase flow with test account\n'
                        '6. Check console logs for detailed information',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value.toString(),
            style: TextStyle(
              color: value == true ? kPrimaryGreen : (value == false ? Colors.red : Colors.grey),
              fontWeight: FontWeight.w500,
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
              'Android Test Error',
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
                _initializeTest();
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