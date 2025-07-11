import 'package:flutter/material.dart';
import 'package:pay/pay.dart';
import 'dart:io';
import 'services/subscription_service.dart';
import 'l10n/app_localizations.dart';
import 'utils/constants.dart';
import 'services/logging_service.dart';
import 'config/payment_config.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  bool _isLoading = true;
  bool _canUseApplePay = false;
  bool _canUseGooglePay = false;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _initializePaymentMethods();
  }

  Future<void> _initializePaymentMethods() async {
    try {
      await _subscriptionService.initialize();
      
      // Check which payment methods are available
      final applePayAvailable = await _subscriptionService.userCanPay(PayProvider.apple_pay);
      final googlePayAvailable = await _subscriptionService.userCanPay(PayProvider.google_pay);
      
      setState(() {
        _canUseApplePay = applePayAvailable;
        _canUseGooglePay = googlePayAvailable;
        _isLoading = false;
      });
    } catch (e) {
      log.error('Failed to initialize payment methods', e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _processPayment(PayProvider provider, String planId) async {
    setState(() {
      _isProcessingPayment = true;
    });

    try {
      await _subscriptionService.processPayment(provider, planId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment processed successfully!'),
            backgroundColor: kPrimaryGreen,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      log.error('Payment failed', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed. Please try again.'),
            backgroundColor: kWarningRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }

  Widget _buildPlanCard(String planId, Map<String, dynamic> plan) {
    final isYearly = planId == 'yearly';
    
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
                  plan['label'],
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
                      'SAVE 17%',
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
              '\$${plan['price']}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              plan['description'],
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            _buildPaymentButtons(planId),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButtons(String planId) {
    return Column(
      children: [
        if (_canUseApplePay && Platform.isIOS)
          ApplePayButton(
            paymentConfiguration: PaymentConfiguration.fromJsonString(
              PaymentConfig.applePayConfig,
            ),
            paymentItems: [
              PaymentItem(
                label: SubscriptionService.subscriptionPlans[planId]!['label'],
                amount: SubscriptionService.subscriptionPlans[planId]!['price'],
                status: PaymentItemStatus.final_price,
              ),
            ],
            style: ApplePayButtonStyle.black,
            type: ApplePayButtonType.buy,
            margin: EdgeInsets.only(bottom: 12),
            onPaymentResult: (result) => _processPayment(PayProvider.apple_pay, planId),
            loadingIndicator: _isProcessingPayment
                ? Center(child: CircularProgressIndicator(color: Colors.white))
                : null,
          ),
        if (_canUseGooglePay && Platform.isAndroid)
          GooglePayButton(
            paymentConfiguration: PaymentConfiguration.fromJsonString(
              PaymentConfig.googlePayConfig,
            ),
            paymentItems: [
              PaymentItem(
                label: SubscriptionService.subscriptionPlans[planId]!['label'],
                amount: SubscriptionService.subscriptionPlans[planId]!['price'],
                status: PaymentItemStatus.final_price,
              ),
            ],
            type: GooglePayButtonType.buy,
            margin: EdgeInsets.only(bottom: 12),
            onPaymentResult: (result) => _processPayment(PayProvider.google_pay, planId),
            loadingIndicator: _isProcessingPayment
                ? Center(child: CircularProgressIndicator(color: Colors.white))
                : null,
          ),
        if (!_canUseApplePay && !_canUseGooglePay)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'No payment methods available',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upgrade to Premium'),
        backgroundColor: kPrimaryGreen,
        foregroundColor: Colors.white,
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
                  _buildPlanCard('monthly', SubscriptionService.subscriptionPlans['monthly']!),
                  _buildPlanCard('yearly', SubscriptionService.subscriptionPlans['yearly']!),
                  
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

  @override
  void dispose() {
    _subscriptionService.dispose();
    super.dispose();
  }
} 