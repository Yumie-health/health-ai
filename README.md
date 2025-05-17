Product Requirements Document (PRD)
Product Name: HealthAI
Version: 1.0.0
Date: 5/16/2025
Owner: Ali Abbas / Fadi Abbas

1. Purpose
HealthAI is a mobile app designed to help users track their daily calorie intake, log meals, receive smart food suggestions, and monitor their nutrition and health progress. The app leverages photo-based food detection and AI insights to make healthy eating easy and engaging.
2. Target Audience
Health-conscious individuals
Fitness enthusiasts
People tracking calories/macros
Users interested in smart, AI-driven nutrition suggestions

3. Core Features
3.1. Authentication
Email/password sign up and sign in
User profile creation and management
Secure sign out
3.2. Dashboard (Home)
Daily summary: calories consumed, activity, remaining calories
Progress bars for daily goal, protein, and carbs
AI-generated nutrition insights
List of today’s meals with calories
“Add Meal” button
3.3. Scan
Camera interface for food photo detection
Option to upload a food photo
Scanning tips for best results
Placeholder for future AI food recognition integration
3.4. Log
Searchable and filterable food log
Meals grouped by time (Breakfast, Lunch, Snack, etc.)
Each meal shows foods, calories, and macros (protein, carbs, fat)
“Add Meal” button
3.5. Profile
User info: avatar, name, email, age, height, weight
Weekly progress: calories, exercise, protein goal (with progress bars)
Settings: preferences, health goals, nutrition plan, account
App version display
Log out button

4. Design & UX
Clean, modern, health-focused color palette (greens, blues, oranges, white)
Bottom navigation bar for main sections: Home, Scan, Log, Profile
Consistent card-based UI for summaries, meals, and settings
Responsive layout for both Android and iOS

5. Technical Requirements
Built with Flutter (cross-platform: Android & iOS)
Firebase for authentication and data storage (Firestore)
Modular codebase for easy feature expansion (e.g., AI food detection)
Support for hot reload during development

6. Non-Functional Requirements
Fast and responsive UI
Secure user data handling
Scalable backend (Firebase)
Accessibility: readable fonts, color contrast, large tap targets

7. Future Enhancements (Post v1.0.0)
AI-powered food recognition from photos
Smart meal suggestions based on user goals
Social features (sharing, challenges)
Integration with fitness trackers (Apple Health, Google Fit)
Push notifications for reminders and insights

8. Out of Scope (v1.0.0)
Real-time AI food detection (placeholder only)
Social/community features
Advanced analytics and reporting

9. Success Metrics
User sign-ups and daily active users
Number of meals logged per user
User retention after 7/30 days
User feedback and app store ratings
End of PRD
