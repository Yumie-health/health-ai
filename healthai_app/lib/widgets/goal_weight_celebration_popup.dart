import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';

class GoalWeightCelebrationPopup extends StatefulWidget {
  final Map<String, dynamic> maintenancePlan;
  final VoidCallback onKeepPlan;
  final VoidCallback onChooseDifferentGoal;

  const GoalWeightCelebrationPopup({
    Key? key,
    required this.maintenancePlan,
    required this.onKeepPlan,
    required this.onChooseDifferentGoal,
  }) : super(key: key);

  @override
  State<GoalWeightCelebrationPopup> createState() => _GoalWeightCelebrationPopupState();
}

class _GoalWeightCelebrationPopupState extends State<GoalWeightCelebrationPopup>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize confetti controller
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    // Initialize scale animation controller
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Initialize fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Create scale animation
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Create fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
    });
    
    // Start confetti after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400 || screenSize.height < 700;

    return WillPopScope(
      onWillPop: () async => false, // Prevent back button dismissal
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.7),
        body: Stack(
        children: [
          // Confetti animations
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                kPrimaryGreen,
                Colors.orange,
                Colors.blue,
                Colors.purple,
                Colors.red,
                Colors.yellow,
              ],
              numberOfParticles: 50,
              maxBlastForce: 20,
              minBlastForce: 10,
            ),
          ),
          
          // Main content
          FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  margin: EdgeInsets.all(isSmallScreen ? 16 : 24),
                  padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  constraints: BoxConstraints(
                    maxWidth: screenSize.width * 0.9,
                    maxHeight: screenSize.height * 0.8,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: isSmallScreen ? 16 : 24),
                        
                        // Celebration icon
                        Container(
                          width: isSmallScreen ? 80 : 100,
                          height: isSmallScreen ? 80 : 100,
                          decoration: BoxDecoration(
                            color: kPrimaryGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.emoji_events,
                            size: isSmallScreen ? 40 : 50,
                            color: kPrimaryGreen,
                          ),
                        ),
                        
                        SizedBox(height: isSmallScreen ? 20 : 24),
                        
                        // Congratulations title
                        Text(
                          AppLocalizations.of(context)!.congratulationsGoalReached,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 24 : 28,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryGreen,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        
                        // Achievement message
                        Text(
                          AppLocalizations.of(context)!.youReachedGoalWeight,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 18 : 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        
                        // Maintenance plan message
                        Text(
                          AppLocalizations.of(context)!.heresYourMaintenancePlan,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        
                        // Maintenance plan preview
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                          decoration: BoxDecoration(
                            color: kPrimaryGreen.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: kPrimaryGreen.withOpacity(0.2)),
                          ),
                          child: Column(
                            children: [
                              _buildNutritionRow(
                                AppLocalizations.of(context)!.calories,
                                '${widget.maintenancePlan['calories']} kcal',
                                Icons.local_fire_department,
                                isSmallScreen,
                              ),
                              SizedBox(height: 8),
                              _buildNutritionRow(
                                AppLocalizations.of(context)!.protein,
                                '${widget.maintenancePlan['protein']}g',
                                Icons.fitness_center,
                                isSmallScreen,
                              ),
                              SizedBox(height: 8),
                              _buildNutritionRow(
                                AppLocalizations.of(context)!.carbs,
                                '${widget.maintenancePlan['carbs']}g',
                                Icons.grain,
                                isSmallScreen,
                              ),
                              SizedBox(height: 8),
                              _buildNutritionRow(
                                AppLocalizations.of(context)!.fat,
                                '${widget.maintenancePlan['fat']}g',
                                Icons.opacity,
                                isSmallScreen,
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: isSmallScreen ? 24 : 32),
                        
                        // Action buttons
                        Column(
                          children: [
                            // Keep this plan button
                            SizedBox(
                              width: double.infinity,
                              height: isSmallScreen ? 48 : 56,
                              child: ElevatedButton(
                                onPressed: widget.onKeepPlan,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryGreen,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shadowColor: kPrimaryGreen.withOpacity(0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.keepThisPlan,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 16 : 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 12),
                            
                            // Choose different goal button
                            SizedBox(
                              width: double.infinity,
                              height: isSmallScreen ? 48 : 56,
                              child: OutlinedButton(
                                onPressed: widget.onChooseDifferentGoal,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: kPrimaryGreen,
                                  side: BorderSide(color: kPrimaryGreen, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.chooseDifferentGoal,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 16 : 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        
                        // Encouragement message
                        Text(
                          AppLocalizations.of(context)!.keepUpGreatWork,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value, IconData icon, bool isSmallScreen) {
    return Row(
      children: [
        Icon(
          icon,
          size: isSmallScreen ? 20 : 24,
          color: kPrimaryGreen,
        ),
        SizedBox(width: 12),
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
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: kPrimaryGreen,
          ),
        ),
      ],
    );
  }
}
