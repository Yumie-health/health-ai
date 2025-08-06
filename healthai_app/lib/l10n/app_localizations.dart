import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @enableDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Enable dark theme'**
  String get enableDarkTheme;

  /// No description provided for @useMetricUnits.
  ///
  /// In en, this message translates to:
  /// **'Use Metric Units'**
  String get useMetricUnits;

  /// No description provided for @unitsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'kg/cm or lb/ft'**
  String get unitsSubtitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select app language'**
  String get selectLanguage;

  /// No description provided for @habitNotifications.
  ///
  /// In en, this message translates to:
  /// **'Habit Notifications'**
  String get habitNotifications;

  /// No description provided for @mealLoggingPrompts.
  ///
  /// In en, this message translates to:
  /// **'Meal Logging Prompts'**
  String get mealLoggingPrompts;

  /// No description provided for @mealLoggingPromptsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get reminders to log your meals'**
  String get mealLoggingPromptsSubtitle;

  /// No description provided for @waterIntakeReminders.
  ///
  /// In en, this message translates to:
  /// **'Water Intake Reminders'**
  String get waterIntakeReminders;

  /// No description provided for @waterIntakeRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get reminders to drink water'**
  String get waterIntakeRemindersSubtitle;

  /// No description provided for @mindfulWalksReminders.
  ///
  /// In en, this message translates to:
  /// **'Mindful Walks Reminders'**
  String get mindfulWalksReminders;

  /// No description provided for @mindfulWalksRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get reminders to take a mindful walk'**
  String get mindfulWalksRemindersSubtitle;

  /// No description provided for @momentOfCalmAfterMeals.
  ///
  /// In en, this message translates to:
  /// **'Moment of Calm After Meals'**
  String get momentOfCalmAfterMeals;

  /// No description provided for @momentOfCalmAfterMealsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show a calming popup after logging a meal'**
  String get momentOfCalmAfterMealsSubtitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @trackNutritionToday.
  ///
  /// In en, this message translates to:
  /// **'Let\'s track your nutrition today'**
  String get trackNutritionToday;

  /// No description provided for @nutritionSummary.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Summary'**
  String get nutritionSummary;

  /// No description provided for @setCalorieAndMacroGoals.
  ///
  /// In en, this message translates to:
  /// **'Set your calorie and macro goals in the Nutrition Plan page.'**
  String get setCalorieAndMacroGoals;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbs;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @logMeal.
  ///
  /// In en, this message translates to:
  /// **'Log Meal'**
  String get logMeal;

  /// No description provided for @trackYourFood.
  ///
  /// In en, this message translates to:
  /// **'Track your food'**
  String get trackYourFood;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @analyzeYourFood.
  ///
  /// In en, this message translates to:
  /// **'Analyze your food'**
  String get analyzeYourFood;

  /// No description provided for @todaysMeals.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Meals'**
  String get todaysMeals;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @noMealsLoggedForThisDay.
  ///
  /// In en, this message translates to:
  /// **'No meals logged for this day.'**
  String get noMealsLoggedForThisDay;

  /// No description provided for @nutritionalPlan.
  ///
  /// In en, this message translates to:
  /// **'Nutritional Plan'**
  String get nutritionalPlan;

  /// No description provided for @healthAwareness.
  ///
  /// In en, this message translates to:
  /// **'Health Awareness'**
  String get healthAwareness;

  /// No description provided for @planSettings.
  ///
  /// In en, this message translates to:
  /// **'Plan Settings'**
  String get planSettings;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'This feature is coming soon!'**
  String get featureComingSoon;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @rateUsOnGoogle.
  ///
  /// In en, this message translates to:
  /// **'Rate us on Google'**
  String get rateUsOnGoogle;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon!'**
  String get comingSoon;

  /// No description provided for @ratingOnGoogleAvailableAfterRelease.
  ///
  /// In en, this message translates to:
  /// **'Rating on Google will be available after release.'**
  String get ratingOnGoogleAvailableAfterRelease;

  /// No description provided for @shareWithFriends.
  ///
  /// In en, this message translates to:
  /// **'Share with Friends'**
  String get shareWithFriends;

  /// No description provided for @sharingAvailableAfterRelease.
  ///
  /// In en, this message translates to:
  /// **'Sharing will be available after release.'**
  String get sharingAvailableAfterRelease;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @apiDocumentation.
  ///
  /// In en, this message translates to:
  /// **'API Documentation'**
  String get apiDocumentation;

  /// No description provided for @needAssistanceContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Need assistance? Contact our support team:'**
  String get needAssistanceContactSupport;

  /// No description provided for @testWebURL.
  ///
  /// In en, this message translates to:
  /// **'Test Web URL'**
  String get testWebURL;

  /// No description provided for @testSimpleMailto.
  ///
  /// In en, this message translates to:
  /// **'Test Simple Mailto'**
  String get testSimpleMailto;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @areYouSureYouWantToLogOut.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get areYouSureYouWantToLogOut;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @commonQuestions.
  ///
  /// In en, this message translates to:
  /// **'Common Questions'**
  String get commonQuestions;

  /// No description provided for @momentOfCalm.
  ///
  /// In en, this message translates to:
  /// **'Moment of Calm'**
  String get momentOfCalm;

  /// No description provided for @practiceMindfulEating.
  ///
  /// In en, this message translates to:
  /// **'Take a moment to appreciate your meal and practice mindful eating.'**
  String get practiceMindfulEating;

  /// No description provided for @howOldAreYou.
  ///
  /// In en, this message translates to:
  /// **'How old are you?'**
  String get howOldAreYou;

  /// No description provided for @personalizeExperience.
  ///
  /// In en, this message translates to:
  /// **'This helps us personalize your experience'**
  String get personalizeExperience;

  /// No description provided for @yourHeight.
  ///
  /// In en, this message translates to:
  /// **'Your height'**
  String get yourHeight;

  /// No description provided for @yourGoalWeight.
  ///
  /// In en, this message translates to:
  /// **'Your goal weight'**
  String get yourGoalWeight;

  /// No description provided for @setRealisticGoal.
  ///
  /// In en, this message translates to:
  /// **'Set a realistic goal for your journey'**
  String get setRealisticGoal;

  /// No description provided for @allSet.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set! 🎉'**
  String get allSet;

  /// No description provided for @personalizedNutritionPlan.
  ///
  /// In en, this message translates to:
  /// **'Here\'s your personalized nutrition plan. Welcome to your health journey with Yumie!'**
  String get personalizedNutritionPlan;

  /// No description provided for @whatIsYourBloodType.
  ///
  /// In en, this message translates to:
  /// **'What is your blood type?'**
  String get whatIsYourBloodType;

  /// No description provided for @personalizeHealthInsights.
  ///
  /// In en, this message translates to:
  /// **'This helps us personalize your health insights.'**
  String get personalizeHealthInsights;

  /// No description provided for @whatIsYourSex.
  ///
  /// In en, this message translates to:
  /// **'What is your sex?'**
  String get whatIsYourSex;

  /// No description provided for @personalizeNutritionPlan.
  ///
  /// In en, this message translates to:
  /// **'This helps us personalize your nutrition plan.'**
  String get personalizeNutritionPlan;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @coach.
  ///
  /// In en, this message translates to:
  /// **'Coach'**
  String get coach;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @log.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get log;

  /// No description provided for @myMeals.
  ///
  /// In en, this message translates to:
  /// **'My Meals'**
  String get myMeals;

  /// No description provided for @suggestedMeals.
  ///
  /// In en, this message translates to:
  /// **'Suggested Meals'**
  String get suggestedMeals;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @snack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snack;

  /// No description provided for @reviewMeal.
  ///
  /// In en, this message translates to:
  /// **'Review Meal'**
  String get reviewMeal;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @clearChat.
  ///
  /// In en, this message translates to:
  /// **'Clear Chat'**
  String get clearChat;

  /// No description provided for @coachWelcome.
  ///
  /// In en, this message translates to:
  /// **'Hello! I\'m Yumie, your nutrition coach. How can I help you today?\n\nAsk Yumie about healthy recipes, meal plans, or nutrition tips!'**
  String get coachWelcome;

  /// No description provided for @refreshInsight.
  ///
  /// In en, this message translates to:
  /// **'Refresh Insight'**
  String get refreshInsight;

  /// No description provided for @healthInsights.
  ///
  /// In en, this message translates to:
  /// **'Health Insights'**
  String get healthInsights;

  /// No description provided for @noInsightAvailable.
  ///
  /// In en, this message translates to:
  /// **'No insight available.'**
  String get noInsightAvailable;

  /// No description provided for @dinnerIdeas.
  ///
  /// In en, this message translates to:
  /// **'Dinner ideas'**
  String get dinnerIdeas;

  /// No description provided for @calorieCheck.
  ///
  /// In en, this message translates to:
  /// **'Calorie check'**
  String get calorieCheck;

  /// No description provided for @proteinSnacks.
  ///
  /// In en, this message translates to:
  /// **'Protein snacks'**
  String get proteinSnacks;

  /// No description provided for @dietTips.
  ///
  /// In en, this message translates to:
  /// **'Diet tips'**
  String get dietTips;

  /// No description provided for @typeYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeYourMessage;

  /// No description provided for @yumie.
  ///
  /// In en, this message translates to:
  /// **'Yumie'**
  String get yumie;

  /// No description provided for @askAboutMeals.
  ///
  /// In en, this message translates to:
  /// **'Ask about meals, nutrition, or get personalized advice'**
  String get askAboutMeals;

  /// No description provided for @coachQuick1.
  ///
  /// In en, this message translates to:
  /// **'What should I eat today?'**
  String get coachQuick1;

  /// No description provided for @coachQuick2.
  ///
  /// In en, this message translates to:
  /// **'Analyze my last meal'**
  String get coachQuick2;

  /// No description provided for @coachQuick3.
  ///
  /// In en, this message translates to:
  /// **'Help me plan my week'**
  String get coachQuick3;

  /// No description provided for @yumieThinking.
  ///
  /// In en, this message translates to:
  /// **'Yumie is thinking...'**
  String get yumieThinking;

  /// No description provided for @bmi.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get bmi;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @targetWeight.
  ///
  /// In en, this message translates to:
  /// **'Target Weight'**
  String get targetWeight;

  /// No description provided for @calorieGoal.
  ///
  /// In en, this message translates to:
  /// **'Calorie Goal'**
  String get calorieGoal;

  /// No description provided for @proteinGoal.
  ///
  /// In en, this message translates to:
  /// **'Protein Goal'**
  String get proteinGoal;

  /// No description provided for @carbGoal.
  ///
  /// In en, this message translates to:
  /// **'Carb Goal'**
  String get carbGoal;

  /// No description provided for @fatGoal.
  ///
  /// In en, this message translates to:
  /// **'Fat Goal'**
  String get fatGoal;

  /// No description provided for @waterIntake.
  ///
  /// In en, this message translates to:
  /// **'Water Intake'**
  String get waterIntake;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @uploadNew.
  ///
  /// In en, this message translates to:
  /// **'Upload New'**
  String get uploadNew;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @editName.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get editName;

  /// No description provided for @bloodType.
  ///
  /// In en, this message translates to:
  /// **'Blood Type'**
  String get bloodType;

  /// No description provided for @areYouDiabetic.
  ///
  /// In en, this message translates to:
  /// **'Are you diabetic?'**
  String get areYouDiabetic;

  /// No description provided for @healthAwarenessUpdated.
  ///
  /// In en, this message translates to:
  /// **'Health awareness updated!'**
  String get healthAwarenessUpdated;

  /// No description provided for @takeMomentToAppreciate.
  ///
  /// In en, this message translates to:
  /// **'Take a moment to appreciate your meal and practice mindful eating.'**
  String get takeMomentToAppreciate;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @mealSaved.
  ///
  /// In en, this message translates to:
  /// **'🎉 Meal saved!'**
  String get mealSaved;

  /// No description provided for @noRecentFoods.
  ///
  /// In en, this message translates to:
  /// **'No recent foods.'**
  String get noRecentFoods;

  /// No description provided for @buildCustomMeal.
  ///
  /// In en, this message translates to:
  /// **'Build a Custom Meal'**
  String get buildCustomMeal;

  /// No description provided for @mealName.
  ///
  /// In en, this message translates to:
  /// **'Meal Name'**
  String get mealName;

  /// No description provided for @searchOrEnterFoodName.
  ///
  /// In en, this message translates to:
  /// **'Search or enter food name'**
  String get searchOrEnterFoodName;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @addIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add ingredient'**
  String get addIngredient;

  /// No description provided for @myFoods.
  ///
  /// In en, this message translates to:
  /// **'My Foods'**
  String get myFoods;

  /// No description provided for @noCustomFoods.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t saved any custom foods yet'**
  String get noCustomFoods;

  /// No description provided for @addCustomFood.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Food'**
  String get addCustomFood;

  /// No description provided for @editCustomMeal.
  ///
  /// In en, this message translates to:
  /// **'Edit Custom Meal'**
  String get editCustomMeal;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @foodName.
  ///
  /// In en, this message translates to:
  /// **'Food Name'**
  String get foodName;

  /// No description provided for @saveMeal.
  ///
  /// In en, this message translates to:
  /// **'Save Meal'**
  String get saveMeal;

  /// No description provided for @customizeMeal.
  ///
  /// In en, this message translates to:
  /// **'Customize meal'**
  String get customizeMeal;

  /// No description provided for @hideIngredients.
  ///
  /// In en, this message translates to:
  /// **'Hide ingredients'**
  String get hideIngredients;

  /// No description provided for @showIngredients.
  ///
  /// In en, this message translates to:
  /// **'Show ingredients'**
  String get showIngredients;

  /// No description provided for @ingredientsColon.
  ///
  /// In en, this message translates to:
  /// **'Ingredients:'**
  String get ingredientsColon;

  /// No description provided for @noIngredientsListed.
  ///
  /// In en, this message translates to:
  /// **'No ingredients listed.'**
  String get noIngredientsListed;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @meal.
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get meal;

  /// No description provided for @fridge.
  ///
  /// In en, this message translates to:
  /// **'Fridge'**
  String get fridge;

  /// No description provided for @placeFoodInFrame.
  ///
  /// In en, this message translates to:
  /// **'Place the food inside of the frame'**
  String get placeFoodInFrame;

  /// No description provided for @retakeScan.
  ///
  /// In en, this message translates to:
  /// **'Retake Scan'**
  String get retakeScan;

  /// No description provided for @previewFullImage.
  ///
  /// In en, this message translates to:
  /// **'Preview Full Image'**
  String get previewFullImage;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @getUnlimitedScans.
  ///
  /// In en, this message translates to:
  /// **'Get unlimited scans and more!'**
  String get getUnlimitedScans;

  /// No description provided for @upgradePlan.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Plan'**
  String get upgradePlan;

  /// No description provided for @watchAdForScan.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad for Scan'**
  String get watchAdForScan;

  /// No description provided for @generateMeal.
  ///
  /// In en, this message translates to:
  /// **'Generate Meal'**
  String get generateMeal;

  /// No description provided for @detectedFridgeItems.
  ///
  /// In en, this message translates to:
  /// **'Detected Fridge Items'**
  String get detectedFridgeItems;

  /// No description provided for @noFridgeItemsDetected.
  ///
  /// In en, this message translates to:
  /// **'No fridge items detected.'**
  String get noFridgeItemsDetected;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// No description provided for @searchingFor.
  ///
  /// In en, this message translates to:
  /// **'Searching for'**
  String get searchingFor;

  /// No description provided for @noResultsFoundFor.
  ///
  /// In en, this message translates to:
  /// **'No results found for'**
  String get noResultsFoundFor;

  /// No description provided for @count.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get count;

  /// No description provided for @servings.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get servings;

  /// No description provided for @fluidOunces.
  ///
  /// In en, this message translates to:
  /// **'Fluid Ounces'**
  String get fluidOunces;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @ingredient.
  ///
  /// In en, this message translates to:
  /// **'Ingredient'**
  String get ingredient;

  /// No description provided for @drink.
  ///
  /// In en, this message translates to:
  /// **'Drink'**
  String get drink;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
