// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get preferences => 'Preferences';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get enableDarkTheme => 'Enable dark theme';

  @override
  String get useMetricUnits => 'Use Metric Units';

  @override
  String get unitsSubtitle => 'Use kg/cm (on) or lb/ft (off)';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select app language';

  @override
  String get habitNotifications => 'Habit Notifications';

  @override
  String get mealLoggingPrompts => 'Meal Logging Prompts';

  @override
  String get mealLoggingPromptsSubtitle => 'Get reminders to log your meals';

  @override
  String get waterIntakeReminders => 'Water Intake Reminders';

  @override
  String get waterIntakeRemindersSubtitle => 'Get reminders to drink water';

  @override
  String get mindfulWalksReminders => 'Mindful Walks Reminders';

  @override
  String get mindfulWalksRemindersSubtitle => 'Get reminders to take a mindful walk';

  @override
  String get momentOfCalmAfterMeals => 'Moment of Calm After Meals';

  @override
  String get momentOfCalmAfterMealsSubtitle => 'Show a calming popup after logging a meal';

  @override
  String get welcomeBack => 'Welcome back!';

  @override
  String get trackNutritionToday => 'Let\'s track your nutrition today';

  @override
  String get subtitleAfternoon => 'Perfect time to log your lunch and keep it balanced.';

  @override
  String get subtitleEvening => 'Stay on track this evening—log your meals.';

  @override
  String get subtitleNight => 'Wrap up your day—don\'t forget to log today\'s meals.';

  @override
  String get streakNearEndingTitle => 'Keep Your Streak 🔥';

  @override
  String get streakNearEndingBody => 'Your streak is about to end. Log a meal today to keep it alive!';

  @override
  String get streakNearEndingTitle2 => 'Almost There! 🔥';

  @override
  String get streakNearEndingBody2 => 'Only a couple hours left. Log a meal to save your streak!';

  @override
  String get streakEndedTitle => 'Streak Ended';

  @override
  String get streakEndedBody => 'Your streak ended. Log a meal to restart and build it back up!';

  @override
  String get streakActive => 'Streak Active';

  @override
  String get streakInactive => 'Streak Inactive';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get entriesInStreak => 'Entries in Streak';

  @override
  String get days => 'days';

  @override
  String get startedOn => 'Started on';

  @override
  String get logMealToStartStreak => 'Log a meal today to start your streak';

  @override
  String get nutritionSummary => 'Nutrition Summary';

  @override
  String get setCalorieAndMacroGoals => 'Set your calorie and macro goals in the Nutrition Plan page.';

  @override
  String get protein => 'Protein';

  @override
  String get carbs => 'Carbs';

  @override
  String get fat => 'Fat';

  @override
  String get calories => 'Calories';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get logMeal => 'Log Meal';

  @override
  String get trackYourFood => 'Track your food';

  @override
  String get scan => 'Scan';

  @override
  String get barcode => 'Barcode';

  @override
  String get analyzeYourFood => 'Analyze your food';

  @override
  String get todaysMeals => 'Today\'s Meals';

  @override
  String get viewAll => 'View All';

  @override
  String get noMealsLoggedForThisDay => 'No meals logged for this day.';

  @override
  String get nutritionalPlan => 'Nutritional Plan';

  @override
  String get weightAnalytics => 'Weight Analytics';

  @override
  String get toGoal => 'TO GOAL';

  @override
  String get remaining => 'remaining';

  @override
  String get weeklyRate => 'WEEKLY RATE';

  @override
  String get weeklyLoss => 'weekly loss';

  @override
  String get starting => 'STARTING';

  @override
  String get current => 'CURRENT';

  @override
  String get today => 'today';

  @override
  String get targetLabel => 'TARGET';

  @override
  String get goalWeight => 'goal weight';

  @override
  String get eta => 'ETA';

  @override
  String get sinceStart => 'since start';

  @override
  String get expectationsDisclaimer => 'These expectations are based on your recent trend and can change as you log new weights.';

  @override
  String get loseVerb => 'lose';

  @override
  String get gainVerb => 'gain';

  @override
  String expectationBlurb(Object direction, Object eta, Object rate, Object remaining, Object unit) {
    return 'Based on your recent trend, you are on track to $direction about $rate $unit per week. At this pace, it will take roughly $eta to reach your target. You have $remaining $unit remaining.';
  }

  @override
  String get healthAwareness => 'Health Awareness';

  @override
  String get planSettings => 'Plan Settings';

  @override
  String get featureComingSoon => 'This feature is coming soon!';

  @override
  String get ok => 'OK';

  @override
  String get rateUsOnGoogle => 'Rate us on Google';

  @override
  String get comingSoon => 'Coming Soon!';

  @override
  String get ratingOnGoogleAvailableAfterRelease => 'Rating on Google will be available after release.';

  @override
  String get shareWithFriends => 'Share with Friends';

  @override
  String get sharingAvailableAfterRelease => 'Sharing will be available after release.';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get close => 'Close';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get send => 'Send';

  @override
  String get resend => 'Resend';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get legal => 'Legal';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get apiDocumentation => 'API Documentation';

  @override
  String get needAssistanceContactSupport => 'Need assistance? Contact our support team:';

  @override
  String get testWebURL => 'Test Web URL';

  @override
  String get testSimpleMailto => 'Test Simple Mailto';

  @override
  String get logOut => 'Log Out';

  @override
  String get areYouSureYouWantToLogOut => 'Are you sure you want to log out?';

  @override
  String get no => 'No';

  @override
  String get yes => 'Yes';

  @override
  String get commonQuestions => 'Common Questions';

  @override
  String get momentOfCalm => 'Moment of Calm';

  @override
  String get practiceMindfulEating => 'Take a moment to appreciate your meal and practice mindful eating.';

  @override
  String get howOldAreYou => 'How old are you?';

  @override
  String get personalizeExperience => 'This helps us personalize your experience';

  @override
  String get yourHeight => 'Your height';

  @override
  String get yourGoalWeight => 'Your goal weight';

  @override
  String get setRealisticGoal => 'Set a realistic goal for your journey';

  @override
  String get allSet => 'You\'re all set! 🎉';

  @override
  String get personalizedNutritionPlan => 'Here\'s your personalized nutrition plan. Welcome to your health journey with Yumie!';

  @override
  String get whatIsYourBloodType => 'What is your blood type?';

  @override
  String get personalizeHealthInsights => 'This helps us personalize your health insights.';

  @override
  String get whatIsYourSex => 'What is your sex?';

  @override
  String get personalizeNutritionPlan => 'This helps us personalize your nutrition plan.';

  @override
  String get home => 'Home';

  @override
  String get food => 'Food';

  @override
  String get coach => 'Coach';

  @override
  String get profile => 'Profile';

  @override
  String get log => 'Log';

  @override
  String get myMeals => 'My Meals';

  @override
  String get suggestedMeals => 'Suggested Meals';

  @override
  String get monthly => 'Monthly';

  @override
  String get weekly => 'Weekly';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Dinner';

  @override
  String get snack => 'Snack';

  @override
  String get reviewMeal => 'Review Meal';

  @override
  String get chat => 'Chat';

  @override
  String get insights => 'Insights';

  @override
  String get clearChat => 'Clear Chat';

  @override
  String get coachWelcome => 'Hello! I\'m Yumie, your nutrition coach. How can I help you today?\n\nAsk Yumie about healthy recipes, meal plans, or nutrition tips!';

  @override
  String get refreshInsight => 'Refresh Insight';

  @override
  String get healthInsights => 'Health Insights';

  @override
  String get noInsightAvailable => 'No insight available.';

  @override
  String get dinnerIdeas => 'Dinner ideas';

  @override
  String get calorieCheck => 'Calorie check';

  @override
  String get proteinSnacks => 'Protein snacks';

  @override
  String get dietTips => 'Diet tips';

  @override
  String get typeYourMessage => 'Type your message...';

  @override
  String get yumie => 'Yumie';

  @override
  String get askAboutMeals => 'Ask about meals & nutrition';

  @override
  String get coachQuick1 => 'What should I eat today?';

  @override
  String get coachQuick2 => 'Analyze my last meal';

  @override
  String get coachQuick3 => 'Help me plan my week';

  @override
  String get yumieThinking => 'Yumie is thinking...';

  @override
  String get bmi => 'BMI';

  @override
  String get target => 'Target';

  @override
  String get weight => 'Weight';

  @override
  String get age => 'Age';

  @override
  String get height => 'Height';

  @override
  String get targetWeight => 'Target Weight';

  @override
  String get calorieGoal => 'Calorie Goal';

  @override
  String get proteinGoal => 'Protein Goal';

  @override
  String get carbGoal => 'Carb Goal';

  @override
  String get fatGoal => 'Fat Goal';

  @override
  String get waterIntake => 'Water Intake';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get undo => 'Undo';

  @override
  String get notSet => 'Not set';

  @override
  String get uploadNew => 'Upload New';

  @override
  String get delete => 'Delete';

  @override
  String get editName => 'Edit name';

  @override
  String get bloodType => 'Blood type';

  @override
  String get areYouDiabetic => 'Are you diabetic?';

  @override
  String get healthAwarenessUpdated => 'Health awareness updated!';

  @override
  String get takeMomentToAppreciate => 'Take a moment to appreciate your meal and practice mindful eating.';

  @override
  String get continueButton => 'Continue';

  @override
  String get mealSaved => 'Meal saved!';

  @override
  String get noRecentFoods => 'No recent foods.';

  @override
  String get buildCustomMeal => 'Build a Custom Meal';

  @override
  String get mealName => 'Meal Name';

  @override
  String get searchOrEnterFoodName => 'Search or enter food name';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get addIngredient => 'Add ingredient';

  @override
  String get myFoods => 'My Foods';

  @override
  String get noCustomFoods => 'You haven\'t saved any custom foods yet';

  @override
  String get addCustomFood => 'Add Custom Food';

  @override
  String get editCustomMeal => 'Edit Custom Meal';

  @override
  String get clearAll => 'Clear All';

  @override
  String get foodName => 'Food Name';

  @override
  String get saveMeal => 'Save Meal';

  @override
  String get customizeMeal => 'Customize meal';

  @override
  String get hideIngredients => 'Hide ingredients';

  @override
  String get showIngredients => 'Show ingredients';

  @override
  String get ingredientsColon => 'Ingredients:';

  @override
  String get noIngredientsListed => 'No ingredients listed.';

  @override
  String get recent => 'Recent';

  @override
  String get meal => 'Meal';

  @override
  String get fridge => 'Fridge';

  @override
  String get placeFoodInFrame => 'Place the food inside of the frame';

  @override
  String get placeBarcodeInFrame => 'Align the barcode inside the frame';

  @override
  String get placeFridgeInFrame => 'Align the fridge inside the frame';

  @override
  String get productNotFound => 'Product not found';

  @override
  String get safetyUnsafe => 'Not safe';

  @override
  String get safetyGood => 'Good to go';

  @override
  String get badgeNutriScore => 'Nutri-Score';

  @override
  String get badgeNova => 'NOVA';

  @override
  String get allergensTitle => 'Allergens';

  @override
  String get contains => 'Contains';

  @override
  String get allergensNone => 'No allergens listed';

  @override
  String get serving => 'Serving';

  @override
  String get kcalPer100g => 'kcal/100g';

  @override
  String get sugar => 'Sugar';

  @override
  String get satFat => 'Sat Fat';

  @override
  String get salt => 'Salt';

  @override
  String get ingredientsTitle => 'Ingredients';

  @override
  String get riskAllergen => 'Allergen risk';

  @override
  String get riskUltraProcessed => 'Ultra‑processed (NOVA 4)';

  @override
  String get riskHighAdditives => 'High additives';

  @override
  String get riskLowNutri => 'Low Nutri‑Score';

  @override
  String get riskVegan => 'Vegan friendly';

  @override
  String get riskVegetarian => 'Vegetarian';

  @override
  String get riskLooksGood => 'Looks good';

  @override
  String get retakeScan => 'Retake Scan';

  @override
  String get previewFullImage => 'Preview Full Image';

  @override
  String get discard => 'Discard';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get getUnlimitedScans => 'Get unlimited scans and more!';

  @override
  String get getUnlimitedSearches => 'Get unlimited searches and more!';

  @override
  String get upgradePlan => 'Upgrade Plan';

  @override
  String get watchAdForScan => 'Watch Ad for Scan';

  @override
  String get watchAdForSearch => 'Watch Ad for Search';

  @override
  String get generateMeal => 'Generate Meal';

  @override
  String get detectedFridgeItems => 'Detected Fridge Items';

  @override
  String get noFridgeItemsDetected => 'No fridge items detected.';

  @override
  String get searchResults => 'Search Results';

  @override
  String get searchingFor => 'Searching for';

  @override
  String get noResultsFoundFor => 'No results found for';

  @override
  String get count => 'count';

  @override
  String get servings => 'servings';

  @override
  String get fluidOunces => 'fl oz';

  @override
  String get quantity => 'Quantity';

  @override
  String get confirm => 'Confirm';

  @override
  String get ingredient => 'Ingredient';

  @override
  String get drink => 'Drink';

  @override
  String get kg => 'kg';

  @override
  String get g => 'g';

  @override
  String get mg => 'mg';

  @override
  String get cm => 'cm';

  @override
  String get m => 'm';

  @override
  String get kcal => 'kcal';

  @override
  String get cal => 'cal';

  @override
  String get lb => 'lb';

  @override
  String get oz => 'oz';

  @override
  String get ft => 'ft';

  @override
  String get inches => 'in';

  @override
  String get cup => 'cup';

  @override
  String get tbsp => 'tbsp';

  @override
  String get tsp => 'tsp';

  @override
  String get ml => 'ml';

  @override
  String get l => 'l';

  @override
  String get upgradeToPremiumTitle => 'Upgrade to Premium';

  @override
  String get premiumFeatures => 'Premium Features';

  @override
  String get unlimitedScans => 'Unlimited scans';

  @override
  String get aiNutritionCoach => 'AI nutrition coach';

  @override
  String get detailedAnalytics => 'Detailed analytics';

  @override
  String get personalizedMealPlans => 'Personalized meal plans';

  @override
  String get noAdvertisements => 'No advertisements';

  @override
  String get yearlyPremium => 'Yearly Premium';

  @override
  String get monthlyPremium => 'Monthly Premium';

  @override
  String savePercent(Object percent) {
    return 'Save $percent%';
  }

  @override
  String get perYear => '/year';

  @override
  String get perMonth => '/month';

  @override
  String get popular => 'POPULAR';

  @override
  String get maybeLater => 'Maybe later';

  @override
  String get welcomeToYumie => '🎉 Welcome to Yumie!';

  @override
  String get unlockPremiumFeatures => 'Unlock Premium Features';

  @override
  String get getMostOutOfHealthJourney => 'Get the most out of your health journey with unlimited access!';

  @override
  String get unlimitedScansAICoaching => 'Unlock unlimited scans, AI coaching, and personalized meal plans!';

  @override
  String get subscribe => 'Subscribe';

  @override
  String get foodNameLabel => 'Food Name';

  @override
  String get managePermissions => 'Manage Permissions';

  @override
  String get cameraNotificationsAndMore => 'Camera, notifications, and more';

  @override
  String get deleteMeal => 'Delete meal';

  @override
  String get areYouSureDeleteMeal => 'Are you sure you want to delete this meal?';

  @override
  String get unknown => 'Unknown';

  @override
  String get servings1 => 'servings 1';

  @override
  String get edit => 'Edit';

  @override
  String get ignoreFood => 'Ignore Food';

  @override
  String get addComponent => 'Add Component';

  @override
  String get components => 'Components';

  @override
  String get recentFoods => 'Recent Foods';

  @override
  String get logWeightChange => 'Log Weight Change';

  @override
  String get lost => 'Lost';

  @override
  String get gained => 'Gained';

  @override
  String get googleSignInHelp => 'Google Sign-In Help';

  @override
  String get couldNotOpenTermsOfService => 'Could not open Terms of Service';

  @override
  String get couldNotOpenPrivacyPolicy => 'Could not open Privacy Policy';

  @override
  String get errorSavingProfile => 'Error saving profile';

  @override
  String get completeYourProfile => 'Complete Your Profile';

  @override
  String get saveAndContinue => 'Save & Continue';

  @override
  String get pleasSignIn => 'Please sign in.';

  @override
  String get noFoodLogsYet => 'No food logs yet.';

  @override
  String get healthAIFoodLog => 'HealthAI - Food Log';

  @override
  String get addLog => 'Add Log';

  @override
  String get unableToShareAtThisTime => 'Unable to share at this time. Please try again.';

  @override
  String get failedToUpdatePhoto => 'Failed to update photo';

  @override
  String get changeProfileName => 'Change Profile Name';

  @override
  String get failedToUpdateName => 'Failed to update name';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String get errorUpdatingProfile => 'Error updating profile';

  @override
  String get editGoals => 'Edit Goals';

  @override
  String get goalsUpdatedSuccessfully => 'Goals updated successfully';

  @override
  String get errorUpdatingGoals => 'Error updating goals';

  @override
  String get couldNotOpenWebsite => 'Could not open website';

  @override
  String get errorOpeningWebsite => 'Error opening website';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get spanish => 'Spanish';

  @override
  String get reviewMealTitle => 'Review Meal';

  @override
  String get startingWeight => 'Starting Weight';

  @override
  String get appPermissions => 'App Permissions';

  @override
  String get permissionStatus => 'Permission Status';

  @override
  String get manageAppPermissions => 'Manage app permissions to ensure all features work properly';

  @override
  String get camera => 'Camera';

  @override
  String get scanFoodItems => 'Scan food items and take photos of meals';

  @override
  String get photoLibrary => 'Photos';

  @override
  String get saveScannedImages => 'Save scanned images and select photos';

  @override
  String get notifications => 'Notifications';

  @override
  String get sendMealReminders => 'Send meal reminders and health alerts';

  @override
  String get needHelp => 'Need Help?';

  @override
  String get permanentlyDeniedHelp => 'If permissions are permanently denied, you can enable them in your device settings';

  @override
  String get openDeviceSettings => 'Open Device Settings';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get goodNight => 'Good night';

  @override
  String get ounces => 'oz';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String get trackYourNutrition => 'Track your nutrition';

  @override
  String get messages => 'Messages';

  @override
  String get subscribeForDailyInsights => 'Subscribe for Daily Insights';

  @override
  String get getPersonalizedHealthInsights => 'Get personalized health insights based on your complete profile';

  @override
  String get upgradeDescription => 'Get unlimited scans, searches, and AI-powered insights';

  @override
  String get unlimitedFoodScans => 'Unlimited Food Scans';

  @override
  String get unlimitedFoodSearches => 'Unlimited Food Searches';

  @override
  String get unlimitedAICoachMessages => 'Unlimited AI Coach Messages';

  @override
  String get dailyHealthInsights => 'Daily Health Insights';

  @override
  String get logWaterIntake => 'Log Water Intake';

  @override
  String get add => 'Add';

  @override
  String get freemium => 'Freemium';

  @override
  String get premium => 'Premium';

  @override
  String get chooseYourPlan => 'Choose Your Plan';

  @override
  String get water => 'Water';

  @override
  String get resetPasswordDescription => 'A password reset link will be sent to your email';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountDescription => 'Permanently delete your account and all data';

  @override
  String get confirmDeleteAccount => 'Are you sure you want to delete your account?';

  @override
  String get deleteAccountWarning => 'This action cannot be undone. All your data including meals, progress, and settings will be permanently deleted.';

  @override
  String get typeDeleteToConfirm => 'Type \"DELETE\" to confirm';

  @override
  String get deleteAccountFinalConfirmation => 'DELETE';

  @override
  String get accountDeleted => 'Account Deleted';

  @override
  String get errorDeletingAccount => 'Error deleting account';

  @override
  String get totalNutrition => 'Total nutrition';

  @override
  String get unlockUnlimitedScans => 'Unlock unlimited scans, AI coaching, and\npersonalized meal plans';

  @override
  String get unlimitedFoodScanning => 'Unlimited food scanning';

  @override
  String get yearPrice => 'year/\$49.99';

  @override
  String get monthPrice => 'month/\$7.99';

  @override
  String get save37 => 'Save 37%';

  @override
  String get youArePremium => 'You Are Premium!';

  @override
  String get yumiePremiumMonthly => 'Yumie™ Premium Monthly';

  @override
  String get yumiePremiumYearly => 'Yumie™ Premium Yearly';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get checkingForPurchases => 'Checking for existing purchases...';

  @override
  String get purchasesRestored => 'Purchases restored successfully!';

  @override
  String get noPurchasesFound => 'No previous purchases found';

  @override
  String get restoreFailed => 'Failed to restore purchases. Please try again.';

  @override
  String get restoreInProgress => 'Restoring purchases...';

  @override
  String get bySubscribing => 'By subscribing, you agree to our Terms of Service and Privacy Policy. Subscriptions automatically renew unless cancelled';

  @override
  String get permissionsComplete => 'Permissions Complete!';

  @override
  String get whyWeAskForPermissions => 'Why we ask for permissions';

  @override
  String get permissionsWhyBody => 'We use your camera to scan foods and barcodes, access photos when you upload images, and notifications to remind you to log meals and hydrate.';

  @override
  String get permissionsNextScreen => 'On the next screen, you\'ll see the system prompts to grant access. You can change this anytime in Settings.';

  @override
  String get references => 'References:';

  @override
  String get cdcAboutBmi => 'CDC: About BMI';

  @override
  String get usdaDietaryGuidelines => 'USDA Dietary Guidelines';

  @override
  String get termsOfUseEula => 'Terms of Use (EULA)';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get manageSessions => 'Manage Sessions';

  @override
  String get selectLanguageTitle => 'Select Language';

  @override
  String get chooseYourPreferredLanguage => 'Choose your preferred language for the app';

  @override
  String get languageChangedTo => 'Language changed to';

  @override
  String get activeSessions => 'Active Sessions';

  @override
  String get thisDevice => 'This device';

  @override
  String get sessionRevoked => 'Session revoked';

  @override
  String get allOtherSessionsSignedOut => 'All other sessions signed out';

  @override
  String get signOutAllOthers => 'Sign Out All Others';

  @override
  String get noSecurityAlerts => 'No security alerts';

  @override
  String get passwordStrengthWeak => 'Weak';

  @override
  String get passwordStrengthFair => 'Fair';

  @override
  String get passwordStrengthGood => 'Good';

  @override
  String get passwordStrengthStrong => 'Strong';

  @override
  String get passwordStrengthVeryStrong => 'Very Strong';

  @override
  String get addLowercaseLetters => 'Add lowercase letters';

  @override
  String get addUppercaseLetters => 'Add uppercase letters';

  @override
  String get addNumbers => 'Add numbers';

  @override
  String get addSpecialCharacters => 'Add special characters (!@#\$%^&*)';

  @override
  String get avoidCommonPatterns => 'Avoid common patterns';

  @override
  String get requiresAtLeast8Characters => 'Requires at least 8 characters';

  @override
  String get tooManySignInAttempts => 'Too many sign-in attempts. Please try again later.';

  @override
  String get tooManySignUpAttempts => 'Too many sign-up attempts. Please try again later.';

  @override
  String get tooManyPasswordResetRequests => 'Too many password reset requests. Please try again later.';

  @override
  String get multipleFailedSignInAttempts => 'Multiple Failed Sign-in Attempts';

  @override
  String get excessivePasswordResetRequests => 'Excessive Password Reset Requests';

  @override
  String get suspiciousActivityDetected => 'Suspicious Activity Detected';

  @override
  String get riskLevelMedium => 'MEDIUM';

  @override
  String get riskLevelHigh => 'HIGH';

  @override
  String get welcomeToYumiePermissions => 'Welcome to Yumie';

  @override
  String get provideBestExperience => 'To provide you with the best experience, we need a few permissions';

  @override
  String get grantPermissions => 'Grant Permissions';

  @override
  String get skipForNow => 'Skip for Now';

  @override
  String get denied => 'Denied';

  @override
  String get granted => 'Granted';

  @override
  String get createAccount => 'Create Account';

  @override
  String get signUpToGetStarted => 'Sign up to get started with Yumie';

  @override
  String get fullName => 'Full Name';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get agreeToTerms => 'and Terms of Service I accept the Privacy Policy';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signInToAccessAccount => 'Sign in to access your account';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get signUpWithGoogle => 'Sign up with Google';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signUpWithApple => 'Sign up with Apple';

  @override
  String get signInWithApple => 'Sign in with Apple';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get enterEmailForReset => 'Enter your email address to receive a password reset link';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get rateUsOn => 'Rate us on';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String get deleteAccountWarningTitle => 'This action is permanent and cannot be undone';

  @override
  String get deleteAccountDataList => 'When you delete your account, we will permanently remove:';

  @override
  String get allMealLogsAndNutrition => 'All your meal logs and nutrition data';

  @override
  String get profileAndPersonalInfo => 'Your profile and personal information';

  @override
  String get allUploadedPhotos => 'All uploaded photos and files';

  @override
  String get customMealsAndRecipes => 'Your custom meals and recipes';

  @override
  String get allAppPreferences => 'All app preferences and settings';

  @override
  String get activeSessionsAllDevices => 'Active sessions on all devices';

  @override
  String get exportDataWarning => 'Make sure to export any data you want to keep before proceeding';

  @override
  String get understandActionPermanent => 'I understand this action is permanent';

  @override
  String get typeDeleteHere => 'Type DELETE here';

  @override
  String get deleteForever => 'Delete Forever';

  @override
  String get noSecurityAlertsFound => 'No security alerts';

  @override
  String get yourAccountLooksGood => 'Your account looks good! No suspicious activity detected.';

  @override
  String get manageActiveSessionsAcrossDevices => 'Manage your active sessions across different devices';

  @override
  String get noActiveSessionsFound => 'No active sessions found';

  @override
  String get signOutAllOtherSessions => 'Sign Out All Others';

  @override
  String get aiSearch => 'AI Search';

  @override
  String get aiSearchDescription => 'Search for food items using AI';

  @override
  String get noIngredientsListedText => 'No ingredients listed';

  @override
  String get breakfastTime => 'Breakfast Time';

  @override
  String get lunchTime => 'Lunch Time';

  @override
  String get dinnerTime => 'Dinner Time';

  @override
  String get snackTime => 'Snack Time';

  @override
  String get deletingYourAccount => 'Deleting your account...';

  @override
  String get thisMayTakeAFewMoments => 'This may take a few moments';

  @override
  String get redirectingToSignIn => 'Redirecting to sign-in...';

  @override
  String get accountSuccessfullyDeleted => 'Account Successfully Deleted';

  @override
  String get pleaseCloseAndRestartApp => 'Please close and restart the app to continue.';

  @override
  String get restartApp => 'Restart App';

  @override
  String get cameraAccess => 'Camera Access';

  @override
  String get cameraAccessMessage => 'Yumie needs camera access to scan food items and help you log your meals accurately.';

  @override
  String get photoLibraryAccess => 'Photo Library Access';

  @override
  String get photoLibraryAccessMessage => 'Yumie needs access to your photo library to save scanned images and select photos for meal logging.';

  @override
  String get notificationAccess => 'Notification Access';

  @override
  String get notificationAccessMessage => 'Yumie needs notification access to send you meal reminders, water intake alerts, and mindful walk prompts.';

  @override
  String get notNow => 'Not Now';

  @override
  String get permissionsCompleted => 'Permissions Complete!';

  @override
  String get allPermissionsGranted => 'All permissions granted! You\'re all set to use Yumie.';

  @override
  String get whatIsYourMainGoal => 'What is your main goal?';

  @override
  String get chooseGoalDescription => 'Choose the goal that best aligns with your journey';

  @override
  String get loseBodyWeight => 'Lose body weight';

  @override
  String get gainWeight => 'Gain weight';

  @override
  String get buildMuscle => 'Build muscle';

  @override
  String get eatHealthier => 'Eat healthier';

  @override
  String get maintainBodyWeight => 'Maintain body weight';

  @override
  String get setRealisticGoalForJourney => 'Set a realistic goal for your journey';

  @override
  String get targetWeightSetToCurrent => 'Your target weight is set to your current weight';

  @override
  String get iAcceptThe => 'I accept the';

  @override
  String get and => 'and';

  @override
  String get johnDoe => 'John Doe';

  @override
  String get yourEmailExample => 'your.email@example.com';

  @override
  String get byContinuingYouAgreeToOur => 'By continuing, you agree to our';

  @override
  String get whatMotivatesYou => 'What motivates you?';

  @override
  String get chooseWhatDrivesYou => 'Choose what drives you to achieve your goals';

  @override
  String get feelEnergeticEveryDay => 'Feel energetic every day';

  @override
  String get achievePersonalMilestone => 'Achieve a personal milestone';

  @override
  String get boostMyConfidence => 'Boost my confidence';

  @override
  String get longTermHealth => 'Long term health';

  @override
  String get trackYourMealsWithEase => 'Track your meals with ease';

  @override
  String get caloriesLeft => 'calories left';

  @override
  String get thisHelpsUsPersonalizeNutrition => 'This helps us personalize your nutrition plan';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get other => 'Other';

  @override
  String get thisHelpsUsPersonalizeExperience => 'This helps us personalize your experience';

  @override
  String get older => 'Older';

  @override
  String get younger => 'Younger';

  @override
  String get yearsOld => 'years old';

  @override
  String get selected => 'Selected';

  @override
  String get teens => 'Teens';

  @override
  String get yourCurrentWeight => 'Your current weight';

  @override
  String get activityLevel => 'Activity level';

  @override
  String get diabetic => 'Diabetic?';

  @override
  String get howMuchWaterADay => 'How much water a day?';

  @override
  String get fitnessProfile => 'Fitness profile';

  @override
  String get dueToCurrentAnswers => 'Due to current answers';

  @override
  String get remindersWouldYouLike => 'Reminders would you like to receive?';

  @override
  String get yumieIsCookingUp => 'Yumie is cooking up your personalized nutrition plan...';

  @override
  String get yourAllSet => 'You\'re all set!';

  @override
  String get google => 'Google';

  @override
  String get fiftyPlus => '50+';

  @override
  String get forties => '40s';

  @override
  String get thirties => '30s';

  @override
  String get twenties => '20s';

  @override
  String get weightUnit => 'kg';

  @override
  String get heightUnit => 'cm';

  @override
  String get feetUnit => 'ft';

  @override
  String get inchesUnit => 'in';

  @override
  String get poundsUnit => 'lbs';

  @override
  String get whatIsYourAge => 'What is your age?';

  @override
  String get whatIsYourHeight => 'What is your height?';

  @override
  String get whatIsYourWeight => 'What is your current weight?';

  @override
  String get whatIsYourGoalWeight => 'What is your goal weight?';

  @override
  String get whatIsYourActivityLevel => 'What is your activity level?';

  @override
  String get howMuchWaterDaily => 'How much water do you drink daily?';

  @override
  String get sedentary => 'Sedentary';

  @override
  String get lightlyActive => 'Lightly Active';

  @override
  String get moderatelyActive => 'Moderately Active';

  @override
  String get veryActive => 'Very Active';

  @override
  String get extremelyActive => 'Extremely Active';

  @override
  String get aPositive => 'A+';

  @override
  String get aNegative => 'A-';

  @override
  String get bPositive => 'B+';

  @override
  String get bNegative => 'B-';

  @override
  String get abPositive => 'AB+';

  @override
  String get abNegative => 'AB-';

  @override
  String get oPositive => 'O+';

  @override
  String get oNegative => 'O-';

  @override
  String get oneToTwoGlasses => '1-2 glasses';

  @override
  String get threeToFourGlasses => '3-4 glasses';

  @override
  String get fiveToSixGlasses => '5-6 glasses';

  @override
  String get sevenToEightGlasses => '7-8 glasses';

  @override
  String get moreThanEightGlasses => 'More than 8 glasses';

  @override
  String get mealReminders => 'Meal reminders';

  @override
  String get waterReminders => 'Water reminders';

  @override
  String get workoutReminders => 'Workout reminders';

  @override
  String get progressUpdates => 'Progress updates';

  @override
  String get dailyTips => 'Daily tips';

  @override
  String get youAreAllSet => 'You are all set!';

  @override
  String get welcomeToYourHealthJourney => 'Welcome to your health journey';

  @override
  String get letsGetStarted => 'Let\'s get started!';

  @override
  String get pleaseWait => 'Please wait...';

  @override
  String get cookingUpYourPlan => 'Cooking up your personalized plan';

  @override
  String get analyzingYourData => 'Analyzing your data';

  @override
  String get creatingCustomPlan => 'Creating your custom nutrition plan';

  @override
  String get almostDone => 'Almost done!';

  @override
  String get subscriptionRequired => 'Subscription Required';

  @override
  String get upgradeToUnlock => 'Upgrade to unlock all features';

  @override
  String get startFreeTrial => 'Start Free Trial';

  @override
  String get month => 'month';

  @override
  String get year => 'year';

  @override
  String get free => 'Free';

  @override
  String get mostPopular => 'Most Popular';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get done => 'Done';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Info';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get tryAgain => 'Try again';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get internetConnectionRequired => 'Internet connection required';

  @override
  String get pleaseCheckConnection => 'Please check your internet connection';

  @override
  String get restartOnboarding => 'Restart Onboarding';

  @override
  String get getStarted => 'Get Started';

  @override
  String get couldNotOpenPlayStore => 'Could not open Play Store';

  @override
  String get errorOpeningPlayStore => 'Error opening Play Store';

  @override
  String get remove => 'Remove';

  @override
  String get couldNotOpenLink => 'Could not open link';

  @override
  String get errorOpeningLink => 'Error opening link';

  @override
  String get help => 'Help';

  @override
  String get name => 'Name';

  @override
  String get dailyCalorieGoal => 'Daily Calorie Goal';

  @override
  String get manageSubscription => 'Manage Subscription';

  @override
  String get deletionFailed => 'Deletion Failed';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get littleOrNoExercise => 'Little or no exercise';

  @override
  String get lightExercise => 'Light exercise/sports 1-3 days/week';

  @override
  String get moderateExercise => 'Moderate exercise/sports 3-5 days/week';

  @override
  String get hardExercise => 'Hard exercise/sports 6-7 days/week';

  @override
  String get share => 'Share';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get notificationsForMealLogging => 'Notifications for meal logging reminders';

  @override
  String get notificationsForWaterIntake => 'Notifications for water intake reminders';

  @override
  String get notificationsForMindfulWalk => 'Notifications for mindful walk reminders';

  @override
  String get increment => 'Increment';

  @override
  String get enterNewName => 'Enter new name';

  @override
  String get readOurPrivacyPolicy => 'Read our privacy policy';

  @override
  String get readOurTermsOfService => 'Read our terms of service';

  @override
  String get helpUsCalculateYourHealthGoals => 'Help us calculate your health goals';

  @override
  String get thisHelpsUsTrackYourProgress => 'This helps us track your progress';

  @override
  String get setARealisticGoalForYourJourney => 'Set a realistic goal for your journey';

  @override
  String get thisHelpsUsPersonalizeYourPlan => 'This helps us personalize your plan';

  @override
  String get stayingHydratedIsKeyToYourHealth => 'Staying hydrated is key to your health';

  @override
  String get yourFitnessProfileDueToYourAnswers => 'Your fitness profile due to your answers';

  @override
  String get currentBMI => 'Current BMI';

  @override
  String get obese => 'Obese';

  @override
  String get activityLevelLabel => 'Activity Level';

  @override
  String get bloodTypeLabel => 'Blood Type';

  @override
  String get diabeticLabel => 'Diabetic';

  @override
  String get waterIntakeLabel => 'Water Intake';

  @override
  String get heresYourPersonalizedNutritionPlan => 'Here\'s your personalized nutrition plan. Welcome to your health journey with Yumie';

  @override
  String get caloriesGoal => 'Calories Goal';

  @override
  String get carbsGoal => 'Carbs Goal';

  @override
  String get startNow => 'Start Now';

  @override
  String get underweight => 'Underweight';

  @override
  String get normalWeight => 'Normal weight';

  @override
  String get healthy => 'Healthy';

  @override
  String get overweight => 'Overweight';

  @override
  String get avocadoToast => 'Avocado Toast';

  @override
  String get italianSalad => 'Italian Salad';

  @override
  String get chickenKatsuRiceBowl => 'Chicken Katsu Rice Bowl';

  @override
  String get yourTargetWeightIsSetToCurrent => 'Your target weight is set to your current weight';

  @override
  String get couldNotGenerateYourPlan => 'Could not generate your plan. Please try again.';

  @override
  String get somethingWentWrongRestart => 'Something went wrong. Please restart the onboarding process.';

  @override
  String get yourBMI => 'Your BMI:';

  @override
  String get lbs => 'lbs';

  @override
  String get yourActivityLevel => 'Your activity level';

  @override
  String get analyzingFridge => 'Analyzing your fridge...';

  @override
  String get aiDetectingFoodItems => 'AI is detecting food items';

  @override
  String get tryClearerPhoto => 'Try taking a clearer photo of your fridge';

  @override
  String get generating => 'Generating...';

  @override
  String get premiumStatus => 'Premium Status';

  @override
  String get thankYouForSupport => 'Thank you for your support! 💚';

  @override
  String get yourPremiumFeatures => 'Your Premium Features';

  @override
  String get subscriptionError => 'Subscription Error';

  @override
  String get unknownErrorOccurred => 'An unknown error occurred';

  @override
  String get privacyAndAds => 'Privacy & Ads';

  @override
  String get reviewAdPreferences => 'Review your ad preferences';

  @override
  String get privacyOptionsNotAvailable => 'Privacy options are not available in your region.';

  @override
  String get consentFlowCompleted => 'Consent flow completed!';

  @override
  String get appleSignInFailed => 'Apple sign-in failed';

  @override
  String get adFailedToShow => 'Ad failed to show. Please try again.';

  @override
  String get adNotLoadedYet => 'Ad not loaded yet. Please try again.';

  @override
  String get errorRequestingPermissions => 'Error requesting permissions';

  @override
  String get showMore => 'Show more';

  @override
  String get showLess => 'Show less';
}
