import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';

class NewPlanDisplay extends StatefulWidget {
  final Map<String, dynamic> planData;
  final VoidCallback onComplete;
  final VoidCallback? onDecline;
  final bool fromNutritionalPlan;

  const NewPlanDisplay({
    Key? key,
    required this.planData,
    required this.onComplete,
    this.onDecline,
    this.fromNutritionalPlan = false,
  }) : super(key: key);

  @override
  State<NewPlanDisplay> createState() => _NewPlanDisplayState();
}

class _NewPlanDisplayState extends State<NewPlanDisplay> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Start animation
    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400 || screenSize.height < 700;

    return WillPopScope(
      onWillPop: () async => widget.fromNutritionalPlan, // Allow back if from nutritional plan
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: widget.fromNutritionalPlan ? AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ) : null,
        body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
          child: Column(
            children: [
              Expanded(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Success icon
                      Container(
                        width: isSmallScreen ? 100 : 120,
                        height: isSmallScreen ? 100 : 120,
                        decoration: BoxDecoration(
                          color: kPrimaryGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          size: isSmallScreen ? 50 : 60,
                          color: kPrimaryGreen,
                        ),
                      ),
                      
                      SizedBox(height: isSmallScreen ? 24 : 32),
                      
                      // Title
                      Text(
                        AppLocalizations.of(context)!.yourNewPlanReady,
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
                        AppLocalizations.of(context)!.heresYourPersonalizedNutritionPlan,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      SizedBox(height: isSmallScreen ? 32 : 40),
                      
                      // Plan details
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                        decoration: BoxDecoration(
                          color: kPrimaryGreen.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: kPrimaryGreen.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            _buildPlanRow(
                              AppLocalizations.of(context)!.caloriesGoal,
                              '${widget.planData['calories']} kcal',
                              Icons.local_fire_department,
                              isSmallScreen,
                            ),
                            SizedBox(height: 16),
                            _buildPlanRow(
                              AppLocalizations.of(context)!.proteinGoal,
                              '${widget.planData['protein']}g',
                              Icons.fitness_center,
                              isSmallScreen,
                            ),
                            SizedBox(height: 16),
                            _buildPlanRow(
                              AppLocalizations.of(context)!.carbsGoal,
                              '${widget.planData['carbs']}g',
                              Icons.grain,
                              isSmallScreen,
                            ),
                            SizedBox(height: 16),
                            _buildPlanRow(
                              AppLocalizations.of(context)!.fatGoal,
                              '${widget.planData['fat']}g',
                              Icons.opacity,
                              isSmallScreen,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Buttons section
              if (widget.fromNutritionalPlan && widget.onDecline != null) ...[
                // Accept button
                SizedBox(
                  width: double.infinity,
                  height: isSmallScreen ? 48 : 56,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : _savePlanAndComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: kPrimaryGreen.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isSaving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.startWithNewPlan,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 12),
                // Decline button
                SizedBox(
                  width: double.infinity,
                  height: isSmallScreen ? 48 : 56,
                  child: OutlinedButton(
                    onPressed: isSaving ? null : widget.onDecline,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.decline,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Single start button (original behavior)
                SizedBox(
                  width: double.infinity,
                  height: isSmallScreen ? 48 : 56,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : _savePlanAndComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: kPrimaryGreen.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isSaving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.startWithNewPlan,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildPlanRow(String label, String value, IconData icon, bool isSmallScreen) {
    return Row(
      children: [
        Container(
          width: isSmallScreen ? 40 : 48,
          height: isSmallScreen ? 40 : 48,
          decoration: BoxDecoration(
            color: kPrimaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: isSmallScreen ? 20 : 24,
            color: kPrimaryGreen,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: kPrimaryGreen,
          ),
        ),
      ],
    );
  }

  Future<void> _savePlanAndComplete() async {
    setState(() {
      isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final updateData = {
          'dailyCalorieGoal': widget.planData['calories'],
          'proteinGoal': widget.planData['protein'],
          'carbsGoal': widget.planData['carbs'],
          'fatGoal': widget.planData['fat'],
          'lastUpdated': FieldValue.serverTimestamp(),
          'goal': widget.planData['goal'] ?? 'Maintain body weight', // Save the fitness goal
          'nutritionalPlanType': widget.planData['goal']?.toLowerCase().replaceAll(' ', '_') ?? 'maintenance',
        };
        
        // Update target weight if provided
        if (widget.planData['targetWeight'] != null) {
          updateData['targetWeight'] = widget.planData['targetWeight'];
          updateData['hasReachedGoal'] = false; // Reset goal achievement if new target set
        }
        
        // Also clear celebration flags
        updateData['needsCelebrationFlow'] = false;
        
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update(updateData);
        
        // Clear SharedPreferences flag
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('needs_goal_celebration', false);
        
        widget.onComplete();
      }
    } catch (e) {
      setState(() {
        isSaving = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.failedToGenerateMaintenancePlan),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
