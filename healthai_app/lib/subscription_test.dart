import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'services/subscription_service.dart';
import 'utils/constants.dart';

class SubscriptionTest extends StatefulWidget {
  const SubscriptionTest({Key? key}) : super(key: key);

  @override
  State<SubscriptionTest> createState() => _SubscriptionTestState();
}

class _SubscriptionTestState extends State<SubscriptionTest> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  Map<String, dynamic> _subscriptionStatus = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionStatus();
  }

  Future<void> _loadSubscriptionStatus() async {
    setState(() => _isLoading = true);
    
    try {
      final status = await _subscriptionService.getSubscriptionStatus();
      setState(() {
        _subscriptionStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading subscription status: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testSubscription() async {
    try {
      await _subscriptionService.setSubscription('premium_monthly');
      await _loadSubscriptionStatus();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test subscription set successfully'),
            backgroundColor: kPrimaryGreen,
          ),
        );
      }
    } catch (e) {
      print('Error setting test subscription: $e');
    }
  }

  Future<void> _clearSubscription() async {
    try {
      await _subscriptionService.clearSubscription();
      await _loadSubscriptionStatus();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Subscription cleared'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Error clearing subscription: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscription Test'),
        backgroundColor: kPrimaryGreen,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: kPrimaryGreen))
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subscription Status',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusRow('Premium User', _subscriptionStatus['isPremium'] ?? false),
                          _buildStatusRow('Subscription Type', _subscriptionStatus['subscriptionType'] ?? 'None'),
                          _buildStatusRow('Purchase Date', _subscriptionStatus['purchaseDate'] ?? 'None'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _testSubscription,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text('Set Test Subscription', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _clearSubscription,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text('Clear Subscription', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Apple Subscription Test',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This test page helps verify that:\n'
                    '• Subscription service is working\n'
                    '• Local storage is functioning\n'
                    '• Status updates are working\n'
                    '• Apple IAP integration is ready',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusRow(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
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
} 