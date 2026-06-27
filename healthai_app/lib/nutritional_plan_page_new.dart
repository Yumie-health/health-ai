import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'providers/preferences_provider.dart';
import 'utils/constants.dart';
import 'widgets/goal_change_flow.dart';
import 'widgets/new_plan_display.dart';

class NutritionalPlanPage extends StatefulWidget {
  @override
  _NutritionalPlanPageState createState() => _NutritionalPlanPageState();
}

class _NutritionalPlanPageState extends State<NutritionalPlanPage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool canGenerateNewPlan = true;
  int plansGenerated = 0;
  DateTime? lastPlanGeneration;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkPlanGenerationLimit();
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      setState(() {
        userData = Map<String, dynamic>.from(doc.data() ?? {});
        isLoading = false;
      });
    }
  }

  Future<void> _checkPlanGenerationLimit() async {
    final prefs = await SharedPreferences.getInstance();
    final lastGenString = prefs.getString('last_plan_generation');
    final plansCount = prefs.getInt('plans_generated_count') ?? 0;

    if (lastGenString != null) {
      final lastGen = DateTime.parse(lastGenString);
      final now = DateTime.now();
      final daysSince = now.difference(lastGen).inDays;

      if (daysSince >= 14) {
        // Reset counter after 14 days
        await prefs.setInt('plans_generated_count', 0);
        setState(() {
          plansGenerated = 0;
          canGenerateNewPlan = true;
        });
      } else {
        setState(() {
          plansGenerated = plansCount;
          canGenerateNewPlan = plansCount < 2;
          lastPlanGeneration = lastGen;
        });
      }
    }
  }

  Future<void> _updateField(String field, dynamic value) async {
    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
              field: value,
              'lastUpdated': FieldValue.serverTimestamp(),
            });

        // Reload data to reflect changes
        await _loadUserData();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.profileUpdatedSuccessfully,
            ),
            backgroundColor: kPrimaryGreen,
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorUpdatingProfile),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showGenerateNewPlan() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => GoalChangeFlow(
              onPlanGenerated: (planData) async {
                Navigator.of(context).pop(); // Close goal change flow

                // Update plan generation tracking
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString(
                  'last_plan_generation',
                  DateTime.now().toIso8601String(),
                );
                await prefs.setInt('plans_generated_count', plansGenerated + 1);

                _showNewPlanDisplay(planData);
              },
              onCancel: () {
                Navigator.of(context).pop();
              },
            ),
      ),
    );
  }

  void _showNewPlanDisplay(Map<String, dynamic> planData) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => NewPlanDisplay(
              planData: planData,
              onComplete: () {
                Navigator.of(context).pop(); // Close plan display
                _loadUserData(); // Refresh the page
                _checkPlanGenerationLimit(); // Update generation limits
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.maintenancePlanUpdated,
                    ),
                    backgroundColor: kPrimaryGreen,
                    duration: Duration(seconds: 3),
                  ),
                );
              },
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferencesProvider>(context);
    final useMetric = prefs.useMetric;
    final localizations = AppLocalizations.of(context)!;

    if (isLoading || userData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.nutritionalPlan),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Center(child: CircularProgressIndicator(color: kPrimaryGreen)),
      );
    }

    // Get user data - handle both old and new field names
    final double weight =
        (userData!['weightKg'] ?? userData!['weight'] ?? 70).toDouble();
    final double heightCm =
        (userData!['heightCm'] ?? userData!['height'] ?? 170).toDouble();
    final double targetWeight =
        (userData!['targetWeightKg'] ?? userData!['targetWeight'] ?? weight)
            .toDouble();
    final int age = (userData!['age'] ?? 18).toInt();
    final int calories = userData!['dailyCalorieGoal'] ?? 2000;
    final int protein = userData!['proteinGoal'] ?? 120;
    final int carbs = userData!['carbsGoal'] ?? 250;
    final int fat = userData!['fatGoal'] ?? 70;

    // Get the current plan name
    final String currentPlan = _getLocalizedPlanName(
      userData!['goal'] ?? 'Maintain body weight',
      localizations,
    );

    // Calculate BMI
    final double heightM = heightCm / 100.0;
    final double bmi = weight / (heightM * heightM);

    // Unit conversions
    final double displayWeight = useMetric ? weight : (weight * 2.20462);
    final double displayTargetWeight =
        useMetric ? targetWeight : (targetWeight * 2.20462);
    final String weightUnit = useMetric ? 'kg' : 'lb';

    String heightDisplay;
    if (useMetric) {
      heightDisplay = '${heightCm.toStringAsFixed(1)} cm';
    } else {
      int totalInches = (heightCm * 0.393701).round();
      int feet = totalInches ~/ 12;
      int inches = totalInches % 12;
      heightDisplay = "${feet}'${inches}\"";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.nutritionalPlan),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Summary
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kPrimaryGreen.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kPrimaryGreen.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Text(
                    currentPlan,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProfileStat(
                        localizations.current,
                        '${displayWeight.toStringAsFixed(1)} $weightUnit',
                        Icons.monitor_weight,
                      ),
                      Container(height: 40, width: 1, color: Colors.grey[300]),
                      _buildProfileStat(
                        localizations.targetLabel,
                        '${displayTargetWeight.toStringAsFixed(1)} $weightUnit',
                        Icons.flag,
                      ),
                      Container(height: 40, width: 1, color: Colors.grey[300]),
                      _buildProfileStat(
                        localizations.bmi,
                        bmi.toStringAsFixed(1),
                        Icons.health_and_safety,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Daily Goals Section
            Text(
              localizations.dailyCalorieGoal,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 16),

            // Nutrition Goals Grid
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildNutritionCard(
                  localizations.calories,
                  '$calories',
                  'kcal',
                  Icons.local_fire_department,
                  Colors.orange,
                  () => _showEditDialog(
                    localizations.calorieGoal,
                    'dailyCalorieGoal',
                    calories.toDouble(),
                    1000,
                    5000,
                    'kcal',
                  ),
                ),
                _buildNutritionCard(
                  localizations.protein,
                  '$protein',
                  'g',
                  Icons.fitness_center,
                  Colors.red,
                  () => _showEditDialog(
                    localizations.proteinGoal,
                    'proteinGoal',
                    protein.toDouble(),
                    40,
                    300,
                    'g',
                  ),
                ),
                _buildNutritionCard(
                  localizations.carbs,
                  '$carbs',
                  'g',
                  Icons.grain,
                  Colors.amber,
                  () => _showEditDialog(
                    localizations.carbGoal,
                    'carbsGoal',
                    carbs.toDouble(),
                    40,
                    600,
                    'g',
                  ),
                ),
                _buildNutritionCard(
                  localizations.fat,
                  '$fat',
                  'g',
                  Icons.opacity,
                  Colors.purple,
                  () => _showEditDialog(
                    localizations.fatGoal,
                    'fatGoal',
                    fat.toDouble(),
                    10,
                    200,
                    'g',
                  ),
                ),
              ],
            ),

            SizedBox(height: 32),

            // Generate New Plan Button
            Container(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: canGenerateNewPlan ? _showGenerateNewPlan : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      canGenerateNewPlan ? kPrimaryGreen : Colors.grey[300],
                  foregroundColor:
                      canGenerateNewPlan ? Colors.white : Colors.grey[600],
                  elevation: canGenerateNewPlan ? 2 : 0,
                  shadowColor: kPrimaryGreen.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: Icon(Icons.auto_awesome, size: 24),
                label: Text(
                  localizations.generateNewPlan,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            SizedBox(height: 12),

            // Plan generation info
            if (!canGenerateNewPlan)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.info, color: Colors.orange[700], size: 24),
                    SizedBox(height: 8),
                    Text(
                      localizations.planGenerationLimitReached,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (lastPlanGeneration != null) ...[
                      SizedBox(height: 4),
                      Text(
                        'Next plan available in ${_getDaysUntilReset()} days',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kPrimaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kPrimaryGreen.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb, color: kPrimaryGreen, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You can generate ${2 - plansGenerated} more personalized plans in the next 14 days.',
                        style: TextStyle(fontSize: 12, color: kPrimaryGreen),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: kPrimaryGreen, size: 24),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionCard(
    String label,
    String value,
    String unit,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),
            Icon(Icons.edit, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    String title,
    String field,
    double currentValue,
    double min,
    double max,
    String unit,
  ) {
    double tempValue = currentValue;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text(title),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${tempValue.toStringAsFixed(0)} $unit',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryGreen,
                        ),
                      ),
                      SizedBox(height: 16),
                      Slider(
                        value: tempValue,
                        min: min,
                        max: max,
                        divisions: (max - min).toInt(),
                        activeColor: kPrimaryGreen,
                        onChanged: (value) {
                          setDialogState(() {
                            tempValue = value;
                          });
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _updateField(field, tempValue.round());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryGreen,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(AppLocalizations.of(context)!.save),
                    ),
                  ],
                ),
          ),
    );
  }

  int _getDaysUntilReset() {
    if (lastPlanGeneration == null) return 0;
    final now = DateTime.now();
    final daysSince = now.difference(lastPlanGeneration!).inDays;
    return 14 - daysSince;
  }

  // Helper function to get localized plan name
  String _getLocalizedPlanName(String goal, AppLocalizations localizations) {
    switch (goal.toLowerCase()) {
      case 'lose body weight':
        return localizations.loseBodyWeight;
      case 'gain weight':
        return localizations.gainWeight;
      case 'build muscle':
        return localizations.buildMuscle;
      case 'maintain body weight':
        return localizations.maintainBodyWeight;
      case 'eat healthier':
        return localizations.eatHealthier;
      default:
        return localizations.maintainBodyWeight; // fallback
    }
  }
}
