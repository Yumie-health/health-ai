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

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    DashboardScreen(),
    ScanScreen(),
    LogScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: kPrimaryGreen,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Log',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final MealService _mealService = MealService();
  final UserService _userService = UserService();

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
            Padding(
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
                  if (user != null && user.photoURL != null)
                    CircleAvatar(radius: 24, backgroundImage: NetworkImage(user.photoURL!)),
                  if (user == null || user.photoURL == null)
                    CircleAvatar(radius: 24, backgroundColor: kPrimaryGreen.withOpacity(0.15), child: Icon(Icons.person, color: kPrimaryGreen)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            // Nutrition Summary Card
            Padding(
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
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Macro Progress
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Nutrition Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                  const SizedBox(height: 16),
                                  _MacroProgressRow(
                                    color: kSecondaryBlue,
                                    label: 'Protein',
                                    value: '$totalProtein g',
                                    percent: totalProtein / proteinGoal,
                                  ),
                                  _MacroProgressRow(
                                    color: kAccentOrange,
                                    label: 'Carbs',
                                    value: '$totalCarbs g',
                                    percent: totalCarbs / carbsGoal,
                                  ),
                                  _MacroProgressRow(
                                    color: kWarningRed,
                                    label: 'Fat',
                                    value: '$totalFat g',
                                    percent: totalFat / fatGoal,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Circular Calories
                            Column(
                              children: [
                                Text('Calories', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
                                const SizedBox(height: 8),
                                _CircularCalories(
                                  calories: totalCalories,
                                  goal: dailyCalorieGoal,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.9,
                    children: [
                      _QuickActionCard(
                        icon: Icons.camera_alt,
                        label: 'Snap Meal',
                        subtitle: 'Analyze your food',
                        color: kPrimaryGreen,
                        onTap: () {
                          // TODO: Implement navigation
                        },
                      ),
                      _QuickActionCard(
                        icon: Icons.qr_code_scanner,
                        label: 'Scan Fridge',
                        subtitle: 'Check inventory',
                        color: kSecondaryBlue,
                        onTap: () {
                          // TODO: Implement navigation
                        },
                      ),
                      _QuickActionCard(
                        icon: Icons.chat_bubble_outline,
                        label: 'AI Coach',
                        subtitle: 'Get advice',
                        color: kAccentOrange,
                        onTap: () {
                          // TODO: Implement navigation
                        },
                      ),
                      _QuickActionCard(
                        icon: Icons.calendar_month,
                        label: 'Meal Plan',
                        subtitle: 'Plan your week',
                        color: kWarningRed,
                        onTap: () {
                          // TODO: Implement navigation
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Today's Meals
            Padding(
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
            Padding(
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
                    children: meals.take(2).map((meal) => _MealCardModern(meal: meal)).toList(),
                  );
                },
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
  const _MacroProgressRow({required this.color, required this.label, required this.value, required this.percent});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          SizedBox(width: 60, child: Text(label, style: TextStyle(fontWeight: FontWeight.w500))),
          Expanded(
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              backgroundColor: kContainerGrey,
              color: color,
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 12),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// Circular calories indicator
class _CircularCalories extends StatelessWidget {
  final int calories;
  final int goal;
  const _CircularCalories({required this.calories, required this.goal});
  @override
  Widget build(BuildContext context) {
    final percent = calories / goal;
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            value: percent.clamp(0.0, 1.0),
            backgroundColor: kContainerGrey,
            color: kPrimaryGreen,
            strokeWidth: 7,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$calories', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text('/ $goal', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
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

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isScanning = false;

  Future<void> _startScanning() async {
    setState(() => _isScanning = true);
    // TODO: Implement camera scanning
    await Future.delayed(const Duration(seconds: 2)); // Simulate scanning
    setState(() => _isScanning = false);
  }

  Future<void> _uploadImage() async {
    // TODO: Implement image upload
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Food', style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Scan Your Food', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.textTheme.bodyLarge?.color)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 260,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.dividerColor, style: BorderStyle.solid, width: 2),
            ),
            child: _isScanning
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: kPrimaryGreen),
                        const SizedBox(height: 16),
                        Text('Scanning...', style: TextStyle(color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7))),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: theme.cardColor,
                          radius: 36,
                          child: Icon(Icons.camera_alt, color: theme.iconTheme.color?.withOpacity(0.5), size: 36),
                        ),
                        const SizedBox(height: 12),
                        Text('Point camera at food to analyze', style: TextStyle(color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7))),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isScanning ? null : _startScanning,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Scan Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSecondaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isScanning ? null : _uploadImage,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Photo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kSecondaryBlue,
                    side: BorderSide(color: kSecondaryBlue, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: kSecondaryBlue),
                    const SizedBox(width: 8),
                    Text('Scanning Tips', style: TextStyle(fontWeight: FontWeight.bold, color: kSecondaryBlue)),
                  ],
                ),
                const SizedBox(height: 12),
                _ScanTip(number: 1, text: 'Place food on a plain background for better results'),
                _ScanTip(number: 2, text: 'Make sure there\'s good lighting'),
                _ScanTip(number: 3, text: 'Position camera 8-12 inches from food'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanTip extends StatelessWidget {
  final int number;
  final String text;
  const _ScanTip({required this.number, required this.text});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: kSecondaryBlue.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('$number', style: const TextStyle(color: kSecondaryBlue, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: theme.textTheme.bodyLarge?.color))),
        ],
      ),
    );
  }
}

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  final MealService _mealService = MealService();
  final TextEditingController _searchController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  // Add filter state
  final Set<String> _selectedMealTypes = {'breakfast', 'lunch', 'dinner', 'snack'};

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Meals'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterCheckbox('Breakfast', 'breakfast'),
              _buildFilterCheckbox('Lunch', 'lunch'),
              _buildFilterCheckbox('Dinner', 'dinner'),
              _buildFilterCheckbox('Snack', 'snack'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterCheckbox(String label, String value) {
    return CheckboxListTile(
      title: Text(label),
      value: _selectedMealTypes.contains(value),
      onChanged: (checked) {
        setState(() {
          if (checked == true) {
            _selectedMealTypes.add(value);
          } else {
            _selectedMealTypes.remove(value);
          }
        });
      },
    );
  }

  void _showAddMealDialog() {
    showDialog(
      context: context,
      builder: (context) => AddMealDialog(
        onMealAdded: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Log', style: TextStyle(color: Colors.black)),
        backgroundColor: kPrimaryGreen,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.notifications_none, color: Colors.black),
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
              backgroundColor: kContainerGrey,
              child: Icon(Icons.person, color: Colors.grey[400]),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Calendar always visible at the top
          TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime.now(),
            focusedDay: _selectedDate,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
              });
            },
            calendarFormat: CalendarFormat.week,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: 16),
          // Search bar and filter
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search foods...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: kContainerGrey,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: kContainerGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.filter_list, color: Colors.grey),
                  onPressed: _showFilterDialog,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Date and section title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Today's Meals", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Meal cards
          StreamBuilder<List<Meal>>(
            stream: _mealService.getMealsForDate(_selectedDate),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    Text('No meals logged for this day.', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                  ],
                );
              }
              final meals = snapshot.data!;
              // Filter by selected meal types
              final filteredMeals = meals.where((m) => _selectedMealTypes.contains(m.mealType)).toList();
              // Group meals by type
              final breakfastMeals = filteredMeals.where((m) => m.mealType == 'breakfast').toList();
              final lunchMeals = filteredMeals.where((m) => m.mealType == 'lunch').toList();
              final dinnerMeals = filteredMeals.where((m) => m.mealType == 'dinner').toList();
              final snackMeals = filteredMeals.where((m) => m.mealType == 'snack').toList();

              return Column(
                children: [
                  if (breakfastMeals.isNotEmpty)
                    _LogMealCard(
                      meal: 'Breakfast',
                      time: breakfastMeals.first.timestamp.toString().split(' ')[1].substring(0, 5),
                      calories: breakfastMeals.fold(0, (sum, m) => sum + m.calories),
                      macros: 'P: ${breakfastMeals.fold(0, (sum, m) => sum + m.protein)}g • C: ${breakfastMeals.fold(0, (sum, m) => sum + m.carbs)}g • F: ${breakfastMeals.fold(0, (sum, m) => sum + m.fat)}g',
                      foods: breakfastMeals.map((m) => _LogFoodItem(
                        name: m.name,
                        calories: m.calories,
                        macros: 'P: ${m.protein}g • C: ${m.carbs}g • F: ${m.fat}g',
                      )).toList(),
                    ),
                  if (lunchMeals.isNotEmpty)
                    _LogMealCard(
                      meal: 'Lunch',
                      time: lunchMeals.first.timestamp.toString().split(' ')[1].substring(0, 5),
                      calories: lunchMeals.fold(0, (sum, m) => sum + m.calories),
                      macros: 'P: ${lunchMeals.fold(0, (sum, m) => sum + m.protein)}g • C: ${lunchMeals.fold(0, (sum, m) => sum + m.carbs)}g • F: ${lunchMeals.fold(0, (sum, m) => sum + m.fat)}g',
                      foods: lunchMeals.map((m) => _LogFoodItem(
                        name: m.name,
                        calories: m.calories,
                        macros: 'P: ${m.protein}g • C: ${m.carbs}g • F: ${m.fat}g',
                      )).toList(),
                    ),
                  if (dinnerMeals.isNotEmpty)
                    _LogMealCard(
                      meal: 'Dinner',
                      time: dinnerMeals.first.timestamp.toString().split(' ')[1].substring(0, 5),
                      calories: dinnerMeals.fold(0, (sum, m) => sum + m.calories),
                      macros: 'P: ${dinnerMeals.fold(0, (sum, m) => sum + m.protein)}g • C: ${dinnerMeals.fold(0, (sum, m) => sum + m.carbs)}g • F: ${dinnerMeals.fold(0, (sum, m) => sum + m.fat)}g',
                      foods: dinnerMeals.map((m) => _LogFoodItem(
                        name: m.name,
                        calories: m.calories,
                        macros: 'P: ${m.protein}g • C: ${m.carbs}g • F: ${m.fat}g',
                      )).toList(),
                    ),
                  if (snackMeals.isNotEmpty)
                    _LogMealCard(
                      meal: 'Snack',
                      time: snackMeals.first.timestamp.toString().split(' ')[1].substring(0, 5),
                      calories: snackMeals.fold(0, (sum, m) => sum + m.calories),
                      macros: 'P: ${snackMeals.fold(0, (sum, m) => sum + m.protein)}g • C: ${snackMeals.fold(0, (sum, m) => sum + m.carbs)}g • F: ${snackMeals.fold(0, (sum, m) => sum + m.fat)}g',
                      foods: snackMeals.map((m) => _LogFoodItem(
                        name: m.name,
                        calories: m.calories,
                        macros: 'P: ${m.protein}g • C: ${m.carbs}g • F: ${m.fat}g',
                      )).toList(),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showAddMealDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('+ Add Meal', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

class AddMealDialog extends StatefulWidget {
  final VoidCallback onMealAdded;

  const AddMealDialog({super.key, required this.onMealAdded});

  @override
  State<AddMealDialog> createState() => _AddMealDialogState();
}

class _AddMealDialogState extends State<AddMealDialog> {
  final _formKey = GlobalKey<FormState>();
  final MealService _mealService = MealService();
  String _selectedMealType = 'breakfast';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();

  Future<void> _addMeal() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final meal = Meal(
        id: '', // Will be set by Firestore
        name: _nameController.text,
        calories: int.parse(_caloriesController.text),
        protein: int.parse(_proteinController.text),
        carbs: int.parse(_carbsController.text),
        fat: int.parse(_fatController.text),
        timestamp: DateTime.now(),
        mealType: _selectedMealType,
        userId: FirebaseAuth.instance.currentUser!.uid,
      );

      await _mealService.addMeal(meal);
      widget.onMealAdded();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding meal: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Meal'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedMealType,
                decoration: const InputDecoration(labelText: 'Meal Type'),
                items: ['breakfast', 'lunch', 'dinner', 'snack']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type[0].toUpperCase() + type.substring(1)),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedMealType = value);
                  }
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Food Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a food name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(labelText: 'Calories'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter calories';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _proteinController,
                decoration: const InputDecoration(labelText: 'Protein (g)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter protein';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _carbsController,
                decoration: const InputDecoration(labelText: 'Carbs (g)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter carbs';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _fatController,
                decoration: const InputDecoration(labelText: 'Fat (g)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter fat';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addMeal,
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _LogMealCard extends StatelessWidget {
  final String meal;
  final String time;
  final int calories;
  final String macros;
  final List<_LogFoodItem> foods;
  const _LogMealCard({required this.meal, required this.time, required this.calories, required this.macros, required this.foods});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(meal, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('$calories cal', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(time, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              Text(macros, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ),
          const Divider(height: 18),
          ...foods,
        ],
      ),
    );
  }
}

class _LogFoodItem extends StatelessWidget {
  final String name;
  final int calories;
  final String macros;
  const _LogFoodItem({required this.name, required this.calories, required this.macros});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: kPrimaryGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(macros, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Text('$calories cal', style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
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
