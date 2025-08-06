# Yumie API Documentation

**Version:** 1.0  
**Last Updated:** August 5, 2025

## Table of Contents

1. [Overview](#overview)
2. [Authentication](#authentication)
3. [Base URLs](#base-urls)
4. [AI Service API](#ai-service-api)
5. [User Service API](#user-service-api)
6. [Meal Service API](#meal-service-api)
7. [Subscription Service API](#subscription-service-api)
8. [Pexels Service API](#pexels-service-api)
9. [Error Handling](#error-handling)
10. [Rate Limits](#rate-limits)
11. [SDK Integration](#sdk-integration)

## Overview

The Yumie API provides access to nutrition tracking, AI-powered food recognition, user management, and subscription services. This documentation covers all public endpoints and integration points.

## Authentication

### Firebase Authentication
All API requests require Firebase Authentication. Include the Firebase ID token in the Authorization header:

```
Authorization: Bearer <firebase_id_token>
```

### Getting Firebase Token
```dart
// Flutter/Dart
String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
```

## Base URLs

- **Production:** `https://healthai-0001.firebaseapp.com`
- **Firebase Storage:** `https://healthai-0001.firebasestorage.app`
- **Firebase Functions:** `https://us-central1-healthai-0001.cloudfunctions.net`
- **AI Service:** `https://openaiproxycallable-jlkcfxcyrq-uc.a.run.app`
- **Pexels API:** `https://api.pexels.com/v1`

## AI Service API

### Food Recognition Analysis

**Endpoint:** `POST /analyze-meal`

Analyzes food photos to identify nutritional content and ingredients.

#### Request
```json
{
  "model": "gpt-4o-mini",
  "messages": [
    {
      "role": "system",
      "content": "You are a nutrition AI expert..."
    },
    {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": "Analyze this food image..."
        },
        {
          "type": "image_url",
          "image_url": {
            "url": "data:image/jpeg;base64,<base64_encoded_image>"
          }
        }
      ]
    }
  ],
  "max_tokens": 512,
  "temperature": 0.3
}
```

#### Response
```json
{
  "food_name": "Grilled Chicken Breast",
  "calories": 165,
  "protein": 31,
  "carbs": 0,
  "fat": 3.6,
  "ingredients": ["chicken breast", "olive oil", "herbs"],
  "food_type": "meal"
}
```

### Fridge Analysis

**Endpoint:** `POST /analyze-fridge`

Analyzes fridge photos to identify available food items.

#### Request
```json
{
  "model": "gpt-4o-mini",
  "messages": [
    {
      "role": "system",
      "content": "You are a kitchen assistant AI..."
    },
    {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": "Identify all food items in this fridge image"
        },
        {
          "type": "image_url",
          "image_url": {
            "url": "data:image/jpeg;base64,<base64_encoded_image>"
          }
        }
      ]
    }
  ],
  "max_tokens": 256,
  "temperature": 0.3
}
```

#### Response
```json
[
  "milk",
  "eggs",
  "yogurt",
  "cheese",
  "tomatoes",
  "lettuce"
]
```

### Meal Generation

**Endpoint:** `POST /generate-meal`

Generates meal suggestions based on available ingredients.

#### Request
```json
{
  "ingredients": ["chicken", "rice", "vegetables"],
  "dietary_preferences": ["low-carb", "high-protein"],
  "calorie_target": 500,
  "language": "en"
}
```

#### Response
```json
{
  "meal_name": "Chicken Stir-Fry",
  "ingredients": ["chicken breast", "broccoli", "soy sauce"],
  "instructions": ["Cut chicken into pieces", "Stir-fry vegetables"],
  "nutrition": {
    "calories": 450,
    "protein": 35,
    "carbs": 25,
    "fat": 12
  }
}
```

## User Service API

### Get User Profile

**Endpoint:** `GET /users/{userId}`

Retrieves user profile information.

#### Response
```json
{
  "id": "user123",
  "email": "user@example.com",
  "name": "John Doe",
  "age": 30,
  "height": 175.0,
  "weight": 70.0,
  "dailyCalorieGoal": 2000,
  "proteinGoal": 120,
  "carbsGoal": 250,
  "fatGoal": 70,
  "targetWeight": 65.0,
  "startingWeight": 75.0,
  "createdAt": "2025-01-01T00:00:00Z",
  "lastUpdated": "2025-08-05T12:00:00Z",
  "photoUrl": "https://example.com/photo.jpg",
  "waterIntake": "8 glasses",
  "waterLoggedMl": 2000
}
```

### Update User Profile

**Endpoint:** `PUT /users/{userId}`

Updates user profile information.

#### Request
```json
{
  "name": "John Doe",
  "age": 30,
  "height": 175.0,
  "weight": 70.0,
  "dailyCalorieGoal": 2000,
  "proteinGoal": 120,
  "carbsGoal": 250,
  "fatGoal": 70,
  "targetWeight": 65.0,
  "lastUpdated": "2025-08-05T12:00:00Z"
}
```

### Create Initial Profile

**Endpoint:** `POST /users/{userId}`

Creates initial user profile during onboarding.

#### Request
```json
{
  "email": "user@example.com",
  "name": "John Doe",
  "dailyCalorieGoal": 2000,
  "proteinGoal": 120,
  "carbsGoal": 250,
  "fatGoal": 70,
  "createdAt": "2025-08-05T12:00:00Z",
  "lastUpdated": "2025-08-05T12:00:00Z",
  "photoUrl": "https://example.com/photo.jpg"
}
```

## Meal Service API

### Log Meal

**Endpoint:** `POST /users/{userId}/meals`

Logs a new meal entry.

#### Request
```json
{
  "name": "Grilled Chicken Salad",
  "calories": 350,
  "protein": 25,
  "carbs": 15,
  "fat": 12,
  "ingredients": ["chicken breast", "lettuce", "tomatoes"],
  "mealType": "lunch",
  "date": "2025-08-05",
  "imageUrl": "https://example.com/meal.jpg",
  "notes": "Delicious and healthy!"
}
```

### Get Meal History

**Endpoint:** `GET /users/{userId}/meals`

Retrieves user's meal history with optional filtering.

#### Query Parameters
- `startDate`: Start date for filtering (YYYY-MM-DD)
- `endDate`: End date for filtering (YYYY-MM-DD)
- `mealType`: Filter by meal type (breakfast, lunch, dinner, snack)
- `limit`: Number of meals to return (default: 50)

#### Response
```json
{
  "meals": [
    {
      "id": "meal123",
      "name": "Grilled Chicken Salad",
      "calories": 350,
      "protein": 25,
      "carbs": 15,
      "fat": 12,
      "ingredients": ["chicken breast", "lettuce", "tomatoes"],
      "mealType": "lunch",
      "date": "2025-08-05",
      "imageUrl": "https://example.com/meal.jpg",
      "notes": "Delicious and healthy!",
      "createdAt": "2025-08-05T12:00:00Z"
    }
  ],
  "total": 1,
  "hasMore": false
}
```

### Update Meal

**Endpoint:** `PUT /users/{userId}/meals/{mealId}`

Updates an existing meal entry.

#### Request
```json
{
  "name": "Updated Chicken Salad",
  "calories": 380,
  "protein": 28,
  "carbs": 18,
  "fat": 14,
  "notes": "Added more vegetables"
}
```

### Delete Meal

**Endpoint:** `DELETE /users/{userId}/meals/{mealId}`

Deletes a meal entry.

## Subscription Service API

### Check Subscription Status

**Endpoint:** `GET /users/{userId}/subscription`

Checks user's subscription status.

#### Response
```json
{
  "isPremium": true,
  "subscriptionType": "premium_yearly",
  "purchaseDate": "2025-01-01T00:00:00Z",
  "expiryDate": "2026-01-01T00:00:00Z",
  "autoRenew": true,
  "platform": "ios"
}
```

### Get Subscription Plans

**Endpoint:** `GET /subscription/plans`

Retrieves available subscription plans.

#### Response
```json
{
  "plans": [
    {
      "id": "premium_monthly",
      "title": "Monthly Premium",
      "description": "No ads",
      "price": "$7.99",
      "rawPrice": 7.99,
      "currencyCode": "USD",
      "billingPeriod": "monthly"
    },
    {
      "id": "premium_yearly",
      "title": "Yearly Premium",
      "description": "No ads (Save 37%)",
      "price": "$49.99",
      "rawPrice": 49.99,
      "currencyCode": "USD",
      "billingPeriod": "yearly"
    }
  ]
}
```

### Purchase Subscription

**Endpoint:** `POST /users/{userId}/subscription/purchase`

Initiates subscription purchase (handled by app stores).

#### Request
```json
{
  "productId": "premium_monthly",
  "platform": "ios"
}
```

## Firebase Functions API

### OpenAI Proxy

**Endpoint:** `POST /openaiProxyCallable`

Proxies requests to OpenAI API for AI-powered features.

#### Request
```json
{
  "model": "gpt-4o-mini",
  "messages": [
    {
      "role": "system",
      "content": "You are Yumie, a friendly nutrition coach..."
    },
    {
      "role": "user",
      "content": "User message here"
    }
  ],
  "max_tokens": 1024,
  "temperature": 0.7
}
```

#### Response
```json
{
  "choices": [
    {
      "message": {
        "content": "AI response content"
      }
    }
  ]
}
```

### Pexels Proxy

**Endpoint:** `POST /pexelsProxyCallable`

Proxies requests to Pexels API for food images.

#### Request
```json
{
  "query": "healthy food",
  "per_page": 1
}
```

#### Response
```json
{
  "photos": [
    {
      "id": 123456,
      "url": "https://images.pexels.com/photos/123456/pexels-photo-123456.jpeg",
      "photographer": "John Doe"
    }
  ]
}
```

## Pexels Service API

### Search Food Images

**Endpoint:** `GET /pexels/search`

Searches for food-related images from Pexels.

#### Query Parameters
- `query`: Search term (e.g., "healthy food", "breakfast")
- `per_page`: Number of images per page (default: 15)
- `page`: Page number (default: 1)

#### Response
```json
{
  "photos": [
    {
      "id": 123456,
      "width": 1920,
      "height": 1080,
      "url": "https://images.pexels.com/photos/123456/pexels-photo-123456.jpeg",
      "photographer": "John Doe",
      "photographer_url": "https://www.pexels.com/@johndoe",
      "src": {
        "original": "https://images.pexels.com/photos/123456/pexels-photo-123456.jpeg",
        "large2x": "https://images.pexels.com/photos/123456/pexels-photo-123456.jpeg",
        "large": "https://images.pexels.com/photos/123456/pexels-photo-123456.jpeg",
        "medium": "https://images.pexels.com/photos/123456/pexels-photo-123456.jpeg",
        "small": "https://images.pexels.com/photos/123456/pexels-photo-123456.jpeg",
        "portrait": "https://images.pexels.com/photos/123456/pexels-photo-123456.jpeg",
        "landscape": "https://images.pexels.com/photos/123456/pexels-photo-123456.jpeg",
        "tiny": "https://images.pexels.com/photos/123456/pexels-photo-123456.jpeg"
      }
    }
  ],
  "total_results": 1000,
  "page": 1,
  "per_page": 15,
  "next_page": "https://api.pexels.com/v1/search?query=food&page=2"
}
```

## Error Handling

### Standard Error Response
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": {
      "field": "Additional error details"
    }
  }
}
```

### Common Error Codes
- `AUTHENTICATION_FAILED`: Invalid or expired token
- `PERMISSION_DENIED`: User lacks required permissions
- `RESOURCE_NOT_FOUND`: Requested resource doesn't exist
- `VALIDATION_ERROR`: Invalid request data
- `RATE_LIMIT_EXCEEDED`: Too many requests
- `INTERNAL_ERROR`: Server error

## Rate Limits

- **AI Service:** 50 requests per hour per user (OpenAI API limits)
- **Firebase Functions:** 100 requests per hour per user
- **User Service:** 1000 requests per hour per user
- **Meal Service:** 500 requests per hour per user
- **Pexels Service:** 200 requests per hour per user
- **Firebase Storage:** 1000 uploads per hour per user

Rate limit headers are included in responses:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640995200
```

## SDK Integration

### Flutter/Dart SDK

```dart
// Initialize services
final aiService = AIService();
final userService = UserService();
final mealService = MealService();
final subscriptionService = SubscriptionService();

// Analyze food image
final result = await aiService.analyzeMealImage(imageFile);

// Get user profile
final profile = await userService.getCurrentUserProfile();

// Log meal
await mealService.logMeal(mealData);

// Check subscription
final isPremium = await subscriptionService.isPremiumUser();
```

### Authentication Flow

```dart
// Sign in with Firebase
final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);

// Get ID token for API calls
final token = await userCredential.user?.getIdToken();

// Use token in API requests
final response = await http.get(
  Uri.parse('$baseUrl/users/${user.uid}'),
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  },
);
```

### Error Handling Example

```dart
try {
  final result = await aiService.analyzeMealImage(imageFile);
  // Handle success
} catch (e) {
  if (e is AuthenticationException) {
    // Handle authentication error
  } else if (e is RateLimitException) {
    // Handle rate limit error
  } else {
    // Handle general error
  }
}
```

---

**Contact:** info@maivenx.com  
**Support:** +1 (313) 384-6585 