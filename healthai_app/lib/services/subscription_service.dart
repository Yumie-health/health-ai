import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'logging_service.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  // Check if user has premium subscription
  Future<bool> isPremiumUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isPremium = prefs.getBool('isPremium') ?? false;
      
      if (isPremium) {
        // Check if subscription is still valid (basic validation)
        final purchaseDate = prefs.getString('purchaseDate');
        if (purchaseDate != null) {
          final purchaseDateTime = DateTime.parse(purchaseDate);
          final now = DateTime.now();
          
          // For monthly subscriptions, check if within 30 days
          final subscriptionType = prefs.getString('subscriptionType');
          if (subscriptionType == 'premium_monthly') {
            final daysSincePurchase = now.difference(purchaseDateTime).inDays;
            if (daysSincePurchase > 30) {
              // Subscription might have expired, clear premium status
              await prefs.setBool('isPremium', false);
              return false;
            }
          }
          // For yearly subscriptions, check if within 365 days
          else if (subscriptionType == 'premium_yearly') {
            final daysSincePurchase = now.difference(purchaseDateTime).inDays;
            if (daysSincePurchase > 365) {
              // Subscription might have expired, clear premium status
              await prefs.setBool('isPremium', false);
              return false;
            }
          }
        }
      }
      
      return isPremium;
    } catch (e) {
      print('Error checking premium status: $e');
      return false;
    }
  }

  Future<String?> getSubscriptionType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('subscriptionType');
    } catch (e) {
      print('Error getting subscription type: $e');
      return null;
    }
  }

  Future<DateTime?> getPurchaseDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final purchaseDateString = prefs.getString('purchaseDate');
      if (purchaseDateString != null) {
        return DateTime.parse(purchaseDateString);
      }
      return null;
    } catch (e) {
      print('Error getting purchase date: $e');
      return null;
    }
  }

  Future<void> clearSubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isPremium');
      await prefs.remove('subscriptionType');
      await prefs.remove('purchaseDate');
      print('Subscription data cleared');
    } catch (e) {
      print('Error clearing subscription: $e');
    }
  }

  Future<void> setSubscription(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isPremium', true);
      await prefs.setString('subscriptionType', productId);
      await prefs.setString('purchaseDate', DateTime.now().toIso8601String());
      print('Subscription set: $productId');
    } catch (e) {
      print('Error setting subscription: $e');
    }
  }

  // Get subscription status for debugging
  Future<Map<String, dynamic>> getSubscriptionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'isPremium': prefs.getBool('isPremium') ?? false,
        'subscriptionType': prefs.getString('subscriptionType'),
        'purchaseDate': prefs.getString('purchaseDate'),
      };
    } catch (e) {
      print('Error getting subscription status: $e');
      return {};
    }
  }

  void dispose() {}
} 