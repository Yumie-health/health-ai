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
import 'services/pexels_service.dart';
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
import 'utils/onboarding_helper.dart';
import 'services/logging_service.dart';
import 'utils/validation.dart';
import 'services/error_handler.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'config/payment_config.dart';
import 'services/subscription_service.dart';
import 'subscription_page.dart';

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

  const AndroidNotificationChannel testChannel = AndroidNotificationChannel(
    'test_channel',
    'Test Notifications',
    description: 'Test notifications for debugging',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  const AndroidNotificationChannel backgroundChannel = AndroidNotificationChannel(
    'background_channel',
    'Background Notifications',
    description: 'Notifications that work when app is closed',
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
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(testChannel);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(backgroundChannel);

  // Request notification permissions
  // For Android, permissions are handled automatically by the plugin
  // For iOS, permissions are requested during initialization via DarwinInitializationSettings
  
  // Initialize Firebase - Android will use google-services.json, iOS will use the options
  await Firebase.initializeApp();
  
  // Verify Firebase configuration
  print('Firebase initialized with project: ${Firebase.app().options.projectId}');
  print('Firebase auth domain: ${Firebase.app().options.authDomain}');
  print('Firebase iOS bundle ID: ${Firebase.app().options.iosBundleId}');
  
  log.initialize(); // THEN: Initialize logging service
  
  // Force Firebase to use the correct project
  print('Firebase project ID: ${Firebase.app().options.projectId}');
  print('Firebase app name: ${Firebase.app().name}');
  print('Firebase options: ${Firebase.app().options}');
  try {
    print('Firebase initialized');

    print('Initializing SubscriptionService...');
    await SubscriptionService().initializeBilling();
    print('SubscriptionService initialized');

    MobileAds.instance.initialize(); // Initialize AdMob

    runApp(
      ChangeNotifierProvider(
        create: (_) => PreferencesProvider(),
        child: const HealthAIApp(),
      ),
    );
  } catch (e, stack) {
    print('Startup error: $e');
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HealthAI App',
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
      locale: _getLocale(prefs.language),
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        // If user has selected a language, use it
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
  }
}

class SplashOrApp extends StatefulWidget {
  const SplashOrApp({super.key});
  @override
  State<SplashOrApp> createState() => _SplashOrAppState();
}

class _SplashOrAppState extends State<SplashOrApp> with SingleTickerProviderStateMixin {
  bool _ready = false;
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
          print('Firestore user doc fetch failed: $e');
        }
      }
    } catch (e, stack) {
      print('Auth state or Firestore error: $e');
    }
    await minSplash;
    if (mounted) {
      setState(() => _ready = true);
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

              return MainNavScreen();
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
  bool showSignUp = false;
  final TextEditingController nameController = TextEditingController();
  bool acceptTerms = false;
  bool isSamsung = false;
  bool isIOS = Platform.isIOS;
  bool isAndroid = Platform.isAndroid;
  // final FirebaseAnalytics analytics = FirebaseAnalytics.instance;  // Removed due to Kotlin conflicts

  @override
  void initState() {
    super.initState();
    _checkSamsung();
  }

  Future<void> _checkSamsung() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      setState(() {
        isSamsung = androidInfo.manufacturer?.toLowerCase().contains('samsung') ?? false;
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => isLoading = false);
        return; // User cancelled
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      // await analytics.logLogin(loginMethod: 'google');  // Removed due to Kotlin conflicts
      final userService = UserService();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
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
      setState(() => isLoading = false);
      // await analytics.logEvent(name: 'login_failed', parameters: {'method': 'google', 'error': e.toString()});  // Removed due to Kotlin conflicts
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: $e')),
      );
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

  Future<void> _handleSamsungSignIn() async {
    setState(() => isLoading = true);
    try {
      log.info('User attempting Samsung sign-in');
      
      // For Samsung Sign In, we'll use a custom implementation
      // This would typically involve Samsung's SDK, but for now we'll show a message
      // In a real implementation, you would integrate Samsung's authentication SDK
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Samsung Sign In requires Samsung SDK integration. Please use Google Sign In for now.'),
          duration: Duration(seconds: 3),
        ),
      );
      
      // For now, we'll redirect to Google Sign In as a fallback
      await _handleGoogleSignIn();
      
    } catch (e) {
      setState(() => isLoading = false);
      // await analytics.logEvent(name: 'login_failed', parameters: {'method': 'samsung', 'error': e.toString()});  // Removed due to Kotlin conflicts
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Samsung sign-in failed: $e')),
      );
    }
  }

  Future<void> signIn() async {
    setState(() {
      isLoading = true;
      message = '';
    });

    // Input validation
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (!ValidationUtils.isValidEmail(email)) {
      setState(() {
        isLoading = false;
        message = 'Please enter a valid email address';
      });
      ValidationUtils.showValidationError(context, 'Please enter a valid email address');
      return;
    }

    if (password.isEmpty) {
      setState(() {
        isLoading = false;
        message = 'Password is required';
      });
      ValidationUtils.showValidationError(context, 'Password is required');
      return;
    }

    try {
      log.info('User attempting sign in', {'email': email});
      
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
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
      setState(() => message = 'Sign in successful!');
    } catch (e) {
      final errorMessage = errorHandler.handleAuthError(e);
      setState(() => message = errorMessage);
      log.error('Sign in failed', e);
      // await analytics.logEvent(name: 'login_failed', parameters: {'method': 'email', 'error': e.toString()});  // Removed due to Kotlin conflicts
    } finally {
      setState(() => isLoading = false);
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

    if (!ValidationUtils.isValidEmail(email)) {
      setState(() {
        isLoading = false;
        message = 'Please enter a valid email address';
      });
      ValidationUtils.showValidationError(context, 'Please enter a valid email address');
      return;
    }

    final passwordError = ValidationUtils.validatePassword(password);
    if (passwordError != null) {
      setState(() {
        isLoading = false;
        message = passwordError;
      });
      ValidationUtils.showValidationError(context, passwordError);
      return;
    }

    final nameError = ValidationUtils.validateName(name);
    if (nameError != null) {
      setState(() {
        isLoading = false;
        message = nameError;
      });
      ValidationUtils.showValidationError(context, nameError);
      return;
    }

    try {
      log.info('User attempting sign up', {'email': email, 'name': name});
      
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // await analytics.logSignUp(signUpMethod: 'email');  // Removed due to Kotlin conflicts
      log.logUserAction('sign_up_successful', {'method': 'email'});
      
      // Create a full user profile
      final userService = UserService();
      await userService.createInitialUserProfile(email, name);
      
      setState(() => message = 'Sign up successful!');
      ValidationUtils.showSuccessMessage(context, 'Account created successfully!');
      
      // Show onboarding after sign up
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OnboardingFlowPage()));
      }
    } catch (e) {
      final errorMessage = errorHandler.handleAuthError(e);
      setState(() => message = errorMessage);
      log.error('Sign up failed', e);
      // await analytics.logEvent(name: 'signup_failed', parameters: {'method': 'email', 'error': e.toString()});  // Removed due to Kotlin conflicts
    } finally {
      setState(() => isLoading = false);
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
            padding: const EdgeInsets.all(24.0),
            child: Container(
              width: 400,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
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
                      showSignUp ? 'Create Account' : 'Sign In',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      showSignUp
                          ? 'Sign up to get started with HealthAI'
                          : 'Sign in to access your account',
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
                          const Text('Full Name', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              hintText: 'John Doe',
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
                      child: const Text('Email', style: TextStyle(fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'your.email@example.com',
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
                      child: const Text('Password', style: TextStyle(fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        prefixIcon: Icon(Icons.vpn_key_outlined, color: Colors.grey[400]),
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
                      obscureText: true,
                    ),
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
                                  'I accept the ',
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
                                        SnackBar(content: Text('Could not open Terms of Service')),
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
                                  ' and ',
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
                                        SnackBar(content: Text('Could not open Privacy Policy')),
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
                            : Text(showSignUp ? 'Create Account' : 'Sign In'),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (!showSignUp)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? ", style: TextStyle(color: Colors.black54)),
                          GestureDetector(
                            onTap: () => setState(() => showSignUp = true),
                            child: Text('Sign up', style: TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                    if (showSignUp)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account? ', style: TextStyle(color: Colors.black54)),
                          GestureDetector(
                            onTap: () => setState(() => showSignUp = false),
                            child: Text('Sign in', style: TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.w500)),
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
                    ] else if (isSamsung) ...[
                      _GoogleSignInButton(
                        onTap: _handleGoogleSignIn, 
                        isSignUp: showSignUp,
                        isDisabled: showSignUp && !acceptTerms,
                      ),
                      SizedBox(height: 12),
                      _SamsungSignInButton(onTap: _handleSamsungSignIn),
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
                              'By continuing, you agree to our ',
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
                                    SnackBar(content: Text('Could not open Terms of Service')),
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
                                    SnackBar(content: Text('Could not open Privacy Policy')),
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
        isSignUp ? 'Sign up with Google' : 'Sign in with Google', 
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
      label: Text('Sign in with Apple', style: TextStyle(fontWeight: FontWeight.w600)),
      onPressed: onTap,
    );
  }
}
class _SamsungSignInButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SamsungSignInButton({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF1428A0),
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(Icons.account_circle, size: 26),
      label: Text('Sign in with Samsung', style: TextStyle(fontWeight: FontWeight.w600)),
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
      appBar: AppBar(title: const Text('Complete Your Profile')),
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
                decoration: const InputDecoration(labelText: 'Name'),
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
                decoration: const InputDecoration(labelText: 'Daily Calorie Goal'),
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
          decoration: const InputDecoration(labelText: 'Food Name'),
        ),
        const SizedBox(height: 8),
        _NumericTextField(
          controller: caloriesController,
          decoration: const InputDecoration(labelText: 'Calories'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: addFoodLog,
          child: const Text('Add Log'),
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
        title: const Text('HealthAI - Food Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
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
                                  label: 'Weight',
                                  icon: Icons.monitor_weight,
                                  onTap: _navigateToWeightLog,
                                  isLarge: false,
                                ),
                                const SizedBox(width: 40),
                                _FabActionButton(
                                  label: 'Water',
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
                            Text(_currentGreeting, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: Colors.black)),
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
                                label: AppLocalizations.of(context)!.logMeal,
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
              // Meal image - prioritize user's photo over Pexels
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: meal.imageUrl != null
                    ? Image.network(
                        meal.imageUrl!,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to Pexels if user's image fails to load
                          return FutureBuilder<String?>(
                            future: PexelsService.staticFetchMealImage(meal.name, locale: Locale(AppLocalizations.of(context)!.localeName)),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors.grey[200],
                                  child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: kPrimaryGreen)),
                                );
                              }
                              final imageUrl = snapshot.data;
                              return imageUrl != null
                                  ? Image.network(
                                      imageUrl,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 70,
                                      height: 70,
                                      color: Colors.grey[200],
                                      child: Icon(Icons.fastfood, color: Colors.grey[400]),
                                    );
                            },
                          );
                        },
                      )
                    : FutureBuilder<String?>(
                        future: PexelsService.staticFetchMealImage(meal.name, locale: Locale(AppLocalizations.of(context)!.localeName)),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Container(
                              width: 70,
                              height: 70,
                              color: Colors.grey[200],
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: kPrimaryGreen)),
                            );
                          }
                          final imageUrl = snapshot.data;
                          return imageUrl != null
                              ? Image.network(
                                  imageUrl,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors.grey[200],
                                  child: Icon(Icons.fastfood, color: Colors.grey[400]),
                                );
                        },
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(meal.mealType.capitalize(), style: TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.w600)),
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
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Delete Meal'),
                              content: Text('Are you sure you want to delete this meal?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  child: Text('Delete'),
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
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
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
                          ...ingredients.map((ing) => Text('• $ing', style: TextStyle(color: Colors.black87))).toList(),
                        ],
                      );
                    } else {
                      return Text('No ingredients listed.', style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic));
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
          title: const Text('Change Profile Name'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter new name', errorText: error),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
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
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _isPremiumUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isPremium') ?? false;
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
                    labelText: 'Name',
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
                      child: const Text('Cancel'),
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
                              const SnackBar(content: Text('Profile updated successfully')),
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
        title: const Text('Edit Goals'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _NumericTextField(
                decoration: const InputDecoration(labelText: 'Daily Calorie Goal'),
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
            child: const Text('Cancel'),
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
                    const SnackBar(content: Text('Goals updated successfully')),
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
            child: const Text('Save'),
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
                                      future: _isPremiumUser(),
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
                                            isPremium ? 'Premium' : 'Freemium', 
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
                                            Text('Starting Weight', style: TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.w600, fontSize: 15), textAlign: TextAlign.center),
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
                                            Text('Target Weight', style: TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.w600, fontSize: 15), textAlign: TextAlign.center),
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
                          _ProfileMenuTile(
                            icon: Icons.star_rate,
                            label: AppLocalizations.of(context)!.rateUsOnGoogle,
                            iconColor: kAccentOrange,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(AppLocalizations.of(context)!.comingSoon),
                                  content: Text(AppLocalizations.of(context)!.ratingOnGoogleAvailableAfterRelease),
                                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.ok))],
                                ),
                              );
                            },
                          ),
                          Divider(height: 1, color: Colors.grey[200]),
                          _ProfileMenuTile(
                            icon: Icons.share,
                            label: AppLocalizations.of(context)!.shareWithFriends,
                            iconColor: kSecondaryBlue,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(AppLocalizations.of(context)!.comingSoon),
                                  content: Text(AppLocalizations.of(context)!.sharingAvailableAfterRelease),
                                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.ok))],
                                ),
                              );
                            },
                          ),
                          Divider(height: 1, color: Colors.grey[200]),
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
                                            Text('Reset Password', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                            SizedBox(height: 8),
                                            Text('A password reset link will be sent to your email:',
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
                                                        try {
                                                          await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                                                          setState(() {
                                                            message = 'Success! Check your email for a reset link.';
                                                            isLoading = false;
                                                          });
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
                                    SnackBar(content: Text('Could not open website')),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error opening website')),
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
                                        Text(
                                          AppLocalizations.of(context)!.legal,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
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
                                                await FirebaseAuth.instance.signOut();
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

  // Check if user is premium
  Future<bool> _isPremiumUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isPremium') ?? false;
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
    try {
      final meals = await MealService().getTodayMeals().first;
      final currentCalories = meals.fold(0, (sum, m) => sum + m.calories);
      final currentMealPeriod = _getCurrentMealPeriod();
      
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

  // Helper to get current meal period
  String _getCurrentMealPeriod() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return 'breakfast';
    if (hour >= 11 && hour < 16) return 'lunch';
    if (hour >= 16 && hour < 21) return 'dinner';
    return 'snack';
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
    setState(() { _loadingInsight = true; });
    final userProfile = await UserService().getCurrentUserProfile().first;
    if (userProfile == null) {
      setState(() { _aiHealthInsight = "Could not load profile."; _loadingInsight = false; });
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    String bloodType = '-';
    bool isDiabetic = false;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data() ?? {};
      bloodType = data['bloodType'] ?? '-';
      isDiabetic = data['isDiabetic'] ?? false;
    }
    final meals = await MealService().getTodayMeals().first;
    int caloriesConsumed = meals.fold(0, (sum, m) => sum + m.calories);
    int proteinG = meals.fold(0, (sum, m) => sum + m.protein);
    int carbsG = meals.fold(0, (sum, m) => sum + m.carbs);
    int fatG = meals.fold(0, (sum, m) => sum + m.fat);
    double waterIntakeL = (userProfile.waterLoggedMl ?? 0) / 1000.0;
    final chatHistory = [
      {'role': 'user', 'content': "Give me a brief health insight or recommendation based on my nutrition summary today."},
    ];
    final prefs = Provider.of<PreferencesProvider>(context, listen: false);
    final aiResponse = await AIService().sendCoachMessage(
      chatHistory: chatHistory,
      name: userProfile.name,
      age: userProfile.age,
      heightCm: userProfile.height.round(),
      weightKg: userProfile.weight,
      calorieGoal: userProfile.dailyCalorieGoal,
      caloriesConsumed: caloriesConsumed,
      proteinG: proteinG,
      carbsG: carbsG,
      fatG: fatG,
      waterIntakeL: waterIntakeL,
      bloodType: bloodType,
      isDiabetic: isDiabetic,
      specialInstruction: 'For this health insight, respond as a concise list of 3-5 bullet points. Each point should be a short, actionable tip or observation. Do not use paragraphs.',
      language: prefs.language,
    );
    setState(() { _aiHealthInsight = aiResponse ?? "Could not get AI insight."; _loadingInsight = false; });
    // Save to SharedPreferences
    final prefs2 = await SharedPreferences.getInstance();
    if (_aiHealthInsight != null) {
      prefs2.setString('last_health_insight', _aiHealthInsight!);
      prefs2.setInt('last_insight_calories', caloriesConsumed);
      prefs2.setString('last_insight_meal_period', _getCurrentMealPeriod());
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
    
    final isPremium = await _isPremiumUser();
    
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

    // 2. Get bloodType and isDiabetic from Firestore (set by Health Awareness page)
    final user = FirebaseAuth.instance.currentUser;
    String bloodType = '-';
    bool isDiabetic = false;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data() ?? {};
      bloodType = data['bloodType'] ?? '-';
      isDiabetic = data['isDiabetic'] ?? false;
    }

    // 3. Fetch today's meals
    final meals = await MealService().getTodayMeals().first;
    String mealsSummary = meals.isEmpty
        ? "No meals logged today."
        : meals.map((m) =>
            "${m.mealType.capitalize()}: ${m.name} (${m.calories} kcal, P:${m.protein}g C:${m.carbs}g F:${m.fat}g)").join("; ");

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
      calorieGoal: userProfile.dailyCalorieGoal,
      caloriesConsumed: caloriesConsumed,
      proteinG: proteinG,
      carbsG: carbsG,
      fatG: fatG,
      waterIntakeL: waterIntakeL,
      bloodType: bloodType,
      isDiabetic: isDiabetic,
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
                              child: _insightCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(AppLocalizations.of(context)!.healthInsights, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                    SizedBox(height: 14),
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
                                          // Remove intro/outro and split into up to 3 bullet points
                                          final lines = _aiHealthInsight!
                                            .replaceAll(RegExp(r'^(hey|hi|hello)[^\n]*\n*', caseSensitive: false), '')
                                            .replaceAll(RegExp(r"you're doing great.*", caseSensitive: false), '')
                                            .split(RegExp(r'\n+|- '))
                                            .map((l) => l.trim())
                                            .where((l) => l.isNotEmpty)
                                            .take(3)
                                            .toList();
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              for (final line in lines)
                                                Padding(
                                                  padding: const EdgeInsets.only(bottom: 8),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Container(width: 8, height: 8, margin: EdgeInsets.only(top: 7), decoration: BoxDecoration(color: kPrimaryGreen, shape: BoxShape.circle)),
                                                      SizedBox(width: 10),
                                                      Expanded(child: Text(line, style: TextStyle(fontSize: 16, color: kPrimaryGreen, fontWeight: FontWeight.w600))),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      )
                                          : Text(AppLocalizations.of(context)!.noInsightAvailable, style: TextStyle(fontSize: 16, color: Colors.grey[800])),

                                  ],
                                ),
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
                  future: _isPremiumUser(),
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
                              'Messages: ${_maxFreeMessages - _messageCount}/$_maxFreeMessages',
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

  String get _currentMealLabel {
    final period = _currentMealPeriod;
    switch (period) {
      case 'breakfast':
        return 'Morning Sunshine ☀️';
      case 'lunch':
        return 'Lunch Time! 🌤️';
      case 'dinner':
        return 'Dinner Tastic! 🌇';
      default:
        return 'Healthy Snacks! 🌙';
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
  final List<String> _foodMealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

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
                    Text('Track your nutrition', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
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
                              final filteredMeals = meals.where((m) => m.mealType.toLowerCase() == _foodMealTypes[_selectedFoodMealTypeIndex].toLowerCase()).toList();
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
                                    child: Text(_currentMealLabel, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
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
                                                // Meal image - AI suggested meals use Pexels since they don't have user photos
                                                FutureBuilder<String?> (
                                                  future: PexelsService.staticFetchMealImage(meal['meal_name'] as String? ?? '', locale: Locale(AppLocalizations.of(context)!.localeName)),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                                      return ClipRRect(
                                                        borderRadius: BorderRadius.circular(16),
                                                        child: Container(
                                                          width: 70,
                                                          height: 70,
                                                          color: Colors.grey[200],
                                                          child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: kPrimaryGreen)),
                                                        ),
                                                      );
                                                    }
                                                    final imageUrl = snapshot.data;
                                                    return ClipRRect(
                                                      borderRadius: BorderRadius.circular(16),
                                                      child: imageUrl != null
                                                          ? Image.network(
                                                              imageUrl,
                                                              width: 70,
                                                              height: 70,
                                                              fit: BoxFit.cover,
                                                            )
                                                          : Container(
                                                              width: 70,
                                                              height: 70,
                                                              color: Colors.grey[200],
                                                              child: Icon(Icons.fastfood, color: Colors.grey[400]),
                                                            ),
                                                    );
                                                  },
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
              // Meal image - prioritize user's photo over Pexels
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: meal.imageUrl != null
                    ? Image.network(
                        meal.imageUrl!,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to Pexels if user's image fails to load
                          return FutureBuilder<String?>(
                            future: PexelsService.staticFetchMealImage(meal.name, locale: Locale(AppLocalizations.of(context)!.localeName)),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors.grey[200],
                                  child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: kPrimaryGreen)),
                                );
                              }
                              final imageUrl = snapshot.data;
                              return imageUrl != null
                                  ? Image.network(
                                      imageUrl,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 70,
                                      height: 70,
                                      color: Colors.grey[200],
                                      child: Icon(Icons.fastfood, color: Colors.grey[400]),
                                    );
                            },
                          );
                        },
                      )
                    : FutureBuilder<String?>(
                        future: PexelsService.staticFetchMealImage(meal.name, locale: Locale(AppLocalizations.of(context)!.localeName)),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Container(
                              width: 70,
                              height: 70,
                              color: Colors.grey[200],
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: kPrimaryGreen)),
                            );
                          }
                          final imageUrl = snapshot.data;
                          return imageUrl != null
                              ? Image.network(
                                  imageUrl,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors.grey[200],
                                  child: Icon(Icons.fastfood, color: Colors.grey[400]),
                                );
                        },
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(meal.mealType.capitalize(), style: TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.w600)),
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
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Delete Meal'),
                              content: Text('Are you sure you want to delete this meal?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  child: Text('Delete'),
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
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
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
                          ...ingredients.map((ing) => Text('• $ing', style: TextStyle(color: Colors.black87))).toList(),
                        ],
                      );
                    } else {
                      return Text('No ingredients listed.', style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic));
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
      appBar: AppBar(title: Text('Settings')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Preferences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
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
              onChanged: (v) => prefs.setUnits(v),
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
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ar', child: Text('Arabic')),
                  DropdownMenuItem(value: 'es', child: Text('Spanish')),
                ],
                onChanged: (v) => prefs.setLanguage(v!),
              ),
            ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              Text('Habit Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
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
              SizedBox(height: 32),
              Text('🧪 Test Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              SizedBox(height: 18),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 2,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.notifications_active, color: Colors.orange),
                      title: Text('Test All Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('Schedule test notifications for 30s, 1min, and 2min from now'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          prefs.testNotifications();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('🧪 Test notifications scheduled! Check your device in 30 seconds, 1 minute, and 2 minutes.')),
                          );
                        },
                        child: Text('Test'),
                      ),
                    ),
                    Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: Icon(Icons.cancel, color: Colors.red),
                      title: Text('Cancel Test Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('Cancel all test notifications'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          prefs.cancelTestNotifications();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('✅ Test notifications cancelled!')),
                          );
                        },
                        child: Text('Cancel'),
                      ),
                    ),
                    Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: Icon(Icons.notifications_active, color: Colors.blue),
                      title: Text('Test Background Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('Schedule notification for 10 seconds, then close app'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          prefs.testBackgroundNotifications();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('🔔 Background test scheduled! Close the app and wait 10 seconds.')),
                          );
                        },
                        child: Text('Test Background'),
                      ),
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
      title: Text('Log Weight Change'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: Text('Lost'),
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
                label: Text('Gained'),
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
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_isAdd ? _value : -_value),
          child: Text(_isAdd ? 'Gained' : 'Lost'),
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
      title: Text('Log Water Intake'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: Text('Add'),
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
                  label: Text('Remove'),
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
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_isAdd ? (_value * 1000).round() : -(_value * 1000).round()),
          child: Text(_isAdd ? 'Add' : 'Remove'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isAdd ? Colors.green : Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

// Helper to remove Markdown formatting from AI responses
String removeMarkdown(String text) {
  return text
      .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'')
      .replaceAll(RegExp(r'__(.*?)__'), r'')
      .replaceAll(RegExp(r'\*(.*?)\*'), r'')
      .replaceAll(RegExp(r'_(.*?)_'), r'');
}

// Add this helper function to main.dart
Locale _getLocale(String code) {
  if (code == 'ar') return const Locale('ar');
  if (code == 'es') return const Locale('es');
  return const Locale('en');
}

// Helper to get current greeting based on time of day
String get _currentGreeting {
  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 11) return 'Good morning ☀️';
  if (hour >= 11 && hour < 16) return 'Good afternoon 🌤️';
  if (hour >= 16 && hour < 21) return 'Good evening 🌇';
  return 'Good night 🌙';
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
              SnackBar(content: Text('Could not open link')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error opening link')),
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