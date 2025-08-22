import 'package:flutter/material.dart';

class ValidationUtils {
  // Email validation
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    
    // Basic email regex pattern
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  // Age validation (16-120 years)
  static bool isValidAge(int age) {
    return age >= 16 && age <= 120;
  }

  // Weight validation (30-300 kg or 66-660 lbs)
  static bool isValidWeight(double weight, bool isMetric) {
    if (isMetric) {
      return weight >= 30.0 && weight <= 300.0;
    } else {
      return weight >= 66.0 && weight <= 660.0;
    }
  }

  // Height validation (100-250 cm or 3-8 ft)
  static bool isValidHeight(double height, bool isMetric) {
    if (isMetric) {
      return height >= 100.0 && height <= 250.0;
    } else {
      return height >= 36.0 && height <= 96.0; // 3-8 feet in inches
    }
  }

  // Password validation
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  // Name validation
  static String? validateName(String name) {
    if (name.isEmpty) {
      return 'Name is required';
    }
    if (name.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    if (name.length > 25) {
      return 'Name must be 25 characters or less';
    }
    return null;
  }

  // Calorie validation
  static bool isValidCalories(int calories) {
    return calories >= 0 && calories <= 10000;
  }

  // Macro validation (protein, carbs, fat)
  static bool isValidMacro(double macro) {
    return macro >= 0.0 && macro <= 1000.0;
  }

  // Meal name validation
  static String? validateMealName(String name) {
    if (name.isEmpty) {
      return 'Meal name is required';
    }
    if (name.length < 2) {
      return 'Meal name must be at least 2 characters long';
    }
    if (name.length > 100) {
      return 'Meal name must be less than 100 characters';
    }
    return null;
  }

  // Ingredient validation
  static String? validateIngredient(String ingredient) {
    if (ingredient.isEmpty) {
      return 'Ingredient name is required';
    }
    if (ingredient.length < 2) {
      return 'Ingredient name must be at least 2 characters long';
    }
    if (ingredient.length > 50) {
      return 'Ingredient name must be less than 50 characters';
    }
    return null;
  }

  // Form field validation with error message
  static String? validateFormField({
    required String value,
    required String fieldName,
    bool isRequired = true,
    int? minLength,
    int? maxLength,
    String? pattern,
  }) {
    if (isRequired && value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (minLength != null && value.length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }
    
    if (maxLength != null && value.length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }
    
    if (pattern != null && !RegExp(pattern).hasMatch(value)) {
      return '$fieldName format is invalid';
    }
    
    return null;
  }

  // Show validation error in UI
  static void showValidationError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Show success message in UI
  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Validate user profile data
  static Map<String, String?> validateUserProfile({
    required String email,
    required int age,
    required double weight,
    required double height,
    required bool isMetric,
    String? name,
  }) {
    final errors = <String, String?>{};
    
    if (!isValidEmail(email)) {
      errors['email'] = 'Please enter a valid email address';
    }
    
    if (!isValidAge(age)) {
      errors['age'] = 'Age must be between 16 and 120 years';
    }
    
    if (!isValidWeight(weight, isMetric)) {
      errors['weight'] = isMetric 
          ? 'Weight must be between 30 and 300 kg'
          : 'Weight must be between 66 and 660 lbs';
    }
    
    if (!isValidHeight(height, isMetric)) {
      errors['height'] = isMetric 
          ? 'Height must be between 100 and 250 cm'
          : 'Height must be between 3 and 8 feet';
    }
    
    if (name != null && name.isNotEmpty) {
      final nameError = validateName(name);
      if (nameError != null) {
        errors['name'] = nameError;
      }
    }
    
    return errors;
  }
} 