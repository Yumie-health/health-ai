import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';
import '../services/ai_service.dart';
import '../providers/preferences_provider.dart';

class GoalChangeFlow extends StatefulWidget {
  final Function(Map<String, dynamic>) onPlanGenerated;
  final VoidCallback? onCancel;
  final VoidCallback? onBackToMaintenancePlan; // For celebration flow

  const GoalChangeFlow({
    Key? key,
    required this.onPlanGenerated,
    this.onCancel,
    this.onBackToMaintenancePlan,
  }) : super(key: key);

  @override
  State<GoalChangeFlow> createState() => _GoalChangeFlowState();
}

class _GoalChangeFlowState extends State<GoalChangeFlow> {
  int currentStep = 0;
  String? selectedGoal;
  double? targetWeight;
  bool isGenerating = false;

  final List<Map<String, dynamic>> goals = [
    {'id': 'Lose body weight', 'icon': '📉', 'needsWeight': true},
    {'id': 'Gain weight', 'icon': '📈', 'needsWeight': true},
    {'id': 'Build muscle', 'icon': '💪', 'needsWeight': false},
    {'id': 'Maintain body weight', 'icon': '⚖️', 'needsWeight': false},
    {'id': 'Eat healthier', 'icon': '🥗', 'needsWeight': false},
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400 || screenSize.height < 700;

    return WillPopScope(
      onWillPop: () async => false, // Prevent back button dismissal
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              // If from celebration popup, go back to maintenance plan choice
              if (widget.onBackToMaintenancePlan != null) {
                widget.onBackToMaintenancePlan!();
              } else if (widget.onCancel != null) {
                widget.onCancel!();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: isGenerating ? _buildGeneratingView(isSmallScreen) : _buildStepView(isSmallScreen),
      ),
    );
  }

  Widget _buildStepView(bool isSmallScreen) {
    if (currentStep == 0) {
      return _buildGoalSelectionStep(isSmallScreen);
    } else if (currentStep == 1) {
      return _buildTargetWeightStep(isSmallScreen);
    }
    return Container();
  }

  Widget _buildGoalSelectionStep(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  AppLocalizations.of(context)!.whatsYourNewGoal,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryGreen,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: isSmallScreen ? 8 : 12),
                
                // Subtitle
                Text(
                  AppLocalizations.of(context)!.chooseGoalDescription,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: isSmallScreen ? 32 : 40),
                
                // Goal options
                ...(
                  (widget.onBackToMaintenancePlan != null
                    ? goals.where((g)=> g['id'] != 'Maintain body weight')
                    : goals)
                ).map((goal) => Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: _buildGoalOption(goal, isSmallScreen),
                )).toList(),
              ],
            ),
          ),
          
          // Continue button
          SizedBox(
            width: double.infinity,
            height: isSmallScreen ? 48 : 56,
            child: ElevatedButton(
              onPressed: selectedGoal != null ? _handleGoalContinue : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryGreen,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.continueButton,
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalOption(Map<String, dynamic> goal, bool isSmallScreen) {
    final isSelected = selectedGoal == goal['id'];
    String goalText;
    
    switch (goal['id']) {
      case 'Lose body weight':
        goalText = AppLocalizations.of(context)!.loseBodyWeight;
        break;
      case 'Gain weight':
        goalText = AppLocalizations.of(context)!.gainWeight;
        break;
      case 'Build muscle':
        goalText = AppLocalizations.of(context)!.buildMuscle;
        break;
      case 'Maintain body weight':
        goalText = AppLocalizations.of(context)!.maintainBodyWeight;
        break;
      case 'Eat healthier':
        goalText = AppLocalizations.of(context)!.eatHealthier;
        break;
      default:
        goalText = goal['id'];
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGoal = goal['id'];
        });
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryGreen.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? kPrimaryGreen : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: isSmallScreen ? 40 : 48,
              height: isSmallScreen ? 40 : 48,
              decoration: BoxDecoration(
                color: isSelected ? kPrimaryGreen : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  goal['icon'],
                  style: TextStyle(fontSize: isSmallScreen ? 20 : 24),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                goalText,
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? kPrimaryGreen : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: kPrimaryGreen,
                size: isSmallScreen ? 20 : 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetWeightStep(bool isSmallScreen) {
    // Fetch current weight to bound the slider appropriately
    // We keep it simple by reading from Firestore snapshot used in _generateNewPlan path
    // but here we pass bounds dynamically based on selectedGoal and a cached current weight.
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  AppLocalizations.of(context)!.whatsYourNewTargetWeight,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryGreen,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: isSmallScreen ? 8 : 12),
                
                // Subtitle
                Text(
                  AppLocalizations.of(context)!.setRealisticGoalForJourney,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: isSmallScreen ? 40 : 48),
                
                // Weight slider input (bound based on goal)
                FutureBuilder<Map<String, dynamic>?>(
                  future: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((d)=>d.data()),
                  builder: (context, snap) {
                    final double currentWeightKg = (snap.data?['weightKg'] ?? snap.data?['weight'] ?? 70.0).toDouble();
                    final bool useMetric = Provider.of<PreferencesProvider>(context).useMetric;
                    final bool isLose = (selectedGoal == 'Lose body weight');
                    
                    // Convert to display units
                    final double currentWeightDisplay = useMetric ? currentWeightKg : (currentWeightKg * 2.20462);
                    final String weightUnit = useMetric ? AppLocalizations.of(context)!.kg : AppLocalizations.of(context)!.poundsUnit;
                    
                    // Set bounds in display units
                    final double minDisplay = isLose ? (useMetric ? 30.0 : 66.0) : currentWeightDisplay;
                    final double maxDisplay = isLose ? currentWeightDisplay : (useMetric ? 300.0 : 660.0);
                    
                    // Initialize target weight in display units
                    final double initialDisplay = targetWeight != null 
                        ? (useMetric ? targetWeight! : (targetWeight! * 2.20462))
                        : currentWeightDisplay;
                    final double targetWeightDisplay = initialDisplay.clamp(minDisplay, maxDisplay);

                    return Container(
                      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.targetWeight,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${targetWeightDisplay.toStringAsFixed(1)} $weightUnit',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 24 : 28,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryGreen,
                            ),
                          ),
                          Slider(
                            value: targetWeightDisplay.clamp(minDisplay, maxDisplay),
                            min: minDisplay,
                            max: maxDisplay,
                            divisions: ((maxDisplay - minDisplay) * (useMetric ? 2 : 1)).round(), // 0.5 kg or 1 lb steps
                            activeColor: kPrimaryGreen,
                            label: targetWeightDisplay.toStringAsFixed(1),
                            onChanged: (v) {
                              setState(() {
                                // Convert back to kg for internal storage
                                targetWeight = useMetric ? v : (v / 2.20462);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Continue button
          SizedBox(
            width: double.infinity,
            height: isSmallScreen ? 48 : 56,
            child: ElevatedButton(
              onPressed: targetWeight != null && targetWeight! > 0 ? _generateNewPlan : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryGreen,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.continueButton,
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratingView(bool isSmallScreen) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Loading animation
            Container(
              width: isSmallScreen ? 80 : 100,
              height: isSmallScreen ? 80 : 100,
              child: CircularProgressIndicator(
                color: kPrimaryGreen,
                strokeWidth: 4,
              ),
            ),
            
            SizedBox(height: isSmallScreen ? 24 : 32),
            
            // Loading text
            Text(
              AppLocalizations.of(context)!.yumieGeneratingNewPlan,
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.w600,
                color: kPrimaryGreen,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: isSmallScreen ? 8 : 12),
            
            Text(
              AppLocalizations.of(context)!.pleaseWait,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleGoalContinue() {
    final goal = goals.firstWhere((g) => g['id'] == selectedGoal);
    if (goal['needsWeight'] == true) {
      setState(() {
        currentStep = 1;
      });
    } else {
      _generateNewPlan();
    }
  }

  Future<void> _generateNewPlan() async {
    setState(() {
      isGenerating = true;
    });

    try {
      // Get current user data from Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final data = doc.data() ?? {};
        
        // Get user data - handle both old and new field names
        final int age = data['age'] ?? 25;
        final double height = (data['heightCm'] ?? data['height'] ?? 170.0).toDouble();
        final double currentWeight = (data['weightKg'] ?? data['weight'] ?? 70.0).toDouble();
        final String activityLevel = data['activityLevel'] ?? 'Moderately Active';
        final String bloodType = data['bloodType'] ?? 'O+';
        final bool isDiabetic = data['isDiabetic'] ?? false;
        final String sex = data['sex'] ?? 'Other';
        
        // Use target weight if provided, otherwise current weight
        final double planWeight = targetWeight ?? currentWeight;
        
        // Calculate BMR using Mifflin-St Jeor equation
        double bmr;
        if (sex.toLowerCase() == 'male') {
          bmr = 10 * planWeight + 6.25 * height - 5 * age + 5;
        } else {
          bmr = 10 * planWeight + 6.25 * height - 5 * age - 161;
        }
        
        // Apply activity multiplier
        double tdee = bmr;
        switch (activityLevel.toLowerCase()) {
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
        switch (selectedGoal?.toLowerCase()) {
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
        if (selectedGoal?.toLowerCase() == 'build muscle') {
          proteinGoal = (planWeight * 2.2).round(); // Higher protein for muscle building
        } else {
          proteinGoal = (planWeight * 1.6).round(); // Standard protein
        }
        
        int fatGoal = (calorieGoal * 0.25 / 9).round(); // 25% of calories from fat
        int carbsGoal = ((calorieGoal - (proteinGoal * 4) - (fatGoal * 9)) / 4).round(); // Remaining calories from carbs
        
        // Get AI recommendation
        final aiService = AIService();
        final aiPlan = await aiService.getNutritionPlanRecommendation(
          age: age,
          heightCm: height.round(),
          weightKg: planWeight,
          calorieGoal: calorieGoal,
          proteinGoal: proteinGoal,
          carbsGoal: carbsGoal,
          fatGoal: fatGoal,
          bloodType: bloodType,
          isDiabetic: isDiabetic,
        );
        
        // Save current plan as previous plan before updating
        final currentPlanData = {
          'startDate': data['lastUpdated'] is Timestamp
              ? data['lastUpdated']
              : Timestamp.now(),
          'endDate': Timestamp.now(),
          'startingWeight': data['startingWeight'] ?? currentWeight,
          'targetWeight': data['targetWeightKg'] ?? data['targetWeight'] ?? currentWeight,
          'goal': data['goal'] ?? 'Maintain body weight',
          'dailyCalorieGoal': data['dailyCalorieGoal'],
          'proteinGoal': data['proteinGoal'],
          'carbsGoal': data['carbsGoal'],
          'fatGoal': data['fatGoal'],
          'status': 'changed', // Manual goal change
        };

        // Add to previous plans array
        final previousPlans = List<Map<String, dynamic>>.from(data['previousPlans'] ?? []);
        // Deduplicate entries to avoid both changed & completed duplicates
        final double swNew = (currentPlanData['startingWeight'] as num?)?.toDouble() ?? 0.0;
        final double twNew = (currentPlanData['targetWeight'] as num?)?.toDouble() ?? 0.0;
        final String goalNew = currentPlanData['goal'] ?? '';
        final bool alreadyExists = previousPlans.any((p) {
          final double sw = (p['startingWeight'] as num?)?.toDouble() ?? -9999;
          final double tw = (p['targetWeight'] as num?)?.toDouble() ?? -9999;
          final String g = p['goal'] ?? '';
          final String st = p['status'] ?? '';
          return st == 'changed' && g == goalNew && (sw - swNew).abs() < 0.001 && (tw - twNew).abs() < 0.001;
        });
        if (!alreadyExists) {
          previousPlans.add(currentPlanData);
        }

        // Prepare plan data
        final planData = {
          'calories': calorieGoal,
          'protein': proteinGoal,
          'carbs': carbsGoal,
          'fat': fatGoal,
          'goal': selectedGoal,
          'targetWeight': targetWeight,
          'ai_plan': aiPlan?['ai_plan'],
          'previousPlans': previousPlans, // Include previous plans in the new plan data
        };
        
        // Ensure minimum loading time for better UX
        await Future.delayed(Duration(seconds: 3));
        
        widget.onPlanGenerated(planData);
      }
    } catch (e) {
      setState(() {
        isGenerating = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.failedToGeneratePlan),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
