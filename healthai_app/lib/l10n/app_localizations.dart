import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('nl'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr')
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
  /// **'Use kg/cm (on) or lb/ft (off)'**
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

  /// No description provided for @subtitleAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Perfect time to log your lunch and keep it balanced.'**
  String get subtitleAfternoon;

  /// No description provided for @subtitleEvening.
  ///
  /// In en, this message translates to:
  /// **'Stay on track this evening—log your meals.'**
  String get subtitleEvening;

  /// No description provided for @subtitleNight.
  ///
  /// In en, this message translates to:
  /// **'Wrap up your day—don\'t forget to log today\'s meals.'**
  String get subtitleNight;

  /// No description provided for @streakNearEndingTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep Your Streak 🔥'**
  String get streakNearEndingTitle;

  /// No description provided for @streakNearEndingBody.
  ///
  /// In en, this message translates to:
  /// **'Your streak is about to end. Log a meal today to keep it alive!'**
  String get streakNearEndingBody;

  /// No description provided for @streakNearEndingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Almost There! 🔥'**
  String get streakNearEndingTitle2;

  /// No description provided for @streakNearEndingBody2.
  ///
  /// In en, this message translates to:
  /// **'Only a couple hours left. Log a meal to save your streak!'**
  String get streakNearEndingBody2;

  /// No description provided for @streakEndedTitle.
  ///
  /// In en, this message translates to:
  /// **'Streak Ended'**
  String get streakEndedTitle;

  /// No description provided for @streakEndedBody.
  ///
  /// In en, this message translates to:
  /// **'Your streak ended. Log a meal to restart and build it back up!'**
  String get streakEndedBody;

  /// No description provided for @streakActive.
  ///
  /// In en, this message translates to:
  /// **'Streak Active'**
  String get streakActive;

  /// No description provided for @streakInactive.
  ///
  /// In en, this message translates to:
  /// **'Streak Inactive'**
  String get streakInactive;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @entriesInStreak.
  ///
  /// In en, this message translates to:
  /// **'Entries in Streak'**
  String get entriesInStreak;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @startedOn.
  ///
  /// In en, this message translates to:
  /// **'Started on'**
  String get startedOn;

  /// No description provided for @logMealToStartStreak.
  ///
  /// In en, this message translates to:
  /// **'Log a meal today to start your streak'**
  String get logMealToStartStreak;

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

  /// No description provided for @barcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get barcode;

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

  /// No description provided for @weightAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Weight Analytics'**
  String get weightAnalytics;

  /// No description provided for @toGoal.
  ///
  /// In en, this message translates to:
  /// **'TO GOAL'**
  String get toGoal;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get remaining;

  /// No description provided for @weeklyRate.
  ///
  /// In en, this message translates to:
  /// **'WEEKLY RATE'**
  String get weeklyRate;

  /// No description provided for @weeklyLoss.
  ///
  /// In en, this message translates to:
  /// **'weekly loss'**
  String get weeklyLoss;

  /// No description provided for @starting.
  ///
  /// In en, this message translates to:
  /// **'STARTING'**
  String get starting;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'CURRENT'**
  String get current;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get today;

  /// No description provided for @targetLabel.
  ///
  /// In en, this message translates to:
  /// **'TARGET'**
  String get targetLabel;

  /// No description provided for @goalWeight.
  ///
  /// In en, this message translates to:
  /// **'goal weight'**
  String get goalWeight;

  /// No description provided for @eta.
  ///
  /// In en, this message translates to:
  /// **'ETA'**
  String get eta;

  /// No description provided for @sinceStart.
  ///
  /// In en, this message translates to:
  /// **'since start'**
  String get sinceStart;

  /// No description provided for @expectationsDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'These expectations are based on your recent trend and can change as you log new weights.'**
  String get expectationsDisclaimer;

  /// No description provided for @loseVerb.
  ///
  /// In en, this message translates to:
  /// **'lose'**
  String get loseVerb;

  /// No description provided for @gainVerb.
  ///
  /// In en, this message translates to:
  /// **'gain'**
  String get gainVerb;

  /// No description provided for @expectationBlurb.
  ///
  /// In en, this message translates to:
  /// **'Based on your recent trend, you are on track to {direction} about {rate} {unit} per week. At this pace, it will take roughly {eta} to reach your target. You have {remaining} {unit} remaining.'**
  String expectationBlurb(Object direction, Object eta, Object rate, Object remaining, Object unit);

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
  /// **'Reset Password'**
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

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

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

  /// No description provided for @failedToOpenStore.
  ///
  /// In en, this message translates to:
  /// **'Failed to open app store'**
  String get failedToOpenStore;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateAvailable;

  /// No description provided for @newVersionAvailable.
  ///
  /// In en, this message translates to:
  /// **'A new version of Yumie is available.'**
  String get newVersionAvailable;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @whatsNew.
  ///
  /// In en, this message translates to:
  /// **'What\'s New:'**
  String get whatsNew;

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
  /// **'Ask about meals & nutrition'**
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
  /// **'Blood type'**
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
  /// **'Meal saved!'**
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

  /// No description provided for @placeBarcodeInFrame.
  ///
  /// In en, this message translates to:
  /// **'Place barcode in frame and tap camera'**
  String get placeBarcodeInFrame;

  /// No description provided for @placeFridgeInFrame.
  ///
  /// In en, this message translates to:
  /// **'Align the fridge inside the frame'**
  String get placeFridgeInFrame;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get productNotFound;

  /// No description provided for @safetyUnsafe.
  ///
  /// In en, this message translates to:
  /// **'Not safe'**
  String get safetyUnsafe;

  /// No description provided for @safetyGood.
  ///
  /// In en, this message translates to:
  /// **'Good to go'**
  String get safetyGood;

  /// No description provided for @badgeNutriScore.
  ///
  /// In en, this message translates to:
  /// **'Nutri-Score'**
  String get badgeNutriScore;

  /// No description provided for @badgeNova.
  ///
  /// In en, this message translates to:
  /// **'NOVA'**
  String get badgeNova;

  /// No description provided for @allergensTitle.
  ///
  /// In en, this message translates to:
  /// **'Allergens'**
  String get allergensTitle;

  /// No description provided for @contains.
  ///
  /// In en, this message translates to:
  /// **'Contains'**
  String get contains;

  /// No description provided for @allergensNone.
  ///
  /// In en, this message translates to:
  /// **'No allergens listed'**
  String get allergensNone;

  /// No description provided for @serving.
  ///
  /// In en, this message translates to:
  /// **'Serving'**
  String get serving;

  /// No description provided for @kcalPer100g.
  ///
  /// In en, this message translates to:
  /// **'kcal/100g'**
  String get kcalPer100g;

  /// No description provided for @sugar.
  ///
  /// In en, this message translates to:
  /// **'Sugar'**
  String get sugar;

  /// No description provided for @satFat.
  ///
  /// In en, this message translates to:
  /// **'Sat Fat'**
  String get satFat;

  /// No description provided for @salt.
  ///
  /// In en, this message translates to:
  /// **'Salt'**
  String get salt;

  /// No description provided for @ingredientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredientsTitle;

  /// No description provided for @riskAllergen.
  ///
  /// In en, this message translates to:
  /// **'Allergen risk'**
  String get riskAllergen;

  /// No description provided for @riskUltraProcessed.
  ///
  /// In en, this message translates to:
  /// **'Ultra‑processed (NOVA 4)'**
  String get riskUltraProcessed;

  /// No description provided for @riskHighAdditives.
  ///
  /// In en, this message translates to:
  /// **'High additives'**
  String get riskHighAdditives;

  /// No description provided for @riskLowNutri.
  ///
  /// In en, this message translates to:
  /// **'Low Nutri‑Score'**
  String get riskLowNutri;

  /// No description provided for @riskVegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan friendly'**
  String get riskVegan;

  /// No description provided for @riskVegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get riskVegetarian;

  /// No description provided for @riskLooksGood.
  ///
  /// In en, this message translates to:
  /// **'Looks good'**
  String get riskLooksGood;

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

  /// No description provided for @getUnlimitedSearches.
  ///
  /// In en, this message translates to:
  /// **'Get unlimited searches and more!'**
  String get getUnlimitedSearches;

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

  /// No description provided for @watchAdForSearch.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad for Search'**
  String get watchAdForSearch;

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
  /// **'count'**
  String get count;

  /// No description provided for @servings.
  ///
  /// In en, this message translates to:
  /// **'servings'**
  String get servings;

  /// No description provided for @fluidOunces.
  ///
  /// In en, this message translates to:
  /// **'fl oz'**
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

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @g.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get g;

  /// No description provided for @mg.
  ///
  /// In en, this message translates to:
  /// **'mg'**
  String get mg;

  /// No description provided for @cm.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get cm;

  /// No description provided for @m.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get m;

  /// No description provided for @kcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get kcal;

  /// No description provided for @cal.
  ///
  /// In en, this message translates to:
  /// **'cal'**
  String get cal;

  /// No description provided for @lb.
  ///
  /// In en, this message translates to:
  /// **'lb'**
  String get lb;

  /// No description provided for @oz.
  ///
  /// In en, this message translates to:
  /// **'oz'**
  String get oz;

  /// No description provided for @ft.
  ///
  /// In en, this message translates to:
  /// **'ft'**
  String get ft;

  /// No description provided for @inches.
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get inches;

  /// No description provided for @cup.
  ///
  /// In en, this message translates to:
  /// **'cup'**
  String get cup;

  /// No description provided for @tbsp.
  ///
  /// In en, this message translates to:
  /// **'tbsp'**
  String get tbsp;

  /// No description provided for @tsp.
  ///
  /// In en, this message translates to:
  /// **'tsp'**
  String get tsp;

  /// No description provided for @ml.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get ml;

  /// No description provided for @l.
  ///
  /// In en, this message translates to:
  /// **'l'**
  String get l;

  /// No description provided for @upgradeToPremiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremiumTitle;

  /// No description provided for @premiumFeatures.
  ///
  /// In en, this message translates to:
  /// **'Premium Features'**
  String get premiumFeatures;

  /// No description provided for @unlimitedScans.
  ///
  /// In en, this message translates to:
  /// **'Unlimited scans'**
  String get unlimitedScans;

  /// No description provided for @aiNutritionCoach.
  ///
  /// In en, this message translates to:
  /// **'AI nutrition coach'**
  String get aiNutritionCoach;

  /// No description provided for @detailedAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Detailed analytics'**
  String get detailedAnalytics;

  /// No description provided for @personalizedMealPlans.
  ///
  /// In en, this message translates to:
  /// **'Personalized meal plans'**
  String get personalizedMealPlans;

  /// No description provided for @noAdvertisements.
  ///
  /// In en, this message translates to:
  /// **'No advertisements'**
  String get noAdvertisements;

  /// No description provided for @yearlyPremium.
  ///
  /// In en, this message translates to:
  /// **'Yearly Premium'**
  String get yearlyPremium;

  /// No description provided for @monthlyPremium.
  ///
  /// In en, this message translates to:
  /// **'Monthly Premium'**
  String get monthlyPremium;

  /// No description provided for @savePercent.
  ///
  /// In en, this message translates to:
  /// **'Save {percent}%'**
  String savePercent(Object percent);

  /// No description provided for @perYear.
  ///
  /// In en, this message translates to:
  /// **'/year'**
  String get perYear;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get perMonth;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'POPULAR'**
  String get popular;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get maybeLater;

  /// No description provided for @welcomeToYumie.
  ///
  /// In en, this message translates to:
  /// **'🎉 Welcome to Yumie!'**
  String get welcomeToYumie;

  /// No description provided for @unlockPremiumFeatures.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium Features'**
  String get unlockPremiumFeatures;

  /// No description provided for @getMostOutOfHealthJourney.
  ///
  /// In en, this message translates to:
  /// **'Get the most out of your health journey with unlimited access!'**
  String get getMostOutOfHealthJourney;

  /// No description provided for @unlimitedScansAICoaching.
  ///
  /// In en, this message translates to:
  /// **'Unlock unlimited scans, AI coaching, and personalized meal plans!'**
  String get unlimitedScansAICoaching;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @foodNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Food Name'**
  String get foodNameLabel;

  /// No description provided for @managePermissions.
  ///
  /// In en, this message translates to:
  /// **'Manage Permissions'**
  String get managePermissions;

  /// No description provided for @cameraNotificationsAndMore.
  ///
  /// In en, this message translates to:
  /// **'Camera, notifications, and more'**
  String get cameraNotificationsAndMore;

  /// No description provided for @deleteMeal.
  ///
  /// In en, this message translates to:
  /// **'Delete meal'**
  String get deleteMeal;

  /// No description provided for @areYouSureDeleteMeal.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this meal?'**
  String get areYouSureDeleteMeal;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @servings1.
  ///
  /// In en, this message translates to:
  /// **'servings 1'**
  String get servings1;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @ignoreFood.
  ///
  /// In en, this message translates to:
  /// **'Ignore Food'**
  String get ignoreFood;

  /// No description provided for @addComponent.
  ///
  /// In en, this message translates to:
  /// **'Add Component'**
  String get addComponent;

  /// No description provided for @components.
  ///
  /// In en, this message translates to:
  /// **'Components'**
  String get components;

  /// No description provided for @recentFoods.
  ///
  /// In en, this message translates to:
  /// **'Recent Foods'**
  String get recentFoods;

  /// No description provided for @logWeightChange.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get logWeightChange;

  /// No description provided for @lost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get lost;

  /// No description provided for @gained.
  ///
  /// In en, this message translates to:
  /// **'Gained'**
  String get gained;

  /// No description provided for @googleSignInHelp.
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In Help'**
  String get googleSignInHelp;

  /// No description provided for @couldNotOpenTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Could not open Terms of Service'**
  String get couldNotOpenTermsOfService;

  /// No description provided for @couldNotOpenPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Could not open Privacy Policy'**
  String get couldNotOpenPrivacyPolicy;

  /// No description provided for @errorSavingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error saving profile'**
  String get errorSavingProfile;

  /// No description provided for @completeYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get completeYourProfile;

  /// No description provided for @saveAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Save & Continue'**
  String get saveAndContinue;

  /// No description provided for @pleasSignIn.
  ///
  /// In en, this message translates to:
  /// **'Please sign in.'**
  String get pleasSignIn;

  /// No description provided for @noFoodLogsYet.
  ///
  /// In en, this message translates to:
  /// **'No food logs yet.'**
  String get noFoodLogsYet;

  /// No description provided for @healthAIFoodLog.
  ///
  /// In en, this message translates to:
  /// **'HealthAI - Food Log'**
  String get healthAIFoodLog;

  /// No description provided for @addLog.
  ///
  /// In en, this message translates to:
  /// **'Add Log'**
  String get addLog;

  /// No description provided for @unableToShareAtThisTime.
  ///
  /// In en, this message translates to:
  /// **'Unable to share at this time. Please try again.'**
  String get unableToShareAtThisTime;

  /// No description provided for @failedToUpdatePhoto.
  ///
  /// In en, this message translates to:
  /// **'Failed to update photo'**
  String get failedToUpdatePhoto;

  /// No description provided for @changeProfileName.
  ///
  /// In en, this message translates to:
  /// **'Change Profile Name'**
  String get changeProfileName;

  /// No description provided for @failedToUpdateName.
  ///
  /// In en, this message translates to:
  /// **'Failed to update name'**
  String get failedToUpdateName;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @errorUpdatingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error updating profile'**
  String get errorUpdatingProfile;

  /// No description provided for @editGoals.
  ///
  /// In en, this message translates to:
  /// **'Edit Goals'**
  String get editGoals;

  /// No description provided for @goalsUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Goals updated successfully'**
  String get goalsUpdatedSuccessfully;

  /// No description provided for @errorUpdatingGoals.
  ///
  /// In en, this message translates to:
  /// **'Error updating goals'**
  String get errorUpdatingGoals;

  /// No description provided for @couldNotOpenWebsite.
  ///
  /// In en, this message translates to:
  /// **'Could not open website'**
  String get couldNotOpenWebsite;

  /// No description provided for @errorOpeningWebsite.
  ///
  /// In en, this message translates to:
  /// **'Error opening website'**
  String get errorOpeningWebsite;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @reviewMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Meal'**
  String get reviewMealTitle;

  /// No description provided for @startingWeight.
  ///
  /// In en, this message translates to:
  /// **'Starting Weight'**
  String get startingWeight;

  /// No description provided for @appPermissions.
  ///
  /// In en, this message translates to:
  /// **'App Permissions'**
  String get appPermissions;

  /// No description provided for @permissionStatus.
  ///
  /// In en, this message translates to:
  /// **'Permission Status'**
  String get permissionStatus;

  /// No description provided for @manageAppPermissions.
  ///
  /// In en, this message translates to:
  /// **'Manage app permissions to ensure all features work properly'**
  String get manageAppPermissions;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @scanFoodItems.
  ///
  /// In en, this message translates to:
  /// **'Scan food items and take photos of meals'**
  String get scanFoodItems;

  /// No description provided for @photoLibrary.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photoLibrary;

  /// No description provided for @saveScannedImages.
  ///
  /// In en, this message translates to:
  /// **'Save scanned images and select photos'**
  String get saveScannedImages;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @sendMealReminders.
  ///
  /// In en, this message translates to:
  /// **'Send meal reminders and health alerts'**
  String get sendMealReminders;

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need Help?'**
  String get needHelp;

  /// No description provided for @permanentlyDeniedHelp.
  ///
  /// In en, this message translates to:
  /// **'If permissions are permanently denied, you can enable them in your device settings'**
  String get permanentlyDeniedHelp;

  /// No description provided for @openDeviceSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Device Settings'**
  String get openDeviceSettings;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @goodNight.
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get goodNight;

  /// No description provided for @ounces.
  ///
  /// In en, this message translates to:
  /// **'oz'**
  String get ounces;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @trackYourNutrition.
  ///
  /// In en, this message translates to:
  /// **'Track your nutrition'**
  String get trackYourNutrition;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @subscribeForDailyInsights.
  ///
  /// In en, this message translates to:
  /// **'Subscribe for Daily Insights'**
  String get subscribeForDailyInsights;

  /// No description provided for @getPersonalizedHealthInsights.
  ///
  /// In en, this message translates to:
  /// **'Get personalized health insights based on your complete profile'**
  String get getPersonalizedHealthInsights;

  /// No description provided for @upgradeDescription.
  ///
  /// In en, this message translates to:
  /// **'Get unlimited scans, searches, and AI-powered insights'**
  String get upgradeDescription;

  /// No description provided for @unlimitedFoodScans.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Food Scans'**
  String get unlimitedFoodScans;

  /// No description provided for @unlimitedFoodSearches.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Food Searches'**
  String get unlimitedFoodSearches;

  /// No description provided for @unlimitedAICoachMessages.
  ///
  /// In en, this message translates to:
  /// **'Unlimited AI Coach Messages'**
  String get unlimitedAICoachMessages;

  /// No description provided for @dailyHealthInsights.
  ///
  /// In en, this message translates to:
  /// **'Daily Health Insights'**
  String get dailyHealthInsights;

  /// No description provided for @logWaterIntake.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get logWaterIntake;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @freemium.
  ///
  /// In en, this message translates to:
  /// **'Freemium'**
  String get freemium;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @chooseYourPlan.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Plan'**
  String get chooseYourPlan;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'A password reset link will be sent to your email'**
  String get resetPasswordDescription;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account and all data'**
  String get deleteAccountDescription;

  /// No description provided for @confirmDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account?'**
  String get confirmDeleteAccount;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All your data including meals, progress, and settings will be permanently deleted.'**
  String get deleteAccountWarning;

  /// No description provided for @typeDeleteToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type \"DELETE\" to confirm'**
  String get typeDeleteToConfirm;

  /// No description provided for @deleteAccountFinalConfirmation.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get deleteAccountFinalConfirmation;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account Deleted'**
  String get accountDeleted;

  /// No description provided for @errorDeletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Error deleting account'**
  String get errorDeletingAccount;

  /// No description provided for @totalNutrition.
  ///
  /// In en, this message translates to:
  /// **'Total nutrition'**
  String get totalNutrition;

  /// No description provided for @unlockUnlimitedScans.
  ///
  /// In en, this message translates to:
  /// **'Unlock unlimited scans, AI coaching, and\npersonalized meal plans'**
  String get unlockUnlimitedScans;

  /// No description provided for @unlimitedFoodScanning.
  ///
  /// In en, this message translates to:
  /// **'Unlimited food scanning'**
  String get unlimitedFoodScanning;

  /// No description provided for @yearPrice.
  ///
  /// In en, this message translates to:
  /// **'year/\$49.99'**
  String get yearPrice;

  /// No description provided for @monthPrice.
  ///
  /// In en, this message translates to:
  /// **'month/\$7.99'**
  String get monthPrice;

  /// No description provided for @save37.
  ///
  /// In en, this message translates to:
  /// **'Save 37%'**
  String get save37;

  /// No description provided for @youArePremium.
  ///
  /// In en, this message translates to:
  /// **'You Are Premium!'**
  String get youArePremium;

  /// No description provided for @yumiePremiumMonthly.
  ///
  /// In en, this message translates to:
  /// **'Yumie™ Premium Monthly'**
  String get yumiePremiumMonthly;

  /// No description provided for @yumiePremiumYearly.
  ///
  /// In en, this message translates to:
  /// **'Yumie™ Premium Yearly'**
  String get yumiePremiumYearly;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @checkingForPurchases.
  ///
  /// In en, this message translates to:
  /// **'Checking for existing purchases...'**
  String get checkingForPurchases;

  /// No description provided for @purchasesRestored.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored successfully!'**
  String get purchasesRestored;

  /// No description provided for @noPurchasesFound.
  ///
  /// In en, this message translates to:
  /// **'No previous purchases found'**
  String get noPurchasesFound;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore purchases. Please try again.'**
  String get restoreFailed;

  /// No description provided for @restoreInProgress.
  ///
  /// In en, this message translates to:
  /// **'Restoring purchases...'**
  String get restoreInProgress;

  /// No description provided for @bySubscribing.
  ///
  /// In en, this message translates to:
  /// **'By subscribing, you agree to our Terms of Service and Privacy Policy. Subscriptions automatically renew unless cancelled'**
  String get bySubscribing;

  /// No description provided for @permissionsComplete.
  ///
  /// In en, this message translates to:
  /// **'Permissions Complete!'**
  String get permissionsComplete;

  /// No description provided for @whyWeAskForPermissions.
  ///
  /// In en, this message translates to:
  /// **'Why we ask for permissions'**
  String get whyWeAskForPermissions;

  /// No description provided for @permissionsWhyBody.
  ///
  /// In en, this message translates to:
  /// **'We use your camera to scan foods and barcodes, access photos when you upload images, and notifications to remind you to log meals and hydrate.'**
  String get permissionsWhyBody;

  /// No description provided for @permissionsNextScreen.
  ///
  /// In en, this message translates to:
  /// **'On the next screen, you\'ll see the system prompts to grant access. You can change this anytime in Settings.'**
  String get permissionsNextScreen;

  /// No description provided for @references.
  ///
  /// In en, this message translates to:
  /// **'References:'**
  String get references;

  /// No description provided for @cdcAboutBmi.
  ///
  /// In en, this message translates to:
  /// **'CDC: About BMI'**
  String get cdcAboutBmi;

  /// No description provided for @usdaDietaryGuidelines.
  ///
  /// In en, this message translates to:
  /// **'USDA Dietary Guidelines'**
  String get usdaDietaryGuidelines;

  /// No description provided for @termsOfUseEula.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use (EULA)'**
  String get termsOfUseEula;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @manageSessions.
  ///
  /// In en, this message translates to:
  /// **'Manage Sessions'**
  String get manageSessions;

  /// No description provided for @selectLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguageTitle;

  /// No description provided for @chooseYourPreferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language for the app'**
  String get chooseYourPreferredLanguage;

  /// No description provided for @languageChangedTo.
  ///
  /// In en, this message translates to:
  /// **'Language changed to'**
  String get languageChangedTo;

  /// No description provided for @activeSessions.
  ///
  /// In en, this message translates to:
  /// **'Active Sessions'**
  String get activeSessions;

  /// No description provided for @thisDevice.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get thisDevice;

  /// No description provided for @sessionRevoked.
  ///
  /// In en, this message translates to:
  /// **'Session revoked'**
  String get sessionRevoked;

  /// No description provided for @allOtherSessionsSignedOut.
  ///
  /// In en, this message translates to:
  /// **'All other sessions signed out'**
  String get allOtherSessionsSignedOut;

  /// No description provided for @signOutAllOthers.
  ///
  /// In en, this message translates to:
  /// **'Sign Out All Others'**
  String get signOutAllOthers;

  /// No description provided for @noSecurityAlerts.
  ///
  /// In en, this message translates to:
  /// **'No security alerts'**
  String get noSecurityAlerts;

  /// No description provided for @passwordStrengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get passwordStrengthWeak;

  /// No description provided for @passwordStrengthFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get passwordStrengthFair;

  /// No description provided for @passwordStrengthGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get passwordStrengthGood;

  /// No description provided for @passwordStrengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get passwordStrengthStrong;

  /// No description provided for @passwordStrengthVeryStrong.
  ///
  /// In en, this message translates to:
  /// **'Very Strong'**
  String get passwordStrengthVeryStrong;

  /// No description provided for @addLowercaseLetters.
  ///
  /// In en, this message translates to:
  /// **'Add lowercase letters'**
  String get addLowercaseLetters;

  /// No description provided for @addUppercaseLetters.
  ///
  /// In en, this message translates to:
  /// **'Add uppercase letters'**
  String get addUppercaseLetters;

  /// No description provided for @addNumbers.
  ///
  /// In en, this message translates to:
  /// **'Add numbers'**
  String get addNumbers;

  /// No description provided for @addSpecialCharacters.
  ///
  /// In en, this message translates to:
  /// **'Add special characters (!@#\$%^&*)'**
  String get addSpecialCharacters;

  /// No description provided for @avoidCommonPatterns.
  ///
  /// In en, this message translates to:
  /// **'Avoid common patterns'**
  String get avoidCommonPatterns;

  /// No description provided for @requiresAtLeast8Characters.
  ///
  /// In en, this message translates to:
  /// **'Requires at least 8 characters'**
  String get requiresAtLeast8Characters;

  /// No description provided for @tooManySignInAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many sign-in attempts. Please try again later.'**
  String get tooManySignInAttempts;

  /// No description provided for @tooManySignUpAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many sign-up attempts. Please try again later.'**
  String get tooManySignUpAttempts;

  /// No description provided for @tooManyPasswordResetRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many password reset requests. Please try again later.'**
  String get tooManyPasswordResetRequests;

  /// No description provided for @multipleFailedSignInAttempts.
  ///
  /// In en, this message translates to:
  /// **'Multiple Failed Sign-in Attempts'**
  String get multipleFailedSignInAttempts;

  /// No description provided for @excessivePasswordResetRequests.
  ///
  /// In en, this message translates to:
  /// **'Excessive Password Reset Requests'**
  String get excessivePasswordResetRequests;

  /// No description provided for @suspiciousActivityDetected.
  ///
  /// In en, this message translates to:
  /// **'Suspicious Activity Detected'**
  String get suspiciousActivityDetected;

  /// No description provided for @riskLevelMedium.
  ///
  /// In en, this message translates to:
  /// **'MEDIUM'**
  String get riskLevelMedium;

  /// No description provided for @riskLevelHigh.
  ///
  /// In en, this message translates to:
  /// **'HIGH'**
  String get riskLevelHigh;

  /// No description provided for @welcomeToYumiePermissions.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Yumie'**
  String get welcomeToYumiePermissions;

  /// No description provided for @provideBestExperience.
  ///
  /// In en, this message translates to:
  /// **'To provide you with the best experience, we need a few permissions'**
  String get provideBestExperience;

  /// No description provided for @grantPermissions.
  ///
  /// In en, this message translates to:
  /// **'Grant Permissions'**
  String get grantPermissions;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for Now'**
  String get skipForNow;

  /// No description provided for @denied.
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get denied;

  /// No description provided for @granted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get granted;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @signUpToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Sign up to get started with Yumie'**
  String get signUpToGetStarted;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @agreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'and Terms of Service I accept the Privacy Policy'**
  String get agreeToTerms;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signInToAccessAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your account'**
  String get signInToAccessAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signUpWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get signUpWithGoogle;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @signUpWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Apple'**
  String get signUpWithApple;

  /// No description provided for @signInWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInWithApple;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @enterEmailForReset.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address to receive a password reset link'**
  String get enterEmailForReset;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @rateUsOn.
  ///
  /// In en, this message translates to:
  /// **'Rate us on'**
  String get rateUsOn;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent and cannot be undone'**
  String get deleteAccountWarningTitle;

  /// No description provided for @deleteAccountDataList.
  ///
  /// In en, this message translates to:
  /// **'When you delete your account, we will permanently remove:'**
  String get deleteAccountDataList;

  /// No description provided for @allMealLogsAndNutrition.
  ///
  /// In en, this message translates to:
  /// **'All your meal logs and nutrition data'**
  String get allMealLogsAndNutrition;

  /// No description provided for @profileAndPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Your profile and personal information'**
  String get profileAndPersonalInfo;

  /// No description provided for @allUploadedPhotos.
  ///
  /// In en, this message translates to:
  /// **'All uploaded photos and files'**
  String get allUploadedPhotos;

  /// No description provided for @customMealsAndRecipes.
  ///
  /// In en, this message translates to:
  /// **'Your custom meals and recipes'**
  String get customMealsAndRecipes;

  /// No description provided for @allAppPreferences.
  ///
  /// In en, this message translates to:
  /// **'All app preferences and settings'**
  String get allAppPreferences;

  /// No description provided for @activeSessionsAllDevices.
  ///
  /// In en, this message translates to:
  /// **'Active sessions on all devices'**
  String get activeSessionsAllDevices;

  /// No description provided for @exportDataWarning.
  ///
  /// In en, this message translates to:
  /// **'Make sure to export any data you want to keep before proceeding'**
  String get exportDataWarning;

  /// No description provided for @understandActionPermanent.
  ///
  /// In en, this message translates to:
  /// **'I understand this action is permanent'**
  String get understandActionPermanent;

  /// No description provided for @typeDeleteHere.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE here'**
  String get typeDeleteHere;

  /// No description provided for @deleteForever.
  ///
  /// In en, this message translates to:
  /// **'Delete Forever'**
  String get deleteForever;

  /// No description provided for @noSecurityAlertsFound.
  ///
  /// In en, this message translates to:
  /// **'No security alerts'**
  String get noSecurityAlertsFound;

  /// No description provided for @yourAccountLooksGood.
  ///
  /// In en, this message translates to:
  /// **'Your account looks good! No suspicious activity detected.'**
  String get yourAccountLooksGood;

  /// No description provided for @manageActiveSessionsAcrossDevices.
  ///
  /// In en, this message translates to:
  /// **'Manage your active sessions across different devices'**
  String get manageActiveSessionsAcrossDevices;

  /// No description provided for @noActiveSessionsFound.
  ///
  /// In en, this message translates to:
  /// **'No active sessions found'**
  String get noActiveSessionsFound;

  /// No description provided for @signOutAllOtherSessions.
  ///
  /// In en, this message translates to:
  /// **'Sign Out All Others'**
  String get signOutAllOtherSessions;

  /// No description provided for @aiSearch.
  ///
  /// In en, this message translates to:
  /// **'AI Search'**
  String get aiSearch;

  /// No description provided for @aiSearchDescription.
  ///
  /// In en, this message translates to:
  /// **'Search for food items using AI'**
  String get aiSearchDescription;

  /// No description provided for @noIngredientsListedText.
  ///
  /// In en, this message translates to:
  /// **'No ingredients listed'**
  String get noIngredientsListedText;

  /// No description provided for @breakfastTime.
  ///
  /// In en, this message translates to:
  /// **'Breakfast Time'**
  String get breakfastTime;

  /// No description provided for @lunchTime.
  ///
  /// In en, this message translates to:
  /// **'Lunch Time'**
  String get lunchTime;

  /// No description provided for @dinnerTime.
  ///
  /// In en, this message translates to:
  /// **'Dinner Time'**
  String get dinnerTime;

  /// No description provided for @snackTime.
  ///
  /// In en, this message translates to:
  /// **'Snack Time'**
  String get snackTime;

  /// No description provided for @deletingYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account...'**
  String get deletingYourAccount;

  /// No description provided for @thisMayTakeAFewMoments.
  ///
  /// In en, this message translates to:
  /// **'This may take a few moments'**
  String get thisMayTakeAFewMoments;

  /// No description provided for @redirectingToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Redirecting to sign-in...'**
  String get redirectingToSignIn;

  /// No description provided for @weightTrendNoData.
  ///
  /// In en, this message translates to:
  /// **'You have {remaining} {unit} remaining to reach your goal. Log weight entries to see your personalized trend.'**
  String weightTrendNoData(Object remaining, Object unit);

  /// No description provided for @weightTrendHealthyRate.
  ///
  /// In en, this message translates to:
  /// **'At a healthy rate of 0.5 {unit} per week, you could reach your goal in approximately {eta}. You have {remaining} {unit} remaining. Log weight entries to see your personalized trend.'**
  String weightTrendHealthyRate(Object eta, Object rate, Object remaining, Object unit);

  /// No description provided for @accountSuccessfullyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account Successfully Deleted'**
  String get accountSuccessfullyDeleted;

  /// No description provided for @pleaseCloseAndRestartApp.
  ///
  /// In en, this message translates to:
  /// **'Please close and restart the app to continue.'**
  String get pleaseCloseAndRestartApp;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @exportDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Export all your data as a PDF file'**
  String get exportDataDescription;

  /// No description provided for @exportComplete.
  ///
  /// In en, this message translates to:
  /// **'Export Complete'**
  String get exportComplete;

  /// No description provided for @exportCompleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Your data has been exported successfully!'**
  String get exportCompleteMessage;

  /// No description provided for @exportCompleteDescription.
  ///
  /// In en, this message translates to:
  /// **'The PDF file has been saved to your device and can be shared or viewed.'**
  String get exportCompleteDescription;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export Failed'**
  String get exportFailed;

  /// No description provided for @exportingData.
  ///
  /// In en, this message translates to:
  /// **'Exporting your data...'**
  String get exportingData;

  /// No description provided for @exportingDataDescription.
  ///
  /// In en, this message translates to:
  /// **'This may take a few moments'**
  String get exportingDataDescription;

  /// No description provided for @restartApp.
  ///
  /// In en, this message translates to:
  /// **'Restart App'**
  String get restartApp;

  /// No description provided for @cameraAccess.
  ///
  /// In en, this message translates to:
  /// **'Camera Access'**
  String get cameraAccess;

  /// No description provided for @cameraAccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Yumie needs camera access to scan food items and help you log your meals accurately.'**
  String get cameraAccessMessage;

  /// No description provided for @photoLibraryAccess.
  ///
  /// In en, this message translates to:
  /// **'Photo Library Access'**
  String get photoLibraryAccess;

  /// No description provided for @photoLibraryAccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Yumie needs access to your photo library to save scanned images and select photos for meal logging.'**
  String get photoLibraryAccessMessage;

  /// No description provided for @notificationAccess.
  ///
  /// In en, this message translates to:
  /// **'Notification Access'**
  String get notificationAccess;

  /// No description provided for @notificationAccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Yumie needs notification access to send you meal reminders, water intake alerts, and mindful walk prompts.'**
  String get notificationAccessMessage;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// No description provided for @permissionsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Permissions Complete!'**
  String get permissionsCompleted;

  /// No description provided for @allPermissionsGranted.
  ///
  /// In en, this message translates to:
  /// **'All permissions granted! You\'re all set to use Yumie.'**
  String get allPermissionsGranted;

  /// No description provided for @whatIsYourMainGoal.
  ///
  /// In en, this message translates to:
  /// **'What is your main goal?'**
  String get whatIsYourMainGoal;

  /// No description provided for @chooseGoalDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the goal that best aligns with your journey'**
  String get chooseGoalDescription;

  /// No description provided for @loseBodyWeight.
  ///
  /// In en, this message translates to:
  /// **'Lose body weight'**
  String get loseBodyWeight;

  /// No description provided for @gainWeight.
  ///
  /// In en, this message translates to:
  /// **'Gain weight'**
  String get gainWeight;

  /// No description provided for @buildMuscle.
  ///
  /// In en, this message translates to:
  /// **'Build muscle'**
  String get buildMuscle;

  /// No description provided for @eatHealthier.
  ///
  /// In en, this message translates to:
  /// **'Eat healthier'**
  String get eatHealthier;

  /// No description provided for @maintainBodyWeight.
  ///
  /// In en, this message translates to:
  /// **'Maintain body weight'**
  String get maintainBodyWeight;

  /// No description provided for @setRealisticGoalForJourney.
  ///
  /// In en, this message translates to:
  /// **'Set a realistic goal for your journey'**
  String get setRealisticGoalForJourney;

  /// No description provided for @targetWeightSetToCurrent.
  ///
  /// In en, this message translates to:
  /// **'Your target weight is set to your current weight'**
  String get targetWeightSetToCurrent;

  /// No description provided for @iAcceptThe.
  ///
  /// In en, this message translates to:
  /// **'I accept the'**
  String get iAcceptThe;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @johnDoe.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get johnDoe;

  /// No description provided for @yourEmailExample.
  ///
  /// In en, this message translates to:
  /// **'your.email@example.com'**
  String get yourEmailExample;

  /// No description provided for @byContinuingYouAgreeToOur.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our'**
  String get byContinuingYouAgreeToOur;

  /// No description provided for @whatMotivatesYou.
  ///
  /// In en, this message translates to:
  /// **'What motivates you?'**
  String get whatMotivatesYou;

  /// No description provided for @chooseWhatDrivesYou.
  ///
  /// In en, this message translates to:
  /// **'Choose what drives you to achieve your goals'**
  String get chooseWhatDrivesYou;

  /// No description provided for @feelEnergeticEveryDay.
  ///
  /// In en, this message translates to:
  /// **'Feel energetic every day'**
  String get feelEnergeticEveryDay;

  /// No description provided for @achievePersonalMilestone.
  ///
  /// In en, this message translates to:
  /// **'Achieve a personal milestone'**
  String get achievePersonalMilestone;

  /// No description provided for @boostMyConfidence.
  ///
  /// In en, this message translates to:
  /// **'Boost my confidence'**
  String get boostMyConfidence;

  /// No description provided for @longTermHealth.
  ///
  /// In en, this message translates to:
  /// **'Long term health'**
  String get longTermHealth;

  /// No description provided for @trackYourMealsWithEase.
  ///
  /// In en, this message translates to:
  /// **'Track your meals with ease'**
  String get trackYourMealsWithEase;

  /// No description provided for @caloriesLeft.
  ///
  /// In en, this message translates to:
  /// **'calories left'**
  String get caloriesLeft;

  /// No description provided for @thisHelpsUsPersonalizeNutrition.
  ///
  /// In en, this message translates to:
  /// **'This helps us personalize your nutrition plan'**
  String get thisHelpsUsPersonalizeNutrition;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @thisHelpsUsPersonalizeExperience.
  ///
  /// In en, this message translates to:
  /// **'This helps us personalize your experience'**
  String get thisHelpsUsPersonalizeExperience;

  /// No description provided for @older.
  ///
  /// In en, this message translates to:
  /// **'Older'**
  String get older;

  /// No description provided for @younger.
  ///
  /// In en, this message translates to:
  /// **'Younger'**
  String get younger;

  /// No description provided for @yearsOld.
  ///
  /// In en, this message translates to:
  /// **'years old'**
  String get yearsOld;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @teens.
  ///
  /// In en, this message translates to:
  /// **'Teens'**
  String get teens;

  /// No description provided for @yourCurrentWeight.
  ///
  /// In en, this message translates to:
  /// **'Your current weight'**
  String get yourCurrentWeight;

  /// No description provided for @activityLevel.
  ///
  /// In en, this message translates to:
  /// **'Activity level'**
  String get activityLevel;

  /// No description provided for @diabetic.
  ///
  /// In en, this message translates to:
  /// **'Diabetic?'**
  String get diabetic;

  /// No description provided for @howMuchWaterADay.
  ///
  /// In en, this message translates to:
  /// **'How much water a day?'**
  String get howMuchWaterADay;

  /// No description provided for @fitnessProfile.
  ///
  /// In en, this message translates to:
  /// **'Fitness profile'**
  String get fitnessProfile;

  /// No description provided for @dueToCurrentAnswers.
  ///
  /// In en, this message translates to:
  /// **'Due to current answers'**
  String get dueToCurrentAnswers;

  /// No description provided for @remindersWouldYouLike.
  ///
  /// In en, this message translates to:
  /// **'Which reminders would you like to receive?'**
  String get remindersWouldYouLike;

  /// No description provided for @yumieIsCookingUp.
  ///
  /// In en, this message translates to:
  /// **'Yumie is cooking up your personalized nutrition plan...'**
  String get yumieIsCookingUp;

  /// No description provided for @yourAllSet.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set!'**
  String get yourAllSet;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @fiftyPlus.
  ///
  /// In en, this message translates to:
  /// **'50+'**
  String get fiftyPlus;

  /// No description provided for @forties.
  ///
  /// In en, this message translates to:
  /// **'40s'**
  String get forties;

  /// No description provided for @thirties.
  ///
  /// In en, this message translates to:
  /// **'30s'**
  String get thirties;

  /// No description provided for @twenties.
  ///
  /// In en, this message translates to:
  /// **'20s'**
  String get twenties;

  /// No description provided for @weightUnit.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get weightUnit;

  /// No description provided for @heightUnit.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get heightUnit;

  /// No description provided for @feetUnit.
  ///
  /// In en, this message translates to:
  /// **'ft'**
  String get feetUnit;

  /// No description provided for @inchesUnit.
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get inchesUnit;

  /// No description provided for @poundsUnit.
  ///
  /// In en, this message translates to:
  /// **'lbs'**
  String get poundsUnit;

  /// No description provided for @whatIsYourAge.
  ///
  /// In en, this message translates to:
  /// **'What is your age?'**
  String get whatIsYourAge;

  /// No description provided for @whatIsYourHeight.
  ///
  /// In en, this message translates to:
  /// **'What is your height?'**
  String get whatIsYourHeight;

  /// No description provided for @whatIsYourWeight.
  ///
  /// In en, this message translates to:
  /// **'What is your current weight?'**
  String get whatIsYourWeight;

  /// No description provided for @whatIsYourGoalWeight.
  ///
  /// In en, this message translates to:
  /// **'What is your goal weight?'**
  String get whatIsYourGoalWeight;

  /// No description provided for @whatIsYourActivityLevel.
  ///
  /// In en, this message translates to:
  /// **'What is your activity level?'**
  String get whatIsYourActivityLevel;

  /// No description provided for @howMuchWaterDaily.
  ///
  /// In en, this message translates to:
  /// **'How much water do you drink daily?'**
  String get howMuchWaterDaily;

  /// No description provided for @sedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get sedentary;

  /// No description provided for @lightlyActive.
  ///
  /// In en, this message translates to:
  /// **'Lightly Active'**
  String get lightlyActive;

  /// No description provided for @moderatelyActive.
  ///
  /// In en, this message translates to:
  /// **'Moderately Active'**
  String get moderatelyActive;

  /// No description provided for @veryActive.
  ///
  /// In en, this message translates to:
  /// **'Very Active'**
  String get veryActive;

  /// No description provided for @extremelyActive.
  ///
  /// In en, this message translates to:
  /// **'Extremely Active'**
  String get extremelyActive;

  /// No description provided for @aPositive.
  ///
  /// In en, this message translates to:
  /// **'A+'**
  String get aPositive;

  /// No description provided for @aNegative.
  ///
  /// In en, this message translates to:
  /// **'A-'**
  String get aNegative;

  /// No description provided for @bPositive.
  ///
  /// In en, this message translates to:
  /// **'B+'**
  String get bPositive;

  /// No description provided for @bNegative.
  ///
  /// In en, this message translates to:
  /// **'B-'**
  String get bNegative;

  /// No description provided for @abPositive.
  ///
  /// In en, this message translates to:
  /// **'AB+'**
  String get abPositive;

  /// No description provided for @abNegative.
  ///
  /// In en, this message translates to:
  /// **'AB-'**
  String get abNegative;

  /// No description provided for @oPositive.
  ///
  /// In en, this message translates to:
  /// **'O+'**
  String get oPositive;

  /// No description provided for @oNegative.
  ///
  /// In en, this message translates to:
  /// **'O-'**
  String get oNegative;

  /// No description provided for @dontKnow.
  ///
  /// In en, this message translates to:
  /// **'Don\'t know'**
  String get dontKnow;

  /// No description provided for @oneToTwoGlasses.
  ///
  /// In en, this message translates to:
  /// **'1-2 glasses'**
  String get oneToTwoGlasses;

  /// No description provided for @threeToFourGlasses.
  ///
  /// In en, this message translates to:
  /// **'3-4 glasses'**
  String get threeToFourGlasses;

  /// No description provided for @fiveToSixGlasses.
  ///
  /// In en, this message translates to:
  /// **'5-6 glasses'**
  String get fiveToSixGlasses;

  /// No description provided for @sevenToEightGlasses.
  ///
  /// In en, this message translates to:
  /// **'7-8 glasses'**
  String get sevenToEightGlasses;

  /// No description provided for @moreThanEightGlasses.
  ///
  /// In en, this message translates to:
  /// **'More than 8 glasses'**
  String get moreThanEightGlasses;

  /// No description provided for @mealReminders.
  ///
  /// In en, this message translates to:
  /// **'Meal reminders'**
  String get mealReminders;

  /// No description provided for @waterReminders.
  ///
  /// In en, this message translates to:
  /// **'Water reminders'**
  String get waterReminders;

  /// No description provided for @workoutReminders.
  ///
  /// In en, this message translates to:
  /// **'Workout reminders'**
  String get workoutReminders;

  /// No description provided for @progressUpdates.
  ///
  /// In en, this message translates to:
  /// **'Progress updates'**
  String get progressUpdates;

  /// No description provided for @dailyTips.
  ///
  /// In en, this message translates to:
  /// **'Daily tips'**
  String get dailyTips;

  /// No description provided for @youAreAllSet.
  ///
  /// In en, this message translates to:
  /// **'You are all set!'**
  String get youAreAllSet;

  /// No description provided for @welcomeToYourHealthJourney.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your health journey'**
  String get welcomeToYourHealthJourney;

  /// No description provided for @letsGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get started!'**
  String get letsGetStarted;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @cookingUpYourPlan.
  ///
  /// In en, this message translates to:
  /// **'Cooking up your personalized plan'**
  String get cookingUpYourPlan;

  /// No description provided for @analyzingYourData.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your data'**
  String get analyzingYourData;

  /// No description provided for @creatingCustomPlan.
  ///
  /// In en, this message translates to:
  /// **'Creating your custom nutrition plan'**
  String get creatingCustomPlan;

  /// No description provided for @almostDone.
  ///
  /// In en, this message translates to:
  /// **'Almost done!'**
  String get almostDone;

  /// No description provided for @subscriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Subscription Required'**
  String get subscriptionRequired;

  /// No description provided for @upgradeToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to unlock all features'**
  String get upgradeToUnlock;

  /// No description provided for @startFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'Start Free Trial'**
  String get startFreeTrial;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get year;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @mostPopular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get mostPopular;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @internetConnectionRequired.
  ///
  /// In en, this message translates to:
  /// **'Internet connection required'**
  String get internetConnectionRequired;

  /// No description provided for @pleaseCheckConnection.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection'**
  String get pleaseCheckConnection;

  /// No description provided for @restartOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Restart Onboarding'**
  String get restartOnboarding;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @couldNotOpenPlayStore.
  ///
  /// In en, this message translates to:
  /// **'Could not open Play Store'**
  String get couldNotOpenPlayStore;

  /// No description provided for @errorOpeningPlayStore.
  ///
  /// In en, this message translates to:
  /// **'Error opening Play Store'**
  String get errorOpeningPlayStore;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @couldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open link'**
  String get couldNotOpenLink;

  /// No description provided for @nothingFoundInScan.
  ///
  /// In en, this message translates to:
  /// **'Nothing found in scan'**
  String get nothingFoundInScan;

  /// No description provided for @errorOpeningLink.
  ///
  /// In en, this message translates to:
  /// **'Error opening link'**
  String get errorOpeningLink;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @dailyCalorieGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Calorie Goal'**
  String get dailyCalorieGoal;

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get manageSubscription;

  /// No description provided for @deletionFailed.
  ///
  /// In en, this message translates to:
  /// **'Deletion Failed'**
  String get deletionFailed;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @grantPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// No description provided for @littleOrNoExercise.
  ///
  /// In en, this message translates to:
  /// **'Little or no exercise'**
  String get littleOrNoExercise;

  /// No description provided for @lightExercise.
  ///
  /// In en, this message translates to:
  /// **'Light exercise/sports 1-3 days/week'**
  String get lightExercise;

  /// No description provided for @moderateExercise.
  ///
  /// In en, this message translates to:
  /// **'Moderate exercise/sports 3-5 days/week'**
  String get moderateExercise;

  /// No description provided for @hardExercise.
  ///
  /// In en, this message translates to:
  /// **'Hard exercise/sports 6-7 days/week'**
  String get hardExercise;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @notificationsForMealLogging.
  ///
  /// In en, this message translates to:
  /// **'Notifications for meal logging reminders'**
  String get notificationsForMealLogging;

  /// No description provided for @notificationsForWaterIntake.
  ///
  /// In en, this message translates to:
  /// **'Notifications for water intake reminders'**
  String get notificationsForWaterIntake;

  /// No description provided for @notificationsForMindfulWalk.
  ///
  /// In en, this message translates to:
  /// **'Notifications for mindful walk reminders'**
  String get notificationsForMindfulWalk;

  /// No description provided for @increment.
  ///
  /// In en, this message translates to:
  /// **'Increment'**
  String get increment;

  /// No description provided for @enterNewName.
  ///
  /// In en, this message translates to:
  /// **'Enter new name'**
  String get enterNewName;

  /// No description provided for @readOurPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Read our privacy policy'**
  String get readOurPrivacyPolicy;

  /// No description provided for @readOurTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Read our terms of service'**
  String get readOurTermsOfService;

  /// No description provided for @helpUsCalculateYourHealthGoals.
  ///
  /// In en, this message translates to:
  /// **'Help us calculate your health goals'**
  String get helpUsCalculateYourHealthGoals;

  /// No description provided for @thisHelpsUsTrackYourProgress.
  ///
  /// In en, this message translates to:
  /// **'This helps us track your progress'**
  String get thisHelpsUsTrackYourProgress;

  /// No description provided for @setARealisticGoalForYourJourney.
  ///
  /// In en, this message translates to:
  /// **'Set a realistic goal for your journey'**
  String get setARealisticGoalForYourJourney;

  /// No description provided for @thisHelpsUsPersonalizeYourPlan.
  ///
  /// In en, this message translates to:
  /// **'This helps us personalize your plan'**
  String get thisHelpsUsPersonalizeYourPlan;

  /// No description provided for @stayingHydratedIsKeyToYourHealth.
  ///
  /// In en, this message translates to:
  /// **'Staying hydrated is key to your health'**
  String get stayingHydratedIsKeyToYourHealth;

  /// No description provided for @yourFitnessProfileDueToYourAnswers.
  ///
  /// In en, this message translates to:
  /// **'Your fitness profile due to your answers'**
  String get yourFitnessProfileDueToYourAnswers;

  /// No description provided for @currentBMI.
  ///
  /// In en, this message translates to:
  /// **'Current BMI'**
  String get currentBMI;

  /// No description provided for @obese.
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get obese;

  /// No description provided for @activityLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get activityLevelLabel;

  /// No description provided for @bloodTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Blood Type'**
  String get bloodTypeLabel;

  /// No description provided for @diabeticLabel.
  ///
  /// In en, this message translates to:
  /// **'Diabetic'**
  String get diabeticLabel;

  /// No description provided for @waterIntakeLabel.
  ///
  /// In en, this message translates to:
  /// **'Water Intake'**
  String get waterIntakeLabel;

  /// No description provided for @heresYourPersonalizedNutritionPlan.
  ///
  /// In en, this message translates to:
  /// **'Here\'s your personalized nutrition plan. Welcome to your health journey with Yumie'**
  String get heresYourPersonalizedNutritionPlan;

  /// No description provided for @caloriesGoal.
  ///
  /// In en, this message translates to:
  /// **'Calories Goal'**
  String get caloriesGoal;

  /// No description provided for @carbsGoal.
  ///
  /// In en, this message translates to:
  /// **'Carbs Goal'**
  String get carbsGoal;

  /// No description provided for @startNow.
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get startNow;

  /// No description provided for @underweight.
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get underweight;

  /// No description provided for @normalWeight.
  ///
  /// In en, this message translates to:
  /// **'Normal weight'**
  String get normalWeight;

  /// No description provided for @healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get healthy;

  /// No description provided for @overweight.
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get overweight;

  /// No description provided for @avocadoToast.
  ///
  /// In en, this message translates to:
  /// **'Avocado Toast'**
  String get avocadoToast;

  /// No description provided for @italianSalad.
  ///
  /// In en, this message translates to:
  /// **'Italian Salad'**
  String get italianSalad;

  /// No description provided for @chickenKatsuRiceBowl.
  ///
  /// In en, this message translates to:
  /// **'Chicken Katsu Rice Bowl'**
  String get chickenKatsuRiceBowl;

  /// No description provided for @yourTargetWeightIsSetToCurrent.
  ///
  /// In en, this message translates to:
  /// **'Your target weight is set to your current weight'**
  String get yourTargetWeightIsSetToCurrent;

  /// No description provided for @couldNotGenerateYourPlan.
  ///
  /// In en, this message translates to:
  /// **'Could not generate your plan. Please try again.'**
  String get couldNotGenerateYourPlan;

  /// No description provided for @somethingWentWrongRestart.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please restart the onboarding process.'**
  String get somethingWentWrongRestart;

  /// No description provided for @yourBMI.
  ///
  /// In en, this message translates to:
  /// **'Your BMI:'**
  String get yourBMI;

  /// No description provided for @lbs.
  ///
  /// In en, this message translates to:
  /// **'lbs'**
  String get lbs;

  /// No description provided for @yourActivityLevel.
  ///
  /// In en, this message translates to:
  /// **'Your activity level'**
  String get yourActivityLevel;

  /// No description provided for @analyzingFridge.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your fridge...'**
  String get analyzingFridge;

  /// No description provided for @aiDetectingFoodItems.
  ///
  /// In en, this message translates to:
  /// **'AI is detecting food items'**
  String get aiDetectingFoodItems;

  /// No description provided for @tryClearerPhoto.
  ///
  /// In en, this message translates to:
  /// **'Try taking a clearer photo of your fridge'**
  String get tryClearerPhoto;

  /// No description provided for @generating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get generating;

  /// No description provided for @premiumStatus.
  ///
  /// In en, this message translates to:
  /// **'Premium Status'**
  String get premiumStatus;

  /// No description provided for @thankYouForSupport.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your support! 💚'**
  String get thankYouForSupport;

  /// No description provided for @yourPremiumFeatures.
  ///
  /// In en, this message translates to:
  /// **'Your Premium Features'**
  String get yourPremiumFeatures;

  /// No description provided for @subscriptionError.
  ///
  /// In en, this message translates to:
  /// **'Subscription Error'**
  String get subscriptionError;

  /// No description provided for @unknownErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get unknownErrorOccurred;

  /// No description provided for @privacyAndAds.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Ads'**
  String get privacyAndAds;

  /// No description provided for @reviewAdPreferences.
  ///
  /// In en, this message translates to:
  /// **'Review your ad preferences'**
  String get reviewAdPreferences;

  /// No description provided for @privacyOptionsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Privacy options are not available in your region.'**
  String get privacyOptionsNotAvailable;

  /// No description provided for @consentFlowCompleted.
  ///
  /// In en, this message translates to:
  /// **'Consent flow completed!'**
  String get consentFlowCompleted;

  /// No description provided for @appleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in failed'**
  String get appleSignInFailed;

  /// No description provided for @adFailedToShow.
  ///
  /// In en, this message translates to:
  /// **'Ad failed to show. Please try again.'**
  String get adFailedToShow;

  /// No description provided for @adNotLoadedYet.
  ///
  /// In en, this message translates to:
  /// **'Ad not loaded yet. Please try again.'**
  String get adNotLoadedYet;

  /// No description provided for @errorRequestingPermissions.
  ///
  /// In en, this message translates to:
  /// **'Error requesting permissions'**
  String get errorRequestingPermissions;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get showMore;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @noSavedCustomMeals.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any saved custom meals.'**
  String get noSavedCustomMeals;

  /// No description provided for @savedCustomMealsPlus.
  ///
  /// In en, this message translates to:
  /// **'Saved custom meals +'**
  String get savedCustomMealsPlus;

  /// No description provided for @customBuilding.
  ///
  /// In en, this message translates to:
  /// **'Custom Building'**
  String get customBuilding;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get enterName;

  /// No description provided for @enterFoodName.
  ///
  /// In en, this message translates to:
  /// **'Enter food name'**
  String get enterFoodName;

  /// No description provided for @congratulationsGoalReached.
  ///
  /// In en, this message translates to:
  /// **'🎉 Congratulations!'**
  String get congratulationsGoalReached;

  /// No description provided for @youReachedGoalWeight.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached your goal weight!'**
  String get youReachedGoalWeight;

  /// No description provided for @switchToMaintenancePlan.
  ///
  /// In en, this message translates to:
  /// **'Now that you\'ve reached your goal weight, let\'s switch your nutritional plan to maintain your weight!'**
  String get switchToMaintenancePlan;

  /// No description provided for @letsDoIt.
  ///
  /// In en, this message translates to:
  /// **'LET\'S DO IT!'**
  String get letsDoIt;

  /// No description provided for @keepUpGreatWork.
  ///
  /// In en, this message translates to:
  /// **'Keep up the great work!'**
  String get keepUpGreatWork;

  /// No description provided for @generatingMaintenancePlan.
  ///
  /// In en, this message translates to:
  /// **'Generating your maintenance plan...'**
  String get generatingMaintenancePlan;

  /// No description provided for @maintenancePlanUpdated.
  ///
  /// In en, this message translates to:
  /// **'🎉 Your nutritional plan has been updated for weight maintenance!'**
  String get maintenancePlanUpdated;

  /// No description provided for @failedToGenerateMaintenancePlan.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate maintenance plan. Please try again.'**
  String get failedToGenerateMaintenancePlan;

  /// No description provided for @heresYourMaintenancePlan.
  ///
  /// In en, this message translates to:
  /// **'Here\'s your new maintenance plan!'**
  String get heresYourMaintenancePlan;

  /// No description provided for @keepThisPlan.
  ///
  /// In en, this message translates to:
  /// **'Keep This Plan'**
  String get keepThisPlan;

  /// No description provided for @chooseDifferentGoal.
  ///
  /// In en, this message translates to:
  /// **'Choose Different Goal'**
  String get chooseDifferentGoal;

  /// No description provided for @whatsYourNewGoal.
  ///
  /// In en, this message translates to:
  /// **'What\'s your new goal?'**
  String get whatsYourNewGoal;

  /// No description provided for @whatsYourNewTargetWeight.
  ///
  /// In en, this message translates to:
  /// **'What\'s your new target weight?'**
  String get whatsYourNewTargetWeight;

  /// No description provided for @yumieGeneratingNewPlan.
  ///
  /// In en, this message translates to:
  /// **'Yumie is generating your new personalized plan...'**
  String get yumieGeneratingNewPlan;

  /// No description provided for @yourNewPlanReady.
  ///
  /// In en, this message translates to:
  /// **'Your new plan is ready!'**
  String get yourNewPlanReady;

  /// No description provided for @startWithNewPlan.
  ///
  /// In en, this message translates to:
  /// **'Start With New Plan'**
  String get startWithNewPlan;

  /// No description provided for @generateNewPlan.
  ///
  /// In en, this message translates to:
  /// **'Generate New Plan'**
  String get generateNewPlan;

  /// No description provided for @planGenerationLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used your 2 plan generations for this period.'**
  String get planGenerationLimitReached;

  /// No description provided for @waterGoal.
  ///
  /// In en, this message translates to:
  /// **'Water Goal'**
  String get waterGoal;

  /// No description provided for @glasses.
  ///
  /// In en, this message translates to:
  /// **'glasses'**
  String get glasses;

  /// No description provided for @planGenerationInfo.
  ///
  /// In en, this message translates to:
  /// **'You can generate {remaining} more personalized plans in the next 14 days.'**
  String planGenerationInfo(int remaining);

  /// No description provided for @nextPlanAvailable.
  ///
  /// In en, this message translates to:
  /// **'Try again in {days} days'**
  String nextPlanAvailable(int days);

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @planDeclined.
  ///
  /// In en, this message translates to:
  /// **'Plan declined'**
  String get planDeclined;

  /// No description provided for @accountDeletionWarning.
  ///
  /// In en, this message translates to:
  /// **'Your account will be deleted in 48 hours. If you log back in to this account within 48 hours, it will reactivate your account and cancel the deletion.'**
  String get accountDeletionWarning;

  /// No description provided for @accountScheduledForDeletion.
  ///
  /// In en, this message translates to:
  /// **'Account scheduled for deletion'**
  String get accountScheduledForDeletion;

  /// No description provided for @reactivateAccount.
  ///
  /// In en, this message translates to:
  /// **'Reactivate Account'**
  String get reactivateAccount;

  /// No description provided for @accountReactivated.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Your account has been reactivated.'**
  String get accountReactivated;

  /// No description provided for @accountDeletionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Account deletion has been cancelled.'**
  String get accountDeletionCancelled;

  /// No description provided for @emailVerificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Email Verification Required'**
  String get emailVerificationRequired;

  /// No description provided for @pleaseVerifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email address to continue'**
  String get pleaseVerifyEmail;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a verification link to your email address. Please check your inbox and click the link to verify your account.'**
  String get verificationEmailSent;

  /// No description provided for @waitingForVerification.
  ///
  /// In en, this message translates to:
  /// **'Waiting for email verification...'**
  String get waitingForVerification;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email and click the verification link'**
  String get checkYourEmail;

  /// No description provided for @resendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Email'**
  String get resendVerificationEmail;

  /// No description provided for @verificationLinkAlreadySent.
  ///
  /// In en, this message translates to:
  /// **'A verification link has already been sent to this email address. Please check your inbox or wait a few minutes before requesting a new one.'**
  String get verificationLinkAlreadySent;

  /// No description provided for @emailVerified.
  ///
  /// In en, this message translates to:
  /// **'Email verified successfully!'**
  String get emailVerified;

  /// No description provided for @emailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Email not verified yet. Please check your inbox.'**
  String get emailNotVerified;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get changeEmail;

  /// No description provided for @continueToApp.
  ///
  /// In en, this message translates to:
  /// **'Continue to App'**
  String get continueToApp;

  /// No description provided for @failedToSendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Failed to send verification email'**
  String get failedToSendVerificationEmail;

  /// No description provided for @failedToResendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Failed to resend verification email'**
  String get failedToResendVerificationEmail;

  /// No description provided for @errorCheckingVerification.
  ///
  /// In en, this message translates to:
  /// **'Error checking verification'**
  String get errorCheckingVerification;

  /// No description provided for @helloIAmYumie.
  ///
  /// In en, this message translates to:
  /// **'Hello, I am Yumie! Log a meal to start your streak today!'**
  String get helloIAmYumie;

  /// No description provided for @happyBirthday.
  ///
  /// In en, this message translates to:
  /// **'🎉 Happy Birthday!'**
  String get happyBirthday;

  /// No description provided for @birthdayMessage.
  ///
  /// In en, this message translates to:
  /// **'Hope you have a wonderful day! You\'re now {age} years old.'**
  String birthdayMessage(int age);

  /// No description provided for @selectBirthday.
  ///
  /// In en, this message translates to:
  /// **'Select your birthday'**
  String get selectBirthday;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @accountAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Account Already Exists'**
  String get accountAlreadyExists;

  /// No description provided for @accountExistsMessage.
  ///
  /// In en, this message translates to:
  /// **'An account with this email address already exists. Would you like to sign in instead?'**
  String get accountExistsMessage;

  /// No description provided for @accountUsesDifferentSignIn.
  ///
  /// In en, this message translates to:
  /// **'Account Uses Different Sign-In Method'**
  String get accountUsesDifferentSignIn;

  /// No description provided for @emailSignedUpWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'This email is already signed up with Google. Please use \"Sign in with Google\" instead.'**
  String get emailSignedUpWithGoogle;

  /// No description provided for @emailSignedUpWithPassword.
  ///
  /// In en, this message translates to:
  /// **'This email is already signed up with email and password. Please sign in using your password instead.'**
  String get emailSignedUpWithPassword;

  /// No description provided for @useGoogleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Use Google Sign-In'**
  String get useGoogleSignIn;

  /// No description provided for @signInWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign In with Email'**
  String get signInWithEmail;

  /// No description provided for @signInSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Sign in successful!'**
  String get signInSuccessful;

  /// No description provided for @signUpSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Sign up successful!'**
  String get signUpSuccessful;

  /// No description provided for @emailVerifiedWelcome.
  ///
  /// In en, this message translates to:
  /// **'Email verified! Welcome!'**
  String get emailVerifiedWelcome;

  /// No description provided for @premiumCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'You have cancelled your subscription'**
  String get premiumCancelledTitle;

  /// No description provided for @premiumCancelledWillEndOn.
  ///
  /// In en, this message translates to:
  /// **'Your premium access will end on {date}'**
  String premiumCancelledWillEndOn(String date);

  /// No description provided for @manageSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscriptions'**
  String get manageSubscriptions;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'de', 'en', 'es', 'fr', 'hi', 'it', 'ja', 'ko', 'nl', 'pt', 'ru', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'hi': return AppLocalizationsHi();
    case 'it': return AppLocalizationsIt();
    case 'ja': return AppLocalizationsJa();
    case 'ko': return AppLocalizationsKo();
    case 'nl': return AppLocalizationsNl();
    case 'pt': return AppLocalizationsPt();
    case 'ru': return AppLocalizationsRu();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
