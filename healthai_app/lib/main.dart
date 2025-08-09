import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/meal.dart';
import 'models/user.dart';
import 'services/meal_service.dart';
import 'services/user_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'log_meal_page.dart';
import 'models/custom_meal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'scan_page.dart';
import 'nutritional_plan_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'onboarding_flow.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'services/ai_service.dart';
import 'package:lottie/lottie.dart';
import 'generated_meal_fridge_page.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

// import 'package:firebase_analytics/firebase_analytics.dart';  // Removed due to Kotlin conflicts
// import 'package:firebase_analytics/observer.dart';  // Removed due to Kotlin conflicts
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'l10n/app_localizations.dart';
import 'utils/constants.dart';
import 'providers/preferences_provider.dart';
import 'providers/language_provider.dart';

import 'widgets/password_strength_indicator.dart';
import 'utils/onboarding_helper.dart';
import 'services/permission_service.dart';
import 'subscription_popup_page.dart';

import 'permission_request_screen.dart';
import 'permission_status_screen.dart';
import 'services/logging_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import 'utils/validation.dart';
import 'services/error_handler.dart';
import 'services/auth_service.dart';
import 'services/device_session_service.dart';
import 'services/account_deletion_service.dart';
import 'services/rate_limiting_service.dart';
import 'services/security_monitoring_service.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'config/payment_config.dart';
import 'services/subscription_service.dart';
import 'subscription_page.dart';

// Global helper function to translate meal types
String getMealTypeLocalized(BuildContext context, String mealType) {
  final localizations = AppLocalizations.of(context)!;
  switch (mealType.toLowerCase()) {
    case 'breakfast':
      return localizations.breakfast;
    case 'lunch':
      return localizations.lunch;
    case 'dinner':
      return localizations.dinner;
    case 'snack':
      return localizations.snack;
    default:
      return mealType.capitalize();
  }
}

// Global helper function to get current meal period
String getCurrentMealPeriod() {
  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 11) return 'breakfast';
  if (hour >= 11 && hour < 16) return 'lunch';
  if (hour >= 16 && hour < 21) return 'dinner';
  return 'snack';
}

// Custom TextField with floating Done button for iOS
class _NumericTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final InputDecoration? decoration;
  final Function(String)? onChanged;
  final bool enabled;

  const _NumericTextField({
    required this.controller,
    this.hintText,
    this.decoration,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<_NumericTextField> createState() => _NumericTextFieldState();
}

class _NumericTextFieldState extends State<_NumericTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onCheckmarkTap() {
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.number,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      decoration: (widget.decoration ?? InputDecoration(
        hintText: widget.hintText,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        filled: true,
        fillColor: kPrimaryGreen.withOpacity(0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      )).copyWith(
        suffixIcon: _isFocused
            ? IconButton(
                icon: Icon(Icons.check, color: kPrimaryGreen, size: 20),
                onPressed: _onCheckmarkTap,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 40, minHeight: 40),
              )
            : null,
      ),
    );
  }
}

// Initialize FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message
}

// Simple Android notification system - no complex background callbacks needed

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/New_York')); // Set default timezone
  
  // Initialize local notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Handle notification tap
      print('Notification tapped: ${response.payload}');
    },
  );

  // Create Android notification channels for proper Android notifications
  const AndroidNotificationChannel mealChannel = AndroidNotificationChannel(
    'meal_channel',
    'Meal Logging',
    description: 'Notifications for meal logging reminders',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  const AndroidNotificationChannel waterChannel = AndroidNotificationChannel(
    'water_channel',
    'Water Intake',
    description: 'Notifications for water intake reminders',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  const AndroidNotificationChannel walkChannel = AndroidNotificationChannel(
    'walk_channel',
    'Mindful Walks',
    description: 'Notifications for mindful walk reminders',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );







  // Create the channels
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(mealChannel);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(waterChannel);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(walkChannel);


  // Request notification permissions
  // For Android, permissions are handled automatically by the plugin
  // For iOS, permissions are requested during initialization via DarwinInitializationSettings
  
  // Simple Android notifications - no complex initialization needed

  // Initialize Firebase - Android will use google-services.json, iOS will use the options
  await Firebase.initializeApp();
  
  // Verify Firebase configuration
      // Firebase initialization complete
  
  log.initialize(); // THEN: Initialize logging service
  
  // Force Firebase to use the correct project
  // Firebase configuration verified
  try {
    // Services initialized
    await SubscriptionService().initializeBilling();

    MobileAds.instance.initialize(); // Initialize AdMob

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) {
              final prefs = PreferencesProvider();
              prefs.loadPreferences(); // Load preferences when provider is created
              return prefs;
            },
          ),
          ChangeNotifierProvider(
            create: (_) {
              final languageProvider = LanguageProvider();
              languageProvider.initialize(); // Initialize language on startup
              return languageProvider;
            },
          ),
        ],
        child: const HealthAIApp(),
      ),
    );
  } catch (e, stack) {
    // Startup error handled
    runApp(ErrorScreen(error: e.toString()));
  }
}

class ErrorScreen extends StatelessWidget {
  final String error;
  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 64),
                SizedBox(height: 24),
                Text('Startup Error', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Text(error, style: TextStyle(fontSize: 16, color: Colors.black54), textAlign: TextAlign.center),
                SizedBox(height: 32),
                Text('Please check your network connection or contact support.',
                  style: TextStyle(fontSize: 16, color: Colors.black45), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HealthAIApp extends StatelessWidget {
  const HealthAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferencesProvider>(context);
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Yumie App',
          navigatorObservers: [
            // FirebaseAnalyticsObserver removed due to Kotlin conflicts
          ],
          // Localization setup
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
            Locale('es'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: languageProvider.isInitialized ? languageProvider.currentLocale : _getLocale(prefs.language),
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            if (languageProvider.isInitialized) {
              return languageProvider.currentLocale;
            }
            // Fallback to existing logic if language provider not initialized
            if (prefs.language.isNotEmpty &&
                supportedLocales.any((l) => l.languageCode == prefs.language)) {
              return Locale(prefs.language);
            }
            // Otherwise, use device language if supported
            if (deviceLocale != null &&
                supportedLocales.any((l) => l.languageCode == deviceLocale.languageCode)) {
              return Locale(deviceLocale.languageCode!);
            }
            // Default to English
            return const Locale('en');
          },
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: kPrimaryGreen,
          onPrimary: Colors.white,
          secondary: kSecondaryBlue,
          onSecondary: Colors.white,
          error: kWarningRed,
          onError: Colors.white,
          surface: kContainerGrey,
          onSurface: Colors.black,
        ),
        scaffoldBackgroundColor: kBackgroundWhite,
        appBarTheme: AppBarTheme(
          backgroundColor: kPrimaryGreen,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: kSecondaryBlue,
            side: BorderSide(color: kSecondaryBlue, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kContainerGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: kPrimaryGreen, width: 2),
          ),
          labelStyle: TextStyle(color: kPrimaryGreen),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: kPrimaryGreen,
          secondary: kSecondaryBlue,
          error: kWarningRed,
          background: Colors.black,
          surface: Colors.black,
          onBackground: Colors.white,
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.black,
        cardColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: kPrimaryGreen, // Always green
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: kSecondaryBlue,
            side: BorderSide(color: kSecondaryBlue, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.black,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: kPrimaryGreen, width: 2),
          ),
          labelStyle: TextStyle(color: Colors.white),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
          displayLarge: TextStyle(color: Colors.white),
          displayMedium: TextStyle(color: Colors.white),
          displaySmall: TextStyle(color: Colors.white),
          headlineLarge: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
          headlineSmall: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
          labelLarge: TextStyle(color: Colors.white),
          labelMedium: TextStyle(color: Colors.white),
          labelSmall: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        dividerColor: Colors.white24,
      ),
                  themeMode: ThemeMode.light,
          home: const SplashOrApp(),
        );
      },
    );
  }
}

class SplashOrApp extends StatefulWidget {
  const SplashOrApp({super.key});
  @override
  State<SplashOrApp> createState() => _SplashOrAppState();
}

class _SplashOrAppState extends State<SplashOrApp> with SingleTickerProviderStateMixin {
  bool _ready = false;
  bool _hasCheckedPermissions = false;
  bool _shouldShowPermissions = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _waitForAppReady();
  }

  Future<void> _waitForAppReady() async {
    final minSplash = Future.delayed(const Duration(milliseconds: 350));
    User? user;
    try {
      await for (final u in FirebaseAuth.instance.authStateChanges()) {
        user = u;
        break;
      }
      if (user != null) {
        try {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        } catch (e, stack) {
          // Firestore fetch failed
        }
      }
    } catch (e, stack) {
      // Auth state error
    }
    
    // Check permissions
    final shouldRequest = await PermissionService.shouldRequestPermissions();
    
    await minSplash;
    if (mounted) {
      setState(() {
        _ready = true;
        _hasCheckedPermissions = true;
        _shouldShowPermissions = shouldRequest;
      });
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show permission screen if needed
    if (_ready && _hasCheckedPermissions && _shouldShowPermissions) {
      return PermissionRequestScreen(
        onPermissionsComplete: () {
          setState(() {
            _shouldShowPermissions = false;
          });
        },
      );
    }

    return Container(
      color: kPrimaryGreen,
      child: Stack(
        children: [
          // Home page (always present, but under splash content)
          if (_ready) const MyApp(),
          // Splash content with fade-out transition
          FadeTransition(
            opacity: ReverseAnimation(_animation),
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.7, end: 1.0),
                duration: Duration(milliseconds: 700),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) => Transform.scale(
                  scale: scale,
                  child: child,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(height: 28),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: Duration(milliseconds: 900),
                      curve: Curves.easeIn,
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: child,
                      ),
                      child: Text(
                        'Yumie',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontFamily: 'Montserrat',
                          decoration: TextDecoration.none,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferencesProvider>(context);
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasData) {
          // User is logged in, check if onboarding is completed
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return OnboardingFlowPage();
              }

              final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
              // Use a single boolean flag for onboarding completion
              final onboardingCompleted = hasCompletedOnboarding(userData);

              if (!onboardingCompleted) {
                return OnboardingFlowPage();
              }

              // Check if we should show subscription popup for returning users (occasional)
              return FutureBuilder<bool>(
                future: SubscriptionPopupPage.shouldShowPopup(isPostOnboarding: false),
                builder: (context, popupSnapshot) {
                  if (popupSnapshot.connectionState == ConnectionState.waiting) {
              return MainNavScreen();
                  }
                  
                  if (popupSnapshot.data == true) {
                    return SubscriptionPopupPage(
                      onDismiss: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => MainNavScreen()),
                        );
                      },
                    );
                  }
                  
                  return MainNavScreen();
                },
              );
            },
          );
        }
        
        return AuthScreen();
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String message = '';
  bool isLoading = false;
  bool showSignUp = true; // Default to sign up page
  final TextEditingController nameController = TextEditingController();
  bool acceptTerms = false;
  bool isIOS = Platform.isIOS;
  bool isAndroid = Platform.isAndroid;
  // final FirebaseAnalytics analytics = FirebaseAnalytics.instance;  // Removed due to Kotlin conflicts
  String _currentPassword = '';
  bool _isPasswordVisible = false;
  final AuthService _authService = AuthService();
  final RateLimitingService _rateLimitingService = RateLimitingService();
  final SecurityMonitoringService _securityService = SecurityMonitoringService();

  @override
  void initState() {
    super.initState();
    // Listen to password changes for strength indicator
    passwordController.addListener(_onPasswordChanged);
    // Initialize security monitoring
    _securityService.initialize();
  }

  @override
  void dispose() {
    passwordController.removeListener(_onPasswordChanged);
    super.dispose();
  }

  void _onPasswordChanged() {
    setState(() {
      _currentPassword = passwordController.text;
    });
  }



  void _showAccountNotFoundDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.grey[50]!],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: kPrimaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_search_rounded,
                    size: 40,
                    color: kPrimaryGreen,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Account Not Found',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'We couldn\'t find an account with this email address. Would you like to create a new account instead?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() => showSignUp = true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAccountExistsDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.grey[50]!],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_off_rounded,
                    size: 40,
                    color: Colors.orange[700],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Account Already Exists',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'An account with this email address already exists. Would you like to sign in instead?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() => showSignUp = false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();
    String resetMessage = '';
    bool resetLoading = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_reset, size: 48, color: kPrimaryGreen),
                    SizedBox(height: 16),
                    Text(AppLocalizations.of(context)!.resetPasswordTitle, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(AppLocalizations.of(context)!.enterEmailForReset,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: resetEmailController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.emailAddress,
                        hintText: 'your.email@example.com',
                        prefixIcon: Icon(Icons.email_outlined, color: kPrimaryGreen),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: kPrimaryGreen, width: 2),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16),
                    if (resetMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          resetMessage,
                          style: TextStyle(
                            color: resetMessage.startsWith('Success') ? kPrimaryGreen : kWarningRed,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kPrimaryGreen,
                            side: BorderSide(color: kPrimaryGreen),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(AppLocalizations.of(context)!.cancel),
                        ),
                        SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: resetLoading
                              ? null
                              : () async {
                                  final email = resetEmailController.text.trim();
                                  if (email.isEmpty) {
                                    setDialogState(() {
                                      resetMessage = 'Please enter your email address';
                                    });
                                    return;
                                  }
                                  
                                  if (!ValidationUtils.isValidEmail(email)) {
                                    setDialogState(() {
                                      resetMessage = 'Please enter a valid email address';
                                    });
                                    return;
                                  }

                                  setDialogState(() { 
                                    resetLoading = true; 
                                    resetMessage = ''; 
                                  });
                                  
                                  // Check rate limit for forgot password
                                  final rateLimitResult = await _rateLimitingService.checkRateLimit('forgot_password_dialog', identifier: email);
                                  if (!rateLimitResult.allowed) {
                                    setDialogState(() {
                                      resetMessage = rateLimitResult.message ?? 'Too many password reset requests. Please try again later.';
                                      resetLoading = false;
                                    });
                                    return;
                                  }

                                  // Record the attempt
                                  await _rateLimitingService.recordAttempt('forgot_password_dialog', identifier: email);
                                  
                                  try {
                                    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                                    
                                    // Record password reset request for security monitoring
                                    await _securityService.recordSecurityEvent(
                                      'password_reset_request',
                                      email: email,
                                      successful: true,
                                      metadata: {'source': 'forgot_password_dialog'},
                                    );
                                    
                                    setDialogState(() {
                                      resetMessage = 'Success! Check your email for a reset link.';
                                      resetLoading = false;
                                    });
                                  } catch (e) {
                                    String errorMessage = 'Error sending reset email.';
                                    if (e is FirebaseAuthException) {
                                      switch (e.code) {
                                        case 'user-not-found':
                                          errorMessage = 'No account found with this email address.';
                                          break;
                                        case 'invalid-email':
                                          errorMessage = 'Please enter a valid email address.';
                                          break;
                                        case 'too-many-requests':
                                          errorMessage = 'Too many requests. Please try again later.';
                                          break;
                                        default:
                                          errorMessage = 'Error: ${e.message}';
                                      }
                                    }
                                    setDialogState(() {
                                      resetMessage = errorMessage;
                                      resetLoading = false;
                                    });
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: resetLoading
                              ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text(AppLocalizations.of(context)!.sendResetLink),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        clientId: '389852437815-3e026b99jvv3g0n0bjlmvo33vfp085vi.apps.googleusercontent.com',
      ).signIn();
      if (googleUser == null) {
        setState(() => isLoading = false);
        return; // User cancelled
      }
      
      // Check if this email was recently deleted (within 24 hours)
      final prefs = await SharedPreferences.getInstance();
      final email = googleUser.email;
      final deletedTimestamp = prefs.getString('deleted_account_$email');
      if (deletedTimestamp != null) {
        final deletedTime = int.tryParse(deletedTimestamp) ?? 0;
        final now = DateTime.now().millisecondsSinceEpoch;
        const twentyFourHours = 24 * 60 * 60 * 1000;
        
        if (now - deletedTime < twentyFourHours) {
          if (!showSignUp) {
            // Account was recently deleted and user is trying to sign in
            setState(() => isLoading = false);
            _showAccountNotFoundDialog();
            return;
          } else {
            // Account was recently deleted but user is signing up - allow it
            await prefs.remove('deleted_account_$email');
          }
        } else {
          // Clean up old deleted account tracking
          await prefs.remove('deleted_account_$email');
        }
      }
      
      // For sign-up mode, try authentication and check if it's an existing account
      if (showSignUp) {
        print('🔍 Google Sign-Up Mode: Checking for existing account for ${googleUser.email}');
      } else {
        print('🔑 Google Sign-In Mode: Proceeding with authentication for ${googleUser.email}');
      }
      
      // Proceed with Google authentication
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      // Check if this was a new user creation or existing user sign-in
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      print('📊 Google Auth Result: isNewUser=$isNewUser, signUpMode=$showSignUp');
      
      // await analytics.logLogin(loginMethod: 'google');  // Removed due to Kotlin conflicts

      final userService = UserService();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        
        // If we're in sign-up mode but the user already exists, show the popup
        if (showSignUp && doc.exists) {
          setState(() => isLoading = false);
          await FirebaseAuth.instance.signOut(); // Sign out since we don't want to proceed
          _showAccountExistsDialog();
          return;
        }
        
        if (!doc.exists) {
          await userService.createInitialUserProfile(user.email ?? '', user.displayName ?? '');
          setState(() => isLoading = false);
          if (mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OnboardingFlowPage()));
          }
          return;
        }
        // Check if onboarding is complete
        final data = doc.data() as Map<String, dynamic>?;
        final onboardingCompleted = hasCompletedOnboarding(data);
        setState(() => isLoading = false);
        if (mounted) {
          if (!onboardingCompleted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OnboardingFlowPage()));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainNavScreen()));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        // await analytics.logEvent(name: 'login_failed', parameters: {'method': 'google', 'error': e.toString()});  // Removed due to Kotlin conflicts
        
        String errorMessage = 'Google sign-in failed: $e';
        
        // Handle specific Google authentication errors
        if (e.toString().contains('SecurityException') || e.toString().contains('Unknown calling package')) {
          errorMessage = 'Google Sign-In configuration error. This is typically caused by:\n'
              '� Debug signing certificate not added to Firebase Console\n'
              '� Package name mismatch\n'
              '� SHA1 fingerprint not configured\n\n'
              'Please check the Firebase Console configuration.';
        } else if (e.toString().contains('DEVELOPER_ERROR')) {
          errorMessage = 'Google Sign-In setup error. Please ensure:\n'
              '� google-services.json is properly configured\n'
              '� OAuth client is set up in Google Cloud Console\n'
              '� App signing certificate is added to Firebase';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.help,
              onPressed: () {
                // Could show a help dialog or navigate to help page
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Google Sign-In Help'),
                    content: Text(
                      'For development:\n'
                      '1. Get your debug SHA1: keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android\n\n'
                      '2. Add the SHA1 to Firebase Console under Project Settings > Your apps > SHA certificate fingerprints\n\n'
                      '3. Download the updated google-services.json'
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(AppLocalizations.of(context)!.ok),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => isLoading = true);
    try {
      log.info('User attempting Apple sign-in');
      
      // Generate a random nonce for security (matches Firebase docs)
      final nonce = _generateNonce();
      log.info('Generated nonce: ${nonce.substring(0, 10)}...');
      
      // Request Apple Sign In with SHA256 hash of nonce (matches Firebase docs)
      log.info('Requesting Apple ID credential with hashed nonce...');
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: _sha256ofString(nonce), // Send SHA256 hash to Apple
      );
      log.info('Apple ID credential received successfully');
      
      // Validate the response (matches Firebase docs approach)
      if (credential.identityToken == null) {
        throw Exception('Apple Sign-In failed: No identity token received');
      }
      
      log.info('Creating Firebase OAuth credential with raw nonce...');
      log.info('Identity token length: ${credential.identityToken?.length ?? 0}');
      log.info('Raw nonce: $nonce');
      log.info('Hashed nonce sent to Apple: ${_sha256ofString(nonce)}');
      
      // Create OAuth credential with raw nonce (matches Firebase docs)
      final oauthCredential = OAuthProvider("apple").credential(
        idToken: credential.identityToken,
        rawNonce: nonce, // Use raw nonce for Firebase validation
      );
      
      // Sign in to Firebase
      log.info('Signing in to Firebase with Apple credential...');
      log.info('Firebase Auth instance: ${FirebaseAuth.instance.app.name}');
      log.info('Firebase Auth app options: ${FirebaseAuth.instance.app.options}');
      log.info('Firebase Auth current user: ${FirebaseAuth.instance.currentUser?.uid}');
      log.info('Firebase project ID: ${FirebaseAuth.instance.app.options.projectId}');
      log.info('Firebase auth domain: ${FirebaseAuth.instance.app.options.authDomain}');
      
      // Additional debugging info
      log.info('OAuth provider: apple');
      log.info('ID token present: ${credential.identityToken != null}');
      log.info('Raw nonce length: ${nonce.length}');
      log.info('Full name: ${credential.givenName} ${credential.familyName}');
      log.info('Email: ${credential.email}');
      
      final userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      final user = userCredential.user;
      
      if (user != null) {
        // await analytics.logLogin(loginMethod: 'apple');  // Removed due to Kotlin conflicts
        log.logUserAction('sign_in_successful', {'method': 'apple'});
        

        
        // Check if user profile exists, if not, create it
        final userService = UserService();
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          // Create user profile with Apple data
          final displayName = credential.givenName != null && credential.familyName != null
              ? '${credential.givenName} ${credential.familyName}'
              : user.displayName ?? '';
          await userService.createInitialUserProfile(user.email ?? '', displayName);
        }
        
        // Check if onboarding is complete
        final data = doc.data() as Map<String, dynamic>?;
        final onboardingCompleted = hasCompletedOnboarding(data);
        
        setState(() => message = 'Apple sign-in successful!');
        if (mounted) {
          if (!onboardingCompleted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OnboardingFlowPage()));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainNavScreen()));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        log.error('Apple sign-in failed with error: $e');
        log.error('Error type: ${e.runtimeType}');
        
        // Enhanced error logging based on Firebase documentation
        if (e.toString().contains('Invalid OAuth response')) {
          log.error('OAuth response error - check Firebase Console Apple Sign-In configuration');
          log.error('Verify Services ID, Team ID, Key ID, and Private Key are correct');
        }
        if (e.toString().contains('internal-error')) {
          log.error('Firebase internal error - check configuration:');
          log.error('1. Apple Sign-In enabled in Firebase Console');
          log.error('2. Services ID: com.yumie.healthai.signin');
          log.error('3. Team ID: BT7WG9ZHD3');
          log.error('4. Key ID: CLV527A2J9');
          log.error('5. Private key properly configured');
        }
        if (e.toString().contains('localhost')) {
          log.error('Firebase redirecting to localhost - auth domain configuration issue');
          log.error('Check Firebase Console auth domain settings');
        }
        if (e.toString().contains('MissingOrInvalidNonce')) {
          log.error('Nonce validation failed - check SHA256 hashing implementation');
          log.error('Make sure nonce is properly hashed before sending to Apple');
        }
        
        // await analytics.logEvent(name: 'login_failed', parameters: {'method': 'apple', 'error': e.toString()});  // Removed due to Kotlin conflicts
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Apple sign-in failed: $e')),
        );
      }
    }
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request. This matches the Firebase documentation approach.
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  /// This matches the Firebase documentation approach for Apple Sign-In.
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }



  Future<void> signIn() async {
    setState(() {
      isLoading = true;
      message = '';
    });

    // Input validation
    final email = emailController.text.trim();
    final password = passwordController.text;

    // Check rate limit
    final rateLimitResult = await _rateLimitingService.checkRateLimit('sign_in_attempt', identifier: email);
    if (!rateLimitResult.allowed) {
      if (mounted) {
        setState(() {
          isLoading = false;
          message = rateLimitResult.message ?? 'Too many sign-in attempts. Please try again later.';
        });
      }
      return;
    }

    if (!ValidationUtils.isValidEmail(email)) {
      if (mounted) {
        setState(() {
          isLoading = false;
          message = 'Please enter a valid email address';
        });
      }
      ValidationUtils.showValidationError(context, 'Please enter a valid email address');
      return;
    }

    if (password.isEmpty) {
      if (mounted) {
        setState(() {
          isLoading = false;
          message = 'Password is required';
        });
      }
      ValidationUtils.showValidationError(context, 'Password is required');
      return;
    }

    try {
      log.info('User attempting sign in', {'email': email});
      
      // Check if this email was recently deleted (within 24 hours)
      final prefs = await SharedPreferences.getInstance();
      final deletedTimestamp = prefs.getString('deleted_account_$email');
      if (deletedTimestamp != null) {
        final deletedTime = int.tryParse(deletedTimestamp) ?? 0;
        final now = DateTime.now().millisecondsSinceEpoch;
        const twentyFourHours = 24 * 60 * 60 * 1000;
        
        if (now - deletedTime < twentyFourHours) {
          // Account was recently deleted
          if (mounted) {
            setState(() => isLoading = false);
          }
          _showAccountNotFoundDialog();
          return;
        } else {
          // Clean up old deleted account tracking
          await prefs.remove('deleted_account_$email');
        }
      }
      
      log.info('Attempting Firebase sign-in', {'email': email});
      
      // Record sign-in attempt before trying
      await _rateLimitingService.recordAttempt('sign_in_attempt', identifier: email);
      
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      log.info('Firebase sign-in successful', {'email': email});
      
      // Record successful sign-in for security monitoring
      await _securityService.recordSecurityEvent(
        'sign_in_attempt',
        userId: FirebaseAuth.instance.currentUser?.uid,
        email: email,
        successful: true,
        metadata: {'method': 'email_password'},
      );
      // await analytics.logLogin(loginMethod: 'email');  // Removed due to Kotlin conflicts
      log.logUserAction('sign_in_successful', {'method': 'email'});
      
      // Check if user profile exists, if not, create it
      final userService = UserService();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          await userService.createInitialUserProfile(user.email ?? '', '');
        }
        // Check if onboarding is complete (mimic Google sign-in logic)
        final data = doc.data() as Map<String, dynamic>?;
        final onboardingCompleted = hasCompletedOnboarding(data);
        setState(() => message = 'Sign in successful!');
        if (mounted) {
          if (!onboardingCompleted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OnboardingFlowPage()));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainNavScreen()));
          }
        }
        return;
      }
      if (mounted) {
        setState(() => message = 'Sign in successful!');
      }
    } catch (e) {
      log.error('Sign in failed', e);
      log.error('Error details - Type: ${e.runtimeType}, Message: ${e.toString()}');
      
      // Record failed sign-in for security monitoring
      await _securityService.recordSecurityEvent(
        'sign_in_attempt',
        email: email,
        successful: false,
        metadata: {
          'method': 'email_password',
          'error_code': e is FirebaseAuthException ? e.code : 'unknown',
          'error_message': e.toString(),
        },
      );
      
      // Handle user-not-found specifically
      if (e is FirebaseAuthException && e.code == 'user-not-found') {
        if (mounted) {
          setState(() => isLoading = false);
        }
        _showAccountNotFoundDialog();
        return;
      }
      
      final errorMessage = errorHandler.handleAuthError(e);
      if (mounted) {
        setState(() => message = errorMessage);
      }
      // await analytics.logEvent(name: 'login_failed', parameters: {'method': 'email', 'error': e.toString()});  // Removed due to Kotlin conflicts
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> signUp() async {
    setState(() {
      isLoading = true;
      message = '';
    });

    // Input validation
    final email = emailController.text.trim();
    final password = passwordController.text;
    final name = nameController.text.trim();

    // Check rate limit
    final rateLimitResult = await _rateLimitingService.checkRateLimit('sign_up_attempt', identifier: email);
    if (!rateLimitResult.allowed) {
      if (mounted) {
        setState(() {
          isLoading = false;
          message = rateLimitResult.message ?? 'Too many sign-up attempts. Please try again later.';
        });
      }
      return;
    }

    if (!ValidationUtils.isValidEmail(email)) {
      if (mounted) {
        setState(() {
          isLoading = false;
          message = 'Please enter a valid email address';
        });
      }
      ValidationUtils.showValidationError(context, 'Please enter a valid email address');
      return;
    }

    final passwordError = ValidationUtils.validatePassword(password);
    if (passwordError != null) {
      if (mounted) {
        setState(() {
          isLoading = false;
          message = passwordError;
        });
      }
      ValidationUtils.showValidationError(context, passwordError);
      return;
    }

    final nameError = ValidationUtils.validateName(name);
    if (nameError != null) {
      if (mounted) {
        setState(() {
          isLoading = false;
          message = nameError;
        });
      }
      ValidationUtils.showValidationError(context, nameError);
      return;
    }

    try {
      log.info('User attempting sign up', {'email': email, 'name': name});
      
      // Check if this email was recently deleted (within 24 hours)
      final prefs = await SharedPreferences.getInstance();
      final deletedTimestamp = prefs.getString('deleted_account_$email');
      if (deletedTimestamp != null) {
        final deletedTime = int.tryParse(deletedTimestamp) ?? 0;
        final now = DateTime.now().millisecondsSinceEpoch;
        const twentyFourHours = 24 * 60 * 60 * 1000;
        
        if (now - deletedTime < twentyFourHours) {
          // Account was recently deleted, allow creating a new one
          await prefs.remove('deleted_account_$email');
          // Continue with sign-up process
        }
      }
      
      // Check if account already exists
      final signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (signInMethods.isNotEmpty) {
        // Account already exists - show the account exists dialog
        if (mounted) {
          setState(() => isLoading = false);
        }
        _showAccountExistsDialog();
        return;
      }
      
      // Record sign-up attempt before trying
      await _rateLimitingService.recordAttempt('sign_up_attempt', identifier: email);
      
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // await analytics.logSignUp(signUpMethod: 'email');  // Removed due to Kotlin conflicts
      log.logUserAction('sign_up_successful', {'method': 'email'});
      
      // Create a full user profile
      final userService = UserService();
      await userService.createInitialUserProfile(email, name);
      
      if (mounted) {
        setState(() => message = 'Sign up successful!');
        ValidationUtils.showSuccessMessage(context, 'Account created successfully!');
      }
      
      // Show onboarding after sign up
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OnboardingFlowPage()));
      }
    } catch (e) {
      final errorMessage = errorHandler.handleAuthError(e);
      if (mounted) {
        setState(() => message = errorMessage);
      }
      log.error('Sign up failed', e);
      // await analytics.logEvent(name: 'signup_failed', parameters: {'method': 'email', 'error': e.toString()});  // Removed due to Kotlin conflicts
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: ThemeData.light().copyWith(
        primaryColor: kPrimaryGreen,
        colorScheme: ThemeData.light().colorScheme.copyWith(primary: kPrimaryGreen),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.all(kPrimaryGreen),
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 24.0 : 16.0),
            child: Container(
              width: MediaQuery.of(context).size.width > 600 ? 400 : double.infinity,
              constraints: BoxConstraints(
                maxWidth: 400,
                minWidth: 280,
              ),
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height > 700 ? 36 : 24, 
                horizontal: MediaQuery.of(context).size.width > 400 ? 28 : 20,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                ),
                child: Column(
                  key: ValueKey(showSignUp),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top icon
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Image.asset('assets/logo.png', height: 56, width: 56, fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      showSignUp ? AppLocalizations.of(context)!.createAccount : AppLocalizations.of(context)!.signIn,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      showSignUp
                          ? AppLocalizations.of(context)!.signUpToGetStarted
                          : AppLocalizations.of(context)!.signInToAccessAccount,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    if (showSignUp)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.fullName, style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.johnDoe,
                              prefixIcon: Icon(Icons.person, color: Colors.grey[400]),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: kPrimaryGreen, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(AppLocalizations.of(context)!.email, style: TextStyle(fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.yourEmailExample,
                        prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: kPrimaryGreen, width: 2),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(AppLocalizations.of(context)!.password, style: TextStyle(fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.enterYourPassword,
                        prefixIcon: Icon(Icons.vpn_key_outlined, color: Colors.grey[400]),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey[400],
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: kPrimaryGreen, width: 2),
                        ),
                      ),
                      obscureText: !_isPasswordVisible,
                    ),
                    // Password strength indicator for sign-up
                    if (showSignUp)
                      PasswordStrengthIndicator(
                        password: _currentPassword,
                        showSuggestions: true,
                      ),
                    if (!showSignUp) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: _showForgotPasswordDialog,
                          child: Text(
                            AppLocalizations.of(context)!.forgotPassword,
                            style: TextStyle(
                              color: kPrimaryGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    if (showSignUp)
                      Row(
                        children: [
                          Checkbox(
                            value: acceptTerms,
                            onChanged: (v) => setState(() => acceptTerms = v ?? false),
                            activeColor: kPrimaryGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          Expanded(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.iAcceptThe + ' ',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    try {
                                      final uri = Uri.parse('https://yumie.me/terms');
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(AppLocalizations.of(context)!.couldNotOpenTermsOfService)),
                                      );
                                    }
                                  },
                                  child: Text(
                                    'Terms of Service',
                                    style: TextStyle(
                                      color: kPrimaryGreen,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                Text(
                                  ' ' + AppLocalizations.of(context)!.and + ' ',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    try {
                                      final uri = Uri.parse('https://yumie.me/privacy');
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(AppLocalizations.of(context)!.couldNotOpenPrivacyPolicy)),
                                      );
                                    }
                                  },
                                  child: Text(
                                    'Privacy Policy',
                                    style: TextStyle(
                                      color: kPrimaryGreen,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : showSignUp
                                ? (acceptTerms ? signUp : null)
                                : signIn,
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(showSignUp ? AppLocalizations.of(context)!.createAccount : AppLocalizations.of(context)!.signIn),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (!showSignUp)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(AppLocalizations.of(context)!.dontHaveAccount + " ", style: TextStyle(color: Colors.black54)),
                          GestureDetector(
                            onTap: () => setState(() => showSignUp = true),
                            child: Text(AppLocalizations.of(context)!.signUp, style: TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                    if (showSignUp)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(AppLocalizations.of(context)!.alreadyHaveAccount + " ", style: TextStyle(color: Colors.black54)),
                          GestureDetector(
                            onTap: () => setState(() => showSignUp = false),
                            child: Text(AppLocalizations.of(context)!.signIn, style: TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                    if (message.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        message,
                        style: TextStyle(
                          color: message.startsWith('Error') ? kWarningRed : kPrimaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Social sign-in buttons
                    if (isIOS) ...[
                      _GoogleSignInButton(
                        onTap: _handleGoogleSignIn, 
                        isSignUp: showSignUp,
                        isDisabled: showSignUp && !acceptTerms,
                      ),
                      SizedBox(height: 12),
                      _AppleSignInButton(onTap: _handleAppleSignIn),
                    ] else if (isAndroid) ...[
                      _GoogleSignInButton(
                        onTap: _handleGoogleSignIn, 
                        isSignUp: showSignUp,
                        isDisabled: showSignUp && !acceptTerms,
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Legal links (only show on sign-in, not sign-up)
                    if (!showSignUp) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.byContinuingYouAgreeToOur + ' ',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                try {
                                  final uri = Uri.parse('https://yumie.me/terms');
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(AppLocalizations.of(context)!.couldNotOpenTermsOfService)),
                                  );
                                }
                              },
                              child: Text(
                                'Terms of Service',
                                style: TextStyle(
                                  color: kPrimaryGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            Text(
                              ' and ',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                try {
                                  final uri = Uri.parse('https://yumie.me/privacy');
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(AppLocalizations.of(context)!.couldNotOpenPrivacyPolicy)),
                                  );
                                }
                              },
                              child: Text(
                                'Privacy Policy',
                                style: TextStyle(
                                  color: kPrimaryGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Social sign-in button widgets (to be implemented below)
class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isSignUp;
  final bool isDisabled;
  const _GoogleSignInButton({required this.onTap, this.isSignUp = false, this.isDisabled = false});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled ? Colors.grey[300] : Colors.white,
        foregroundColor: isDisabled ? Colors.grey[600] : Colors.black,
        minimumSize: Size(double.infinity, 48),
        side: BorderSide(color: isDisabled ? Colors.grey[400]! : Colors.grey[300]!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Image.asset('assets/google_logo.png', height: 24, color: isDisabled ? Colors.grey[600] : null),
      label: Text(
        isSignUp ? AppLocalizations.of(context)!.signUpWithGoogle : AppLocalizations.of(context)!.signInWithGoogle, 
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDisabled ? Colors.grey[600] : Colors.black,
        )
      ),
      onPressed: isDisabled ? null : onTap,
    );
  }
}
class _AppleSignInButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AppleSignInButton({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(Icons.apple, size: 26),
      label: Text(AppLocalizations.of(context)!.signInWithApple, style: TextStyle(fontWeight: FontWeight.w600)),
      onPressed: onTap,
    );
  }
}


class StartupProfileScreen extends StatefulWidget {
  final User user;
  const StartupProfileScreen({super.key, required this.user});

  @override
  State<StartupProfileScreen> createState() => _StartupProfileScreenState();
}

class _StartupProfileScreenState extends State<StartupProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final calorieController = TextEditingController(text: '2000');
  final proteinController = TextEditingController(text: '120');
  final carbsController = TextEditingController(text: '250');
  final fatController = TextEditingController(text: '70');
  bool isLoading = false;

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      final now = DateTime.now();
      final profile = UserProfile(
        id: widget.user.uid,
        email: widget.user.email ?? '',
        name: nameController.text,
        age: int.parse(ageController.text),
        height: double.parse(heightController.text),
        weight: double.parse(weightController.text),
        dailyCalorieGoal: int.parse(calorieController.text),
        proteinGoal: int.parse(proteinController.text),
        carbsGoal: int.parse(carbsController.text),
        fatGoal: int.parse(fatController.text),
        targetWeight: double.parse(weightController.text),
        startingWeight: double.parse(weightController.text), // Set starting weight to initial weight
        createdAt: now,
        lastUpdated: now,
      );
      await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).set(profile.toMap());
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainNavScreen()));
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.completeYourProfile)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text("Let's get to know you!", style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.name),
                validator: (v) => v == null || v.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Enter your age' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: heightController,
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Enter your height' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: weightController,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Enter your weight' : null,
              ),
              const SizedBox(height: 24),
              Text('Nutrition Goals', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextFormField(
                controller: calorieController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.dailyCalorieGoal),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Enter calorie goal' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: proteinController,
                decoration: const InputDecoration(labelText: 'Protein Goal (g)'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Enter protein goal' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: carbsController,
                decoration: const InputDecoration(labelText: 'Carbs Goal (g)'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Enter carbs goal' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: fatController,
                decoration: const InputDecoration(labelText: 'Fat Goal (g)'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Enter fat goal' : null,
              ),
              const SizedBox(height: 24),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Save & Continue'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: kPrimaryGreen,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class FoodLogForm extends StatefulWidget {
  const FoodLogForm({super.key});

  @override
  _FoodLogFormState createState() => _FoodLogFormState();
}

class _FoodLogFormState extends State<FoodLogForm> {
  final TextEditingController foodController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  String message = '';

  Future<void> addFoodLog() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => message = 'Please sign in first.');
      return;
    }
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('food_logs')
          .add({
        'food': foodController.text.trim(),
        'calories': int.tryParse(caloriesController.text) ?? 0,
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        message = 'Food log added!';
        foodController.clear();
        caloriesController.clear();
      });
    } catch (e) {
      setState(() => message = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        Text('Add Food Log', style: TextStyle(fontWeight: FontWeight.bold, color: kPrimaryGreen)),
        const SizedBox(height: 8),
        TextField(
          controller: foodController,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.foodName),
        ),
        const SizedBox(height: 8),
        _NumericTextField(
          controller: caloriesController,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.calories),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: addFoodLog,
          child: Text(AppLocalizations.of(context)!.addLog),
        ),
        if (message.isNotEmpty)
          Text(
            message,
            style: TextStyle(
              color: message.startsWith('Error') ? kWarningRed : kPrimaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}

class FoodLogList extends StatelessWidget {
  const FoodLogList({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Text('Please sign in.');

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('food_logs')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return Text('No food logs yet.');
        return ListView.builder(
          shrinkWrap: true,
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data['food'] ?? ''),
              subtitle: Text('Calories: ${data['calories'] ?? 0}'),
              trailing: Text(
                data['timestamp'] != null
                    ? (data['timestamp'] as Timestamp).toDate().toLocal().toString().split(' ')[0]
                    : '',
              ),
            );
          },
        );
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yumie - Food Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FoodLogForm(),
            const SizedBox(height: 16),
            FoodLogList(),
          ],
        ),
      ),
    );
  }
}

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _fabExpanded = false;
  bool _showFabActions = false;
  static bool _footerEntrancePlayed = false;
  late AnimationController _footerController;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _footerController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );
    if (!_footerEntrancePlayed) {
      _footerController.forward();
      _footerEntrancePlayed = true;
    } else {
      _footerController.value = 1.0;
    }
    
    // Initialize device session tracking for authenticated users
    DeviceSessionService().initialize();
    
    // Check for post-onboarding popup
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final justCompletedOnboarding = prefs.getBool('just_completed_onboarding') ?? false;
      
      if (justCompletedOnboarding) {
        print('🎯 POST-ONBOARDING: Detected just completed onboarding...');
        // Clear the flag
        await prefs.setBool('just_completed_onboarding', false);
        
        final shouldShow = await SubscriptionPopupPage.shouldShowPopup(isPostOnboarding: true);
        print('🎯 POST-ONBOARDING: shouldShow=$shouldShow, mounted=$mounted');
        if (shouldShow && mounted) {
          await Future.delayed(Duration(milliseconds: 1000)); // Longer delay for stable navigation
          print('🎯 POST-ONBOARDING: About to show popup after delay...');
          if (mounted) {
            print('🎯 POST-ONBOARDING: Pushing subscription popup page...');
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => SubscriptionPopupPage(
                isOnboardingComplete: true,
              )),
            );
          } else {
            print('❌ POST-ONBOARDING: Widget not mounted, skipping popup');
          }
        } else {
          print('❌ POST-ONBOARDING: shouldShow=false, not showing popup');
        }
      }
    });
    _screens = [
      DashboardScreen(
        onViewAllMeals: () => _onItemTapped(1),
        onProfileTap: () => _onItemTapped(4),
      ),
      FoodScreen(),
      SizedBox.shrink(),
      CoachScreen(),
      ProfileScreen(),
    ];
  }

  @override
  void dispose() {
    _footerController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) async {
    if (index == 2) {
      if (!_fabExpanded) {
        setState(() {
          _fabExpanded = true;
        });
        // Wait for X animation, then show actions
        await Future.delayed(Duration(milliseconds: 220));
        setState(() {
          _showFabActions = true;
        });
      } else {
        setState(() {
          _showFabActions = false;
        });
        // Wait for actions to disappear, then animate X back to plus
        await Future.delayed(Duration(milliseconds: 180));
        setState(() {
          _fabExpanded = false;
        });
      }
    } else {
      setState(() {
        _selectedIndex = index;
        _fabExpanded = false;
        _showFabActions = false;
      });
    }
  }

  void _navigateToLog() {
    setState(() {
      _fabExpanded = false;
      _showFabActions = false;
    });
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LogMealPage()));
  }

  void _navigateToScan() {
    setState(() {
      _fabExpanded = false;
      _showFabActions = false;
    });
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ScanPage()));
  }

  void _navigateToWeightLog() async {
    setState(() {
      _fabExpanded = false;
      _showFabActions = false;
    });
    
    double? weightChange = await showDialog<double>(
      context: context,
      builder: (context) => _WeightLogDialog(),
    );
    
    if (weightChange != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final data = doc.data() ?? {};
        final double currentWeight = (data['weight'] ?? 0.0).toDouble();
        final double newWeight = currentWeight + weightChange;
        
        // Get the current total weight change
        final double currentTotalChange = (data['totalWeightChange'] ?? 0.0).toDouble();
        final double newTotalChange = currentTotalChange + weightChange;
        
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'weight': newWeight,
          'lastWeightChange': weightChange,
          'lastWeightUpdate': DateTime.now(),
          'totalWeightChange': newTotalChange,
        });
      }
    }
  }

  void _navigateToWaterLog() async {
    setState(() {
      _fabExpanded = false;
      _showFabActions = false;
    });
    
    // Show water log dialog
    int? amount = await showDialog<int>(
      context: context,
      builder: (context) => _WaterLogSliderDialog(),
    );
    if (amount != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final data = doc.data() ?? {};
        final int prev = (data['waterLoggedMl'] ?? 0) as int;
        final int newAmount = prev + amount;
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'waterLoggedMl': newAmount < 0 ? 0 : newAmount,
          'lastUpdated': DateTime.now(),
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Scaffold(
          body: AnimatedSwitcher(
            duration: Duration(milliseconds: 400),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: child,
            ),
            child: KeyedSubtree(
              key: ValueKey(_selectedIndex),
              child: _screens[_selectedIndex],
            ),
          ),
          bottomNavigationBar: SlideTransition(
            position: Tween<Offset>(begin: Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: _footerController, curve: Curves.easeOutCubic)),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 70,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _AnimatedNavBarItem(
                            icon: Icons.home,
                            label: AppLocalizations.of(context)!.home,
                            selected: _selectedIndex == 0,
                            onTap: () => _onItemTapped(0),
                            selectedColor: kPrimaryGreen,
                          ),
                          _AnimatedNavBarItem(
                            icon: Icons.restaurant_menu,
                            label: AppLocalizations.of(context)!.food,
                            selected: _selectedIndex == 1,
                            onTap: () => _onItemTapped(1),
                          ),
                          SizedBox(width: 56), // Space for FAB
                          _AnimatedNavBarItem(
                            icon: Icons.chat_bubble_outline,
                            label: AppLocalizations.of(context)!.coach,
                            selected: _selectedIndex == 3,
                            onTap: () => _onItemTapped(3),
                          ),
                          _AnimatedNavBarItem(
                            icon: Icons.person,
                            label: AppLocalizations.of(context)!.profile,
                            selected: _selectedIndex == 4,
                            onTap: () => _onItemTapped(4),
                            iconSize: 28,
                          ),
                        ],
                      ),
                      // FAB positioned in the center of the footer
                      Positioned(
                        top: 7,
                        child: _AnimatedFab(
                          expanded: _fabExpanded,
                          onTap: () => _onItemTapped(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Overlay for Log/Scan
        if (_fabExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _onItemTapped(2),
              child: Container(
                color: Colors.black.withOpacity(0.08),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    if (_showFabActions)
                      Positioned(
                        bottom: 120, // Adjust for raised FAB
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // First row: Weight and Water (small buttons)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _FabActionButton(
                                  label: AppLocalizations.of(context)!.weight,
                                  icon: Icons.monitor_weight,
                                  onTap: _navigateToWeightLog,
                                  isLarge: false,
                                ),
                                const SizedBox(width: 40),
                                _FabActionButton(
                                  label: AppLocalizations.of(context)!.water,
                                  icon: Icons.water_drop,
                                  onTap: _navigateToWaterLog,
                                  isLarge: false,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Second row: Log and Scan (big buttons)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _FabActionButton(
                                  label: AppLocalizations.of(context)!.log,
                                  icon: Icons.edit,
                                  onTap: _navigateToLog,
                                  isLarge: true,
                                ),
                                const SizedBox(width: 40),
                                _FabActionButton(
                                  label: AppLocalizations.of(context)!.scan,
                                  icon: Icons.camera_alt,
                                  onTap: _navigateToScan,
                                  isLarge: true,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AnimatedNavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? selectedColor;
  final double? iconSize;
  const _AnimatedNavBarItem({required this.icon, required this.label, required this.selected, required this.onTap, this.selectedColor, this.iconSize});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.18 : 1.0,
              duration: Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: Icon(icon, color: selected ? (selectedColor ?? kPrimaryGreen) : Colors.grey[600], size: iconSize ?? 28),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 200),
              style: TextStyle(
                color: selected ? (selectedColor ?? kPrimaryGreen) : Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedFab extends StatefulWidget {
  final bool expanded;
  final VoidCallback onTap;
  const _AnimatedFab({required this.expanded, required this.onTap});
  @override
  State<_AnimatedFab> createState() => _AnimatedFabState();
}
class _AnimatedFabState extends State<_AnimatedFab> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 220));
  }
  @override
  void didUpdateWidget(covariant _AnimatedFab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final color = Color.lerp(kPrimaryGreen, Colors.grey[200], _controller.value)!;
        final icon = _controller.value < 0.5 ? Icons.add : Icons.close;
        final iconColor = _controller.value < 0.5 ? Colors.white : Colors.grey[600];
        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 28),
            ),
          ),
        );
      },
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onViewAllMeals;
  final VoidCallback? onProfileTap;
  const DashboardScreen({Key? key, this.onViewAllMeals, this.onProfileTap}) : super(key: key);
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  final MealService _mealService = MealService();
  final UserService _userService = UserService();
  
  // Helper function to get food type icon
  IconData _getFoodTypeIcon(String? foodType) {
    switch (foodType?.toLowerCase()) {
      case 'drink':
        return Icons.local_drink;
      case 'ingredient':
        return Icons.eco;
      case 'meal':
      default:
        return Icons.restaurant;
    }
  }

  late AnimationController _headerController;
  late AnimationController _summaryController;
  late AnimationController _quickActionsController;
  late AnimationController _mealsController;

  static bool _hasAnimatedEntrance = false;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _summaryController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _quickActionsController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _mealsController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _playEntranceAnimationsIfNeeded();
    _checkAndResetWaterIntake();
  }

  void _playEntranceAnimationsIfNeeded() {
    if (!_hasAnimatedEntrance) {
      _headerController.forward().then((_) {
        _summaryController.forward().then((_) {
          _quickActionsController.forward().then((_) {
            _mealsController.forward().then((_) {
              setState(() {
                _hasAnimatedEntrance = true;
              });
            });
          });
        });
      });
    } else {
      _headerController.value = 1.0;
      _summaryController.value = 1.0;
      _quickActionsController.value = 1.0;
      _mealsController.value = 1.0;
    }
  }

  // Check and reset water intake daily
  Future<void> _checkAndResetWaterIntake() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final lastWaterResetKey = 'last_water_reset_${user.uid}';
    final lastResetDate = prefs.getString(lastWaterResetKey);
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    
    // If it's a new day, reset water intake
    if (lastResetDate != todayStr) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'waterLoggedMl': 0,
        'lastUpdated': DateTime.now(),
      });
      await prefs.setString(lastWaterResetKey, todayStr);
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _summaryController.dispose();
    _quickActionsController.dispose();
    _mealsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: kBackgroundWhite,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          children: [
            // Header
            FadeTransition(
              opacity: _headerController,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(_headerController),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_getCurrentGreeting(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: Colors.black)),
                            const SizedBox(height: 4),
                            Text(AppLocalizations.of(context)!.trackNutritionToday, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                          ],
                        ),
                      ),
                      AnimatedScale(
                        scale: _headerController.value,
                        duration: const Duration(milliseconds: 600),
                        child: GestureDetector(
                          onTap: widget.onProfileTap,
                        child: user != null && user.photoURL != null
                          ? CircleAvatar(radius: 24, backgroundImage: NetworkImage(user.photoURL!))
                          : CircleAvatar(radius: 24, backgroundColor: kPrimaryGreen.withOpacity(0.15), child: Icon(Icons.person, color: kPrimaryGreen)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            // Nutrition Summary Card
            FadeTransition(
              opacity: _summaryController,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(_summaryController),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: StreamBuilder<UserProfile?>(
                    stream: _userService.getCurrentUserProfile(),
                    builder: (context, userSnap) {
                      if (!userSnap.hasData) return const SizedBox(height: 220, child: Center(child: CircularProgressIndicator()));
                      final userProfile = userSnap.data!;
                      final dailyCalorieGoal = userProfile.dailyCalorieGoal;
                      final proteinGoal = userProfile.proteinGoal;
                      final carbsGoal = userProfile.carbsGoal;
                      final fatGoal = userProfile.fatGoal;
                      return StreamBuilder<List<Meal>>(
                        stream: _mealService.getTodayMeals(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox(height: 220, child: Center(child: CircularProgressIndicator()));
                          final meals = snapshot.data!;
                          final totalCalories = meals.fold(0, (sum, m) => sum + m.calories);
                          final totalProtein = meals.fold(0, (sum, m) => sum + m.protein);
                          final totalCarbs = meals.fold(0, (sum, m) => sum + m.carbs);
                          final totalFat = meals.fold(0, (sum, m) => sum + m.fat);
                          if (dailyCalorieGoal == null || proteinGoal == null || carbsGoal == null || fatGoal == null) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.06),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(AppLocalizations.of(context)!.nutritionSummary, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                    SizedBox(height: 12),
                                    Text(AppLocalizations.of(context)!.setCalorieAndMacroGoals, style: TextStyle(color: Colors.grey[700], fontSize: 16)),
                                  ],
                                ),
                              ),
                            );
                          }
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.06),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Macro Progress
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(AppLocalizations.of(context)!.nutritionSummary, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                                      const SizedBox(height: 18),
                                      TweenAnimationBuilder<double>(
                                        tween: Tween<double>(begin: 0, end: totalProtein / proteinGoal!),
                                        duration: const Duration(milliseconds: 900),
                                        curve: Curves.easeOutCubic,
                                        builder: (context, value, child) => _MacroProgressRow(
                                          color: kSecondaryBlue,
                                          label: AppLocalizations.of(context)!.protein,
                                          value: '${(value * proteinGoal!).round()} g',
                                          percent: value,
                                          valueSuffix: 'g',
                                          valueFontWeight: FontWeight.w600,
                                          valueFontSize: 16,
                                          barHeight: 8,
                                          labelColor: Colors.black,
                                          dotSize: 12,
                                        ),
                                      ),
                                      TweenAnimationBuilder<double>(
                                        tween: Tween<double>(begin: 0, end: totalCarbs / carbsGoal!),
                                        duration: const Duration(milliseconds: 1100),
                                        curve: Curves.easeOutCubic,
                                        builder: (context, value, child) => _MacroProgressRow(
                                          color: kAccentOrange,
                                          label: AppLocalizations.of(context)!.carbs,
                                          value: '${(value * carbsGoal!).round()} g',
                                          percent: value,
                                          valueSuffix: 'g',
                                          valueFontWeight: FontWeight.w600,
                                          valueFontSize: 16,
                                          barHeight: 8,
                                          labelColor: Colors.black,
                                          dotSize: 12,
                                        ),
                                      ),
                                      TweenAnimationBuilder<double>(
                                        tween: Tween<double>(begin: 0, end: totalFat / fatGoal!),
                                        duration: const Duration(milliseconds: 1200),
                                        curve: Curves.easeOutCubic,
                                        builder: (context, value, child) => _MacroProgressRow(
                                          color: kWarningRed,
                                          label: AppLocalizations.of(context)!.fat,
                                          value: '${(value * fatGoal!).round()} g',
                                          percent: value,
                                          valueSuffix: 'g',
                                          valueFontWeight: FontWeight.w600,
                                          valueFontSize: 16,
                                          barHeight: 8,
                                          labelColor: Colors.black,
                                          dotSize: 12,
                                        ),
                                      ),
                                      // Water Intake Tracker
                                      StreamBuilder<UserProfile?> (
                                        stream: _userService.getCurrentUserProfile(),
                                        builder: (context, userSnap) {
                                          if (!userSnap.hasData) return SizedBox.shrink();
                                          final userProfile = userSnap.data!;
                                          final String waterGoalStr = userProfile.waterIntake ?? '2L';
                                          final double waterGoal = double.tryParse(waterGoalStr.replaceAll('L', '').replaceAll('+', '')) ?? 2.0;
                                          final int waterGoalMl = (waterGoal * 1000).round();
                                          final int waterLoggedMl = userProfile.waterLoggedMl ?? 0;
                                          final double percent = (waterLoggedMl / waterGoalMl).clamp(0.0, 1.0);
                                          return Container(
                                            padding: const EdgeInsets.only(top: 12.0),
                                            height: 56,
                                            child: Stack(
                                              alignment: Alignment.centerLeft,
                                              children: [
                                                // Progress bar and text
                                                Row(
                                                  children: [
                                                    Icon(Icons.water_drop, color: Colors.blue[400]),
                                                    SizedBox(width: 10),
                                                    Expanded(
                                                      child: LinearProgressIndicator(
                                                        value: percent,
                                                        backgroundColor: Colors.blue[50],
                                                        color: Colors.blue[400],
                                                        minHeight: 8,
                                                      ),
                                                    ),
                                                    SizedBox(width: 12),
                                                                      Text('${(waterLoggedMl / 1000).toStringAsFixed(1)} / $waterGoalStr', style: TextStyle(fontWeight: FontWeight.bold)),
                                                  ],
                                                ),
                                                
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),
                                // Circular Calories (move down slightly)
                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0, end: totalCalories / dailyCalorieGoal!),
                                  duration: const Duration(milliseconds: 1200),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, child) => Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 24),
                                      Text(AppLocalizations.of(context)!.calories, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600, fontSize: 16)),
                                      const SizedBox(height: 8),
                                      _CircularCalories(
                                        calories: totalCalories,
                                        goal: dailyCalorieGoal!,
                                        size: 90,
                                        fontSize: 26,
                                        subFontSize: 15,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Quick Actions
            FadeTransition(
              opacity: _quickActionsController,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(_quickActionsController),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.quickActions, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _AnimatedScaleOnTap(
                              child: _QuickActionCard(
                                icon: Icons.camera_alt,
                                label: AppLocalizations.of(context)!.scan,
                                color: kPrimaryGreen,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const LogMealPage()),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _AnimatedScaleOnTap(
                              child: _QuickActionCard(
                                icon: Icons.qr_code_scanner,
                                label: AppLocalizations.of(context)!.scan,
                                color: kSecondaryBlue,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const ScanPage()),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Today's Meals
            FadeTransition(
              opacity: _mealsController,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(_mealsController),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.todaysMeals, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      TextButton(
                        onPressed: widget.onViewAllMeals,
                        child: Text(AppLocalizations.of(context)!.viewAll, style: TextStyle(color: kPrimaryGreen)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            FadeTransition(
              opacity: _mealsController,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(_mealsController),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: StreamBuilder<List<Meal>>(
                    stream: _mealService.getTodayMeals(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
                      final meals = snapshot.data!;
                      if (meals.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: Text(AppLocalizations.of(context)!.noMealsLoggedForThisDay, style: TextStyle(color: Colors.grey[600]))),
                        );
                      }
                      return Column(
                        children: [
                          for (int i = 0; i < meals.take(2).length; i++)
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: Duration(milliseconds: 500 + i * 200),
                              builder: (context, value, child) => Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, (1 - value) * 30),
                                  child: _AnimatedScaleOnTap(child: _MealCardModern(meal: meals[i])),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// Macro progress row for Nutrition Summary
class _MacroProgressRow extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final double percent;
  final String? valueSuffix;
  final FontWeight? valueFontWeight;
  final double? valueFontSize;
  final double? barHeight;
  final Color? labelColor;
  final double? dotSize;
  const _MacroProgressRow({
    required this.color,
    required this.label,
    required this.value,
    required this.percent,
    this.valueSuffix,
    this.valueFontWeight,
    this.valueFontSize,
    this.barHeight,
    this.labelColor,
    this.dotSize,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        children: [
          Container(width: dotSize ?? 10, height: dotSize ?? 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          SizedBox(width: 70, child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: labelColor ?? Colors.black))),
          Expanded(
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              backgroundColor: kContainerGrey,
              color: color,
              minHeight: barHeight ?? 8,
            ),
          ),
          const SizedBox(width: 16),
          Text(value, style: TextStyle(fontWeight: valueFontWeight ?? FontWeight.w500, fontSize: valueFontSize ?? 15)),
        ],
      ),
    );
  }
}

// Helper to interpolate between two colors
Color _lerpColor(Color a, Color b, double t) {
  return Color.lerp(a, b, t)!;
}

Color getCalorieProgressColor(int calories, int goal) {
  final percent = calories / goal;
  if (percent < 1.0) {
    // Interpolate from yellow (kAccentOrange) to green (kPrimaryGreen)
    return _lerpColor(kAccentOrange, kPrimaryGreen, percent.clamp(0.0, 1.0));
  } else if (percent == 1.0) {
    return kPrimaryGreen;
  } else {
    return kWarningRed;
  }
}

// Circular calories indicator
class _CircularCalories extends StatelessWidget {
  final int calories;
  final int goal;
  final double? size;
  final double? fontSize;
  final double? subFontSize;
  const _CircularCalories({required this.calories, required this.goal, this.size, this.fontSize, this.subFontSize});
  @override
  Widget build(BuildContext context) {
    final percent = calories / goal;
    final color = getCalorieProgressColor(calories, goal);
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: size ?? 80,
          height: size ?? 80,
          child: CircularProgressIndicator(
            value: percent.clamp(0.0, 1.0),
            backgroundColor: kContainerGrey,
            color: color,
            strokeWidth: 8,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$calories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize ?? 20)),
            Text('/ $goal', style: TextStyle(color: Colors.grey[600], fontSize: subFontSize ?? 14)),
          ],
        ),
      ],
    );
  }
}

// Quick Action Card
class _QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickActionCard({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.93).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
      child: Container(
          height: 80, // fixed height for all cards
          width: double.infinity,
        decoration: BoxDecoration(
            color: widget.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.color.withOpacity(0.15)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(10),
                child: Icon(widget.icon, color: widget.color, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Text(
                      widget.label,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

// Modern Meal Card
class _MealCardModern extends StatefulWidget {
  final Meal meal;
  const _MealCardModern({required this.meal});
  @override
  State<_MealCardModern> createState() => _MealCardModernState();
}

class _MealCardModernState extends State<_MealCardModern> {
  bool _expanded = false;
  
  // Helper function to get food type icon
  IconData _getFoodTypeIcon(String? foodType) {
    switch (foodType?.toLowerCase()) {
      case 'drink':
        return Icons.local_drink;
      case 'ingredient':
        return Icons.eco;
      case 'meal':
      default:
        return Icons.restaurant;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal image - prioritize user's photo, otherwise use food type icon
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: meal.imageUrl != null
                    ? Image.network(
                        meal.imageUrl!,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to food type icon if user's image fails to load
                                return Container(
                                  width: 70,
                                  height: 70,
                            decoration: BoxDecoration(
                              color: kPrimaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              _getFoodTypeIcon(meal.foodType),
                              size: 35,
                              color: kPrimaryGreen,
                            ),
                          );
                        },
                                )
                              : Container(
                                  width: 70,
                                  height: 70,
                        decoration: BoxDecoration(
                          color: kPrimaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _getFoodTypeIcon(meal.foodType),
                          size: 35,
                          color: kPrimaryGreen,
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(getMealTypeLocalized(context, meal.mealType), style: TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        Text(formatTime(meal.timestamp), style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                        if (meal.quantity != null && meal.quantityUnit != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: kPrimaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${meal.quantity} ${meal.quantityUnit}',
                              style: TextStyle(
                                color: kPrimaryGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meal.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: AppLocalizations.of(context)!.localeName.startsWith('ar') ? TextDirection.rtl : TextDirection.ltr,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 2,
                      children: [
                        _MacroTag(label: 'P', value: '${meal.protein}g', color: kSecondaryBlue),
                        _MacroTag(label: 'C', value: '${meal.carbs}g', color: kAccentOrange),
                        _MacroTag(label: 'F', value: '${meal.fat}g', color: kWarningRed),
                      ],
                    ),
                  ],
                ),
              ),
              // Calories, delete, and dropdown in a vertical column
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('${meal.calories}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('cal', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent, size: 22),
                        tooltip: 'Delete meal',
                        padding: EdgeInsets.all(8),
                        constraints: BoxConstraints(minWidth: 48, minHeight: 48),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(AppLocalizations.of(context)!.deleteMeal),
                              content: Text(AppLocalizations.of(context)!.areYouSureDeleteMeal),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text(AppLocalizations.of(context)!.cancel),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  child: Text(AppLocalizations.of(context)!.delete),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await MealService().deleteMeal(meal.id);
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: kPrimaryGreen, size: 22),
                        tooltip: _expanded ? 'Hide ingredients' : 'Show ingredients',
                        padding: EdgeInsets.all(8),
                        constraints: BoxConstraints(minWidth: 48, minHeight: 48),
                        onPressed: () => setState(() => _expanded = !_expanded),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Builder(
                  builder: (context) {
                    final ingredients = meal.ingredients;
                    if (ingredients.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ingredients:', style: TextStyle(fontWeight: FontWeight.w600, color: kPrimaryGreen)),
                          ...ingredients.map((ing) => Text('� $ing', style: TextStyle(color: Colors.black87))).toList(),
                        ],
                      );
                    } else {
                      return Text(AppLocalizations.of(context)!.noIngredientsListed, style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic));
                    }
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String formatTime(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

// Macro Tag
class _MacroTag extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MacroTag({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(width: 2),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}



class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final RateLimitingService _rateLimitingService = RateLimitingService();
  final SecurityMonitoringService _securityService = SecurityMonitoringService();

  // Check if the current user signed in with a social provider (Google or Apple)
  bool _isSocialUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    
    // Check if user has Google or Apple as a provider
    return user.providerData.any((provider) => 
      provider.providerId == 'google.com' || provider.providerId == 'apple.com');
  }

  // Helper functions for sharing and rating
  Future<void> _shareApp(BuildContext context) async {
    try {
      const String shareText = '''
� Check out Yumie - Your Personal Nutrition Assistant! �

Track your calories, scan food with AI, and get personalized nutrition insights to achieve your health goals!

📱 Download Yumie now:
� iOS: https://apps.apple.com/us/app/yumie-ai/id6748360245
� Android: https://play.google.com/store/apps/details?id=com.yumie.healthai

#Yumie #Nutrition #Fitness #HealthyLiving
      ''';
      
      await Share.share(
        shareText,
        subject: 'Yumie - Your Personal Nutrition Assistant',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to share at this time. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Rating function removed

  // Rating dialog function removed

  Future<void> _changeProfilePicture() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final ref = FirebaseStorage.instance.ref().child('profile_pics/${user.uid}.jpg');
      final file = File(picked.path);
      final uploadTask = await ref.putFile(file);
      if (uploadTask.state != TaskState.success) {
        throw Exception('Upload failed: \'${uploadTask.state}\'');
      }
              final url = await ref.getDownloadURL();
      await _userService.updateUserPhotoUrl(url);
      await user.updatePhotoURL(url);
      setState(() {}); // Refresh UI
          } catch (e, stack) {
        // Handle error silently
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update photo: $e')));
    } finally {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  // Show language selection dialog
  void _showLanguageSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          final supportedLanguages = languageProvider.getAllSupportedLanguages();
          
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.language, color: Colors.blue),
                SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.selectLanguageTitle),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.chooseYourPreferredLanguage,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: supportedLanguages.length,
                    itemBuilder: (context, index) {
                      final language = supportedLanguages[index];
                      final isSelected = languageProvider.currentLanguageCode == language['code'];
                      
                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        color: isSelected ? Colors.blue.withOpacity(0.1) : null,
                        child: ListTile(
                          leading: Icon(
                            Icons.language,
                            color: isSelected ? Colors.blue : Colors.grey,
                          ),
                          title: Text(
                            language['nativeName']!,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            language['name']!,
                            style: TextStyle(fontSize: 12),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: Colors.blue)
                              : null,
                          onTap: () async {
                            await languageProvider.changeLanguage(language['code']!);
                            Navigator.pop(context);
                            
                            // Show confirmation
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${AppLocalizations.of(context)!.languageChangedTo} ${language['nativeName']}'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.close),
              ),
            ],
          );
        },
      ),
    );
  }



  Future<void> _changeProfileName(String currentName) async {
    final controller = TextEditingController(text: currentName);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    String? error;
    final parentContext = context;
    bool didUpdate = false;
    await showDialog(
      context: parentContext,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.changeProfileName),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter new name', errorText: error),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(AppLocalizations.of(context)!.cancel)),
            ElevatedButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isEmpty) {
                  setState(() { error = 'Name cannot be empty'; });
                                  return;
              }
              Navigator.pop(dialogContext); // Close the input dialog
                showDialog(
                  context: parentContext,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );
                try {
                  // Update Firestore
                  final snap = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
                  final data = snap.data();
                  if (data != null) {
                    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'name': newName, 'lastUpdated': DateTime.now()});
                  }
                  // Update Auth
                  await user.updateDisplayName(newName);
                  didUpdate = true;
                } catch (e, stack) {
                  if (mounted) ScaffoldMessenger.of(parentContext).showSnackBar(SnackBar(content: Text('Failed to update name: $e')));
                } finally {
                  await Future.delayed(const Duration(milliseconds: 100));
                  Navigator.of(parentContext, rootNavigator: true).maybePop();
                  if (didUpdate && mounted) setState(() {}); // Only refresh parent if needed
                }
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        ),
      ),
    );
  }



  void _showEditProfileDialog(UserProfile profile) {
    final nameController = TextEditingController(text: profile.name);
    final startingWeightController = TextEditingController(text: profile.startingWeight.toStringAsFixed(1));
    final weightController = TextEditingController(text: profile.weight.toStringAsFixed(1));
    final targetWeightController = TextEditingController(text: profile.targetWeight.toStringAsFixed(1));

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: theme.cardColor,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit Profile', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                const SizedBox(height: 18),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.name,
                    prefixIcon: Icon(Icons.person, color: theme.iconTheme.color),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    labelStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
                  ),
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                ),
                const SizedBox(height: 12),
                _NumericTextField(
                  controller: startingWeightController,
                  decoration: InputDecoration(
                    labelText: 'Starting Weight (kg)',
                    prefixIcon: Icon(Icons.trending_up, color: theme.iconTheme.color),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    labelStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
                  ),
                  enabled: profile.startingWeight == 0.0, // Only allow editing if not set
                ),
                const SizedBox(height: 12),
                _NumericTextField(
                  controller: weightController,
                  decoration: InputDecoration(
                    labelText: 'Current Weight (kg)',
                    prefixIcon: Icon(Icons.monitor_weight, color: theme.iconTheme.color),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    labelStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
                  ),
                ),
                const SizedBox(height: 12),
                _NumericTextField(
                  controller: targetWeightController,
                  decoration: InputDecoration(
                    labelText: 'Target Weight (kg)',
                    prefixIcon: Icon(Icons.flag, color: theme.iconTheme.color),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    labelStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimaryGreen,
                        side: BorderSide(color: kPrimaryGreen, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          // Only update startingWeight if it was not set before
                          final updatedProfile = UserProfile(
                            id: profile.id,
                            email: profile.email,
                            name: nameController.text,
                            age: profile.age, // Keep existing age
                            height: profile.height, // Keep existing height
                            weight: double.parse(weightController.text),
                            dailyCalorieGoal: profile.dailyCalorieGoal,
                            proteinGoal: profile.proteinGoal,
                            carbsGoal: profile.carbsGoal,
                            fatGoal: profile.fatGoal,
                            targetWeight: double.parse(targetWeightController.text),
                            startingWeight: profile.startingWeight == 0.0 ? double.parse(startingWeightController.text) : profile.startingWeight,
                            createdAt: profile.createdAt,
                            lastUpdated: DateTime.now(),
                          );
                          await _userService.updateUserProfile(updatedProfile);
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(context)!.profileUpdatedSuccessfully)),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error updating profile: $e')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      ),
                      child: const Text('Save', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditGoalsDialog(UserProfile profile) {
    final caloriesController = TextEditingController(text: profile.dailyCalorieGoal.toString());
    final proteinController = TextEditingController(text: profile.proteinGoal.toString());
    final carbsController = TextEditingController(text: profile.carbsGoal.toString());
    final fatController = TextEditingController(text: profile.fatGoal.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.editGoals),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _NumericTextField(
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.dailyCalorieGoal),
                controller: caloriesController,
              ),
              _NumericTextField(
                decoration: const InputDecoration(labelText: 'Protein Goal (g)'),
                controller: proteinController,
              ),
              _NumericTextField(
                decoration: const InputDecoration(labelText: 'Carbs Goal (g)'),
                controller: carbsController,
              ),
              _NumericTextField(
                decoration: const InputDecoration(labelText: 'Fat Goal (g)'),
                controller: fatController,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _userService.updateUserGoals(
                  dailyCalorieGoal: int.parse(caloriesController.text),
                  proteinGoal: int.parse(proteinController.text),
                  carbsGoal: int.parse(carbsController.text),
                  fatGoal: int.parse(fatController.text),
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.goalsUpdatedSuccessfully)),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating goals: $e')),
                  );
                }
              }
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final int userLevel = 8;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: StreamBuilder<UserProfile?>(
          stream: _userService.getCurrentUserProfile(),
          builder: (context, snapshot) {
            final profile = snapshot.data;
            final userName = profile?.name ?? '';
            final userAvatar = profile?.photoUrl ?? '';
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Text(AppLocalizations.of(context)!.profile, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
                  ),

                  Divider(height: 1, thickness: 1, color: Colors.grey[200]),
                  // Profile Card
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(24.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Stack(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 60,
                                                    backgroundImage: profile != null && profile.photoUrl.isNotEmpty
                                                      ? NetworkImage(profile.photoUrl)
                                                      : null,
                                                    backgroundColor: kPrimaryGreen.withOpacity(0.08),
                                                    child: profile == null || profile.photoUrl.isEmpty
                                                      ? Icon(Icons.person, color: kPrimaryGreen, size: 60)
                                                      : null,
                                                  ),
                                                  Positioned(
                                                    top: 0,
                                                    right: 0,
                                                    child: IconButton(
                                                      icon: Icon(Icons.close, color: Colors.grey[700]),
                                                      onPressed: () => Navigator.pop(context),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 18),
                                              Column(
                                                children: [
                                                  SizedBox(
                                                    width: double.infinity,
                                                    child: ElevatedButton.icon(
                                                      icon: Icon(Icons.upload),
                                                      label: Text(AppLocalizations.of(context)!.uploadNew),
                                                      onPressed: () async {
                                                        Navigator.pop(context);
                                                        await _changeProfilePicture();
                                                      },
                                                    ),
                                                  ),
                                                  if (profile != null && profile.photoUrl.isNotEmpty) ...[
                                                    SizedBox(height: 12),
                                                    SizedBox(
                                                      width: double.infinity,
                                                      child: OutlinedButton.icon(
                                                        icon: Icon(Icons.delete),
                                                        label: Text(AppLocalizations.of(context)!.delete),
                                                        onPressed: () async {
                                                          Navigator.pop(context);
                                                          final user = FirebaseAuth.instance.currentUser;
                                                          if (user != null) {
                                                            await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'photoUrl': ''});
                                                            await user.updatePhotoURL('');
                                                            setState(() {});
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: kPrimaryGreen, width: 3),
                                      ),
                                      child: CircleAvatar(
                                        radius: 34,
                                        backgroundImage: profile != null && profile.photoUrl.isNotEmpty
                                          ? NetworkImage(profile.photoUrl)
                                          : null,
                                        backgroundColor: kPrimaryGreen.withOpacity(0.08),
                                        child: profile == null || profile.photoUrl.isEmpty ? Icon(Icons.person, color: kPrimaryGreen, size: 38) : null,
                                      ),
                                    ),
                                    if (profile == null || profile.photoUrl.isEmpty)
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
                                          ),
                                          padding: EdgeInsets.all(4),
                                          child: Icon(Icons.edit, color: kPrimaryGreen, size: 18),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(userName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                                        IconButton(
                                          icon: Icon(Icons.edit, color: kPrimaryGreen, size: 20),
                                          tooltip: AppLocalizations.of(context)!.editName,
                                          onPressed: () => _changeProfileName(userName),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    FutureBuilder<bool>(
                                      future: SubscriptionService().isPremiumUser(),
                                      builder: (context, snapshot) {
                                        final isPremium = snapshot.data ?? false;
                                        return Container(
                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isPremium 
                                                ? kPrimaryGreen.withOpacity(0.10)
                                                : Colors.grey.withOpacity(0.10),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            isPremium ? AppLocalizations.of(context)!.premium : AppLocalizations.of(context)!.freemium, 
                                            style: TextStyle(
                                              color: isPremium ? kPrimaryGreen : Colors.grey[600], 
                                              fontWeight: FontWeight.w600, 
                                              fontSize: 12
                                            )
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          // Add three pill-shaped buttons horizontally
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Removed Plan Settings button
                            ],
                          ),
                          const SizedBox(height: 14),
                          if (profile != null) ...[
                            Builder(
                              builder: (context) {
                                final prefs = Provider.of<PreferencesProvider>(context);
                                final useMetric = prefs.useMetric;
                                final weight = useMetric ? profile.weight : (profile.weight * 2.20462);
                                final weightUnit = useMetric ? 'kg' : 'lb';
                                final height = useMetric ? profile.height : (profile.height * 0.393701);
                                final heightUnit = useMetric ? 'cm' : 'ft';
                                String heightDisplay;
                                if (useMetric) {
                                  heightDisplay = '${height.toStringAsFixed(1)} cm';
                                } else {
                                  int totalInches = height.round();
                                  int feet = totalInches ~/ 12;
                                  int inches = totalInches % 12;
                                  heightDisplay = "${feet}'${inches}\" ft";
                                }
                                return Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: kPrimaryGreen.withOpacity(0.07),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: kPrimaryGreen.withOpacity(0.13)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.trending_up, color: kPrimaryGreen, size: 26),
                                            SizedBox(height: 6),
                                            Text(AppLocalizations.of(context)!.startingWeight, style: TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.w600, fontSize: 15), textAlign: TextAlign.center),
                                            SizedBox(height: 2),
                                            Text('${useMetric ? profile.startingWeight.toStringAsFixed(1) : (profile.startingWeight * 2.20462).toStringAsFixed(1)} ${useMetric ? 'kg' : 'lb'}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: 48,
                                        width: 1.2,
                                        color: kPrimaryGreen.withOpacity(0.13),
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.monitor_weight, color: kPrimaryGreen, size: 26),
                                            SizedBox(height: 6),
                                            Text(AppLocalizations.of(context)!.weight, style: TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.w600, fontSize: 15)),
                                            SizedBox(height: 2),
                                            Text('${weight.toStringAsFixed(1)} $weightUnit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                                            // Weight change indicator
                                            Consumer<PreferencesProvider>(
                                              builder: (context, prefs, child) {
                                                final useMetric = prefs.useMetric;
                                                return FutureBuilder<DocumentSnapshot>(
                                                  future: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).get(),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasData && snapshot.data != null) {
                                                      final data = snapshot.data!.data() as Map<String, dynamic>?;
                                                      final totalWeightChange = data?['totalWeightChange'] as double?;
                                                      final lastWeightUpdate = data?['lastWeightUpdate'] as Timestamp?;
                                                      
                                                      if (totalWeightChange != null && totalWeightChange != 0 && lastWeightUpdate != null) {
                                                        final daysSinceUpdate = DateTime.now().difference(lastWeightUpdate.toDate()).inDays;
                                                        if (daysSinceUpdate <= 7) { // Show for last 7 days
                                                          final isPositive = totalWeightChange > 0;
                                                          final color = isPositive ? Colors.red : Colors.blue;
                                                          final sign = isPositive ? '+' : '';
                                                          
                                                          // Convert to user's preferred unit
                                                          final displayWeightChange = useMetric ? totalWeightChange : (totalWeightChange * 2.20462);
                                                          final unit = useMetric ? 'kg' : 'lb';
                                                          
                                                          return Container(
                                                            margin: EdgeInsets.only(top: 2),
                                                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                            decoration: BoxDecoration(
                                                              color: color.withOpacity(0.1),
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                            child: Text(
                                                              '$sign${displayWeightChange.toStringAsFixed(1)}$unit',
                                                              style: TextStyle(
                                                                color: color,
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      }
                                                    }
                                                    return SizedBox.shrink();
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: 48,
                                        width: 1.2,
                                        color: kPrimaryGreen.withOpacity(0.13),
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.flag, color: kPrimaryGreen, size: 26),
                                            SizedBox(height: 6),
                                            Text(AppLocalizations.of(context)!.targetWeight, style: TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.w600, fontSize: 15), textAlign: TextAlign.center),
                                            SizedBox(height: 2),
                                            Text('${useMetric ? profile.targetWeight.toStringAsFixed(1) : (profile.targetWeight * 2.20462).toStringAsFixed(1)} ${useMetric ? 'kg' : 'lb'}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Menu List
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _ProfileMenuTile(
                            icon: Icons.show_chart,
                            label: AppLocalizations.of(context)!.nutritionalPlan,
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => NutritionalPlanPage()));
                            },
                          ),
                          Divider(height: 1, color: Colors.grey[200]),
                          _ProfileMenuTile(
                            icon: Icons.health_and_safety,
                            label: AppLocalizations.of(context)!.healthAwareness,
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => HealthAwarenessPage()));
                            },
                          ),
                          Divider(height: 1, color: Colors.grey[200]),
                          _ProfileMenuTile(
                            icon: Icons.settings,
                            label: AppLocalizations.of(context)!.settings,
                            iconColor: kPrimaryGreen,
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingsPage()));
                            },
                          ),
                          Divider(height: 1, color: Colors.grey[200]),
                          FutureBuilder<bool>(
                            future: SubscriptionService().isPremiumUser(),
                            builder: (context, snapshot) {
                              final isPremium = snapshot.data ?? false;
                              return Column(
                                children: [
                                  _ProfileMenuTile(
                                    icon: isPremium ? Icons.workspace_premium : Icons.workspace_premium_outlined,
                                    label: isPremium ? AppLocalizations.of(context)!.youArePremium : AppLocalizations.of(context)!.upgradeToPremium,
                                    iconColor: isPremium ? kPrimaryGreen : Colors.grey[600],
                                    onTap: () {
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => SubscriptionPage()));
                                    },
                                  ),
                                  if (isPremium)
                                    Divider(height: 1, color: Colors.grey[200]),
                                  if (isPremium)
                                    _ProfileMenuTile(
                                      icon: Icons.settings,
                                      label: AppLocalizations.of(context)!.manageSubscription,
                                      iconColor: Colors.grey[600],
                                      onTap: () {
                                        // Open device subscription management
                                        if (Platform.isIOS) {
                                          // For iOS, open Settings app
                                          launchUrl(Uri.parse('App-Prefs:root=General&path=SUBSCRIBE_TO_APP'));
                                        } else {
                                          // For Android, open Play Store subscription management
                                          launchUrl(Uri.parse('https://play.google.com/store/account/subscriptions'));
                                        }
                                      },
                                    ),

                                ],
                              );
                            },
                          ),
                          Divider(height: 1, color: Colors.grey[200]),
                          _ProfileMenuTile(
                            icon: Icons.share,
                            label: AppLocalizations.of(context)!.shareWithFriends,
                            iconColor: kSecondaryBlue,
                            onTap: () => _shareApp(context),
                          ),
                          Divider(height: 1, color: Colors.grey[200]),
                          _ProfileMenuTile(
                            icon: Icons.star,
                            label: AppLocalizations.of(context)!.rateUsOn + ' Play Store',
                            iconColor: Colors.amber[600],
                            onTap: () async {
                              try {
                                // Use the correct package name for the app
                                final uri = Uri.parse('https://play.google.com/store/apps/details?id=com.yumie.healthai');
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(AppLocalizations.of(context)!.couldNotOpenPlayStore)),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(AppLocalizations.of(context)!.errorOpeningPlayStore)),
                                );
                              }
                            },
                          ),
                          Divider(height: 1, color: Colors.grey[200]),
                          
                          // Session Management
                          _ProfileMenuTile(
                            icon: Icons.devices,
                            label: AppLocalizations.of(context)!.manageSessions,
                            onTap: () {
                              DeviceSessionService().showSessionManagementDialog(context);
                            },
                          ),
                          Divider(height: 1, color: Colors.grey[200]),
                          
                          // Security Alerts
                          _ProfileMenuTile(
                            icon: Icons.security,
                            label: AppLocalizations.of(context)!.securityAlerts,
                            onTap: () {
                              _securityService.showSecurityAlertsDialog(context);
                            },
                          ),
                          Divider(height: 1, color: Colors.grey[200]),
                          
                          // Language Settings
                          _ProfileMenuTile(
                            icon: Icons.language,
                            label: AppLocalizations.of(context)!.language,
                            onTap: () {
                              _showLanguageSelectionDialog(context);
                            },
                          ),
                          Divider(height: 1, color: Colors.grey[200]),
                          
                          // Only show Reset Password for email/password users, not social users (Google/Apple)
                          if (!_isSocialUser())
                            _ProfileMenuTile(
                              icon: Icons.lock_reset,
                              label: AppLocalizations.of(context)!.resetPassword,
                              onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  final user = FirebaseAuth.instance.currentUser;
                                  final String? email = user?.email;
                                  bool isLoading = false;
                                  String message = '';
                                  return StatefulBuilder(
                                    builder: (context, setState) => Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.all(24),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.lock_reset, size: 48, color: kPrimaryGreen),
                                            SizedBox(height: 16),
                                            Text(AppLocalizations.of(context)!.resetPassword, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                            SizedBox(height: 8),
                                            Text(AppLocalizations.of(context)!.resetPasswordDescription,
                                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(height: 16),
                                            Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                              decoration: BoxDecoration(
                                                color: kPrimaryGreen.withOpacity(0.08),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: kPrimaryGreen.withOpacity(0.18)),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.email, color: kPrimaryGreen),
                                                  SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(
                                                      email ?? 'No email found',
                                                      style: TextStyle(fontWeight: FontWeight.w600, color: kPrimaryGreen, fontSize: 16),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 16),
                                            if (message.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 8),
                                                child: Text(
                                                  message,
                                                  style: TextStyle(
                                                    color: message.startsWith('Success') ? kPrimaryGreen : kWarningRed,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                OutlinedButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor: kPrimaryGreen,
                                                    side: BorderSide(color: kPrimaryGreen),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                  child: Text(AppLocalizations.of(context)!.close),
                                                ),
                                                SizedBox(width: 12),
                                                ElevatedButton(
                                                  onPressed: (isLoading || email == null)
                                                    ? null
                                                    : () async {
                                                        setState(() { isLoading = true; message = ''; });
                                                        
                                                        // Check rate limit for password reset
                                                        final rateLimitResult = await _rateLimitingService.checkRateLimit('password_reset', identifier: email);
                                                        if (!rateLimitResult.allowed) {
                                                          setState(() {
                                                            message = rateLimitResult.message ?? 'Too many password reset requests. Please try again later.';
                                                            isLoading = false;
                                                          });
                                                          return;
                                                        }

                                                        // Record the attempt
                                                        await _rateLimitingService.recordAttempt('password_reset', identifier: email);
                                                        
                                                        try {
                                                          await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                                                          
                                                          // Record password reset request for security monitoring
                                                          await _securityService.recordSecurityEvent(
                                                            'password_reset_request',
                                                            userId: FirebaseAuth.instance.currentUser?.uid,
                                                            email: email,
                                                            successful: true,
                                                            metadata: {'source': 'profile_screen'},
                                                          );
                                                          
                                                          setState(() {
                                                            message = 'Success! Check your email for a reset link. Logging you out for security...';
                                                            isLoading = false;
                                                          });
                                                          // Show message briefly, then logout and navigate properly
                                                          await Future.delayed(Duration(seconds: 2));
                                                          // Log out the user after sending password reset email
                                                          await FirebaseAuth.instance.signOut();
                                                          // Close the dialog first
                                                          if (mounted) {
                                                            Navigator.of(context).pop();
                                                            // Navigate to a redirect screen to properly handle logout
                                                            Navigator.of(context).pushAndRemoveUntil(
                                                              MaterialPageRoute(builder: (_) => _PasswordResetRedirectScreen()),
                                                              (route) => false,
                                                            );
                                                          }
                                                        } catch (e) {
                                                          setState(() {
                                                            message = 'Error: ${e.toString()}';
                                                            isLoading = false;
                                                          });
                                                        }
                                                      },
                                                  child: isLoading
                                                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                                    : Text(AppLocalizations.of(context)!.sendResetLink),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),

                          Divider(height: 1, color: Colors.grey[200]),
                          _ProfileMenuTile(
                            icon: Icons.help_outline,
                            label: AppLocalizations.of(context)!.helpSupport,
                            iconColor: Colors.red,
                            onTap: () async {
                              try {
                                final uri = Uri.parse('https://maivenx.com/');
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(AppLocalizations.of(context)!.couldNotOpenWebsite)),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(AppLocalizations.of(context)!.errorOpeningWebsite)),
                                );
                              }
                            },
                          ),
                          Divider(height: 1, color: Colors.grey[200]),
                          _ProfileMenuTile(
                            icon: Icons.gavel,
                            label: AppLocalizations.of(context)!.legal,
                            iconColor: Colors.grey[600],
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.gavel,
                                          size: 48,
                                          color: kPrimaryGreen,
                                        ),
                                        SizedBox(height: 16),
                                        RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'YUMIE',
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: kPrimaryGreen,
                                                ),
                                              ),
                                              TextSpan(
                                                text: ' by mAIven X inc.',
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        _LegalLinkTile(
                                          icon: Icons.privacy_tip,
                                          title: AppLocalizations.of(context)!.privacyPolicy,
                                          subtitle: 'Read our privacy policy',
                                          url: 'https://yumie.me/privacy',
                                        ),
                                        SizedBox(height: 12),
                                        _LegalLinkTile(
                                          icon: Icons.description,
                                          title: AppLocalizations.of(context)!.termsOfService,
                                          subtitle: 'Read our terms of service',
                                          url: 'https://yumie.me/terms',
                                        ),
                                        SizedBox(height: 12),

                                        SizedBox(height: 24),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            OutlinedButton(
                                              onPressed: () => Navigator.pop(context),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: kPrimaryGreen,
                                                side: BorderSide(color: kPrimaryGreen),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: Text(AppLocalizations.of(context)!.close),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          Divider(height: 1, color: Colors.grey[200]),
                          
                          // Account Deletion
                          _ProfileMenuTile(
                            icon: Icons.delete_forever,
                            label: AppLocalizations.of(context)!.deleteAccount,
                            iconColor: Colors.red[800],
                            labelColor: Colors.red[800],
                            onTap: () {
                              AccountDeletionService().showAccountDeletionDialog(context);
                            },
                          ),
                          Divider(height: 1, color: Colors.grey[200]),
                          
                          _ProfileMenuTile(
                            icon: Icons.logout,
                            label: AppLocalizations.of(context)!.logOut,
                            iconColor: Colors.red,
                            labelColor: Colors.red,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.logout,
                                          size: 48,
                                          color: Colors.red,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          AppLocalizations.of(context)!.logOut,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          AppLocalizations.of(context)!.areYouSureYouWantToLogOut,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 24),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            OutlinedButton(
                                              onPressed: () => Navigator.pop(context),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: kPrimaryGreen,
                                                side: BorderSide(color: kPrimaryGreen),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                              ),
                                              child: Text(AppLocalizations.of(context)!.no),
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                Navigator.pop(context);
                                                await AuthService().logout();
                                                Navigator.of(context).pushAndRemoveUntil(
                                                  MaterialPageRoute(builder: (_) => AuthScreen()),
                                                  (route) => false,
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                              ),
                                              child: Text(AppLocalizations.of(context)!.yes),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }


}

// Helper widget for menu tiles
class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;
  const _ProfileMenuTile({required this.icon, required this.label, required this.onTap, this.iconColor, this.labelColor});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.grey[600]),
      title: Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: labelColor ?? Colors.black)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
      minLeadingWidth: 0,
    );
  }
}

class CoachScreen extends StatefulWidget {
  const CoachScreen({Key? key}) : super(key: key);
  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> with TickerProviderStateMixin {
  int _tabIndex = 0;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _tabController;
  late AnimationController _chatController;
  late AnimationController _insightsController;
  static bool _hasAnimatedEntrance = false;

  List<_ChatMessage> _messages = [];
  int _messageCount = 0; // Track user messages sent
  static const int _maxFreeMessages = 10; // Free message limit

  String? _aiHealthInsight;
  bool _loadingInsight = false;
  int? _lastInsightCalories; // Track calories when last insight was generated
  String? _lastInsightMealPeriod; // Track meal period when last insight was generated
  
  // Scroll to bottom button state
  bool _showScrollToBottomButton = false;

  @override
  void initState() {
    super.initState();
    _tabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _chatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _insightsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _loadChatHistory();
    _loadMessageCount();
    _playEntranceAnimationsIfNeeded();
    _loadLastInsight();
    // Add scroll listener to track scroll position
    _scrollController.addListener(_onScrollChanged);
    // Check initial scroll position after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialScrollState();
    });
  }



  // Load message count from SharedPreferences
  Future<void> _loadMessageCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    final messageCountKey = 'message_count_$todayStr';
    
    setState(() {
      _messageCount = prefs.getInt(messageCountKey) ?? 0;
    });
  }

  // Save message count to SharedPreferences
  Future<void> _saveMessageCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    final messageCountKey = 'message_count_$todayStr';
    
    await prefs.setInt(messageCountKey, _messageCount);
  }

  // Get message counter color based on remaining messages
  Color _getMessageCounterColor() {
    final remainingMessages = _maxFreeMessages - _messageCount;
    if (remainingMessages >= 7) {
      return kPrimaryGreen; // Green for 7-10 messages remaining
    } else if (remainingMessages >= 3) {
      return Colors.orange; // Orange for 3-6 messages remaining
    } else {
      return Colors.red; // Red for 0-2 messages remaining
    }
  }

  // Load chat history from SharedPreferences
  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _initializeWelcomeMessage();
      return;
    }
    
    final chatKey = 'chat_history_${user.uid}';
    final chatJson = prefs.getString(chatKey);
    
    if (chatJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(chatJson);
        final messages = decoded.map((msg) => _ChatMessage(
          text: msg['text'],
          isUser: msg['isUser'],
          quickReplies: List<String>.from(msg['quickReplies'] ?? []),
        )).toList();
        
        setState(() {
          _messages = messages;
        });
        // Check scroll state after messages are loaded
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkInitialScrollState();
        });
      } catch (e) {
        // If there's an error parsing, initialize with welcome message
        _initializeWelcomeMessage();
      }
    } else {
      _initializeWelcomeMessage();
    }
  }

  // Initialize with welcome message
  void _initializeWelcomeMessage() {
    setState(() {
      _messages = [
        _ChatMessage(
          text: AppLocalizations.of(context)!.coachWelcome,
          isUser: false,
          quickReplies: [
            AppLocalizations.of(context)!.coachQuick1,
            AppLocalizations.of(context)!.coachQuick2,
            AppLocalizations.of(context)!.coachQuick3,
          ],
        ),
      ];
    });
    // Check scroll state after welcome message is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialScrollState();
    });
  }

  // Save chat history to SharedPreferences
  Future<void> _saveChatHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final chatKey = 'chat_history_${user.uid}';
    
    final messagesJson = _messages.map((msg) => {
      'text': msg.text,
      'isUser': msg.isUser,
      'quickReplies': msg.quickReplies,
    }).toList();
    
    await prefs.setString(chatKey, jsonEncode(messagesJson));
  }

  // Clear chat history from SharedPreferences
  Future<void> _clearChatHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final chatKey = 'chat_history_${user.uid}';
    await prefs.remove(chatKey);
  }

  // Check if insights need to be refreshed based on calorie changes or meal period changes
  Future<void> _checkAndRefreshInsights() async {
    // Only refresh insights for premium users
    final subscriptionService = SubscriptionService();
    final isPremium = await subscriptionService.isPremiumUser();
    if (!isPremium) {
      return; // Don't refresh for non-premium users
    }
    
    try {
      final meals = await MealService().getTodayMeals().first;
      final currentCalories = meals.fold(0, (sum, m) => sum + m.calories);
      final currentMealPeriod = getCurrentMealPeriod();
      
      // If no previous insight exists, generate one
      if (_aiHealthInsight == null || _aiHealthInsight!.isEmpty) {
        await _fetchAIHealthInsight();
        return;
      }
      
      // Only refresh if calories have changed significantly (more than 50 calories difference)
      if (_lastInsightCalories != null && (_lastInsightCalories! - currentCalories).abs() > 50) {
        await _fetchAIHealthInsight();
        return;
      }
      
      // Only refresh if meal period has changed AND it's been more than 2 hours since last insight
      final lastMealPeriod = _getLastInsightMealPeriod();
      if (lastMealPeriod != null && lastMealPeriod != currentMealPeriod) {
        // Check if it's been more than 2 hours since last insight
        final prefs = await SharedPreferences.getInstance();
        final lastInsightTime = prefs.getInt('last_insight_timestamp');
        final now = DateTime.now().millisecondsSinceEpoch;
        if (lastInsightTime == null || (now - lastInsightTime) > (2 * 60 * 60 * 1000)) { // 2 hours in milliseconds
          await _fetchAIHealthInsight();
          await prefs.setInt('last_insight_timestamp', now);
        }
      }
    } catch (e) {
      // If there's an error, try to fetch a new insight
      await _fetchAIHealthInsight();
    }
  }



  // Helper to translate meal types
  String _getMealTypeLocalized(BuildContext context, String mealType) {
    return getMealTypeLocalized(context, mealType);
  }

  // Helper to get last insight meal period from SharedPreferences
  String? _getLastInsightMealPeriod() {
    return _lastInsightMealPeriod;
  }

  Future<void> _loadLastInsight() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _aiHealthInsight = prefs.getString('last_health_insight');
      _lastInsightCalories = prefs.getInt('last_insight_calories');
      _lastInsightMealPeriod = prefs.getString('last_insight_meal_period');
    });
  }

  Future<void> _fetchAIHealthInsight() async {
    // Only fetch insights for premium users
    final subscriptionService = SubscriptionService();
    final isPremium = await subscriptionService.isPremiumUser();
    if (!isPremium) {
      return; // Don't fetch insights for non-premium users
    }
    
    setState(() { _loadingInsight = true; });
    final userProfile = await UserService().getCurrentUserProfile().first;
    if (userProfile == null) {
      setState(() { _aiHealthInsight = "Could not load profile."; _loadingInsight = false; });
      return;
    }
    // User health data (bloodType, isDiabetic, etc.) is now available in userProfile
    final meals = await MealService().getTodayMeals().first;
    int caloriesConsumed = meals.fold(0, (sum, m) => sum + m.calories);
    int proteinG = meals.fold(0, (sum, m) => sum + m.protein);
    int carbsG = meals.fold(0, (sum, m) => sum + m.carbs);
    int fatG = meals.fold(0, (sum, m) => sum + m.fat);
    double waterIntakeL = (userProfile.waterLoggedMl ?? 0) / 1000.0;
    final chatHistory = [
      {'role': 'user', 'content': "Analyze my health data and provide exactly 3 concise insights. Focus on calorie goal achievement, macro balance, and actionable recommendations. Be direct and factual - no conversational tone."},
    ];
    final prefs = Provider.of<PreferencesProvider>(context, listen: false);
    final aiResponse = await AIService().sendCoachMessage(
      chatHistory: chatHistory,
      name: userProfile.name,
      age: userProfile.age,
      heightCm: userProfile.height.round(),
      weightKg: userProfile.weight,
      startingWeight: userProfile.startingWeight,
      targetWeight: userProfile.targetWeight,
      activityLevel: userProfile.activityLevel,
      calorieGoal: userProfile.dailyCalorieGoal,
      caloriesConsumed: caloriesConsumed,
      proteinGoal: userProfile.proteinGoal,
      carbsGoal: userProfile.carbsGoal,
      fatGoal: userProfile.fatGoal,
      proteinG: proteinG,
      carbsG: carbsG,
      fatG: fatG,
      waterIntakeL: waterIntakeL,
      bloodType: userProfile.bloodType,
      isDiabetic: userProfile.isDiabetic,
      specialInstruction: 'Provide exactly 3 concise health insights. Format as simple bullet points without markdown formatting. Focus on: 1) Calorie goal achievement with specific percentages, 2) Macro balance assessment, 3) One actionable recommendation. Be direct and factual - no greetings or conversational language. Keep each point brief to fit in the UI box.',
      language: prefs.language,
    );
    setState(() { _aiHealthInsight = aiResponse ?? "Could not get AI insight."; _loadingInsight = false; });
    // Save to SharedPreferences
    final prefs2 = await SharedPreferences.getInstance();
    if (_aiHealthInsight != null) {
      prefs2.setString('last_health_insight', _aiHealthInsight!);
      prefs2.setInt('last_insight_calories', caloriesConsumed);
      prefs2.setString('last_insight_meal_period', getCurrentMealPeriod());
      prefs2.setInt('last_insight_timestamp', DateTime.now().millisecondsSinceEpoch);
    }
  }

  void _playEntranceAnimationsIfNeeded() {
    if (!_hasAnimatedEntrance) {
      _chatController.forward();
      _insightsController.forward();
      _hasAnimatedEntrance = true;
    } else {
      _chatController.value = 1.0;
      _insightsController.value = 1.0;
    }
  }

  void _handleCommonQuestion(String question) {
    setState(() {
      _tabIndex = 0;
    });
    Future.delayed(Duration(milliseconds: 200), () {
      _sendMessage(question);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    _insightsController.dispose();
    _controller.dispose();
    _scrollController.removeListener(_onScrollChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    final subscriptionService = SubscriptionService();
    final isPremium = await subscriptionService.isPremiumUser();
    
    // Check message limit for free users
    if (!isPremium && _messageCount >= _maxFreeMessages) {
      // Show subscription prompt instead of sending message
      _showSubscriptionPrompt();
      return;
    }
    
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      if (!isPremium) {
        _messageCount++;
      }
    });
    _controller.clear();
    // Don't auto-scroll - let user control with button
    _saveChatHistory(); // Save after user message
    _saveMessageCount(); // Save message count
    Future.delayed(Duration(milliseconds: 400), () => _botReply(text));
  }

  void _showSubscriptionPrompt() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SubscriptionPage(),
      ),
    );
  }

  void _botReply(String userText) async {
    setState(() {
      _messages.add(_ChatMessage(text: AppLocalizations.of(context)!.yumieThinking, isUser: false));
    });

    // 1. Get user profile
    final userProfile = await UserService().getCurrentUserProfile().first;
    if (userProfile == null) {
      setState(() {
        _messages.removeLast();
        _messages.add(_ChatMessage(text: "Sorry, I couldn't find your profile.", isUser: false));
      });
      return;
    }

    // 2. User health data (bloodType, isDiabetic, etc.) is now available in userProfile

    // 3. Fetch today's meals
    final meals = await MealService().getTodayMeals().first;
    String mealsSummary = meals.isEmpty
        ? "No meals logged today."
        : meals.map((m) =>
            "${getMealTypeLocalized(context, m.mealType)}: ${m.name} (${m.calories} kcal, P:${m.protein}g C:${m.carbs}g F:${m.fat}g)").join("; ");

    // 4. Nutrition log
    int caloriesConsumed = meals.fold(0, (sum, m) => sum + m.calories);
    int proteinG = meals.fold(0, (sum, m) => sum + m.protein);
    int carbsG = meals.fold(0, (sum, m) => sum + m.carbs);
    int fatG = meals.fold(0, (sum, m) => sum + m.fat);
    double waterIntakeL = (userProfile.waterLoggedMl ?? 0) / 1000.0;

    // 5. Build chat history for OpenAI
    final chatHistory = _messages
        .where((m) => m.text != "Yumie is thinking...")
        .map((m) => {
              'role': m.isUser ? 'user' : 'assistant',
              'content': m.text,
            })
        .toList();
    // Add the new user message
    chatHistory.add({'role': 'user', 'content': userText + "\n\nToday's meals: $mealsSummary"});

    // 6. Call the AI with full chat history
    final prefs = Provider.of<PreferencesProvider>(context, listen: false);
    final aiResponse = await AIService().sendCoachMessage(
      chatHistory: chatHistory,
      name: userProfile.name,
      age: userProfile.age,
      heightCm: userProfile.height.round(),
      weightKg: userProfile.weight,
      startingWeight: userProfile.startingWeight,
      targetWeight: userProfile.targetWeight,
      activityLevel: userProfile.activityLevel,
      calorieGoal: userProfile.dailyCalorieGoal,
      caloriesConsumed: caloriesConsumed,
      proteinGoal: userProfile.proteinGoal,
      carbsGoal: userProfile.carbsGoal,
      fatGoal: userProfile.fatGoal,
      proteinG: proteinG,
      carbsG: carbsG,
      fatG: fatG,
      waterIntakeL: waterIntakeL,
      bloodType: userProfile.bloodType,
      isDiabetic: userProfile.isDiabetic,
      language: prefs.language,
    );

    setState(() {
      _messages.removeLast();
      _messages.add(_ChatMessage(text: aiResponse ?? "Sorry, I couldn't get a response.", isUser: false));
    });
    // Don't auto-scroll - let user control with button
    _saveChatHistory(); // Save after AI response
  }



  void _onScrollChanged() {
    if (!_scrollController.hasClients) return;
    
    final position = _scrollController.position;
    final isAtBottom = position.pixels >= position.maxScrollExtent - 50; // Consider at bottom when within 50px
    
    setState(() {
      // If there are messages and we're not at bottom, show scroll button
      // If no messages or we're at bottom, show send button
      _showScrollToBottomButton = _messages.length > 1 && !isAtBottom;
    });
  }

  void _checkInitialScrollState() {
    if (!_scrollController.hasClients) return;
    
    final position = _scrollController.position;
    final isAtBottom = position.pixels >= position.maxScrollExtent - 50;
    
    setState(() {
      // If there are messages and we're not at bottom, show scroll button
      // If no messages or we're at bottom, show send button
      _showScrollToBottomButton = _messages.length > 1 && !isAtBottom;
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: null,
          title: Padding(
            padding: EdgeInsets.only(left: 16, right: 0),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: kPrimaryGreen.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(4),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.yumie, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 22)),
                    SizedBox(height: 2),
                    Text(AppLocalizations.of(context)!.askAboutMeals, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                  ],
                ),
              ],
            ),
          ),
          titleSpacing: 0,
        ),
      ),
      body: Column(
        children: [
          // TabBar
          Container(
            color: Colors.transparent,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _tabIndex = 0);
                      _tabController.forward(from: 0.0);
                      _chatController.forward(from: 0.0);
                      // Check scroll position when switching to chat tab
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _checkInitialScrollState();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _tabIndex == 0 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: Text(AppLocalizations.of(context)!.chat, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: _tabIndex == 0 ? Colors.black : Colors.grey[500])),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _tabIndex = 1);
                      _tabController.forward(from: 0.0);
                      _insightsController.forward(from: 0.0);
                      // Always check for refresh when insights tab is clicked
                      _checkAndRefreshInsights();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _tabIndex == 1 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: Text(AppLocalizations.of(context)!.insights, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: _tabIndex == 1 ? Colors.black : Colors.grey[500])),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Clear Chat Button
          if (_tabIndex == 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _clearChatHistory(); // Clear from SharedPreferences
                      setState(() {
                        _messages.clear();
                        _messages.add(_ChatMessage(
                          text: AppLocalizations.of(context)!.coachWelcome,
                          isUser: false,
                          quickReplies: [
                            AppLocalizations.of(context)!.coachQuick1,
                            AppLocalizations.of(context)!.coachQuick2,
                            AppLocalizations.of(context)!.coachQuick3,
                          ],
                        ));
                      });
                    },
                    icon: Icon(Icons.refresh, size: 18),
                    label: Text(AppLocalizations.of(context)!.clearChat),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryGreen,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          // Content
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: _tabIndex == 0
                ? FadeTransition(
                    opacity: _chatController,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: Offset(0, 0.1), end: Offset.zero).animate(_chatController),
                      child: ListView.builder(
                        key: ValueKey('chat'),
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        itemCount: _messages.length,
                        itemBuilder: (context, i) {
                          final msg = _messages[i];
                          final isUser = msg.isUser;
                          final prefs = Provider.of<PreferencesProvider>(context, listen: false);
                          final isArabic = prefs.language == 'ar';
                          return TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: Duration(milliseconds: 400),
                            builder: (context, value, child) => Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, (1 - value) * 20),
                                child: Column(
                                  crossAxisAlignment: isUser
                                      ? (isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.end)
                                      : (isArabic ? CrossAxisAlignment.start : CrossAxisAlignment.start),
                                  children: [
                                    if (!isUser)
                                      Container(
                                        margin: isArabic
                                            ? EdgeInsets.only(bottom: 8, right: 8, left: 48)
                                            : EdgeInsets.only(bottom: 8, left: 8, right: 48),
                                        padding: EdgeInsets.all(18),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(18),
                                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: Offset(0, 2))],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Directionality(
                                              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                                              child: Text(removeMarkdown(msg.text), style: TextStyle(fontSize: 17, color: Colors.black)),
                                            ),
                                            if (msg.quickReplies.isNotEmpty) ...[
                                              SizedBox(height: 14),
                                              Wrap(
                                                spacing: 10,
                                                runSpacing: 10,
                                                children: msg.quickReplies.map((qr) => _QuickReplyButton(
                                                  text: qr,
                                                  onTap: () => _sendMessage(qr),
                                                )).toList(),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    if (isUser)
                                      Container(
                                        margin: isArabic
                                            ? EdgeInsets.only(bottom: 8, left: 8, right: 48)
                                            : EdgeInsets.only(bottom: 8, right: 8, left: 48),
                                        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                                        decoration: BoxDecoration(
                                          color: kPrimaryGreen,
                                          borderRadius: BorderRadius.circular(18),
                                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: Offset(0, 2))],
                                        ),
                                        child: Directionality(
                                          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                                          child: Text(removeMarkdown(msg.text), style: TextStyle(fontSize: 17, color: Colors.white)),
                                        ),
                                      ),
                                    SizedBox(height: 6),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : FadeTransition(
                    opacity: _insightsController,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: Offset(0, 0.1), end: Offset.zero).animate(_insightsController),
                      child: SingleChildScrollView(
                        key: ValueKey('insights'),
                        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Nutrition Summary
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: StreamBuilder<UserProfile?>(
                                stream: UserService().getCurrentUserProfile(),
                                builder: (context, userSnap) {
                                  if (!userSnap.hasData) return _insightCard(child: Center(child: CircularProgressIndicator()));
                                  final userProfile = userSnap.data!;
                                  final dailyCalorieGoal = userProfile.dailyCalorieGoal;
                                  return StreamBuilder<List<Meal>>(
                                    stream: MealService().getTodayMeals(),
                                    builder: (context, mealSnap) {
                                      if (!mealSnap.hasData) return _insightCard(child: Center(child: CircularProgressIndicator()));
                                      final meals = mealSnap.data!;
                                      final totalCalories = meals.fold(0, (sum, m) => sum + m.calories);
                                      return TweenAnimationBuilder<double>(
                                        tween: Tween<double>(begin: 0, end: totalCalories / dailyCalorieGoal),
                                        duration: Duration(milliseconds: 900),
                                        builder: (context, value, child) => _insightCard(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(AppLocalizations.of(context)!.nutritionSummary, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                              SizedBox(height: 18),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(AppLocalizations.of(context)!.calories, style: TextStyle(fontSize: 16)),
                                                  Text('$totalCalories / $dailyCalorieGoal', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              LinearProgressIndicator(
                                                value: value.clamp(0.0, 1.0),
                                                backgroundColor: kContainerGrey,
                                                color: kAccentOrange,
                                                minHeight: 8,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 18),
                            // Health Insights (AI-powered)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: FutureBuilder<bool>(
                                future: SubscriptionService().isPremiumUser(),
                                builder: (context, snapshot) {
                                  final isPremium = snapshot.data ?? false;
                                  
                                  return _insightCard(
                                    child: Stack(
                                      children: [
                                        // Content
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(AppLocalizations.of(context)!.healthInsights, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                            SizedBox(height: 14),
                                            if (isPremium) ...[
                                              _loadingInsight
                                                ? Center(
                                                    child: Lottie.asset(
                                                      'assets/animations/AI Loading spinner..json',
                                                      width: 80,
                                                      height: 80,
                                                      fit: BoxFit.contain,
                                                    ),
                                                  )
                                                : _aiHealthInsight != null
                                                    ? Builder(
                                                  builder: (context) {
                                                    // Clean the AI response and ensure exactly 3 bullet points
                                                    String cleanedText = _aiHealthInsight!
                                                      .replaceAll(RegExp(r'\*\*\*.*?\*\*\*', caseSensitive: false), '') // Remove markdown bold
                                                      .replaceAll(RegExp(r'\*\*.*?\*\*', caseSensitive: false), '') // Remove markdown bold
                                                      .replaceAll(RegExp(r'^\s*(hey|hi|hello|great to see you)[^\n]*\n*', caseSensitive: false), '') // Remove greetings
                                                      .replaceAll(RegExp(r"you're doing great.*", caseSensitive: false), '') // Remove outro
                                                      .trim();
                                                    
                                                    // Split into bullet points and take exactly 3
                                                    final lines = cleanedText
                                                      .split(RegExp(r'\n+|- '))
                                                      .map((l) => l.trim())
                                                      .where((l) => l.isNotEmpty && l.length > 10) // Filter out very short lines
                                                      .take(3)
                                                      .toList();
                                                    
                                                    // Ensure we have exactly 3 points
                                                    while (lines.length < 3) {
                                                      lines.add("Continue tracking your nutrition goals for optimal health.");
                                                    }
                                                    
                                                    return Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        for (int i = 0; i < lines.length; i++)
                                                          Padding(
                                                            padding: const EdgeInsets.only(bottom: 12),
                                                            child: Row(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Container(
                                                                  width: 8, 
                                                                  height: 8, 
                                                                  margin: EdgeInsets.only(top: 7), 
                                                                  decoration: BoxDecoration(color: kPrimaryGreen, shape: BoxShape.circle)
                                                                ),
                                                                SizedBox(width: 10),
                                                                Expanded(
                                                                  child: Text(
                                                                    lines[i], 
                                                                    style: TextStyle(
                                                                      fontSize: 15, 
                                                                      color: Colors.black87, 
                                                                      fontWeight: FontWeight.w500,
                                                                      height: 1.3,
                                                                    ),
                                                                    maxLines: 4,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                      ],
                                                    );
                                                  },
                                                )
                                                    : Text(AppLocalizations.of(context)!.noInsightAvailable, style: TextStyle(fontSize: 16, color: Colors.grey[800])),
                                                                                         ] else ...[
                                               // Non-premium placeholder content
                                               Column(
                                                 crossAxisAlignment: CrossAxisAlignment.start,
                                                 children: [
                                                   for (int i = 0; i < 3; i++)
                                                     Padding(
                                                       padding: const EdgeInsets.only(bottom: 12),
                                                       child: Row(
                                                         crossAxisAlignment: CrossAxisAlignment.start,
                                                         children: [
                                                           Container(
                                                             width: 8, 
                                                             height: 8, 
                                                             margin: EdgeInsets.only(top: 7), 
                                                             decoration: BoxDecoration(color: Colors.grey[400], shape: BoxShape.circle)
                                                           ),
                                                           SizedBox(width: 10),
                                                           Expanded(
                                                             child: Container(
                                                               height: 15,
                                                               width: double.infinity,
                                                               decoration: BoxDecoration(
                                                                 color: Colors.grey[200],
                                                                 borderRadius: BorderRadius.circular(4),
                                                               ),
                                                             ),
                                                           ),
                                                         ],
                                                       ),
                                                     ),
                                                 ],
                                               ),
                                             ],
                                          ],
                                        ),
                                        
                                                                                 // Premium overlay for non-premium users
                                         if (!isPremium)
                                           Container(
                                             decoration: BoxDecoration(
                                               color: Colors.white.withOpacity(0.95),
                                               borderRadius: BorderRadius.circular(16),
                                             ),
                                             child: Padding(
                                               padding: const EdgeInsets.all(24),
                                               child: Column(
                                                 mainAxisAlignment: MainAxisAlignment.center,
                                                 children: [
                                                   Icon(
                                                     Icons.lock_outline,
                                                     size: 56,
                                                     color: Colors.grey[500],
                                                   ),
                                                   SizedBox(height: 20),
                                                   Text(
                                                     AppLocalizations.of(context)!.subscribeForDailyInsights,
                                                     textAlign: TextAlign.center,
                                                     style: TextStyle(
                                                       fontSize: 20,
                                                       fontWeight: FontWeight.bold,
                                                       color: Colors.grey[800],
                                                     ),
                                                   ),
                                                   SizedBox(height: 12),
                                                   Text(
                                                     AppLocalizations.of(context)!.getPersonalizedHealthInsights,
                                                     textAlign: TextAlign.center,
                                                     style: TextStyle(
                                                       fontSize: 15,
                                                       color: Colors.grey[600],
                                                       height: 1.4,
                                                     ),
                                                   ),
                                                   SizedBox(height: 28),
                                                   Container(
                                                     width: double.infinity,
                                                     child: ElevatedButton(
                                                       onPressed: () {
                                                         Navigator.of(context).push(
                                                           MaterialPageRoute(
                                                             builder: (context) => SubscriptionPage(),
                                                           ),
                                                         );
                                                       },
                                                       style: ElevatedButton.styleFrom(
                                                         backgroundColor: kPrimaryGreen,
                                                         foregroundColor: Colors.white,
                                                         padding: EdgeInsets.symmetric(vertical: 16),
                                                         shape: RoundedRectangleBorder(
                                                           borderRadius: BorderRadius.circular(12),
                                                         ),
                                                         elevation: 2,
                                                       ),
                                                       child: Text(
                                                         AppLocalizations.of(context)!.upgradeToPremium,
                                                         style: TextStyle(
                                                           fontSize: 16,
                                                           fontWeight: FontWeight.bold,
                                                         ),
                                                       ),
                                                     ),
                                                   ),
                                                 ],
                                               ),
                                             ),
                                           ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 18),
                            // Common Questions
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0),
                              child: TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0, end: 1),
                                duration: Duration(milliseconds: 600),
                                builder: (context, value, child) => _insightCard(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                                        decoration: BoxDecoration(
                                          color: kPrimaryGreen.withOpacity(0.08),
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                        ),
                                        child: Text(AppLocalizations.of(context)!.commonQuestions, style: TextStyle(fontWeight: FontWeight.w600, color: kPrimaryGreen, fontSize: 18)),
                                      ),
                                      ...[
                                        AppLocalizations.of(context)!.dinnerIdeas,
                                        AppLocalizations.of(context)!.calorieCheck,
                                        AppLocalizations.of(context)!.proteinSnacks,
                                        AppLocalizations.of(context)!.dietTips,
                                      ].map((q) => TweenAnimationBuilder<double>(
                                        tween: Tween<double>(begin: 0, end: 1),
                                        duration: Duration(milliseconds: 400),
                                        builder: (context, value, child) => Opacity(
                                          opacity: value,
                                          child: Transform.translate(
                                            offset: Offset(0, (1 - value) * 20),
                                            child: ListTile(
                                              leading: Container(
                                                decoration: BoxDecoration(
                                                  color: kPrimaryGreen.withOpacity(0.10),
                                                  shape: BoxShape.circle,
                                                ),
                                                padding: EdgeInsets.all(8),
                                                child: Icon(Icons.search, color: Colors.black54, size: 22),
                                              ),
                                              title: Text(q, style: TextStyle(fontWeight: FontWeight.w500)),
                                              onTap: () => _handleCommonQuestion(q),
                                            ),
                                          ),
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            ),
          ),
          // Input
          if (_tabIndex == 0)
            Column(
              children: [
                // Message counter for free users
                FutureBuilder<bool>(
                  future: SubscriptionService().isPremiumUser(),
                  builder: (context, snapshot) {
                    final isPremium = snapshot.data ?? false;
                    if (isPremium) return SizedBox.shrink();
                    
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getMessageCounterColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getMessageCounterColor(),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${AppLocalizations.of(context)!.messages}: ${_maxFreeMessages - _messageCount}/$_maxFreeMessages',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getMessageCounterColor(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Color(0xFFE5E7EB)),
                          ),
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.typeYourMessage,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            onSubmitted: _sendMessage,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 200),
                        child: _showScrollToBottomButton
                            ? GestureDetector(
                                key: ValueKey('scroll_button'),
                                onTap: _scrollToBottom,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: kPrimaryGreen,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: EdgeInsets.all(12),
                                  child: Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 22),
                                ),
                              )
                            : GestureDetector(
                                key: ValueKey('send_button'),
                                onTap: () => _sendMessage(_controller.text),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: kPrimaryGreen,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: EdgeInsets.all(12),
                                  child: Icon(Icons.send, color: Colors.white, size: 22),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final List<String> quickReplies;
  _ChatMessage({required this.text, required this.isUser, this.quickReplies = const []});
}

class _QuickReplyButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _QuickReplyButton({required this.text, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: kPrimaryGreen.withOpacity(0.08),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: kPrimaryGreen.withOpacity(0.18)),
        ),
        child: Text(text, style: TextStyle(fontWeight: FontWeight.w500, color: kPrimaryGreen)),
      ),
    );
  }
}

// Helper for card UI
Widget _insightCard({required Widget child}) {
  return Container(
    margin: EdgeInsets.only(bottom: 18),
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: child,
  );
}

class FoodScreen extends StatefulWidget {
  const FoodScreen({Key? key}) : super(key: key);
  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> with TickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int _tabIndex = 0; // 0: My Meals, 1: Suggested Meals
  final MealService _mealService = MealService();
  
  // Helper function to get food type icon
  IconData _getFoodTypeIcon(String? foodType) {
    switch (foodType?.toLowerCase()) {
      case 'drink':
        return Icons.local_drink;
      case 'ingredient':
        return Icons.eco;
      case 'meal':
      default:
        return Icons.restaurant;
    }
  }

  // AI-powered suggested meals (no longer hardcoded)
  List<Map<String, dynamic>> _aiMeals = [];

  // Helper to get current meal period
  String get _currentMealPeriod {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return 'breakfast';
    if (hour >= 11 && hour < 15) return 'lunch';
    if (hour >= 15 && hour < 20) return 'dinner';
    return 'snack';
  }

  String _getCurrentMealLabel(BuildContext context) {
    final period = _currentMealPeriod;
    switch (period) {
      case 'breakfast':
        return AppLocalizations.of(context)!.breakfastTime + ' ☀️';
      case 'lunch':
        return AppLocalizations.of(context)!.lunchTime + '! 🌤️';
      case 'dinner':
        return AppLocalizations.of(context)!.dinnerTime + '! 🌇';
      default:
        return AppLocalizations.of(context)!.snackTime + '! 🌙';
    }
  }

  late AnimationController _tabController;
  late AnimationController _calendarController;
  late AnimationController _myMealsController;
  late AnimationController _suggestedController;

  // Add state for calendar view mode
  String _calendarView = 'week'; // 'week' or 'month'
  CalendarFormat _calendarFormat = CalendarFormat.week;

  // Add state for meal type filter in Food page
  int _selectedFoodMealTypeIndex = 0;
  bool _hasFoodPageInitialized = false;
  
  // Helper to get localized food meal types
  List<String> _getFoodMealTypes(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return [
      localizations.breakfast,
      localizations.lunch,
      localizations.dinner,
      localizations.snack,
    ];
  }
  
  // Helper to get meal type keys for filtering
  final List<String> _foodMealTypeKeys = ['breakfast', 'lunch', 'dinner', 'snack'];
  
  // Helper to get meal type index based on current time
  int _getCurrentMealTypeIndex() {
    final currentMealPeriod = getCurrentMealPeriod();
    switch (currentMealPeriod) {
      case 'breakfast':
        return 0;
      case 'lunch':
        return 1;
      case 'dinner':
        return 2;
      case 'snack':
        return 3;
      default:
        return 0;
    }
  }

  // Add cache for AI meals
  Map<String, List<Map<String, dynamic>>> _cachedAIMeals = {};
  String? _cachedPeriodKey;
  DateTime? _cachedDate;

  Future<List<Map<String, dynamic>>?> _getOrFetchAIMeals() async {
    final prefs = Provider.of<PreferencesProvider>(context, listen: false);
    final period = _currentMealPeriod;
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month}-${today.day}';
    final cacheKey = 'ai_meals_${period}_$dateKey';
    // If already loaded in memory for this period and day
    if (_cachedPeriodKey == cacheKey && _cachedAIMeals[cacheKey] != null) {
      return _cachedAIMeals[cacheKey]!;
    }
    // Try to load from SharedPreferences
    final cachedJson = await SharedPreferences.getInstance().then((sp) => sp.getString(cacheKey));
    if (cachedJson != null) {
      final List<dynamic> decoded = jsonDecode(cachedJson);
      final meals = decoded.cast<Map<String, dynamic>>();
      _cachedAIMeals[cacheKey] = meals;
      _cachedPeriodKey = cacheKey;
      _cachedDate = today;
      return meals;
    }
    // Fetch from AI
    final language = prefs.language;
    final meals = await AIService().getSuggestedMeals(mealPeriod: period, language: language);
    if (meals != null) {
      final sp = await SharedPreferences.getInstance();
      sp.setString(cacheKey, jsonEncode(meals));
      _cachedAIMeals[cacheKey] = meals;
      _cachedPeriodKey = cacheKey;
      _cachedDate = today;
    }
    return meals;
  }

  @override
  void initState() {
    super.initState();
    _tabController = AnimationController(vsync: this, duration: Duration(milliseconds: 350));
    _calendarController = AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _myMealsController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _suggestedController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _selectedDay = DateTime.now();
    _refreshAIMeals();
    _calendarController.forward();
    _myMealsController.forward();
    _suggestedController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _calendarController.dispose();
    _myMealsController.dispose();
    _suggestedController.dispose();
    super.dispose();
  }

  Future<void> _refreshAIMeals() async {
    final meals = await _getOrFetchAIMeals();
    if (meals != null) {
      setState(() {
        _aiMeals = meals;
      });
    }
    _suggestedController.reset();
    _suggestedController.forward();
  }
  
  // Method to force refresh meals (for manual refresh)
  Future<void> _forceRefreshAIMeals() async {
    // Clear cache for current period
    final prefs = Provider.of<PreferencesProvider>(context, listen: false);
    final period = _currentMealPeriod;
    final language = prefs.language;
    await AIService().clearSuggestedMealsCache(period, language);
    
    // Clear in-memory cache
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month}-${today.day}';
    final cacheKey = 'ai_meals_${period}_$dateKey';
    _cachedAIMeals.remove(cacheKey);
    _cachedPeriodKey = null;
    
    // Fetch fresh meals
    await _refreshAIMeals();
  }

  void _onTabChanged(int index) {
    setState(() => _tabIndex = index);
    _tabController.forward(from: 0.0);
    if (index == 0) {
      _myMealsController.forward(from: 0.0);
    } else {
      // Only trigger animation, don't refresh meals
      _suggestedController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final List<String> localizedMealTypes = [
      localizations.breakfast,
      localizations.lunch,
      localizations.dinner,
      localizations.snack,
    ];
    
    // Initialize meal type selection based on current time (only once)
    if (!_hasFoodPageInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedFoodMealTypeIndex = _getCurrentMealTypeIndex();
          _hasFoodPageInitialized = true;
        });
      });
    }
    String getCurrentMealLabel() {
      final period = _currentMealPeriod;
      switch (period) {
        case 'breakfast':
          return localizations.breakfast;
        case 'lunch':
          return localizations.lunch;
        case 'dinner':
          return localizations.dinner;
        default:
          return localizations.snack;
      }
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: null,
          title: Padding(
            padding: EdgeInsets.only(left: 16, right: 0),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: kPrimaryGreen.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(4),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(localizations.food, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 22)),
                    SizedBox(height: 2),
                    Text(localizations.trackYourNutrition, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                  ],
                ),
              ],
            ),
          ),
          titleSpacing: 0,
        ),
      ),
      body: Column(
        children: [
          // TabBar
          Container(
            color: Colors.transparent,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onTabChanged(0),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _tabIndex == 0 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: Text(localizations.myMeals, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: _tabIndex == 0 ? Colors.black : Colors.grey[500])),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onTabChanged(1),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _tabIndex == 1 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: Text(localizations.suggestedMeals, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: _tabIndex == 1 ? Colors.black : Colors.grey[500])),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Animated tab content
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 350),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _tabIndex == 0
                  ? Column(
                      key: ValueKey('mymeals'),
                      children: [
                        FadeTransition(
                          opacity: _calendarController,
                          child: SlideTransition(
                            position: Tween<Offset>(begin: Offset(0, 0.08), end: Offset.zero).animate(_calendarController),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: TableCalendar(
                                firstDay: DateTime.utc(2020, 1, 1),
                                lastDay: DateTime.utc(2100, 12, 31),
                                focusedDay: _focusedDay,
                                selectedDayPredicate: (day) => _selectedDay != null && day.year == _selectedDay!.year && day.month == _selectedDay!.month && day.day == _selectedDay!.day,
                                onDaySelected: (selectedDay, focusedDay) {
                                  setState(() {
                                    _selectedDay = selectedDay;
                                    _focusedDay = focusedDay;
                                  });
                                  _myMealsController.forward(from: 0.0);
                                },
                                calendarFormat: _calendarFormat,
                                onFormatChanged: (format) {
                                  setState(() {
                                    _calendarFormat = format;
                                    _calendarView = format == CalendarFormat.week ? 'week' : 'month';
                                  });
                                },
                                calendarStyle: CalendarStyle(
                                  todayDecoration: BoxDecoration(color: kPrimaryGreen.withOpacity(0.18), shape: BoxShape.circle),
                                  selectedDecoration: BoxDecoration(color: kPrimaryGreen, shape: BoxShape.circle),
                                  selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  todayTextStyle: const TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.bold),
                                ),
                                headerStyle: HeaderStyle(
                                  formatButtonVisible: false,
                                  titleCentered: true,
                                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
                                  titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                                ),
                                daysOfWeekStyle: DaysOfWeekStyle(
                                  weekdayStyle: TextStyle(color: Colors.grey[600]),
                                  weekendStyle: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Meal type bar for filtering meals
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(localizedMealTypes.length, (i) {
                              final selected = i == _selectedFoodMealTypeIndex;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedFoodMealTypeIndex = i),
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 180),
                                    margin: EdgeInsets.symmetric(horizontal: 4),
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: selected ? kPrimaryGreen : Color(0xFFF1F1F1),
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    child: Center(
                                      child: Text(
                                        localizedMealTypes[i],
                                        style: TextStyle(
                                          color: selected ? Colors.white : Colors.grey[700],
                                          fontWeight: FontWeight.w600,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        // Filtered meal list
                        Expanded(
                          child: StreamBuilder<List<Meal>>(
                            stream: _mealService.getMealsForDate(_selectedDay ?? DateTime.now()),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                              final meals = snapshot.data!;
                              final filteredMeals = meals.where((m) => m.mealType.toLowerCase() == _foodMealTypeKeys[_selectedFoodMealTypeIndex]).toList();
                              if (filteredMeals.isEmpty) {
                                return Center(child: Text(localizations.noMealsLoggedForThisDay, style: TextStyle(color: Colors.grey)));
                              }
                              return ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                itemCount: filteredMeals.length,
                                itemBuilder: (context, i) {
                                  return TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 0, end: 1),
                                    duration: Duration(milliseconds: 400 + i * 80),
                                    builder: (context, value, child) => Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(0, (1 - value) * 24),
                                        child: _FoodMealCard(meal: filteredMeals[i]),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : FadeTransition(
                      key: ValueKey('suggested'),
                      opacity: _suggestedController,
                      child: SlideTransition(
                        position: Tween<Offset>(begin: Offset(0, 0.06), end: Offset.zero).animate(_suggestedController),
                        child: FutureBuilder<List<Map<String, dynamic>>?>(
                          future: _getOrFetchAIMeals(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return SizedBox(
                                height: 320,
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                              return Padding(
                                padding: const EdgeInsets.all(32),
                                child: Center(child: Text(localizations.noMealsLoggedForThisDay, style: TextStyle(color: Colors.grey[600], fontSize: 16))),
                              );
                            }
                            final meals = snapshot.data!;
                            return SafeArea(
                              child: ListView(
                                padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 24),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                                    child: Text(_getCurrentMealLabel(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                                  ),
                                  ...List.generate(meals.length, (i) {
                                    final meal = meals[i];
                                    // Log the image URL for debugging
                            
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24), // increased from 20
                                      child: Stack(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(0, 24, 48, 24), // <-- increased top and bottom padding
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.04),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Meal image - AI suggested meals use food type icon
                                                ClipRRect(
                                                        borderRadius: BorderRadius.circular(16),
                                                        child: Container(
                                                          width: 70,
                                                          height: 70,
                                                    decoration: BoxDecoration(
                                                      color: kPrimaryGreen.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(16),
                                                    ),
                                                    child: Icon(
                                                      _getFoodTypeIcon('meal'), // AI suggested meals are always meals
                                                      size: 35,
                                                      color: kPrimaryGreen,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 14),
                                                // Meal info
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              meal['meal_name'] as String? ?? '',
                                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Text(
                                                            '${meal['calories']} cal',
                                                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(meal['time'] as String? ?? '5 mins', style: TextStyle(color: Colors.grey[600], fontSize: 15)),
                                                      const SizedBox(height: 8),
                                                      Wrap(
                                                        spacing: 8,
                                                        runSpacing: 4,
                                                        children: [
                                                          for (final tag in (meal['benefits'] as List<dynamic>? ?? []))
                                                            Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                              decoration: BoxDecoration(
                                                                color: Colors.orange[50],
                                                                borderRadius: BorderRadius.circular(10),
                                                              ),
                                                              child: Text(
                                                                tag.toString(),
                                                                style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.w500, fontSize: 13),
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 18,
                                            right: 18,
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius: BorderRadius.circular(20),
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) => GeneratedMealFromFridgePage(meal: meal),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius: BorderRadius.circular(20),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.green.withOpacity(0.12),
                                                        blurRadius: 6,
                                                        offset: Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  padding: const EdgeInsets.all(8),
                                                  child: Icon(Icons.add, color: Colors.white, size: 24),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodMealCard extends StatefulWidget {
  final Meal meal;
  const _FoodMealCard({required this.meal});
  @override
  State<_FoodMealCard> createState() => _FoodMealCardState();
}

class _FoodMealCardState extends State<_FoodMealCard> {
  bool _expanded = false;
  
  // Helper function to get food type icon
  IconData _getFoodTypeIcon(String? foodType) {
    switch (foodType?.toLowerCase()) {
      case 'drink':
        return Icons.local_drink;
      case 'ingredient':
        return Icons.eco;
      case 'meal':
      default:
        return Icons.restaurant;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal image - prioritize user's photo, otherwise use food type icon
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: meal.imageUrl != null
                    ? Image.network(
                        meal.imageUrl!,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to food type icon if user's image fails to load
                                return Container(
                                  width: 70,
                                  height: 70,
                            decoration: BoxDecoration(
                              color: kPrimaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              _getFoodTypeIcon(meal.foodType),
                              size: 35,
                              color: kPrimaryGreen,
                            ),
                          );
                        },
                                )
                              : Container(
                                  width: 70,
                                  height: 70,
                        decoration: BoxDecoration(
                          color: kPrimaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _getFoodTypeIcon(meal.foodType),
                          size: 35,
                          color: kPrimaryGreen,
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(getMealTypeLocalized(context, meal.mealType), style: TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        Text(formatTime(meal.timestamp), style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meal.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: AppLocalizations.of(context)!.localeName.startsWith('ar') ? TextDirection.rtl : TextDirection.ltr,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 2,
                      children: [
                        _MacroTag(label: 'P', value: '${meal.protein}g', color: kSecondaryBlue),
                        _MacroTag(label: 'C', value: '${meal.carbs}g', color: kAccentOrange),
                        _MacroTag(label: 'F', value: '${meal.fat}g', color: kWarningRed),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('${meal.calories}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('cal', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent, size: 22),
                        tooltip: 'Delete meal',
                        padding: EdgeInsets.all(8),
                        constraints: BoxConstraints(minWidth: 48, minHeight: 48),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(AppLocalizations.of(context)!.deleteMeal),
                              content: Text(AppLocalizations.of(context)!.areYouSureDeleteMeal),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text(AppLocalizations.of(context)!.cancel),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  child: Text(AppLocalizations.of(context)!.delete),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await MealService().deleteMeal(meal.id);
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: kPrimaryGreen, size: 22),
                        tooltip: _expanded ? 'Hide ingredients' : 'Show ingredients',
                        padding: EdgeInsets.all(8),
                        constraints: BoxConstraints(minWidth: 48, minHeight: 48),
                        onPressed: () => setState(() => _expanded = !_expanded),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Builder(
                  builder: (context) {
                    final ingredients = meal.ingredients;
                    if (ingredients.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ingredients:', style: TextStyle(fontWeight: FontWeight.w600, color: kPrimaryGreen)),
                          ...ingredients.map((ing) => Text('� $ing', style: TextStyle(color: Colors.black87))).toList(),
                        ],
                      );
                    } else {
                      return Text(AppLocalizations.of(context)!.noIngredientsListed, style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic));
                    }
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}


class _RecipeCardBig extends StatelessWidget {
  final Map<String, dynamic> recipe;
  const _RecipeCardBig({required this.recipe});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              recipe['image'],
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(recipe['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text('${recipe['calories']} cal', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(recipe['time'], style: TextStyle(color: Colors.grey[600], fontSize: 15)),
                const SizedBox(width: 12),
                ...List.generate(recipe['tags'].length, (i) {
                  final tag = recipe['tags'][i];
                  final color = tag == 'High Protein' ? kSecondaryBlue : tag == 'Vegetarian' ? Colors.green : Colors.blue[200];
                  return Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color?.withOpacity(0.12) ?? Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(tag, style: TextStyle(color: color ?? Colors.blue, fontWeight: FontWeight.w500, fontSize: 13)),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _RecipeCardSmall extends StatelessWidget {
  final Map<String, dynamic> recipe;
  const _RecipeCardSmall({required this.recipe});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              recipe['image'],
              height: 54,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
            child: Text(recipe['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Text(recipe['time'], style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const SizedBox(width: 6),
                ...List.generate(recipe['tags'].length > 0 ? 1 : 0, (i) {
                  final tag = recipe['tags'][i];
                  final color = tag == 'High Protein' ? kSecondaryBlue : tag == 'Vegetarian' ? Colors.green : Colors.blue[200];
                  return Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color?.withOpacity(0.12) ?? Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(tag, style: TextStyle(color: color ?? Colors.blue, fontWeight: FontWeight.w500, fontSize: 11)),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// FAB Action Button
class _FabActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isLarge;
  const _FabActionButton({required this.label, required this.icon, required this.onTap, this.isLarge = false});

  @override
  Widget build(BuildContext context) {
    // Both Log and Scan use kPrimaryGreen
    Color color = kPrimaryGreen;
    final iconSize = isLarge ? 24.0 : 18.0;
    final fontSize = isLarge ? 16.0 : 14.0;
    final horizontalPadding = isLarge ? 24.0 : 18.0;
    final verticalPadding = isLarge ? 16.0 : 12.0;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: iconSize),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: fontSize, color: color, decoration: TextDecoration.none)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Animated Scale on Tap
class _AnimatedScaleOnTap extends StatefulWidget {
  final Widget child;
  const _AnimatedScaleOnTap({required this.child});

  @override
  State<_AnimatedScaleOnTap> createState() => _AnimatedScaleOnTapState();
}

class _AnimatedScaleOnTapState extends State<_AnimatedScaleOnTap> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

// Add this widget before ProfileScreen
class _ProfileActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ProfileActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: kPrimaryGreen.withOpacity(0.08),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: kPrimaryGreen.withOpacity(0.18)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: kPrimaryGreen, size: 20),
                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileInfoChip({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: kPrimaryGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimaryGreen.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: kPrimaryGreen, size: 16),
          SizedBox(width: 4),
          Flexible(
            child: Text(
              '$label: $value',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: kPrimaryGreen,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferencesProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.preferences, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              SizedBox(height: 18),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 2,
                child: Column(
          children: [

            SwitchListTile(
                      title: Text(AppLocalizations.of(context)!.useMetricUnits, style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(AppLocalizations.of(context)!.unitsSubtitle),
              value: prefs.useMetric,
              onChanged: (v) => prefs.setUseMetric(v),
              secondary: Icon(Icons.straighten),
            ),
                    Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: Icon(Icons.language),
              title: Text(AppLocalizations.of(context)!.language, style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(AppLocalizations.of(context)!.selectLanguage),
              trailing: DropdownButton<String>(
                value: prefs.language,
                items: [
                  DropdownMenuItem(value: 'en', child: Text(AppLocalizations.of(context)!.english)),
                  DropdownMenuItem(value: 'ar', child: Text(AppLocalizations.of(context)!.arabic)),
                  DropdownMenuItem(value: 'es', child: Text(AppLocalizations.of(context)!.spanish)),
                ],
                onChanged: (v) => prefs.setLanguage(v!),
              ),
            ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              Text(AppLocalizations.of(context)!.appPermissions, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              SizedBox(height: 18),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 2,
                child: ListTile(
                  leading: Icon(Icons.security),
                  title: Text(AppLocalizations.of(context)!.managePermissions, style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(AppLocalizations.of(context)!.cameraNotificationsAndMore),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PermissionStatusScreen(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 32),
              Text(AppLocalizations.of(context)!.habitNotifications, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              SizedBox(height: 18),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 2,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(AppLocalizations.of(context)!.mealLoggingPrompts, style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(AppLocalizations.of(context)!.mealLoggingPromptsSubtitle),
                      value: prefs.mealLoggingPrompts,
                      onChanged: (v) => prefs.setMealLoggingPrompts(v),
                      secondary: Icon(Icons.restaurant),
                    ),
                    Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
                    SwitchListTile(
                      title: Text(AppLocalizations.of(context)!.waterIntakeReminders, style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(AppLocalizations.of(context)!.waterIntakeRemindersSubtitle),
                      value: prefs.waterIntakeReminders,
                      onChanged: (v) => prefs.setWaterIntakeReminders(v),
                      secondary: Icon(Icons.water_drop),
                    ),
                    Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
                    SwitchListTile(
                      title: Text(AppLocalizations.of(context)!.mindfulWalksReminders, style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(AppLocalizations.of(context)!.mindfulWalksRemindersSubtitle),
                      value: prefs.mindfulWalksReminders,
                      onChanged: (v) => prefs.setMindfulWalksReminders(v),
                      secondary: Icon(Icons.directions_walk),
                    ),
                    Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
                    SwitchListTile(
                      title: Text(AppLocalizations.of(context)!.momentOfCalmAfterMeals, style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(AppLocalizations.of(context)!.momentOfCalmAfterMealsSubtitle),
                      value: prefs.momentOfCalmReminders,
                      onChanged: (v) => prefs.setMomentOfCalmReminders(v),
                      secondary: Icon(Icons.self_improvement),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class HealthAwarenessPage extends StatefulWidget {
  @override
  _HealthAwarenessPageState createState() => _HealthAwarenessPageState();
}

class _HealthAwarenessPageState extends State<HealthAwarenessPage> {
  String? _bloodType;
  bool? _isDiabetic;
  bool _saving = false;

  final List<String> bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data() ?? {};
      setState(() {
        _bloodType = data['bloodType'] as String?;
        _isDiabetic = data['isDiabetic'] as bool?;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'bloodType': _bloodType,
        'isDiabetic': _isDiabetic,
        'lastUpdated': DateTime.now(),
      });
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.healthAwarenessUpdated)));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.healthAwareness)),
      body: _saving
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.bloodType, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: bloodTypes.map((type) {
                      final isSelected = _bloodType == type;
                      return ChoiceChip(
                        label: Text(type, style: TextStyle(fontWeight: FontWeight.bold)),
                        selected: isSelected,
                        selectedColor: theme.primaryColor.withOpacity(0.18),
                        onSelected: (selected) => setState(() => _bloodType = type),
                        labelStyle: TextStyle(color: isSelected ? theme.primaryColor : Colors.black),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: isSelected ? theme.primaryColor : Colors.grey[300]!, width: 2),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 32),
                  Text(AppLocalizations.of(context)!.areYouDiabetic, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      ChoiceChip(
                        label: Row(children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 6), Text(AppLocalizations.of(context)!.yes)]),
                        selected: _isDiabetic == true,
                        selectedColor: Colors.green.withOpacity(0.18),
                        onSelected: (selected) => setState(() => _isDiabetic = true),
                        labelStyle: TextStyle(color: _isDiabetic == true ? Colors.green : Colors.black),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: _isDiabetic == true ? Colors.green : Colors.grey[300]!, width: 2),
                      ),
                      SizedBox(width: 18),
                      ChoiceChip(
                        label: Row(children: [Icon(Icons.cancel, color: Colors.red), SizedBox(width: 6), Text(AppLocalizations.of(context)!.no)]),
                        selected: _isDiabetic == false,
                        selectedColor: Colors.red.withOpacity(0.18),
                        onSelected: (selected) => setState(() => _isDiabetic = false),
                        labelStyle: TextStyle(color: _isDiabetic == false ? Colors.red : Colors.black),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: _isDiabetic == false ? Colors.red : Colors.grey[300]!, width: 2),
                      ),
                    ],
                  ),
                  Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_bloodType != null && _isDiabetic != null && !_saving) ? _save : null,
                      child: Text(AppLocalizations.of(context)!.save),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// Weight Log Dialog
class _WeightLogDialog extends StatefulWidget {
  @override
  State<_WeightLogDialog> createState() => _WeightLogDialogState();
}

class _WeightLogDialogState extends State<_WeightLogDialog> {
  double _value = 0.5; // default 0.5kg
  final double _min = 0.1;
  final double _max = 10.0;
  final double _step = 0.1;
  bool _isAdd = true;
  
  // Convert values based on user's unit preference
  double _getDisplayValue(double kgValue, bool useMetric) {
    return useMetric ? kgValue : (kgValue * 2.20462);
  }
  
  double _getKgValue(double displayValue, bool useMetric) {
    return useMetric ? displayValue : (displayValue / 2.20462);
  }
  
  String _getUnit(bool useMetric) {
    return useMetric ? 'kg' : 'lb';
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferencesProvider>(context);
    final useMetric = prefs.useMetric;
    final displayValue = _getDisplayValue(_value, useMetric);
    final displayMin = _getDisplayValue(_min, useMetric);
    final displayMax = _getDisplayValue(_max, useMetric);
    final unit = _getUnit(useMetric);
    
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.logWeightChange),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: Text(AppLocalizations.of(context)!.lost),
                selected: !_isAdd,
                selectedColor: Colors.blue[100],
                onSelected: (selected) => setState(() => _isAdd = false),
                labelStyle: TextStyle(
                  color: !_isAdd ? Colors.blue[700] : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 12),
              ChoiceChip(
                label: Text(AppLocalizations.of(context)!.gained),
                selected: _isAdd,
                selectedColor: Colors.red[100],
                onSelected: (selected) => setState(() => _isAdd = true),
                labelStyle: TextStyle(
                  color: _isAdd ? Colors.red[700] : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          Text('${displayValue.toStringAsFixed(1)}$unit', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _isAdd ? Colors.red[400] : Colors.blue[400])),
          SizedBox(height: 16),
          Slider(
            value: displayValue,
            min: displayMin,
            max: displayMax,
            divisions: ((displayMax - displayMin) / _getDisplayValue(_step, useMetric)).round(),
            onChanged: (v) => setState(() => _value = _getKgValue(double.parse(v.toStringAsFixed(1)), useMetric)),
            activeColor: _isAdd ? Colors.red : Colors.blue,
            inactiveColor: Colors.grey[300],
            thumbColor: _isAdd ? Colors.red : Colors.blue,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${displayMin.toStringAsFixed(1)}$unit'),
              Text('${displayMax.toStringAsFixed(1)}$unit'),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_isAdd ? _value : -_value),
          child: Text(_isAdd ? AppLocalizations.of(context)!.gained : AppLocalizations.of(context)!.lost),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isAdd ? Colors.red : Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

// Add this widget at the end of the file or in a suitable place
class _WaterLogSliderDialog extends StatefulWidget {
  @override
  State<_WaterLogSliderDialog> createState() => _WaterLogSliderDialogState();
}

class _WaterLogSliderDialogState extends State<_WaterLogSliderDialog> {
  double _value = 0.25; // default 0.25L
  final double _min = 0.1;
  final double _max = 2.0;
  final double _step = 0.1;
  bool _isAdd = true;
  int _currentWaterLogged = 0;
  bool _hasWaterLogged = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentWaterLogged();
  }

  Future<void> _loadCurrentWaterLogged() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data() ?? {};
      final waterLogged = data['waterLoggedMl'] ?? 0;
      setState(() {
        _currentWaterLogged = waterLogged;
        _hasWaterLogged = waterLogged > 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.logWaterIntake),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: Text(AppLocalizations.of(context)!.add),
                selected: _isAdd,
                selectedColor: Colors.blue[100],
                onSelected: (selected) => setState(() => _isAdd = true),
                labelStyle: TextStyle(
                  color: _isAdd ? Colors.blue[700] : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_hasWaterLogged) ...[
                SizedBox(width: 12),
                ChoiceChip(
                  label: Text(AppLocalizations.of(context)!.remove),
                  selected: !_isAdd,
                  selectedColor: Colors.red[100],
                  onSelected: (selected) => setState(() => _isAdd = false),
                  labelStyle: TextStyle(
                    color: !_isAdd ? Colors.red[700] : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 18),
          Text('${_value.toStringAsFixed(2)}L', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _isAdd ? Colors.blue[400] : Colors.red[400])),
          SizedBox(height: 16),
          Slider(
            value: _value,
            min: _isAdd ? _min : 0.1,
            max: _isAdd ? _max : (_currentWaterLogged / 1000.0).clamp(0.1, _max),
            divisions: _isAdd 
                ? ((_max - _min) / _step).round()
                : (((_currentWaterLogged / 1000.0).clamp(0.1, _max) - 0.1) / _step).round(),
            onChanged: (v) => setState(() => _value = double.parse(v.toStringAsFixed(2))),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_isAdd ? '${_min.toStringAsFixed(1)}L' : '0.1L'),
              Text(_isAdd ? '${_max.toStringAsFixed(1)}L' : '${(_currentWaterLogged / 1000.0).clamp(0.1, _max).toStringAsFixed(1)}L'),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_isAdd ? (_value * 1000).round() : -(_value * 1000).round()),
          child: Text(AppLocalizations.of(context)!.add),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isAdd ? Colors.green : Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

// Helper to remove Markdown formatting from AI responses - DUPLICATE REMOVED
/* String removeMarkdown_OLD_DUPLICATE(String text) {
  return text
      .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'')
      .replaceAll(RegExp(r'__(.*?)__'), r'')
      .replaceAll(RegExp(r'\*(.*?)\*'), r'')
      .replaceAll(RegExp(r'_(.*?)_'), r'');
} */

// Add this helper function to main.dart
Locale _getLocale(String code) {
  if (code == 'ar') return const Locale('ar');
  if (code == 'es') return const Locale('es');
  return const Locale('en');
}

// Helper to remove Markdown formatting from AI responses
String removeMarkdown(String text) {
  return text
      // Remove headers (### ## #)
      .replaceAll(RegExp(r'^#{1,6}\s*(.*)$', multiLine: true), r'$1')
      // Remove bold (**text** and __text__)
      .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1')
      .replaceAll(RegExp(r'__(.*?)__'), r'$1')
      // Remove italic (*text* and _text_)
      .replaceAll(RegExp(r'\*(.*?)\*'), r'$1')
      .replaceAll(RegExp(r'_(.*?)_'), r'$1')
      // Remove strikethrough (~~text~~)
      .replaceAll(RegExp(r'~~(.*?)~~'), r'$1')
      // Remove code blocks (```text``` and `text`)
      .replaceAll(RegExp(r'```[\s\S]*?```'), '')
      .replaceAll(RegExp(r'`(.*?)`'), r'$1')
      // Remove links [text](url)
      .replaceAll(RegExp(r'\[([^\]]*)\]\([^\)]*\)'), r'$1')
      // Remove list markers (- * +)
      .replaceAll(RegExp(r'^[\s]*[-\*\+]\s*', multiLine: true), '')
      // Remove numbered lists (1. 2. etc)
      .replaceAll(RegExp(r'^[\s]*\d+\.\s*', multiLine: true), '')
      // Remove horizontal rules (--- or ***)
      .replaceAll(RegExp(r'^[\s]*[-\*]{3,}[\s]*$', multiLine: true), '')
      // Remove blockquotes (>)
      .replaceAll(RegExp(r'^[\s]*>\s*', multiLine: true), '')
      // Remove dollar signs with numbers ($1, $2, etc) - meal section markers
      .replaceAll(RegExp(r'^\$\d+\s*$', multiLine: true), '')
      .replaceAll(RegExp(r'^\$\d+\s*', multiLine: true), '')
      // Remove any remaining standalone dollar signs
      .replaceAll(RegExp(r'^\$\s*$', multiLine: true), '')
      // Remove table formatting (|)
      .replaceAll(RegExp(r'\|'), '')
      // Remove LaTeX/Math expressions
      .replaceAll(RegExp(r'\$\$.*?\$\$'), '')
      .replaceAll(RegExp(r'\$.*?\$'), '')
      // Clean up multiple spaces and newlines
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .replaceAll(RegExp(r'[ \t]{2,}'), ' ')
      .trim();
}

// Helper to get current greeting based on time of day
String _getCurrentGreeting(BuildContext context) {
  final hour = DateTime.now().hour;
  final localizations = AppLocalizations.of(context)!;
  if (hour >= 5 && hour < 11) return '${localizations.goodMorning} ☀️';
  if (hour >= 11 && hour < 16) return '${localizations.goodAfternoon} 🌤️';
  if (hour >= 16 && hour < 21) return '${localizations.goodEvening} 🌇';
  return '${localizations.goodNight} 🌙';
}

class _LegalLinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String url;

  const _LegalLinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        try {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.couldNotOpenLink)),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.errorOpeningLink)),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(icon, color: kPrimaryGreen, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.open_in_new, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }
}

// Password reset redirect screen that shows success message and redirects to sign-in
class _PasswordResetRedirectScreen extends StatefulWidget {
  @override
  State<_PasswordResetRedirectScreen> createState() => _PasswordResetRedirectScreenState();
}

class _PasswordResetRedirectScreenState extends State<_PasswordResetRedirectScreen> {
  @override
  void initState() {
    super.initState();
    // Redirect after 3 seconds
    Timer(Duration(seconds: 3), () {
      if (mounted) {
        // Navigate back to AuthScreen since user is now logged out
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => AuthScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mail_outline, color: Colors.blue, size: 64),
              SizedBox(height: 24),
              Text(
                'Password Reset Email Sent',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Check your email for a password reset link.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'You have been logged out for security.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Redirecting to sign-in...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(width: 12),
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
