import 'package:firebase_auth/firebase_auth.dart';
import 'rate_limiting_service.dart';
import 'subscription_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Complete logout
  Future<void> logout() async {
    print('User logging out - clearing subscription data');
    
    // Clear rate limiting data on logout to prevent blocking legitimate users
    await RateLimitingService().clearAllRateLimitData();
    
    // Clear subscription data to prevent cross-account access
    final subscriptionService = SubscriptionService();
    await subscriptionService.clearLocalSubscriptionData();
    
    await FirebaseAuth.instance.signOut();
  }
}
