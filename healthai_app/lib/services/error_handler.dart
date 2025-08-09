import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'logging_service.dart';

class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  // Handle Firebase Auth errors
  String handleAuthError(dynamic error) {
    log.error('Authentication error occurred', error);
    
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email address.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'email-already-in-use':
          return 'An account with this email already exists.';
        case 'weak-password':
          return 'Password is too weak. Please choose a stronger password.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'too-many-requests':
          return 'Too many failed attempts. Please try again later.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support.';
        case 'invalid-credential':
          return 'Invalid credentials. Please check your email and password.';
        case 'account-exists-with-different-credential':
          return 'An account already exists with this email using a different sign-in method.';
        case 'requires-recent-login':
          return 'Please sign out and sign in again to complete this action.';
        default:
          log.error('Unhandled Firebase Auth error code: ${error.code}', error);
          return 'Authentication failed: ${error.message ?? 'Unknown error'}';
      }
    }
    
    return 'An unexpected error occurred. Please try again.';
  }

  // Handle Firestore errors
  String handleFirestoreError(dynamic error) {
    log.error('Firestore error occurred', error);
    
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Access denied. Please check your permissions.';
        case 'unavailable':
          return 'Service temporarily unavailable. Please try again.';
        case 'not-found':
          return 'The requested data was not found.';
        case 'already-exists':
          return 'This data already exists.';
        case 'resource-exhausted':
          return 'Service limit exceeded. Please try again later.';
        case 'failed-precondition':
          return 'Operation failed due to invalid state.';
        case 'aborted':
          return 'Operation was aborted. Please try again.';
        case 'out-of-range':
          return 'Requested data is out of range.';
        case 'unimplemented':
          return 'This feature is not yet implemented.';
        case 'internal':
          return 'Internal server error. Please try again.';
        case 'unavailable':
          return 'Service is currently unavailable.';
        case 'data-loss':
          return 'Data loss occurred. Please try again.';
        case 'unauthenticated':
          return 'Please sign in to continue.';
        default:
          return 'Database error occurred. Please try again.';
      }
    }
    
    return 'An unexpected error occurred. Please try again.';
  }

  // Handle Firebase Storage errors
  String handleStorageError(dynamic error) {
    log.error('Firebase Storage error occurred', error);
    
    if (error is FirebaseException) {
      switch (error.code) {
        case 'object-not-found':
          return 'File not found.';
        case 'bucket-not-found':
          return 'Storage bucket not found.';
        case 'project-not-found':
          return 'Project not found.';
        case 'quota-exceeded':
          return 'Storage quota exceeded.';
        case 'unauthenticated':
          return 'Please sign in to upload files.';
        case 'unauthorized':
          return 'You are not authorized to upload files.';
        case 'retry-limit-exceeded':
          return 'Upload failed. Please try again.';
        case 'invalid-checksum':
          return 'File upload failed due to corruption.';
        case 'download-size-exceeded':
          return 'File is too large to download.';
        case 'invalid-argument':
          return 'Invalid file or path.';
        case 'already-exists':
          return 'File already exists.';
        case 'permission-denied':
          return 'Permission denied for this operation.';
        default:
          return 'File upload failed. Please try again.';
      }
    }
    
    return 'File operation failed. Please try again.';
  }

  // Handle network errors
  String handleNetworkError(dynamic error) {
    log.error('Network error occurred', error);
    
    if (error.toString().contains('SocketException')) {
      return 'No internet connection. Please check your network.';
    }
    
    if (error.toString().contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    }
    
    if (error.toString().contains('HandshakeException')) {
      return 'Secure connection failed. Please try again.';
    }
    
    return 'Network error. Please check your connection and try again.';
  }

  // Handle API errors
  String handleApiError(dynamic error, {String? endpoint}) {
    log.error('API error occurred', error);
    
    if (endpoint != null) {
      log.logApiCall(endpoint, error: error.toString());
    }
    
    if (error.toString().contains('401')) {
      return 'Authentication required. Please sign in again.';
    }
    
    if (error.toString().contains('403')) {
      return 'Access denied. You do not have permission for this action.';
    }
    
    if (error.toString().contains('404')) {
      return 'Requested resource not found.';
    }
    
    if (error.toString().contains('500')) {
      return 'Server error. Please try again later.';
    }
    
    if (error.toString().contains('503')) {
      return 'Service temporarily unavailable. Please try again later.';
    }
    
    return 'API request failed. Please try again.';
  }

  // Handle general errors
  String handleGeneralError(dynamic error, {String? context}) {
    log.error('General error occurred${context != null ? ' in $context' : ''}', error);
    
    if (error is TypeError) {
      return 'Data format error. Please try again.';
    }
    
    if (error is FormatException) {
      return 'Invalid data format. Please try again.';
    }
    
    if (error is RangeError) {
      return 'Value out of range. Please check your input.';
    }
    
    if (error is ArgumentError) {
      return 'Invalid argument provided. Please try again.';
    }
    
    return 'An unexpected error occurred. Please try again.';
  }

  // Show error dialog
  void showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show error snackbar
  void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Handle errors with retry functionality
  Future<T?> handleWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (error) {
        attempts++;
        log.warning('Operation failed, attempt $attempts of $maxRetries', {'error': error.toString()});
        
        if (attempts >= maxRetries) {
          rethrow;
        }
        
        await Future.delayed(delay * attempts);
      }
    }
    
    throw Exception('Operation failed after $maxRetries attempts');
  }
}

// Global error handler instance
final errorHandler = ErrorHandler(); 