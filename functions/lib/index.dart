import 'package:cloud_functions/cloud_functions.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'play_integrity_verification.dart';

// Firebase Functions entry point
void main() {
  // Initialize Firebase Functions
  final functions = FirebaseFunctions.instance;
  
  // Register the Play Integrity verification function
  functions.httpsCallable('verifyPlayIntegrity').call = PlayIntegrityVerification.verifyPlayIntegrity;
}
