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

// Define the color palette
const Color kPrimaryGreen = Color(0xFF4CAF50); // Soft green
const Color kAccentOrange = Color(0xFFFFA726); // Bright orange
const Color kAccentYellow = Color(0xFFFFEB3B); // Bright yellow
const Color kSecondaryBlue = Color(0xFF2196F3); // Cool blue
const Color kBackgroundWhite = Color(0xFFFFFFFF); // Clean white
const Color kWarningRed = Color(0xFFFF7043); // Orange/Red for warnings
const Color kContainerGrey = Color(0xFFF5F5F5); // Light grey for containers

// Preferences Provider
class PreferencesProvider extends ChangeNotifier {
  bool _darkMode = false;
  bool _useMetric = true;

  bool get darkMode => _darkMode;
  bool get useMetric => _useMetric;

  PreferencesProvider() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool('darkMode') ?? false;
    _useMetric = prefs.getBool('useMetric') ?? true;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = value;
    await prefs.setBool('darkMode', value);
    notifyListeners();
  }

  Future<void> setUnits(bool useMetric) async {
    final prefs = await SharedPreferences.getInstance();
    _useMetric = useMetric;
    await prefs.setBool('useMetric', useMetric);
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => PreferencesProvider(),
      child: const HealthAIApp(),
    ),
  );
}

class HealthAIApp extends StatelessWidget {
  const HealthAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferencesProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HealthAI App',
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
      themeMode: prefs.darkMode ? ThemeMode.dark : ThemeMode.light,
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
    await Firebase.initializeApp();
    User? user;
    await for (final u in FirebaseAuth.instance.authStateChanges()) {
      user = u;
      break;
    }
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
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
                    child: Center(
                      child: Icon(Icons.eco, color: kPrimaryGreen, size: 54),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'HealthAI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
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
    return MaterialApp(
      title: 'HealthAI App',
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
      themeMode: prefs.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: StreamBuilder<User?> (
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink(); // Show nothing, splash will cover this
          }
          if (snapshot.hasData) {
            final user = snapshot.data!;
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
              builder: (context, userSnap) {
                if (userSnap.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink(); // Show nothing, splash will cover this
                }
                if (!userSnap.hasData || !userSnap.data!.exists) {
                  // No profile, show startup page
                  return StartupProfileScreen(user: user);
                }
                final data = userSnap.data!.data() as Map<String, dynamic>?;
                // Check for required fields
                if (data == null ||
                    data['name'] == null || data['name'] == '' ||
                    data['age'] == null || data['height'] == null || data['weight'] == null ||
                    data['dailyCalorieGoal'] == null || data['proteinGoal'] == null || data['carbsGoal'] == null || data['fatGoal'] == null) {
                  return StartupProfileScreen(user: user);
                }
                return MainNavScreen();
              },
            );
          }
          return AuthScreen();
        },
      ),
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

  Future<void> signIn() async {
    setState(() {
      isLoading = true;
      message = '';
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      // Check if user profile exists, if not, create it
      final userService = UserService();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          await userService.createInitialUserProfile(user.email ?? '', '');
        }
      }
      setState(() => message = 'Sign in successful!');
    } catch (e) {
      setState(() => message = 'Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> signUp() async {
    setState(() {
      isLoading = true;
      message = '';
    });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      // Create a full user profile
      final userService = UserService();
      await userService.createInitialUserProfile(
        emailController.text.trim(),
        nameController.text.trim(),
      );
      setState(() => message = 'Sign up successful!');
    } catch (e) {
      setState(() => message = 'Error: $e');
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
                      padding: const EdgeInsets.all(24),
                      child: Icon(Icons.code, size: 48, color: Colors.deepPurple),
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
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(color: Colors.grey[800], fontSize: 14),
                                children: [
                                  const TextSpan(text: 'I accept the '),
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.w500),
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
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
        createdAt: now,
        lastUpdated: now,
        targetWeight: double.parse(weightController.text),
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
        TextField(
          controller: caloriesController,
          decoration: const InputDecoration(labelText: 'Calories'),
          keyboardType: TextInputType.number,
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

  final List<Widget> _screens = [
    DashboardScreen(),
    Center(child: Text('Food')), // Placeholder for Food
    SizedBox.shrink(), // Placeholder for FAB
    CoachScreen(), // Placeholder for Coach
    ProfileScreen(),
  ];

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
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Center(child: Text('Log Page'))));
  }

  void _navigateToScan() {
    setState(() {
      _fabExpanded = false;
      _showFabActions = false;
    });
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Center(child: Text('Scan Page'))));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Scaffold(
          body: _screens[_selectedIndex],
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
                            label: 'Home',
                            selected: _selectedIndex == 0,
                            onTap: () => _onItemTapped(0),
                            selectedColor: kPrimaryGreen,
                          ),
                          _AnimatedNavBarItem(
                            icon: Icons.restaurant_menu,
                            label: 'Food',
                            selected: _selectedIndex == 1,
                            onTap: () => _onItemTapped(1),
                          ),
                          SizedBox(width: 64), // Space for FAB
                          _AnimatedNavBarItem(
                            icon: Icons.chat_bubble_outline,
                            label: 'Coach',
                            selected: _selectedIndex == 3,
                            onTap: () => _onItemTapped(3),
                          ),
                          _AnimatedNavBarItem(
                            icon: Icons.person,
                            label: 'Profile',
                            selected: _selectedIndex == 4,
                            onTap: () => _onItemTapped(4),
                            iconSize: 28,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // FAB always above the footer
        // FAB always above the footer
        Positioned(
          left: 0,
          right: 0,
          bottom: 38, // Raise FAB above the footer
          child: Center(
            child: _AnimatedFab(
              expanded: _fabExpanded,
              onTap: () => _onItemTapped(2),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _FabActionButton(
                              label: 'Log',
                              icon: Icons.edit,
                              onTap: _navigateToLog,
                            ),
                            const SizedBox(width: 32),
                            _FabActionButton(
                              label: 'Scan',
                              icon: Icons.camera_alt,
                              onTap: _navigateToScan,
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
            width: 64,
            height: 64,
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
              child: Icon(icon, color: iconColor, size: 32),
            ),
          ),
        );
      },
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

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
                            Text('Welcome back!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: Colors.black)),
                            const SizedBox(height: 4),
                            Text("Let's track your nutrition today", style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                          ],
                        ),
                      ),
                      AnimatedScale(
                        scale: _headerController.value,
                        duration: const Duration(milliseconds: 600),
                        child: user != null && user.photoURL != null
                          ? CircleAvatar(radius: 24, backgroundImage: NetworkImage(user.photoURL!))
                          : CircleAvatar(radius: 24, backgroundColor: kPrimaryGreen.withOpacity(0.15), child: Icon(Icons.person, color: kPrimaryGreen)),
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
                      final dailyCalorieGoal = userProfile.dailyCalorieGoal ?? 2000;
                      final proteinGoal = userProfile.proteinGoal ?? 120;
                      final carbsGoal = userProfile.carbsGoal ?? 250;
                      final fatGoal = userProfile.fatGoal ?? 50;
                      return StreamBuilder<List<Meal>>(
                        stream: _mealService.getTodayMeals(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox(height: 220, child: Center(child: CircularProgressIndicator()));
                          final meals = snapshot.data!;
                          final totalCalories = meals.fold(0, (sum, m) => sum + m.calories);
                          final totalProtein = meals.fold(0, (sum, m) => sum + m.protein);
                          final totalCarbs = meals.fold(0, (sum, m) => sum + m.carbs);
                          final totalFat = meals.fold(0, (sum, m) => sum + m.fat);
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
                                      Text('Nutrition Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                                      const SizedBox(height: 18),
                                      TweenAnimationBuilder<double>(
                                        tween: Tween<double>(begin: 0, end: totalProtein / proteinGoal),
                                        duration: const Duration(milliseconds: 900),
                                        curve: Curves.easeOutCubic,
                                        builder: (context, value, child) => _MacroProgressRow(
                                          color: kSecondaryBlue,
                                          label: 'Protein',
                                          value: '${(value * proteinGoal).round()} g',
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
                                        tween: Tween<double>(begin: 0, end: totalCarbs / carbsGoal),
                                        duration: const Duration(milliseconds: 1100),
                                        curve: Curves.easeOutCubic,
                                        builder: (context, value, child) => _MacroProgressRow(
                                          color: kAccentOrange,
                                          label: 'Carbs',
                                          value: '${(value * carbsGoal).round()} g',
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
                                        tween: Tween<double>(begin: 0, end: totalFat / fatGoal),
                                        duration: const Duration(milliseconds: 1200),
                                        curve: Curves.easeOutCubic,
                                        builder: (context, value, child) => _MacroProgressRow(
                                          color: kWarningRed,
                                          label: 'Fat',
                                          value: '${(value * fatGoal).round()} g',
                                          percent: value,
                                          valueSuffix: 'g',
                                          valueFontWeight: FontWeight.w600,
                                          valueFontSize: 16,
                                          barHeight: 8,
                                          labelColor: Colors.black,
                                          dotSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),
                                // Circular Calories (move down slightly)
                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0, end: totalCalories / dailyCalorieGoal),
                                  duration: const Duration(milliseconds: 1200),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, child) => Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 24),
                                      Text('Calories', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600, fontSize: 16)),
                                      const SizedBox(height: 8),
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          SizedBox(
                                            width: 90,
                                            height: 90,
                                            child: CircularProgressIndicator(
                                              value: value.clamp(0.0, 1.0),
                                              backgroundColor: kContainerGrey,
                                              color: kPrimaryGreen,
                                              strokeWidth: 8,
                                            ),
                                          ),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              TweenAnimationBuilder<int>(
                                                tween: IntTween(begin: 0, end: totalCalories),
                                                duration: const Duration(milliseconds: 900),
                                                builder: (context, val, child) => Text('$val', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
                                              ),
                                              Text('/ $dailyCalorieGoal', style: TextStyle(color: Colors.grey[600], fontSize: 15)),
                                            ],
                                          ),
                                        ],
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
                      Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _AnimatedScaleOnTap(
                              child: _QuickActionCard(
                                icon: Icons.camera_alt,
                                label: 'Log Meal',
                                subtitle: 'Track your food',
                                color: kPrimaryGreen,
                                onTap: () {
                                  // TODO: Implement navigation
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _AnimatedScaleOnTap(
                              child: _QuickActionCard(
                                icon: Icons.qr_code_scanner,
                                label: 'Scan',
                                subtitle: 'Analyze your food',
                                color: kSecondaryBlue,
                                onTap: () {
                                  // TODO: Implement navigation
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
                      Text("Today's Meals", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      TextButton(
                        onPressed: () {},
                        child: Text('View All', style: TextStyle(color: kPrimaryGreen)),
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
                          child: Center(child: Text('No meals logged for this day.', style: TextStyle(color: Colors.grey[600]))),
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
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: size ?? 80,
          height: size ?? 80,
          child: CircularProgressIndicator(
            value: percent.clamp(0.0, 1.0),
            backgroundColor: kContainerGrey,
            color: kPrimaryGreen,
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
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _QuickActionCard({required this.icon, required this.label, required this.subtitle, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Modern Meal Card
class _MealCardModern extends StatelessWidget {
  final Meal meal;
  const _MealCardModern({required this.meal});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal image placeholder (no imageUrl in model)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: kContainerGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.fastfood, color: kPrimaryGreen, size: 32),
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
                    Text(_formatTime(meal.timestamp), style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(meal.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _MacroTag(label: 'P', value: '${meal.protein}g', color: kSecondaryBlue),
                    const SizedBox(width: 6),
                    _MacroTag(label: 'C', value: '${meal.carbs}g', color: kAccentOrange),
                    const SizedBox(width: 6),
                    _MacroTag(label: 'F', value: '${meal.fat}g', color: kWarningRed),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${meal.calories}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text('cal', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
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

  void _showEditProfileDialog(UserProfile profile) {
    final nameController = TextEditingController(text: profile.name);
    final ageController = TextEditingController(text: profile.age.toString());
    final heightController = TextEditingController(text: profile.height.toString());
    final weightController = TextEditingController(text: profile.weight.toString());

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
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    prefixIcon: Icon(Icons.cake, color: theme.iconTheme.color),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    labelStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
                  ),
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Height (cm)',
                    prefixIcon: Icon(Icons.height, color: theme.iconTheme.color),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    labelStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
                  ),
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Current Weight (kg)',
                    prefixIcon: Icon(Icons.monitor_weight, color: theme.iconTheme.color),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    labelStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
                  ),
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color),
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
                          final updatedProfile = UserProfile(
                            id: profile.id,
                            email: profile.email,
                            name: nameController.text,
                            age: int.parse(ageController.text),
                            height: double.parse(heightController.text),
                            weight: double.parse(weightController.text),
                            dailyCalorieGoal: profile.dailyCalorieGoal,
                            proteinGoal: profile.proteinGoal,
                            carbsGoal: profile.carbsGoal,
                            fatGoal: profile.fatGoal,
                            createdAt: profile.createdAt,
                            lastUpdated: DateTime.now(),
                            targetWeight: profile.targetWeight,
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
              TextField(
                decoration: const InputDecoration(labelText: 'Daily Calorie Goal'),
                keyboardType: TextInputType.number,
                controller: caloriesController,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Protein Goal (g)'),
                keyboardType: TextInputType.number,
                controller: proteinController,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Carbs Goal (g)'),
                keyboardType: TextInputType.number,
                controller: carbsController,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Fat Goal (g)'),
                keyboardType: TextInputType.number,
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
        backgroundColor: kPrimaryGreen,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.notifications_none, color: theme.iconTheme.color),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: theme.cardColor,
              child: Icon(Icons.person, color: theme.iconTheme.color?.withOpacity(0.5)),
            ),
          ),
        ],
      ),
      body: StreamBuilder<UserProfile?>(
        stream: _userService.getCurrentUserProfile(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = userSnapshot.data;
          if (profile == null) {
            return Center(child: Text('No profile data available', style: TextStyle(color: theme.textTheme.bodyLarge?.color)));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // User info card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: theme.cardColor,
                          child: Icon(Icons.person, color: kSecondaryBlue, size: 36),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(profile.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.textTheme.bodyLarge?.color)),
                              Text(profile.email, style: TextStyle(color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7))),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _ProfileStatBox(
                          label: profile.age.toString(),
                          sublabel: 'Age',
                          color: kPrimaryGreen.withOpacity(0.12),
                          valueColor: kPrimaryGreen,
                        ),
                        _ProfileStatBox(
                          label: '${profile.height}cm',
                          sublabel: 'Height',
                          color: kSecondaryBlue.withOpacity(0.12),
                          valueColor: kSecondaryBlue,
                        ),
                        _ProfileStatBox(
                          label: '${profile.weight}kg',
                          sublabel: 'Weight',
                          color: kAccentOrange.withOpacity(0.12),
                          valueColor: kAccentOrange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _showEditProfileDialog(profile),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kSecondaryBlue,
                          side: BorderSide(color: kSecondaryBlue, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Edit Profile'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Weekly Progress
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditGoalsScreen(profile: profile, userService: _userService),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Nutrition & Health Goals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.textTheme.bodyLarge?.color)),
                                Icon(Icons.edit, color: kPrimaryGreen),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _ProfileProgressRow(
                              icon: Icons.bar_chart,
                              label: 'Calories',
                              value: '${profile.dailyCalorieGoal} cal/day',
                              percent: 0.85,
                              color: kPrimaryGreen,
                              barColor: kPrimaryGreen,
                              secondaryBarColor: kSecondaryBlue,
                            ),
                            _ProfileProgressRow(
                              icon: Icons.favorite_border,
                              label: 'Protein',
                              value: '${profile.proteinGoal}g',
                              percent: 0.6,
                              color: kSecondaryBlue,
                              barColor: kSecondaryBlue,
                              secondaryBarColor: kPrimaryGreen,
                            ),
                            _ProfileProgressRow(
                              icon: Icons.show_chart,
                              label: 'Carbs',
                              value: '${profile.carbsGoal}g',
                              percent: 0.79,
                              color: kAccentOrange,
                              barColor: kPrimaryGreen,
                              secondaryBarColor: kSecondaryBlue,
                            ),
                            _ProfileProgressRow(
                              icon: Icons.show_chart,
                              label: 'Fat',
                              value: '${profile.fatGoal}g',
                              percent: 0.65,
                              color: kAccentOrange,
                              barColor: kPrimaryGreen,
                              secondaryBarColor: kSecondaryBlue,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Settings
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.textTheme.bodyLarge?.color)),
                    const SizedBox(height: 12),
                    _ProfileSettingTile(
                      icon: Icons.settings,
                      label: 'Preferences',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PreferencesScreen()),
                        );
                      },
                    ),
                    _ProfileSettingTile(icon: Icons.person, label: 'Account', onTap: () {}),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(child: Text('Version 1.0.0', style: TextStyle(color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7)))),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  style: TextButton.styleFrom(foregroundColor: kWarningRed),
                  child: const Text('Log Out'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileStatBox extends StatelessWidget {
  final String label;
  final String sublabel;
  final Color color;
  final Color valueColor;
  const _ProfileStatBox({required this.label, required this.sublabel, required this.color, required this.valueColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text(sublabel, style: TextStyle(color: valueColor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ProfileProgressRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double percent;
  final Color color;
  final Color barColor;
  final Color secondaryBarColor;
  const _ProfileProgressRow({required this.icon, required this.label, required this.value, required this.percent, required this.color, required this.barColor, required this.secondaryBarColor});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          SizedBox(width: 90, child: Text(label)),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: secondaryBarColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Container(
                  height: 10,
                  width: percent.clamp(0.0, 1.0) * MediaQuery.of(context).size.width * 0.35,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ProfileSettingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ProfileSettingTile({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: kSecondaryBlue),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}

// Add this new screen for editing goals
class EditGoalsScreen extends StatefulWidget {
  final UserProfile profile;
  final UserService userService;
  const EditGoalsScreen({required this.profile, required this.userService, Key? key}) : super(key: key);

  @override
  State<EditGoalsScreen> createState() => _EditGoalsScreenState();
}

class _EditGoalsScreenState extends State<EditGoalsScreen> {
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  late TextEditingController _targetWeightController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _caloriesController = TextEditingController(text: widget.profile.dailyCalorieGoal.toString());
    _proteinController = TextEditingController(text: widget.profile.proteinGoal.toString());
    _carbsController = TextEditingController(text: widget.profile.carbsGoal.toString());
    _fatController = TextEditingController(text: widget.profile.fatGoal.toString());
    _targetWeightController = TextEditingController(text: widget.profile.targetWeight > 0 ? widget.profile.targetWeight.toString() : '');
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  Future<void> _saveGoals() async {
    setState(() => _isSaving = true);
    try {
      final updatedProfile = UserProfile(
        id: widget.profile.id,
        email: widget.profile.email,
        name: widget.profile.name,
        age: widget.profile.age,
        height: widget.profile.height,
        weight: widget.profile.weight,
        dailyCalorieGoal: int.tryParse(_caloriesController.text) ?? widget.profile.dailyCalorieGoal,
        proteinGoal: int.tryParse(_proteinController.text) ?? widget.profile.proteinGoal,
        carbsGoal: int.tryParse(_carbsController.text) ?? widget.profile.carbsGoal,
        fatGoal: int.tryParse(_fatController.text) ?? widget.profile.fatGoal,
        targetWeight: double.tryParse(_targetWeightController.text) ?? widget.profile.targetWeight,
        createdAt: widget.profile.createdAt,
        lastUpdated: DateTime.now(),
      );
      await widget.userService.updateUserProfile(updatedProfile);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goals updated successfully')),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating goals: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Nutrition & Health Goals')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const SizedBox(height: 12),
            Text('Current Weight', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: widget.profile.weight.toString(),
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Current Weight (kg)',
                filled: true,
                fillColor: Color(0xFFF5F5F5),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Text('Target Weight', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _targetWeightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target Weight (kg)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 28),
            Text('Nutrition Goals', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Daily Calorie Goal',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _proteinController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Protein Goal (g)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _carbsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Carbs Goal (g)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _fatController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Fat Goal (g)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 28),
            _isSaving
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _saveGoals,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Save', style: TextStyle(fontSize: 16)),
                  ),
          ],
        ),
      ),
    );
  }
}

// Preferences Screen
class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({Key? key}) : super(key: key);
  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferencesProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Preferences')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ListTile(
            title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: Switch(
              value: prefs.darkMode,
              onChanged: prefs.setDarkMode,
              activeColor: kPrimaryGreen,
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Units', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(prefs.useMetric ? 'Metric (cm, kg)' : 'Imperial (in, lb)'),
            trailing: Switch(
              value: prefs.useMetric,
              onChanged: prefs.setUnits,
              activeColor: kPrimaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget for tap scale animation
class _AnimatedScaleOnTap extends StatefulWidget {
  final Widget child;
  const _AnimatedScaleOnTap({required this.child});
  @override
  State<_AnimatedScaleOnTap> createState() => _AnimatedScaleOnTapState();
}
class _AnimatedScaleOnTapState extends State<_AnimatedScaleOnTap> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100), lowerBound: 0.95, upperBound: 1.0)..value = 1.0;
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  void _onTapDown(TapDownDetails details) => _controller.reverse();
  void _onTapUp(TapUpDetails details) => _controller.forward();
  void _onTapCancel() => _controller.forward();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _controller,
        child: widget.child,
      ),
    );
  }
}

class _FabActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _FabActionButton({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: 1.0,
        duration: Duration(milliseconds: 200),
        child: Container(
          width: 80,
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.grey[800], size: 32),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[800], fontSize: 16)),
            ],
          ),
        ),
      ),
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

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: "Hello! I'm your nutrition coach. How can I help you today?",
      isUser: false,
      quickReplies: [
        'What should I eat today?',
        'Analyze my last meal',
        'Help me plan my week',
      ],
    ),
  ];

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
    _playEntranceAnimationsIfNeeded();
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

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    _insightsController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
    });
    _controller.clear();
    _scrollToBottom();
    Future.delayed(Duration(milliseconds: 400), () => _botReply(text));
  }

  void _botReply(String userText) {
    String reply = '';
    List<String> quickReplies = [];
    if (userText.toLowerCase().contains('plan my week')) {
      reply = "I'm here to help with your nutrition and wellness questions. Would you like me to analyze your recent meals, suggest recipes based on your goals, or provide general nutrition advice?";
      quickReplies = [
        'Analyze my recent meals',
        'Suggest healthy recipes',
        'Give me nutrition tips',
      ];
    } else if (userText.toLowerCase().contains('analyze my last meal')) {
      reply = "Your last meal was well balanced! Would you like more details or suggestions?";
      quickReplies = [
        'More details',
        'Suggest healthy recipes',
      ];
    } else if (userText.toLowerCase().contains('what should i eat')) {
      reply = "Based on your goals, I recommend a balanced meal with protein, veggies, and whole grains.";
      quickReplies = [
        'Suggest a recipe',
        'Help me plan my week',
      ];
    } else {
      reply = "I'm here to help! Please select an option or ask a question.";
      quickReplies = [
        'What should I eat today?',
        'Analyze my last meal',
        'Help me plan my week',
      ];
    }
    setState(() {
      _messages.add(_ChatMessage(text: reply, isUser: false, quickReplies: quickReplies));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: kPrimaryGreen.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(8),
                child: Icon(Icons.chat_bubble_outline, color: kPrimaryGreen, size: 28),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nutrition Coach', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 22)),
                  SizedBox(height: 2),
                  Text('Ask about meals, nutrition, or get personalized advice', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                ],
              ),
            ],
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
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _tabIndex == 0 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: Text('Chat', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: _tabIndex == 0 ? Colors.black : Colors.grey[500])),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _tabIndex = 1);
                      _tabController.forward(from: 0.0);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _tabIndex == 1 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: Text('Insights', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: _tabIndex == 1 ? Colors.black : Colors.grey[500])),
                      ),
                    ),
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
                          return TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: Duration(milliseconds: 400),
                            builder: (context, value, child) => Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, (1 - value) * 20),
                                child: Column(
                                  crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    if (!msg.isUser)
                                      Container(
                                        margin: EdgeInsets.only(bottom: 8, left: 8, right: 48),
                                        padding: EdgeInsets.all(18),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(18),
                                          border: Border.all(color: Color(0xFFE5E7EB)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(msg.text, style: TextStyle(fontSize: 17, color: Colors.black)),
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
                                    if (msg.isUser)
                                      Container(
                                        margin: EdgeInsets.only(bottom: 8, right: 8, left: 48),
                                        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                                        decoration: BoxDecoration(
                                          color: kPrimaryGreen,
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                        child: Text(msg.text, style: TextStyle(fontSize: 17, color: Colors.white)),
                                      ),
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
                                              Text('Nutrition Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                              SizedBox(height: 18),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('Calories', style: TextStyle(fontSize: 16)),
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
                            // Health Insights
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: StreamBuilder<UserProfile?>(
                                stream: UserService().getCurrentUserProfile(),
                                builder: (context, userSnap) {
                                  if (!userSnap.hasData) return _insightCard(child: Center(child: CircularProgressIndicator()));
                                  final userProfile = userSnap.data!;
                                  return StreamBuilder<List<Meal>>(
                                    stream: MealService().getTodayMeals(),
                                    builder: (context, mealSnap) {
                                      if (!mealSnap.hasData) return _insightCard(child: Center(child: CircularProgressIndicator()));
                                      final meals = mealSnap.data!;
                                      final proteinGoal = userProfile.proteinGoal;
                                      final proteinToday = meals.fold(0, (sum, m) => sum + m.protein);
                                      final proteinLow = proteinToday < (proteinGoal * 0.7);
                                      final balancedMeals = meals.where((m) => m.protein > 10 && m.carbs > 10 && m.fat > 5).length;
                                      final energyInsight = proteinToday > 30 ? 'Your energy levels are highest after morning protein intake' : null;
                                      final insights = <String>[
                                        if (proteinLow) 'Your protein intake has been lower than recommended today',
                                        if (balancedMeals > 0) 'You tend to eat more balanced meals on weekdays',
                                        if (energyInsight != null) energyInsight,
                                      ];
                                      return TweenAnimationBuilder<double>(
                                        tween: Tween<double>(begin: 0, end: 1),
                                        duration: Duration(milliseconds: 600),
                                        builder: (context, value, child) => _insightCard(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Health Insights', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                              SizedBox(height: 14),
                                              ...insights.map((insight) => TweenAnimationBuilder<double>(
                                                tween: Tween<double>(begin: 0, end: 1),
                                                duration: Duration(milliseconds: 400),
                                                builder: (context, value, child) => Opacity(
                                                  opacity: value,
                                                  child: Transform.translate(
                                                    offset: Offset(0, (1 - value) * 20),
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(bottom: 8),
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Container(width: 8, height: 8, margin: EdgeInsets.only(top: 7), decoration: BoxDecoration(color: kPrimaryGreen, shape: BoxShape.circle)),
                                                          SizedBox(width: 10),
                                                          Expanded(child: Text(insight, style: TextStyle(fontSize: 16, color: Colors.grey[800]))),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )),
                                              SizedBox(height: 10),
                                              OutlinedButton(
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      title: Text('Detailed Analytics'),
                                                      content: Text('Analytics coming soon!'),
                                                      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Close'))],
                                                    ),
                                                  );
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: kPrimaryGreen,
                                                  side: BorderSide(color: kPrimaryGreen),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                                  padding: EdgeInsets.symmetric(vertical: 14),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text('View Detailed Analytics', style: TextStyle(fontWeight: FontWeight.w600)),
                                                    SizedBox(width: 8),
                                                    Icon(Icons.chevron_right, size: 20),
                                                  ],
                                                ),
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
                                        child: Text('Common Questions', style: TextStyle(fontWeight: FontWeight.w600, color: kPrimaryGreen, fontSize: 18)),
                                      ),
                                      ...['Dinner ideas', 'Calorie check', 'Protein snacks', 'Diet tips'].map((q) => TweenAnimationBuilder<double>(
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
                                              onTap: () {
                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('AI response coming soon!')));
                                              },
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
                          hintText: 'Type your message...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
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
                ],
              ),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Color(0xFFE5E7EB)),
        ),
        child: Text(text, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black)),
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
