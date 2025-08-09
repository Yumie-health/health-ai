import 'package:firebase_auth/firebase_auth.dart';
import 'rate_limiting_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();



  // Complete logout
  Future<void> logout() async {
    // Clear rate limiting data on logout to prevent blocking legitimate users
    await RateLimitingService().clearAllRateLimitData();
    await FirebaseAuth.instance.signOut();
  }
}
