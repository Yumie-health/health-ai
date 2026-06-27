import 'package:flutter/material.dart';

enum PasswordStrength { weak, fair, good, strong, veryStrong }

class PasswordStrengthResult {
  final PasswordStrength strength;
  final double score; // 0.0 to 1.0
  final String message;
  final Color color;
  final List<String> suggestions;

  const PasswordStrengthResult({
    required this.strength,
    required this.score,
    required this.message,
    required this.color,
    required this.suggestions,
  });
}

class PasswordStrengthChecker {
  static const int minLength = 8;
  static const int strongLength = 12;

  static PasswordStrengthResult checkStrength(String password) {
    if (password.isEmpty) {
      return const PasswordStrengthResult(
        strength: PasswordStrength.weak,
        score: 0.0,
        message: 'Enter a password',
        color: Colors.grey,
        suggestions: ['Password is required'],
      );
    }

    List<String> suggestions = [];
    double score = 0.0;
    int strengthPoints = 0;

    // Length check
    if (password.length >= minLength) {
      strengthPoints += 1;
      score += 0.2;
    } else {
      suggestions.add('requires_at_least_8_characters');
    }

    if (password.length >= strongLength) {
      strengthPoints += 1;
      score += 0.1;
    }

    // Character variety checks
    bool hasLower = password.contains(RegExp(r'[a-z]'));
    bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (hasLower) {
      strengthPoints += 1;
      score += 0.15;
    } else {
      suggestions.add('add_lowercase_letters');
    }

    if (hasUpper) {
      strengthPoints += 1;
      score += 0.15;
    } else {
      suggestions.add('add_uppercase_letters');
    }

    if (hasDigit) {
      strengthPoints += 1;
      score += 0.15;
    } else {
      suggestions.add('add_numbers');
    }

    if (hasSpecial) {
      strengthPoints += 1;
      score += 0.15;
    } else {
      suggestions.add('add_special_characters');
    }

    // Bonus for longer passwords
    if (password.length > 15) {
      score += 0.1;
      strengthPoints += 1;
    }

    // Penalty for common patterns
    if (_hasCommonPatterns(password)) {
      score -= 0.2;
      suggestions.add('avoid_common_patterns');
    }

    // Ensure score is between 0 and 1
    score = score.clamp(0.0, 1.0);

    // Determine strength level
    PasswordStrength strength;
    String message;
    Color color;

    if (score < 0.3) {
      strength = PasswordStrength.weak;
      message = 'Weak';
      color = Colors.red;
    } else if (score < 0.5) {
      strength = PasswordStrength.fair;
      message = 'Fair';
      color = Colors.orange;
    } else if (score < 0.7) {
      strength = PasswordStrength.good;
      message = 'Good';
      color = Colors.yellow[700]!;
    } else if (score < 0.9) {
      strength = PasswordStrength.strong;
      message = 'Strong';
      color = Colors.lightGreen;
    } else {
      strength = PasswordStrength.veryStrong;
      message = 'Very Strong';
      color = Colors.green;
    }

    // Clear suggestions if password is strong enough
    if (score >= 0.7) {
      suggestions.clear();
    }

    return PasswordStrengthResult(
      strength: strength,
      score: score,
      message: message,
      color: color,
      suggestions: suggestions,
    );
  }

  static bool _hasCommonPatterns(String password) {
    final commonPatterns = [
      RegExp(r'123456'),
      RegExp(r'password', caseSensitive: false),
      RegExp(r'qwerty', caseSensitive: false),
      RegExp(r'abc', caseSensitive: false),
      RegExp(r'(.)\1{2,}'), // Repeated characters like 'aaa'
    ];

    return commonPatterns.any((pattern) => pattern.hasMatch(password));
  }
}
