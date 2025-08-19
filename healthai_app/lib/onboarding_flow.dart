import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main.dart'; // For AuthScreen
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'services/ai_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'providers/preferences_provider.dart';
import 'subscription_popup_page.dart';
import 'widgets/improved_age_selector.dart';
import 'widgets/improved_height_selector.dart';
import 'widgets/improved_height_step.dart';
import 'widgets/improved_weight_step.dart';
import 'widgets/improved_goal_weight_step.dart';
import 'l10n/app_localizations.dart';

class OnboardingFlowPage extends StatefulWidget {
  const OnboardingFlowPage({Key? key}) : super(key: key);
  @override
  State<OnboardingFlowPage> createState() => _OnboardingFlowPageState();
}

class _OnboardingFlowPageState extends State<OnboardingFlowPage> with SingleTickerProviderStateMixin {
  int step = 0;
  String? selectedGoal;
  String? selectedMotivation;
  int? selectedAge;
  int? selectedBirthMonth;
  int? selectedBirthDay;
  double? selectedHeightCm;
  bool useMetricHeight = false;
  int selectedHeightFeet = 5;
  int selectedHeightInches = 8;
  // Weight state
  double? selectedWeightKg;
  bool useMetricWeight = false;
  double selectedWeightLb = 154;
  double? targetWeightKg;
  String? activityLevel;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  List<String> selectedHabits = [];
  String? bloodType;
  bool? isDiabetic;
  String? waterIntake;
  String? selectedSex;
  bool isLoadingNutritionPlan = false;
  Map<String, dynamic>? aiNutritionPlan;
  String? aiError;
  List<String> selectedReminders = [];



  // Persist/recover onboarding progress to avoid resets on rebuilds (e.g., locale or Firestore updates)
  String _onboardingStepKeyForUser(String? uid) => 'onboarding_resume_step_${uid ?? 'anon'}';
  static const String _onboardingStepKeyGlobal = 'onboarding_resume_step_global';

  String _draftKeyForUser(String? uid) => 'onboarding_draft_${uid ?? 'anon'}';
  static const String _draftKeyGlobal = 'onboarding_draft_global';

  Future<void> _saveDraftToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final draft = {
        'selectedGoal': selectedGoal,
        'selectedMotivation': selectedMotivation,
        'selectedAge': selectedAge,
        'selectedBirthMonth': selectedBirthMonth,
        'selectedBirthDay': selectedBirthDay,
        'selectedHeightCm': selectedHeightCm,
        'useMetricHeight': useMetricHeight,
        'selectedHeightFeet': selectedHeightFeet,
        'selectedHeightInches': selectedHeightInches,
        'selectedWeightKg': selectedWeightKg,
        'useMetricWeight': useMetricWeight,
        'selectedWeightLb': selectedWeightLb,
        'targetWeightKg': targetWeightKg,
        'activityLevel': activityLevel,
        'selectedSex': selectedSex,
        'bloodType': bloodType,
        'isDiabetic': isDiabetic,
        'waterIntake': waterIntake,
        'selectedReminders': selectedReminders,
      };
      final json = draft.toString();
      await prefs.setString(_draftKeyForUser(uid), json);
    } catch (_) {}
  }

  Future<void> _clearDraftPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      await prefs.remove(_draftKeyForUser(uid));
    } catch (_) {}
  }

  Future<void> _restoreDraftFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      String? json = prefs.getString(_draftKeyForUser(uid));
      if (json == null) return;
      // Very lightweight parser since we saved via Map.toString()
      // Format: {key: value, key2: value2}
      Map<String, String> kv = {};
      final body = json.trim();
      if (body.startsWith('{') && body.endsWith('}')) {
        final inner = body.substring(1, body.length - 1);
        for (final part in inner.split(',')) {
          final idx = part.indexOf(':');
          if (idx > 0) {
            final k = part.substring(0, idx).trim();
            final v = part.substring(idx + 1).trim();
            kv[k] = v;
          }
        }
      }
      T? _parse<T>(String key, T? Function(String) conv) {
        if (!kv.containsKey(key)) return null;
        return conv(kv[key]!);
      }
      setState(() {
        selectedGoal = _parse<String>('selectedGoal', (s) => s == 'null' ? null : s);
        selectedMotivation = _parse<String>('selectedMotivation', (s) => s == 'null' ? null : s);
        selectedAge = _parse<int>('selectedAge', (s) => s == 'null' ? null : int.tryParse(s));
        selectedBirthMonth = _parse<int>('selectedBirthMonth', (s) => s == 'null' ? null : int.tryParse(s));
        selectedBirthDay = _parse<int>('selectedBirthDay', (s) => s == 'null' ? null : int.tryParse(s));
        selectedHeightCm = _parse<double>('selectedHeightCm', (s) => s == 'null' ? null : double.tryParse(s));
        useMetricHeight = _parse<bool>('useMetricHeight', (s) => s == 'true') ?? useMetricHeight;
        selectedHeightFeet = _parse<int>('selectedHeightFeet', (s) => int.tryParse(s)) ?? selectedHeightFeet;
        selectedHeightInches = _parse<int>('selectedHeightInches', (s) => int.tryParse(s)) ?? selectedHeightInches;
        selectedWeightKg = _parse<double>('selectedWeightKg', (s) => s == 'null' ? null : double.tryParse(s));
        useMetricWeight = _parse<bool>('useMetricWeight', (s) => s == 'true') ?? useMetricWeight;
        selectedWeightLb = _parse<double>('selectedWeightLb', (s) => double.tryParse(s)) ?? selectedWeightLb;
        targetWeightKg = _parse<double>('targetWeightKg', (s) => s == 'null' ? null : double.tryParse(s));
        activityLevel = _parse<String>('activityLevel', (s) => s == 'null' ? null : s);
        selectedSex = _parse<String>('selectedSex', (s) => s == 'null' ? null : s);
        bloodType = _parse<String>('bloodType', (s) => s == 'null' ? null : s);
        isDiabetic = _parse<bool>('isDiabetic', (s) => s == 'true' ? true : s == 'false' ? false : null);
        waterIntake = _parse<String>('waterIntake', (s) => s == 'null' ? null : s);
      });
    } catch (_) {}
  }

  Future<void> _persistOnboardingStep() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      // Save under both user-specific and global keys to survive auth timing races
      await prefs.setInt(_onboardingStepKeyForUser(uid), step);
    } catch (_) {}
  }

  Future<void> _clearPersistedOnboardingStep() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      await prefs.remove(_onboardingStepKeyForUser(uid));
    } catch (_) {}
  }

  Future<void> _restoreOnboardingStepIfAny() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      int? saved = prefs.getInt(_onboardingStepKeyForUser(uid));
      if (saved != null && saved >= 0 && saved <= 15 && mounted) {
        setState(() {
          step = saved!;
          _controller.reset();
          _controller.forward();
        });
      }
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
    // Initialize defaults for onboarding values
    selectedAge = selectedAge ?? 16;
    selectedHeightCm = selectedHeightCm ?? 170;
    selectedWeightKg = selectedWeightKg ?? 70;
    selectedWeightLb = selectedWeightKg! * 2.20462;
    // Old behavior: do not restore mid-onboarding state after app relaunch
    // Ensure any previously persisted progress/draft is cleared
    _clearPersistedOnboardingStep();
    _clearDraftPrefs();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void nextStep() {
    if (!mounted) return; // Prevent setState after dispose
    setState(() {
      step++;
      // Set defaults for each step if not set
      if (step == 3 && selectedAge == null) selectedAge = 16;
      if (step == 4 && selectedHeightCm == null) selectedHeightCm = 170;
      if (step == 5 && selectedWeightKg == null) {
        selectedWeightKg = 70;
        selectedWeightLb = selectedWeightKg! * 2.20462;
      }
      // If goal is to maintain weight, set target weight to current weight and skip the target weight step
      if (step == 7 && selectedGoal == 'Maintain body weight') {
        targetWeightKg = selectedWeightKg;
        step++; // Skip the target weight step
      }
      _controller.reset();
      _controller.forward();
    });
  }

  void prevStep() {
    if (!mounted) return; // Prevent setState after dispose
    setState(() {
      if (step == 15) {
        step = 13;
        _controller.reset();
        _controller.forward();
      } else if (step == 14) {
        step = 13;
        _controller.reset();
        _controller.forward();
      } else if (step > 0) {
      step--;
      _controller.reset();
      _controller.forward();
      } else {
        // If at the first step, exit onboarding (go to AuthScreen)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => AuthScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    final double sliderMinCm = 100;
    final double sliderMaxCm = 220;
    final int sliderMinIn = 36;
    final int sliderMaxIn = 87;
    final double sliderHeight = 64;
    final double valueFontSize = 44;

    // Ensure height value is always initialized and visible
    if (useMetricHeight && (selectedHeightCm == null)) {
      selectedHeightCm = 170;
    } else if (!useMetricHeight && (selectedHeightCm == null)) {
      // Default to 5'7" (67 inches)
      selectedHeightCm = ((selectedHeightFeet * 12 + selectedHeightInches) * 2.54).toDouble();
    }

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Builder(
            builder: (context) {
              if (step == 0) {
                return _GoalStep(
                  fadeAnimation: _fadeAnimation,
                  slideAnimation: _slideAnimation,
                  selectedGoal: selectedGoal,
                  onSelect: (goal) => setState(() => selectedGoal = goal),
                  onContinue: selectedGoal == null ? null : nextStep,
                  onBack: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => AuthScreen()),
                  ),
                );
              } else if (step == 1) {
                return _MotivationStep(
                  fadeAnimation: _fadeAnimation,
                  slideAnimation: _slideAnimation,
                  selectedMotivation: selectedMotivation,
                  onSelect: (motivation) => setState(() => selectedMotivation = motivation),
                  onContinue: selectedMotivation == null ? null : nextStep,
                  onBack: prevStep,
                );
              } else if (step == 2) {
                return _CalorieIntroStep(
                  fadeAnimation: _fadeAnimation,
                  slideAnimation: _slideAnimation,
                  onContinue: nextStep,
                  onBack: prevStep,
                  isSmallScreen: isSmallScreen,
                );
              } else if (step == 3) {
                return _SexStep(
                  fadeAnimation: _fadeAnimation,
                  slideAnimation: _slideAnimation,
                  selectedSex: selectedSex,
                  onSelect: (sex) => setState(() => selectedSex = sex),
                  onContinue: selectedSex == null ? null : nextStep,
                  onBack: prevStep,
                );
              } else if (step == 4) {
                return _AgeStep(
                  fadeAnimation: _fadeAnimation,
                  slideAnimation: _slideAnimation,
                  selectedAge: selectedAge,
                  selectedBirthMonth: selectedBirthMonth,
                  selectedBirthDay: selectedBirthDay,
                  onSelectAge: (age) => setState(() => selectedAge = age),
                  onSelectBirthday: (month, day) => setState(() {
                    selectedBirthMonth = month;
                    selectedBirthDay = day;
                  }),
                  onContinue: (selectedAge != null && selectedBirthMonth != null && selectedBirthDay != null) ? nextStep : null,
                  onBack: prevStep,
                  isSmallScreen: isSmallScreen,
                );
              } else if (step == 5) {
                return ImprovedHeightStep(
                  fadeAnimation: _fadeAnimation,
                  slideAnimation: _slideAnimation,
                  useMetric: useMetricHeight,
                  heightCm: selectedHeightCm,
                  heightFeet: selectedHeightFeet,
                  heightInches: selectedHeightInches,
                  isSmallScreen: isSmallScreen,
                  onUnitToggle: (metric) => setState(() {
                    useMetricHeight = metric;
                    // Lock weight unit and water mapping immediately based on height unit
                    // Rule: ft (imperial) => US units (lbs, Liters for water)
                    // cm (metric) => kg and fl oz.
                    useMetricWeight = metric ? true : false; // if cm => kg, if ft => lbs
                    if (selectedHeightCm != null) {
                      if (metric) {
                        selectedHeightCm = ((selectedHeightFeet * 12 + selectedHeightInches) * 2.54).toDouble();
                      } else {
                        final totalInches = (selectedHeightCm! / 2.54).round().clamp(36, 87);
                        selectedHeightFeet = totalInches ~/ 12;
                        selectedHeightInches = totalInches % 12;
                      }
                    }
                  }),
                  onSelectCm: (cm) => setState(() => selectedHeightCm = cm),
                  onSelectFtIn: (ft, inch) => setState(() {
                    selectedHeightFeet = ft;
                    selectedHeightInches = inch;
                    selectedHeightCm = ((ft * 12 + inch) * 2.54).toDouble();
                  }),
                  onContinue: selectedHeightCm == null ? null : nextStep,
                  onBack: prevStep,
                );
              } else if (step == 6) {
                // Lock weight unit based on height unit selection earlier
                useMetricWeight = useMetricHeight;
                return ImprovedWeightStep(
                  fadeAnimation: _fadeAnimation,
                  slideAnimation: _slideAnimation,
                  useMetric: useMetricWeight,
                  weightKg: selectedWeightKg,
                  weightLb: selectedWeightLb,
                  isSmallScreen: isSmallScreen,
                  onUnitToggle: (metric) {
                    // This won't be called anymore since we removed the toggle
                  },
                  onSelectKg: (kg) => setState(() {
                    selectedWeightKg = kg;
                    selectedWeightLb = kg * 2.20462;
                  }),
                  onSelectLb: (lb) => setState(() {
                    selectedWeightLb = lb;
                    selectedWeightKg = lb / 2.20462;
                  }),
                  onContinue: selectedWeightKg == null ? null : nextStep,
                  onBack: prevStep,
                );
              } else if (step == 7) {
                return ImprovedGoalWeightStep(
                  fadeAnimation: _fadeAnimation,
                  slideAnimation: _slideAnimation,
                  useMetric: useMetricWeight,
                  goalWeightKg: targetWeightKg ?? selectedWeightKg ?? 70,
                  currentWeightKg: selectedWeightKg ?? 70,
                  isSmallScreen: isSmallScreen,
                  onGoalWeightChanged: (v) => setState(() => targetWeightKg = v),
                  onContinue: (targetWeightKg != null) ? nextStep : null,
                  onBack: prevStep,
                  selectedGoal: selectedGoal,
                );
              } else if (step == 8) {
                return _ActivityLevelStep(
                  fadeAnimation: _fadeAnimation,
                  slideAnimation: _slideAnimation,
                  activityLevel: activityLevel,
                  onActivityLevelChanged: (v) => setState(() => activityLevel = v),
                  onContinue: (activityLevel != null) ? nextStep : null,
                  onBack: prevStep,
                );
              } else if (step == 9) {
                return _BloodTypeStep(
                  fadeAnimation: _fadeAnimation,
                  slideAnimation: _slideAnimation,
                  selectedBloodType: bloodType,
                  onSelect: (type) => setState(() => bloodType = type),
                  onContinue: bloodType == null ? null : nextStep,
                  onBack: prevStep,
                );
              } else if (step == 10) {
                return _DiabeticStep(
                  fadeAnimation: _fadeAnimation,
                  slideAnimation: _slideAnimation,
                  isDiabetic: isDiabetic,
                  onSelect: (value) => setState(() => isDiabetic = value),
                  onContinue: isDiabetic == null ? null : nextStep,
                  onBack: prevStep,
                );
              } else if (step == 11) {
                return _WaterIntakeStep(
                  fadeAnimation: _fadeAnimation,
                  slideAnimation: _slideAnimation,
                  selectedWaterIntake: waterIntake,
                  useMetricHeight: useMetricHeight,
                  onSelect: (value) => setState(() => waterIntake = value),
                  onContinue: waterIntake == null ? null : nextStep,
                  onBack: prevStep,
                );
              } else if (step == 12) {
                return _ProfileSummaryStep(
                  fadeAnimation: _fadeAnimation,
                  slideAnimation: _slideAnimation,
                  age: selectedAge ?? 16,
                  weightKg: selectedWeightKg ?? 70,
                  useMetricWeight: useMetricWeight,
                  heightCm: selectedHeightCm ?? 170,
                  targetWeightKg: targetWeightKg ?? selectedWeightKg ?? 70,
                  onTargetWeightChanged: (v) => setState(() => targetWeightKg = v),
                  activityLevel: activityLevel,
                  onActivityLevelChanged: (v) => setState(() => activityLevel = v),
                  onContinue: (activityLevel != null && targetWeightKg != null)
                      ? () async {
                          if (mounted) nextStep();
                        }
                      : null,
                  onBack: prevStep,
                  bloodType: bloodType,
                  isDiabetic: isDiabetic,
                  waterIntake: waterIntake,
                );
              } else if (step == 13) {
                return _RemindersStep(
                  fadeAnimation: _fadeAnimation,
                  slideAnimation: _slideAnimation,
                  selectedReminders: selectedReminders,
                  onReminderToggle: (reminder) => setState(() {
                    if (selectedReminders.contains(reminder)) {
                      selectedReminders.remove(reminder);
                    } else {
                      selectedReminders.add(reminder);
                    }
                  }),
                  onContinue: selectedReminders.isNotEmpty
                      ? () async {
                          // Kick off the nutrition plan fetch immediately
                          try { _fetchNutritionPlan(); } catch (_) {}
                          // Use normal step progression
                          if (mounted) nextStep();
                        }
                      : null,
                  onBack: prevStep,
                );
              } else if (step == 14) {
                // Loading step - show loading animation while nutrition plan is being generated
                return NutritionLoadingAnimation(message: AppLocalizations.of(context)!.yumieIsCookingUp);
              } else if (step == 15) {
                if (aiNutritionPlan != null) {
                return _NutritionPlanSummaryStep(
                  fadeAnimation: _fadeAnimation,
                  slideAnimation: _slideAnimation,
                    calories: aiNutritionPlan!["calories"]!,
                    protein: aiNutritionPlan!["protein"]!,
                    fat: aiNutritionPlan!["fat"]!,
                    carbs: aiNutritionPlan!["carbs"]!,
                  onFinish: () async {
                    final user = await getCurrentUser();
                    if (user != null) {
                      final now = DateTime.now();

                        try {
                          final Map<String, bool> remindersMap = {
                            'mealLoggingPrompts': selectedReminders.contains('Meal Logging Prompts'),
                            'waterIntakeReminders': selectedReminders.contains('Water Intake Reminders'),
                            'mindfulWalksReminders': selectedReminders.contains('Mindful Walks Reminders'),
                            'momentOfCalmReminders': selectedReminders.contains('Moment of Calm After Meals'),
                          };
                      // First, get the existing user data to preserve the name and photo URL
                      final existingDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
                      final existingData = existingDoc.data() as Map<String, dynamic>?;
                      final existingName = existingData?['name'] ?? '';
                      final existingPhotoUrl = existingData?['photoUrl'] ?? '';
                      
                      print('Onboarding: Preserving existing name: "$existingName", photoUrl: "$existingPhotoUrl"'); // Debug log
                      
                      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                            'dailyCalorieGoal': aiNutritionPlan!["calories"],
                            'proteinGoal': aiNutritionPlan!["protein"],
                            'fatGoal': aiNutritionPlan!["fat"],
                            'carbsGoal': aiNutritionPlan!["carbs"],
                        'lastUpdated': now,
                        'hasCompletedOnboarding': true,
                            'reminders': remindersMap, // Save reminders as a map of booleans
                            'useMetric': useMetricWeight, // Save unit preference
                            'age': selectedAge,
                            'heightCm': selectedHeightCm,
                            'weightKg': selectedWeightKg,
                            'startingWeight': selectedWeightKg, // Save starting weight
                            'targetWeightKg': targetWeightKg,
                            'activityLevel': activityLevel,
                            'goal': selectedGoal,
                            'sex': selectedSex,
                            'bloodType': bloodType,
                            'isDiabetic': isDiabetic,
                            'waterIntake': waterIntake,
                            'name': existingName, // Preserve the existing name from Apple Sign-In
                            'photoUrl': existingPhotoUrl, // Preserve the existing photo URL
                      }, SetOptions(merge: true));

                        } catch (e) {
                          // Handle error silently
                        }
                        
                        // Also save unit preference to SharedPreferences
                        final prefsProvider = Provider.of<PreferencesProvider>(context, listen: false);
                        await prefsProvider.setUseMetric(useMetricWeight);
                    }
                    
                    // Navigate to main app with post-onboarding flag
                    // Mark that onboarding just completed
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('just_completed_onboarding', true);
                    await _clearPersistedOnboardingStep();
                    await _clearDraftPrefs();
                    
                    // Navigate to main app immediately
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => MainNavScreen()),
                      (route) => false,
                    );
                  },
                  onBack: prevStep,
                );
                }
                if (aiError != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 48),
                        SizedBox(height: 16),
                        Text(AppLocalizations.of(context)!.couldNotGenerateYourPlan, style: TextStyle(fontSize: 18)),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              aiError = null;
                              _fetchNutritionPlan();
                            });
                          },
                          child: Text(AppLocalizations.of(context)!.retry),
                        ),
                      ],
                    ),
                  );
                }
                // Trigger AI fetch on first build of this step
                Future.microtask(_fetchNutritionPlan);
                return NutritionLoadingAnimation(message: AppLocalizations.of(context)!.yumieIsCookingUp);
              } else {
                // Fallback UI for unknown steps
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 48),
                      SizedBox(height: 16),
                      Text(AppLocalizations.of(context)!.somethingWentWrongRestart, style: TextStyle(fontSize: 18)),
                      SizedBox(height: 24),
                      // References for BMI and guidance
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('References:', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          Expanded(
                        child: Wrap(
                              alignment: WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            TextButton(
                              onPressed: () => launchUrl(Uri.parse('https://www.cdc.gov/healthyweight/assessing/bmi/index.html'), mode: LaunchMode.externalApplication),
                              child: const Text('CDC: About BMI'),
                            ),
                            TextButton(
                              onPressed: () => launchUrl(Uri.parse('https://www.dietaryguidelines.gov/'), mode: LaunchMode.externalApplication),
                              child: const Text('USDA Dietary Guidelines'),
                            ),
                          ],
                        ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            step = 0;
                          });
                          _clearPersistedOnboardingStep();
                        },
                        child: Text(AppLocalizations.of(context)!.restartOnboarding),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  void _fetchNutritionPlan() async {
    setState(() {
      isLoadingNutritionPlan = true;
      aiNutritionPlan = null;
      aiError = null;
    });
    try {
      final aiService = AIService();
      final int age = selectedAge ?? 16;
      final String sex = selectedSex ?? "Other";
      final String goal = selectedGoal ?? "Maintenance";
      final String activity = activityLevel ?? "Sedentary";
      final String blood = bloodType ?? "O+";
      final bool diabetic = isDiabetic ?? false;
      final String? water = waterIntake;
      final start = DateTime.now();
      
      // Use the correct height and weight values
      final int heightCm = selectedHeightCm?.round() ?? 170;
      final double weightKg = selectedWeightKg ?? 70;
      
      // Calculate BMR using Mifflin-St Jeor equation
      double bmr;
      if (sex.toLowerCase() == 'male') {
        bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
      } else {
        bmr = 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
      }
      
      // Apply activity multiplier
      double tdee = bmr;
      switch (activity.toLowerCase()) {
        case 'sedentary':
          tdee = bmr * 1.2;
          break;
        case 'lightly active':
          tdee = bmr * 1.375;
          break;
        case 'moderately active':
          tdee = bmr * 1.55;
          break;
        case 'very active':
          tdee = bmr * 1.725;
          break;
        case 'extremely active':
          tdee = bmr * 1.9;
          break;
      }
      
      // Adjust calories based on goal
      int calorieGoal;
      switch (goal.toLowerCase()) {
        case 'lose body weight':
          calorieGoal = (tdee - 500).round();
          break;
        case 'gain weight':
          calorieGoal = (tdee + 300).round();
          break;
        case 'build muscle':
          calorieGoal = (tdee + 200).round();
          break;
        default: // maintain or eat healthier
          calorieGoal = tdee.round();
      }
      
      // Calculate macro goals
      int proteinGoal;
      if (goal.toLowerCase() == 'build muscle') {
        proteinGoal = (weightKg * 2.2).round(); // 1g per lb for muscle building
      } else {
        proteinGoal = (weightKg * 1.8).round(); // 0.8g per lb for general health
      }
      
      int fatGoal = (calorieGoal * 0.25 / 9).round(); // 25% of calories from fat
      int carbsGoal = ((calorieGoal - (proteinGoal * 4) - (fatGoal * 9)) / 4).round(); // Remaining calories from carbs
      
      final plan = await aiService.getNutritionPlanRecommendation(
        age: age,
        heightCm: heightCm,
        weightKg: weightKg,
        calorieGoal: calorieGoal,
        proteinGoal: proteinGoal,
        carbsGoal: carbsGoal,
        fatGoal: fatGoal,
        bloodType: blood,
        isDiabetic: diabetic,
      );

      if (plan == null) throw Exception("AI did not return a plan");
      // Ensure at least 7 seconds of loading
      final elapsed = DateTime.now().difference(start).inMilliseconds;
      final minLoading = 7000;
      if (elapsed < minLoading) {
        await Future.delayed(Duration(milliseconds: minLoading - elapsed));
      }
      setState(() {
        aiNutritionPlan = plan;
        isLoadingNutritionPlan = false;
      });
      // Automatically advance to step 15 when nutrition plan is ready
      if (mounted) {
        setState(() {
          step = 15;
        });
      }
    } catch (e) {
      setState(() {
        aiError = e.toString();
        isLoadingNutritionPlan = false;
      });
      // Automatically advance to step 15 even on error
      if (mounted) {
        setState(() {
          step = 15;
        });
      }
    }
  }
}

class _GoalStep extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final String? selectedGoal;
  final void Function(String) onSelect;
  final VoidCallback? onContinue;
  final VoidCallback onBack;
  _GoalStep({required this.fadeAnimation, required this.slideAnimation, required this.selectedGoal, required this.onSelect, required this.onContinue, required this.onBack});

  // Goals stored in English for consistency in Firebase
  static const List<Map<String, dynamic>> _goalData = [
    {'icon': Icons.trending_down, 'value': 'Lose body weight', 'color': Color(0xFFFF6B6B)},
    {'icon': Icons.favorite, 'value': 'Gain weight', 'color': Color(0xFF4ECDC4)},
    {'icon': Icons.fitness_center, 'value': 'Build muscle', 'color': Color(0xFFFFD93D)},
    {'icon': Icons.restaurant, 'value': 'Eat healthier', 'color': Color(0xFF95E1D3)},
    {'icon': Icons.balance, 'value': 'Maintain body weight', 'color': Color(0xFF9C27B0)},
  ];
  
  List<Map<String, dynamic>> _getLocalizedGoals(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return [
      {'icon': Icons.trending_down, 'label': localizations.loseBodyWeight, 'value': 'Lose body weight', 'color': Color(0xFFFF6B6B)},
      {'icon': Icons.favorite, 'label': localizations.gainWeight, 'value': 'Gain weight', 'color': Color(0xFF4ECDC4)},
      {'icon': Icons.fitness_center, 'label': localizations.buildMuscle, 'value': 'Build muscle', 'color': Color(0xFFFFD93D)},
      {'icon': Icons.restaurant, 'label': localizations.eatHealthier, 'value': 'Eat healthier', 'color': Color(0xFF95E1D3)},
      {'icon': Icons.balance, 'label': localizations.maintainBodyWeight, 'value': 'Maintain body weight', 'color': Color(0xFF9C27B0)},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
                      children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(Icons.arrow_back, color: theme.primaryColor, size: 24),
                                onPressed: onBack,
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildProgressDot(context, true),
                              _buildProgressLine(context, true),
                              _buildProgressDot(context, false),
                              _buildProgressLine(context, false),
                              _buildProgressDot(context, false),
                            ],
                          ),
                          SizedBox(height: 32),
                          FadeTransition(
                            opacity: fadeAnimation,
                            child: SlideTransition(
                              position: slideAnimation,
                              child: Column(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.whatIsYourMainGoal,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 32,
                                      letterSpacing: -0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    AppLocalizations.of(context)!.chooseGoalDescription,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 32),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _getLocalizedGoals(context).length,
                            itemBuilder: (context, index) {
                              final goal = _getLocalizedGoals(context)[index];
                              final isSelected = selectedGoal == goal['value']; // Compare with stored English value
                              return FadeTransition(
                                opacity: fadeAnimation,
                                child: SlideTransition(
                                  position: slideAnimation,
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 16),
                                    child: _buildGoalCard(goal, isSelected, theme, onSelect),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
        SafeArea(
          minimum: EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.continueButton),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 20),
              ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressDot(BuildContext context, bool isActive) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.grey[300],
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildProgressLine(BuildContext context, bool isActive) {
    return Container(
      width: 40,
      height: 2,
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.grey[300],
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> goal, bool isSelected, ThemeData theme, void Function(String) onSelect) {
    return GestureDetector(
      onTap: () => onSelect(goal['value']), // Store English value
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? goal['color'].withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? goal['color'] : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: goal['color'].withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(14),
              child: Icon(goal['icon'], color: goal['color'], size: 28),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Text(
                goal['label'],
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: isSelected ? goal['color'] : Colors.black,
                ),
              ),
            ),
            if (isSelected)
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: goal['color'].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: goal['color'], size: 20),
              ),
          ],
        ),
      ),
    );
  }
}

class _MotivationStep extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final String? selectedMotivation;
  final void Function(String) onSelect;
  final VoidCallback? onContinue;
  final VoidCallback onBack;
  _MotivationStep({required this.fadeAnimation, required this.slideAnimation, required this.selectedMotivation, required this.onSelect, required this.onContinue, required this.onBack});

  List<Map<String, dynamic>> _getLocalizedMotivations(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return [
      {'icon': Icons.wb_sunny_outlined, 'label': localizations.feelEnergeticEveryDay, 'value': 'Feel energetic every day', 'color': Color(0xFFFFB74D)},
      {'icon': Icons.emoji_events, 'label': localizations.achievePersonalMilestone, 'value': 'Achieve a personal milestone', 'color': Color(0xFFBA68C8)},
      {'icon': Icons.self_improvement, 'label': localizations.boostMyConfidence, 'value': 'Boost my confidence', 'color': Color(0xFF64B5F6)},
      {'icon': Icons.health_and_safety, 'label': localizations.longTermHealth, 'value': 'Long term health', 'color': Color(0xFF4CAF50)},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
                      children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(Icons.arrow_back, color: theme.primaryColor, size: 24),
                                onPressed: onBack,
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildProgressDot(context, true),
                              _buildProgressLine(context, true),
                              _buildProgressDot(context, true),
                              _buildProgressLine(context, false),
                              _buildProgressDot(context, false),
                            ],
                          ),
                          SizedBox(height: 32),
                          FadeTransition(
                            opacity: fadeAnimation,
                            child: SlideTransition(
                              position: slideAnimation,
                              child: Column(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.whatMotivatesYou,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 32,
                                      letterSpacing: -0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    AppLocalizations.of(context)!.chooseWhatDrivesYou,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 32),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _getLocalizedMotivations(context).length,
                            itemBuilder: (context, index) {
                              final motivation = _getLocalizedMotivations(context)[index];
                              final isSelected = selectedMotivation == motivation['value']; // Compare with stored English value
                              return FadeTransition(
                                opacity: fadeAnimation,
                                child: SlideTransition(
                                  position: slideAnimation,
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 16),
                                    child: _buildMotivationCard(motivation, isSelected, theme, onSelect),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
        SafeArea(
          minimum: EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.continueButton),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 20),
              ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressDot(BuildContext context, bool isActive) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.grey[300],
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildProgressLine(BuildContext context, bool isActive) {
    return Container(
      width: 40,
      height: 2,
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.grey[300],
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildMotivationCard(Map<String, dynamic> motivation, bool isSelected, ThemeData theme, void Function(String) onSelect) {
    return GestureDetector(
      onTap: () => onSelect(motivation['value']), // Store English value
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? motivation['color'].withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? motivation['color'] : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: motivation['color'].withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(14),
              child: Icon(motivation['icon'], color: motivation['color'], size: 28),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Text(
                motivation['label'],
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: isSelected ? motivation['color'] : Colors.black,
                ),
              ),
            ),
            if (isSelected)
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: motivation['color'].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: motivation['color'], size: 20),
              ),
          ],
        ),
      ),
    );
  }
}

class _CalorieIntroStep extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final VoidCallback onContinue;
  final VoidCallback onBack;
  final bool isSmallScreen;
  _CalorieIntroStep({required this.fadeAnimation, required this.slideAnimation, required this.onContinue, required this.onBack, required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        children: [
          // Header with back button and progress
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: theme.primaryColor, size: 24),
                      onPressed: onBack,
                    ),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 16 : 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildProgressDot(context, true),
                    _buildProgressLine(context, true),
                    _buildProgressDot(context, true),
                    _buildProgressLine(context, true),
                    _buildProgressDot(context, true),
                  ],
                ),
              ],
            ),
          ),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: FadeTransition(
                opacity: fadeAnimation,
                child: SlideTransition(
                  position: slideAnimation,
                  child: Column(
                    children: [
                      SizedBox(height: isSmallScreen ? 16 : 32),
                      Text(
                        AppLocalizations.of(context)!.trackYourMealsWithEase,
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: isSmallScreen ? 24 : 28
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 24),
                      _AnimatedCalorieRing(caloriesLeft: 1857, goal: 2200),
                      SizedBox(height: isSmallScreen ? 16 : 24),
                      _SampleMealCard(
                        mealType: AppLocalizations.of(context)!.breakfast,
                        color: Color(0xFFFFD93D),
                        mealName: AppLocalizations.of(context)!.avocadoToast,
                        calories: 195,
                        macros: '20g carb  •  5g protein  •  11g fat  •  8g fibre',
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 12),
                      _SampleMealCard(
                        mealType: AppLocalizations.of(context)!.lunch,
                        color: Color(0xFFFFB74D),
                        mealName: AppLocalizations.of(context)!.italianSalad,
                        calories: 189,
                        macros: '11g carb  •  12g protein  •  10g fat  •  4g fibre',
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 12),
                      _SampleMealCard(
                        mealType: AppLocalizations.of(context)!.dinner,
                        color: Color(0xFF64B5F6),
                        mealName: AppLocalizations.of(context)!.chickenKatsuRiceBowl,
                        calories: 479,
                        macros: '51g carb  •  52g protein  •  6g fat  •  4g fibre',
                      ),
                      SizedBox(height: 20), // Bottom padding for scroll
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Continue button always visible at bottom
          SafeArea(
            child: Container(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: Text(AppLocalizations.of(context)!.continueButton),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDot(BuildContext context, bool isActive) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.grey[300],
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildProgressLine(BuildContext context, bool isActive) {
    return Container(
      width: 40,
      height: 2,
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.grey[300],
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}

class _AnimatedCalorieRing extends StatelessWidget {
  final int caloriesLeft;
  final int goal;
  const _AnimatedCalorieRing({required this.caloriesLeft, required this.goal});
  @override
  Widget build(BuildContext context) {
    final percent = caloriesLeft / goal;
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 110,
              height: 110,
              child: CircularProgressIndicator(
                value: percent.clamp(0.0, 1.0),
                backgroundColor: Color(0xFFF0F1F6),
                color: Color(0xFF4ECDC4),
                strokeWidth: 10,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$caloriesLeft', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32)),
                Text(AppLocalizations.of(context)!.caloriesLeft, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _SampleMealCard extends StatelessWidget {
  final String mealType;
  final Color color;
  final String mealName;
  final int calories;
  final String macros;
  const _SampleMealCard({required this.mealType, required this.color, required this.mealName, required this.calories, required this.macros});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.restaurant_menu, color: color, size: 18),
                SizedBox(width: 6),
                Text(mealType, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mealName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 2),
                Text('$calories ${AppLocalizations.of(context)!.calories}', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                SizedBox(height: 2),
                Text(macros, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AgeStep extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final int? selectedAge;
  final int? selectedBirthMonth;
  final int? selectedBirthDay;
  final void Function(int) onSelectAge;
  final void Function(int, int) onSelectBirthday;
  final VoidCallback? onContinue;
  final VoidCallback onBack;
  final bool isSmallScreen;
  _AgeStep({required this.fadeAnimation, required this.slideAnimation, required this.selectedAge, required this.selectedBirthMonth, required this.selectedBirthDay, required this.onSelectAge, required this.onSelectBirthday, required this.onContinue, required this.onBack, required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: theme.primaryColor, size: 24),
                  onPressed: onBack,
                ),
              ),
            ),
          ),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: isSmallScreen ? 12 : 20),
                  FadeTransition(
                    opacity: fadeAnimation,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: Column(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.howOldAreYou,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 24 : 28,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isSmallScreen ? 6 : 8),
                          Text(
                            AppLocalizations.of(context)!.thisHelpsUsPersonalizeExperience,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 32),
                  FadeTransition(
                    opacity: fadeAnimation,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: Column(
                        children: [
                          ImprovedAgeSelector(
                        selectedAge: selectedAge,
                            onSelect: onSelectAge,
                          ),
                          SizedBox(height: isSmallScreen ? 20 : 24),
                          // Birthday selection
                          Text(
                            AppLocalizations.of(context)!.selectBirthday,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          Row(
                            children: [
                              // Month picker
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.month,
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 12 : 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: isSmallScreen ? 6 : 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: isSmallScreen ? 8 : 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[300]!),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: DropdownButton<int>(
                                        value: selectedBirthMonth,
                                        hint: Text('Month'),
                                        isExpanded: true,
                                        underline: SizedBox(),
                                        items: List.generate(12, (index) {
                                          final month = index + 1;
                                          final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                                          return DropdownMenuItem(
                                            value: month,
                                            child: Text(monthNames[index]),
                                          );
                                        }),
                                        onChanged: (month) {
                                          if (month != null) {
                                            onSelectBirthday(month, selectedBirthDay ?? 1);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              // Day picker
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.day,
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 12 : 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: isSmallScreen ? 6 : 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: isSmallScreen ? 8 : 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[300]!),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: DropdownButton<int>(
                                        value: selectedBirthDay,
                                        hint: Text('Day'),
                                        isExpanded: true,
                                        underline: SizedBox(),
                                        items: List.generate(31, (index) {
                                          final day = index + 1;
                                          return DropdownMenuItem(
                                            value: day,
                                            child: Text(day.toString()),
                                          );
                                        }),
                                        onChanged: (day) {
                                          if (day != null) {
                                            onSelectBirthday(selectedBirthMonth ?? 1, day);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 20), // Bottom padding for scroll
                ],
              ),
            ),
          ),
          // Continue button always visible at bottom
          SafeArea(
            child: Container(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: Text(AppLocalizations.of(context)!.continueButton),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeightStep extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final bool useMetric;
  final double? heightCm;
  final int heightFeet;
  final int heightInches;
  final void Function(bool) onUnitToggle;
  final void Function(double) onSelectCm;
  final void Function(int, int) onSelectFtIn;
  final VoidCallback? onContinue;
  final VoidCallback onBack;
  _HeightStep({required this.fadeAnimation, required this.slideAnimation, required this.useMetric, required this.heightCm, required this.heightFeet, required this.heightInches, required this.onUnitToggle, required this.onSelectCm, required this.onSelectFtIn, required this.onContinue, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double sliderMinCm = 100;
    final double sliderMaxCm = 220;
    final int sliderMinIn = 36;
    final int sliderMaxIn = 87;
    final double sliderHeight = 64;
    final double valueFontSize = 44;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.primaryColor, size: 28),
              onPressed: onBack,
            ),
          ),
        ),
        SizedBox(height: 32),
        FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.yourHeight,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => onUnitToggle(true),
                      child: Container(
                        decoration: BoxDecoration(
                          color: useMetric ? theme.primaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: theme.primaryColor, width: 2),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                        child: Text(AppLocalizations.of(context)!.cm, style: TextStyle(color: useMetric ? Colors.white : theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 20)),
                      ),
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => onUnitToggle(false),
                      child: Container(
                        decoration: BoxDecoration(
                          color: !useMetric ? theme.primaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: theme.primaryColor, width: 2),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                        child: Text(AppLocalizations.of(context)!.ft, style: TextStyle(color: !useMetric ? Colors.white : theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 20)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 36),
        // Consistent vertical space for both units
        SizedBox(
          height: 180,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Large slider
                SizedBox(
                  height: sliderHeight,
                  child: useMetric
                      ? _BigSliderCm(
                          value: heightCm ?? 170,
                          min: sliderMinCm,
                          max: sliderMaxCm,
                          onChanged: onSelectCm,
                        )
                      : _BigSliderFtIn(
                          feet: heightFeet,
                          inches: heightInches,
                          minInches: sliderMinIn,
                          maxInches: sliderMaxIn,
                          onChanged: onSelectFtIn,
                        ),
                ),
                SizedBox(height: 18),
                // Animated value display
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: FadeTransition(opacity: anim, child: child)),
                  child: useMetric
                      ? Text(
                          heightCm != null ? '${heightCm!.toStringAsFixed(1)} cm' : '',
                          key: ValueKey('cm-${heightCm?.toStringAsFixed(1)}'),
                          style: TextStyle(fontSize: valueFontSize, fontWeight: FontWeight.bold, color: Colors.black),
                        )
                      : Text(
                          '${heightFeet}’${heightInches}” ft',
                          key: ValueKey('ft-${heightFeet}-${heightInches}'),
                          style: TextStyle(fontSize: valueFontSize, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                ),
              ],
            ),
          ),
        ),
        Spacer(),
        // Large value at the bottom
        if (heightCm != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              useMetric
                  ? '${heightCm!.toStringAsFixed(1)} cm'
                  : '${heightFeet}’${heightInches}” ft',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: Text(AppLocalizations.of(context)!.continueButton),
          ),
        ),
      ],
    );
  }
}

class _BigSliderCm extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final void Function(double) onChanged;
  const _BigSliderCm({required this.value, required this.min, required this.max, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 8,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 18),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 28),
        activeTrackColor: Theme.of(context).primaryColor,
        inactiveTrackColor: Colors.grey[200],
        thumbColor: Theme.of(context).primaryColor,
      ),
      child: Slider(
        min: min,
        max: max,
        divisions: (max - min).toInt(),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _BigSliderFtIn extends StatelessWidget {
  final int feet;
  final int inches;
  final int minInches;
  final int maxInches;
  final void Function(int, int) onChanged;
  const _BigSliderFtIn({required this.feet, required this.inches, required this.minInches, required this.maxInches, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    int totalInches = feet * 12 + inches;
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 8,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 18),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 28),
        activeTrackColor: Theme.of(context).primaryColor,
        inactiveTrackColor: Colors.grey[200],
        thumbColor: Theme.of(context).primaryColor,
      ),
      child: Slider(
        min: minInches.toDouble(),
        max: maxInches.toDouble(),
        divisions: maxInches - minInches,
        value: totalInches.toDouble(),
        onChanged: (v) {
          int ti = v.round();
          int f = ti ~/ 12;
          int i = ti % 12;
          onChanged(f, i);
        },
      ),
    );
  }
}

class _WeightStep extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final bool useMetric;
  final double? weightKg;
  final double weightLb;
  final void Function(bool) onUnitToggle;
  final void Function(double) onSelectKg;
  final void Function(double) onSelectLb;
  final double? heightCm;
  final VoidCallback? onContinue;
  final VoidCallback onBack;
  _WeightStep({required this.fadeAnimation, required this.slideAnimation, required this.useMetric, required this.weightKg, required this.weightLb, required this.onUnitToggle, required this.onSelectKg, required this.onSelectLb, required this.heightCm, required this.onContinue, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double sliderMinKg = 30;
    final double sliderMaxKg = 200;
    final double sliderMinLb = 66;
    final double sliderMaxLb = 440;
    final double sliderHeight = 64;
    final double valueFontSize = 44;
    // Calculate BMI if possible
    double? bmi;
    if (heightCm != null && weightKg != null) {
      final heightM = heightCm! / 100.0;
      bmi = weightKg! / (heightM * heightM);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.primaryColor, size: 28),
              onPressed: onBack,
            ),
          ),
        ),
        SizedBox(height: 32),
        FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.yourCurrentWeight,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => onUnitToggle(true),
                      child: Container(
                        decoration: BoxDecoration(
                          color: useMetric ? theme.primaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: theme.primaryColor, width: 2),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                        child: Text(AppLocalizations.of(context)!.kg, style: TextStyle(color: useMetric ? Colors.white : theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 20)),
                      ),
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => onUnitToggle(false),
                      child: Container(
                        decoration: BoxDecoration(
                          color: !useMetric ? theme.primaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: theme.primaryColor, width: 2),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                        child: Text(AppLocalizations.of(context)!.lbs, style: TextStyle(color: !useMetric ? Colors.white : theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 20)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 36),
        SizedBox(
          height: 180,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Large slider
                SizedBox(
                  height: sliderHeight,
                  child: useMetric
                      ? _BigSliderWeightKg(
                          value: weightKg ?? 70,
                          min: sliderMinKg,
                          max: sliderMaxKg,
                          onChanged: onSelectKg,
                        )
                      : _BigSliderWeightLb(
                          value: weightLb,
                          min: sliderMinLb,
                          max: sliderMaxLb,
                          onChanged: onSelectLb,
                        ),
                ),
                SizedBox(height: 18),
                // Animated value display
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: FadeTransition(opacity: anim, child: child)),
                  child: useMetric
                      ? Text(
                          weightKg != null ? '${weightKg!.toStringAsFixed(1)} kg' : '',
                          key: ValueKey('kg-${weightKg?.toStringAsFixed(1)}'),
                          style: TextStyle(fontSize: valueFontSize, fontWeight: FontWeight.bold, color: Colors.black),
                        )
                      : Text(
                          '${weightLb.toStringAsFixed(1)} lbs',
                          key: ValueKey('lb-${weightLb.toStringAsFixed(1)}'),
                          style: TextStyle(fontSize: valueFontSize, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                ),
              ],
            ),
          ),
        ),
        Spacer(),
        // BMI display at bottom like height step
        if (bmi != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                Text(AppLocalizations.of(context)!.yourBMI, style: TextStyle(fontSize: 18, color: Colors.black)),
                SizedBox(height: 4),
                Text(bmi.toStringAsFixed(1), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: bmiColor(bmi))),
              ],
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: Text(AppLocalizations.of(context)!.continueButton),
          ),
        ),
      ],
    );
  }

  Color bmiColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }
}

class _BigSliderWeightKg extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final void Function(double) onChanged;
  const _BigSliderWeightKg({required this.value, required this.min, required this.max, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 8,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 18),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 28),
        activeTrackColor: Theme.of(context).primaryColor,
        inactiveTrackColor: Colors.grey[200],
        thumbColor: Theme.of(context).primaryColor,
      ),
      child: Slider(
        min: min,
        max: max,
        divisions: (max - min).toInt(),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _BigSliderWeightLb extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final void Function(double) onChanged;
  const _BigSliderWeightLb({required this.value, required this.min, required this.max, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 8,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 18),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 28),
        activeTrackColor: Theme.of(context).primaryColor,
        inactiveTrackColor: Colors.grey[200],
        thumbColor: Theme.of(context).primaryColor,
      ),
      child: Slider(
        min: min,
        max: max,
        divisions: (max - min).toInt(),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _GoalWeightStep extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final bool useMetricWeight;
  final double goalWeightKg;
  final void Function(double) onGoalWeightChanged;
  final VoidCallback? onContinue;
  final VoidCallback onBack;
  final String? selectedGoal;
  final double currentWeightKg;

  const _GoalWeightStep({
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.useMetricWeight,
    required this.goalWeightKg,
    required this.onGoalWeightChanged,
    required this.onContinue,
    required this.onBack,
    required this.selectedGoal,
    required this.currentWeightKg,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double sliderMinKg = 30;
    final double sliderMaxKg = 200;
    final double sliderMinLb = 66;
    final double sliderMaxLb = 440;
    final double sliderHeight = 64;
    final double valueFontSize = 44;
    final double currentWeightDisplay = useMetricWeight ? currentWeightKg : currentWeightKg * 2.20462;
    final String weightUnit = useMetricWeight ? 'kg' : 'lbs';

    // Determine slider min, max, and initial based on goal
    double min, max, initial;
    if (selectedGoal == 'Lose body weight') {
      min = useMetricWeight ? 30 : 66;
      max = currentWeightDisplay;
      initial = currentWeightDisplay;
    } else if (selectedGoal == 'Gain weight') {
      min = currentWeightDisplay;
      max = useMetricWeight ? 200 : 440;
      initial = currentWeightDisplay;
    } else if (selectedGoal == 'Build muscle' || selectedGoal == 'Eat healthier') {
      // For build muscle and eat healthier, set target to current weight by default
      min = currentWeightDisplay;
      max = currentWeightDisplay;
      initial = currentWeightDisplay;
      // Set the target weight to current weight when the widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onGoalWeightChanged(currentWeightKg);
      });
    } else {
      min = useMetricWeight ? 30 : 66;
      max = useMetricWeight ? 200 : 440;
      initial = currentWeightDisplay;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.primaryColor, size: 28),
              onPressed: onBack,
            ),
          ),
        ),
        SizedBox(height: 32),
        FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.yourGoalWeight,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 18),
                Text(
                  (selectedGoal == 'Build muscle' || selectedGoal == 'Eat healthier')
                      ? AppLocalizations.of(context)!.targetWeightSetToCurrent
                      : AppLocalizations.of(context)!.setRealisticGoalForJourney,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 36),
        if (selectedGoal != 'Build muscle' && selectedGoal != 'Eat healthier')
          SizedBox(
            height: 180,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Large slider
                  SizedBox(
                    height: sliderHeight,
                    child: Slider(
                      value: useMetricWeight ? goalWeightKg : goalWeightKg * 2.20462,
                      min: min,
                      max: max,
                      divisions: (max - min).toInt(),
                      onChanged: (v) => onGoalWeightChanged(useMetricWeight ? v : v / 2.20462),
                    ),
                  ),
                  SizedBox(height: 18),
                  // Animated value display
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: FadeTransition(opacity: anim, child: child)),
                    child: Text(
                      '${(useMetricWeight ? goalWeightKg : goalWeightKg * 2.20462).toStringAsFixed(1)} $weightUnit',
                      key: ValueKey('goal-${(useMetricWeight ? goalWeightKg : goalWeightKg * 2.20462).toStringAsFixed(1)}'),
                      style: TextStyle(fontSize: valueFontSize, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (selectedGoal == 'Build muscle' || selectedGoal == 'Eat healthier')
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text(
              '${(useMetricWeight ? currentWeightKg : currentWeightKg * 2.20462).toStringAsFixed(1)} $weightUnit',
              style: TextStyle(fontSize: valueFontSize, fontWeight: FontWeight.bold, color: theme.primaryColor),
            ),
          ),
        Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: Text(AppLocalizations.of(context)!.continueButton),
          ),
        ),
      ],
    );
  }
}

class _ActivityLevelStep extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final String? activityLevel;
  final void Function(String) onActivityLevelChanged;
  final VoidCallback? onContinue;
  final VoidCallback onBack;
  _ActivityLevelStep({required this.fadeAnimation, required this.slideAnimation, required this.activityLevel, required this.onActivityLevelChanged, required this.onContinue, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Map<String, dynamic>> activityLevels = [
      {'label': AppLocalizations.of(context)!.sedentary, 'value': 'Sedentary', 'desc': AppLocalizations.of(context)!.littleOrNoExercise, 'icon': Icons.self_improvement},
      {'label': AppLocalizations.of(context)!.lightlyActive, 'value': 'Lightly active', 'desc': AppLocalizations.of(context)!.lightExercise, 'icon': Icons.directions_walk},
      {'label': AppLocalizations.of(context)!.moderatelyActive, 'value': 'Active', 'desc': AppLocalizations.of(context)!.moderateExercise, 'icon': Icons.directions_run},
      {'label': AppLocalizations.of(context)!.veryActive, 'value': 'Very active', 'desc': AppLocalizations.of(context)!.hardExercise, 'icon': Icons.fitness_center},
    ];
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.primaryColor, size: 28),
              onPressed: onBack,
            ),
          ),
        ),
        SizedBox(height: 32),
        FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.yourActivityLevel,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 18),
                Text(
                  AppLocalizations.of(context)!.thisHelpsUsPersonalizeYourPlan,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 36),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
            itemCount: activityLevels.length,
            itemBuilder: (context, i) {
              final level = activityLevels[i];
              final isSelected = activityLevel == level['value']; // Compare with stored English value
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: GestureDetector(
                  onTap: () => onActivityLevelChanged(level['value']), // Store English value
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isSelected ? theme.primaryColor.withOpacity(0.08) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? theme.primaryColor : Colors.grey[200]!,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(14),
                          child: Icon(level['icon'], color: theme.primaryColor, size: 28),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(level['label'], style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: isSelected ? theme.primaryColor : Colors.black)),
                              SizedBox(height: 6),
                              Text(level['desc'], style: TextStyle(color: Colors.grey[600], fontSize: 15)),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.check, color: theme.primaryColor, size: 20),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
        SafeArea(
          minimum: EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: Text(AppLocalizations.of(context)!.continueButton),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileSummaryStep extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final int age;
  final double weightKg;
  final bool useMetricWeight;
  final double heightCm;
  final double targetWeightKg;
  final void Function(double) onTargetWeightChanged;
  final String? activityLevel;
  final void Function(String) onActivityLevelChanged;
  final VoidCallback? onContinue;
  final VoidCallback onBack;
  final String? bloodType;
  final bool? isDiabetic;
  final String? waterIntake;
  _ProfileSummaryStep({
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.age,
    required this.weightKg,
    required this.useMetricWeight,
    required this.heightCm,
    required this.targetWeightKg,
    required this.onTargetWeightChanged,
    required this.activityLevel,
    required this.onActivityLevelChanged,
    required this.onContinue,
    required this.onBack,
    this.bloodType,
    this.isDiabetic,
    this.waterIntake,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double heightM = heightCm / 100.0;
    final double bmi = weightKg / (heightM * heightM);
    final String bmiLabel = bmi < 18.5 ? AppLocalizations.of(context)!.underweight : bmi < 25 ? AppLocalizations.of(context)!.healthy : bmi < 30 ? AppLocalizations.of(context)!.overweight : AppLocalizations.of(context)!.obese;
    final Color bmiColor = bmi < 18.5 ? Colors.blue : bmi < 25 ? Colors.green : bmi < 30 ? Colors.orange : Colors.red;
    final double weightDisplay = useMetricWeight ? weightKg : weightKg * 2.20462;
    final double targetWeightDisplay = useMetricWeight ? targetWeightKg : targetWeightKg * 2.20462;
    final String weightUnit = useMetricWeight ? 'kg' : 'lbs';
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    
    return Column(
      children: [
        // Back button
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.primaryColor, size: 28),
              onPressed: onBack,
            ),
          ),
        ),
        SizedBox(height: 24),
        
        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            child: FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.yourFitnessProfileDueToYourAnswers,
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: isSmallScreen ? 22 : 26
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 18),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
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
                              Text(AppLocalizations.of(context)!.currentBMI, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                              SizedBox(width: 10),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: bmiColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(bmiLabel, style: TextStyle(color: bmiColor, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(bmi.toStringAsFixed(1), style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: bmiColor)),
                              SizedBox(width: 10),
                              Text(AppLocalizations.of(context)!.bmi, style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                            ],
                          ),
                          SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: (bmi / 40).clamp(0.0, 1.0),
                            backgroundColor: Colors.grey[200],
                            color: bmiColor,
                            minHeight: 8,
                          ),
                          SizedBox(height: 18),
                          Row(
                            children: [
                              Icon(Icons.cake, color: theme.primaryColor),
                              SizedBox(width: 6),
                              Text('${AppLocalizations.of(context)!.age}: ', style: TextStyle(fontWeight: FontWeight.w600)),
                              Text('$age', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.monitor_weight, color: theme.primaryColor),
                              SizedBox(width: 6),
                              Text('${AppLocalizations.of(context)!.weight}: ', style: TextStyle(fontWeight: FontWeight.w600)),
                              Text('${weightDisplay.toStringAsFixed(1)} $weightUnit', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.flag, color: theme.primaryColor),
                              SizedBox(width: 6),
                              Text('${AppLocalizations.of(context)!.targetWeight}: ', style: TextStyle(fontWeight: FontWeight.w600)),
                              Text('${targetWeightDisplay.toStringAsFixed(1)} $weightUnit', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.directions_run, color: theme.primaryColor),
                              SizedBox(width: 6),
                              Text('${AppLocalizations.of(context)!.activityLevelLabel}: ', style: TextStyle(fontWeight: FontWeight.w600)),
                              Text(activityLevel ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.bloodtype, color: theme.primaryColor),
                              SizedBox(width: 6),
                              Text('${AppLocalizations.of(context)!.bloodTypeLabel}: ', style: TextStyle(fontWeight: FontWeight.w600)),
                              Text(bloodType ?? '-', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: theme.primaryColor),
                              SizedBox(width: 6),
                              Text('${AppLocalizations.of(context)!.diabetic}: ', style: TextStyle(fontWeight: FontWeight.w600)),
                              Text(isDiabetic == null ? '-' : (isDiabetic! ? AppLocalizations.of(context)!.yes : AppLocalizations.of(context)!.no), style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.water_drop, color: theme.primaryColor),
                              SizedBox(width: 6),
                              Text(AppLocalizations.of(context)!.waterIntake + ': ', style: TextStyle(fontWeight: FontWeight.w600)),
                              Text(waterIntake ?? '-', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    // References for BMI and guidance (aligned)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.references, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        Expanded(
                      child: Wrap(
                            alignment: WrapAlignment.start,
                            crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          TextButton(
                            onPressed: () => launchUrl(Uri.parse('https://www.cdc.gov/healthyweight/assessing/bmi/index.html'), mode: LaunchMode.externalApplication),
                            child: Text(AppLocalizations.of(context)!.cdcAboutBmi),
                          ),
                          TextButton(
                            onPressed: () => launchUrl(Uri.parse('https://www.dietaryguidelines.gov/'), mode: LaunchMode.externalApplication),
                            child: Text(AppLocalizations.of(context)!.usdaDietaryGuidelines),
                          ),
                        ],
                      ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Continue button in SafeArea
        SafeArea(
          minimum: EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 16 : 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
                textStyle: TextStyle(fontSize: isSmallScreen ? 16 : 18, fontWeight: FontWeight.bold),
              ),
              child: Text(AppLocalizations.of(context)!.continueButton),
            ),
          ),
        ),
      ],
    );
  }
}

class _NutritionPlanSummaryStep extends StatefulWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final int calories;
  final int protein;
  final int fat;
  final int carbs;
  final VoidCallback onFinish;
  final VoidCallback onBack;
  _NutritionPlanSummaryStep({required this.fadeAnimation, required this.slideAnimation, required this.calories, required this.protein, required this.fat, required this.carbs, required this.onFinish, required this.onBack});

  @override
  State<_NutritionPlanSummaryStep> createState() => _NutritionPlanSummaryStepState();
}

class _NutritionPlanSummaryStepState extends State<_NutritionPlanSummaryStep> with SingleTickerProviderStateMixin {
  bool _showConfetti = true;
  double _confettiOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Fade in
    Future.delayed(Duration(milliseconds: 50), () {
      if (mounted) setState(() => _confettiOpacity = 1.0);
    });
    // Fade out after 2.1s, then hide after 2.5s
    Future.delayed(Duration(milliseconds: 2100), () {
      if (mounted) setState(() => _confettiOpacity = 0.0);
    });
    Future.delayed(Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _showConfetti = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Container(
          color: Color(0xFFF8F9FA),
          width: double.infinity,
          height: double.infinity,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            margin: EdgeInsets.only(top: 8, left: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back, color: theme.primaryColor, size: 28),
                              onPressed: widget.onBack,
                            ),
                          ),
                        ),
                        SizedBox(height: 36),
                        Text(
                          AppLocalizations.of(context)!.yourAllSet,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: theme.primaryColor, letterSpacing: -1.2),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            AppLocalizations.of(context)!.heresYourPersonalizedNutritionPlan,
                            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 36),
                        Center(
                          child: Container(
                            width: 360,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.07),
                                  blurRadius: 18,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(vertical: 36, horizontal: 28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _NutritionRow(
                                  icon: Icons.local_fire_department,
                                  label: AppLocalizations.of(context)!.calories,
                                  value: '${widget.calories} kcal',
                                  iconColor: Color(0xFF43A047),
                                ),
                                SizedBox(height: 18),
                                _NutritionRow(
                                  icon: Icons.fitness_center,
                                  label: AppLocalizations.of(context)!.protein,
                                  value: '${widget.protein} g',
                                  iconColor: Color(0xFF1976D2),
                                ),
                                SizedBox(height: 18),
                                _NutritionRow(
                                  icon: Icons.opacity,
                                  label: AppLocalizations.of(context)!.fat,
                                  value: '${widget.fat} g',
                                  iconColor: Color(0xFFFBC02D),
                                ),
                                SizedBox(height: 18),
                                _NutritionRow(
                                  icon: Icons.grain,
                                  label: AppLocalizations.of(context)!.carbs,
                                  value: '${widget.carbs} g',
                                  iconColor: Color(0xFF8D6E63),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: ElevatedButton(
                      onPressed: widget.onFinish,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 3,
                        textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        shadowColor: theme.primaryColor.withOpacity(0.18),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 26, color: Colors.white),
                          SizedBox(width: 12),
                          Text(AppLocalizations.of(context)!.getStarted),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Confetti overlay
        if (_showConfetti)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: _confettiOpacity,
              duration: Duration(milliseconds: 400),
              child: Container(
                color: Colors.transparent,
                child: Lottie.asset(
                  'assets/animations/confetti.json',
                  repeat: false,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _NutritionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  const _NutritionRow({required this.icon, required this.label, required this.value, required this.iconColor});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          Container(
                decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(12),
            child: Icon(icon, color: iconColor, size: 32),
            ),
          SizedBox(width: 18),
          Text('$label:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
                            SizedBox(width: 8),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: iconColor)),
                          ],
      ),
    );
  }
} 

class _BloodTypeStep extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final String? selectedBloodType;
  final void Function(String) onSelect;
  final VoidCallback? onContinue;
  final VoidCallback onBack;
  _BloodTypeStep({required this.fadeAnimation, required this.slideAnimation, required this.selectedBloodType, required this.onSelect, required this.onContinue, required this.onBack});

  final List<String> bloodTypes = const [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];
  final Map<String, IconData> bloodIcons = const {
    'A+': Icons.bloodtype,
    'A-': Icons.bloodtype,
    'B+': Icons.bloodtype,
    'B-': Icons.bloodtype,
    'AB+': Icons.bloodtype,
    'AB-': Icons.bloodtype,
    'O+': Icons.bloodtype,
    'O-': Icons.bloodtype,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.primaryColor, size: 24),
              onPressed: onBack,
            ),
          ),
        ),
        SizedBox(height: 32),
        Text(AppLocalizations.of(context)!.whatIsYourBloodType, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
        SizedBox(height: 18),
        Text(AppLocalizations.of(context)!.thisHelpsUsPersonalizeExperience, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        SizedBox(height: 32),
        Wrap(
          spacing: 18,
          runSpacing: 18,
          children: bloodTypes.map((type) {
            final isSelected = selectedBloodType == type;
            return GestureDetector(
              onTap: () => onSelect(type),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 28),
                decoration: BoxDecoration(
                  color: isSelected ? theme.primaryColor.withOpacity(0.12) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: isSelected ? theme.primaryColor : Colors.grey[300]!, width: 2),
                  boxShadow: isSelected
                      ? [BoxShadow(color: theme.primaryColor.withOpacity(0.08), blurRadius: 12, offset: Offset(0, 4))]
                      : [],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      bloodIcons[type],
                      color: isSelected ? theme.primaryColor : Color(0xFFFFCDD2), // faded red for unselected
                      size: 36,
                    ),
                    SizedBox(height: 8),
                    Text(type, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: isSelected ? theme.primaryColor : Colors.black)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 36),
              ],
            ),
          ),
        ),
        SafeArea(
          minimum: EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: Text(AppLocalizations.of(context)!.continueButton),
            ),
          ),
        ),
      ],
    );
  }
}

class _DiabeticStep extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final bool? isDiabetic;
  final void Function(bool) onSelect;
  final VoidCallback? onContinue;
  final VoidCallback onBack;
  _DiabeticStep({required this.fadeAnimation, required this.slideAnimation, required this.isDiabetic, required this.onSelect, required this.onContinue, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.primaryColor, size: 24),
              onPressed: onBack,
            ),
          ),
        ),
        SizedBox(height: 32),
        Text(AppLocalizations.of(context)!.areYouDiabetic, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
        SizedBox(height: 18),
        Text(AppLocalizations.of(context)!.thisHelpsUsPersonalizeYourPlan, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _DiabeticOption(
              label: AppLocalizations.of(context)!.yes,
              icon: Icons.check_circle,
              selected: isDiabetic == true,
              color: Colors.green,
              onTap: () => onSelect(true),
            ),
            SizedBox(width: 32),
            _DiabeticOption(
              label: AppLocalizations.of(context)!.no,
              icon: Icons.cancel,
              selected: isDiabetic == false,
              color: Colors.red,
              onTap: () => onSelect(false),
            ),
          ],
        ),
        SizedBox(height: 36),
              ],
            ),
          ),
        ),
        SafeArea(
          minimum: EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: Text(AppLocalizations.of(context)!.continueButton),
            ),
          ),
        ),
      ],
    );
  }
}

class _DiabeticOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _DiabeticOption({required this.label, required this.icon, required this.selected, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 36),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? color : Colors.grey[300]!, width: 2),
          boxShadow: selected
              ? [BoxShadow(color: color.withOpacity(0.08), blurRadius: 12, offset: Offset(0, 4))]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? color : Colors.grey[500], size: 40),
            SizedBox(height: 10),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: selected ? color : Colors.black)),
          ],
        ),
      ),
    );
  }
}

class _WaterIntakeStep extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final String? selectedWaterIntake;
  final bool useMetricHeight;
  final void Function(String) onSelect;
  final VoidCallback? onContinue;
  final VoidCallback onBack;
  _WaterIntakeStep({required this.fadeAnimation, required this.slideAnimation, required this.selectedWaterIntake, required this.useMetricHeight, required this.onSelect, required this.onContinue, required this.onBack});

  List<String> get options {
    // US (ft) uses L, others (cm) use fl oz
    final bool isUS = !useMetricHeight;
    return isUS 
      ? ['0.5L', '1L', '1.5L', '2L', '2.5L', '3L+']
      : ['17 fl oz', '34 fl oz', '51 fl oz', '68 fl oz', '85 fl oz', '102+ fl oz'];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.primaryColor, size: 24),
              onPressed: onBack,
            ),
          ),
        ),
        SizedBox(height: 32),
        Text(
          AppLocalizations.of(context)!.howMuchWaterDaily,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 18),
        Text(
          AppLocalizations.of(context)!.stayingHydratedIsKeyToYourHealth,
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32),
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 18,
            runSpacing: 18,
          children: options.map((opt) {
            final isSelected = selectedWaterIntake == opt;
            return GestureDetector(
              onTap: () => onSelect(opt),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 28),
                decoration: BoxDecoration(
                  color: isSelected ? theme.primaryColor.withOpacity(0.12) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: isSelected ? theme.primaryColor : Colors.grey[300]!, width: 2),
                  boxShadow: isSelected
                      ? [BoxShadow(color: theme.primaryColor.withOpacity(0.08), blurRadius: 12, offset: Offset(0, 4))]
                      : [],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.water_drop, color: isSelected ? theme.primaryColor : Colors.blue[200], size: 36),
                    SizedBox(height: 8),
                    Text(
                      opt,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: isSelected ? theme.primaryColor : Colors.black),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          ),
        ),
        SizedBox(height: 36),
              ],
            ),
          ),
        ),
        SafeArea(
          minimum: EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: Text(AppLocalizations.of(context)!.continueButton),
            ),
          ),
        ),
      ],
    );
  }
}

class _SexStep extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final String? selectedSex;
  final void Function(String) onSelect;
  final VoidCallback? onContinue;
  final VoidCallback onBack;
  _SexStep({
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.selectedSex,
    required this.onSelect,
    required this.onContinue,
    required this.onBack,
  });

  List<Map<String, dynamic>> _getLocalizedSexOptions(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return [
      {'label': localizations.male, 'value': 'Male', 'icon': Icons.male, 'color': Color(0xFF64B5F6)},
      {'label': localizations.female, 'value': 'Female', 'icon': Icons.female, 'color': Color(0xFFFFB6C1)},
      {'label': localizations.other, 'value': 'Other', 'icon': Icons.transgender, 'color': Color(0xFFBA68C8)},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.primaryColor, size: 24),
              onPressed: onBack,
            ),
          ),
        ),
        SizedBox(height: 32),
        FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.whatIsYourSex,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, letterSpacing: -0.5),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 18),
                Text(
                  AppLocalizations.of(context)!.thisHelpsUsPersonalizeNutrition,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 36),
        Expanded(
          child: ListView.builder(
            itemCount: _getLocalizedSexOptions(context).length,
            itemBuilder: (context, i) {
              final opt = _getLocalizedSexOptions(context)[i];
              final isSelected = selectedSex == opt['value']; // Compare with stored English value
              return FadeTransition(
                opacity: fadeAnimation,
                child: SlideTransition(
                  position: slideAnimation,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () => onSelect(opt['value']), // Store English value
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected ? opt['color'].withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? opt['color'] : Colors.grey[200]!,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: opt['color'].withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              padding: EdgeInsets.all(14),
                              child: Icon(opt['icon'], color: opt['color'], size: 28),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                opt['label'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: isSelected ? opt['color'] : Colors.black,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: opt['color'].withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.check, color: opt['color'], size: 20),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 16),
          child: ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.continueButton),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Helper to get current user
Future<User?> getCurrentUser() async {
  return FirebaseAuth.instance.currentUser;
}

class NutritionLoadingAnimation extends StatelessWidget {
  final String message;
  const NutritionLoadingAnimation({this.message = "Creating your plan..."});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/AI Loading spinner..json',
            width: 220,
            height: 220,
            repeat: true,
          ),
          SizedBox(height: 32),
          Text(
            message,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RemindersStep extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final List<String> selectedReminders;
  final void Function(String) onReminderToggle;
  final VoidCallback? onContinue;
  final VoidCallback onBack;
  _RemindersStep({required this.fadeAnimation, required this.slideAnimation, required this.selectedReminders, required this.onReminderToggle, required this.onContinue, required this.onBack});

  // Helper method to get localized reminders list
  List<Map<String, dynamic>> _getLocalizedReminders(BuildContext context) {
    return [
      {'emoji': '🍽️', 'label': AppLocalizations.of(context)!.mealReminders, 'value': 'Meal Logging Prompts'},
      {'emoji': '💧', 'label': AppLocalizations.of(context)!.waterReminders, 'value': 'Water Intake Reminders'},
      {'emoji': '🚶‍♂️', 'label': AppLocalizations.of(context)!.workoutReminders, 'value': 'Mindful Walks Reminders'},
      {'emoji': '🧘‍♀️', 'label': AppLocalizations.of(context)!.momentOfCalmAfterMeals, 'value': 'Moment of Calm After Meals'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizedReminders = _getLocalizedReminders(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.primaryColor, size: 28),
              onPressed: onBack,
            ),
          ),
        ),
        SizedBox(height: 32),
        FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.remindersWouldYouLike,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 18),
              ],
            ),
          ),
        ),
        SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: localizedReminders.length,
            itemBuilder: (context, i) {
              final reminder = localizedReminders[i];
              final isSelected = selectedReminders.contains(reminder['value']); // Check against stored English value
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: GestureDetector(
                  onTap: () => onReminderToggle(reminder['value']), // Store English value
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    padding: EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isSelected ? theme.primaryColor.withOpacity(0.08) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? theme.primaryColor : Colors.grey[200]!,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(reminder['emoji'], style: TextStyle(fontSize: 28)),
                        SizedBox(width: 18),
                        Expanded(
                          child: Text(reminder['label'], style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: isSelected ? theme.primaryColor : Colors.black)),
                        ),
                        if (isSelected)
                          Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.check, color: theme.primaryColor, size: 20),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SafeArea(
          minimum: EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: Text(AppLocalizations.of(context)!.continueButton),
            ),
          ),
        ),
      ],
    );
  }
}