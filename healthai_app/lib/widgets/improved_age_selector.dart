import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../utils/responsive_text.dart';

class ImprovedAgeSelector extends StatefulWidget {
  final int? selectedAge;
  final void Function(int) onSelect;

  const ImprovedAgeSelector({
    Key? key,
    required this.selectedAge,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<ImprovedAgeSelector> createState() => _ImprovedAgeSelectorState();
}

class _ImprovedAgeSelectorState extends State<ImprovedAgeSelector>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _changeAge(int delta) {
    final currentAge = widget.selectedAge ?? 25;
    final newAge = (currentAge + delta).clamp(16, 100);
    if (newAge != currentAge) {
      widget.onSelect(newAge);
      HapticFeedback.lightImpact();
      _bounceController.forward().then((_) => _bounceController.reverse());
    }
  }

  void _jumpToDecade(int decade) {
    final newAge = (decade * 10).clamp(16, 100);
    widget.onSelect(newAge);
    HapticFeedback.mediumImpact();
    _bounceController.forward().then((_) => _bounceController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final currentAge = widget.selectedAge ?? 25;

    return Column(
      children: [
        // Quick decade selector
        Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _DecadeButton(
                label: AppLocalizations.of(context)!.teens,
                isActive: currentAge >= 16 && currentAge < 20,
                onTap: () => _jumpToDecade(1),
              ),
              _DecadeButton(
                label: AppLocalizations.of(context)!.twenties,
                isActive: currentAge >= 20 && currentAge < 30,
                onTap: () => _jumpToDecade(2),
              ),
              _DecadeButton(
                label: AppLocalizations.of(context)!.thirties,
                isActive: currentAge >= 30 && currentAge < 40,
                onTap: () => _jumpToDecade(3),
              ),
              _DecadeButton(
                label: AppLocalizations.of(context)!.forties,
                isActive: currentAge >= 40 && currentAge < 50,
                onTap: () => _jumpToDecade(4),
              ),
              _DecadeButton(
                label: AppLocalizations.of(context)!.fiftyPlus,
                isActive: currentAge >= 50,
                onTap: () => _jumpToDecade(5),
              ),
            ],
          ),
        ),

        SizedBox(height: 40),

        // Main age display and controls
        Container(
          height: 200,
          child: Row(
            children: [
              // Decrease button
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTapDown: (_) => _scaleController.forward(),
                  onTapUp: (_) => _scaleController.reverse(),
                  onTapCancel: () => _scaleController.reverse(),
                  onTap: () => _changeAge(-1),
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.remove,
                                size: 40,
                                color: Theme.of(context).primaryColor,
                              ),
                              SizedBox(height: 8),
                              ResponsiveText.responsiveText(
                                context,
                                AppLocalizations.of(context)!.younger,
                                baseFontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              SizedBox(width: 20),

              // Age display
              Expanded(
                flex: 3,
                child: AnimatedBuilder(
                  animation: _bounceAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _bounceAnimation.value,
                      child: Container(
                        height: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).primaryColor.withOpacity(0.15),
                              Theme.of(context).primaryColor.withOpacity(0.25),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.4),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.2),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ResponsiveText.fittedText(
                              context,
                              "$currentAge",
                              baseFontSize: 72,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                              height: 1.0,
                              textAlign: TextAlign.center,
                            ),
                            ResponsiveText.responsiveText(
                              context,
                              AppLocalizations.of(context)!.yearsOld,
                              baseFontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.8),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(width: 20),

              // Increase button
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTapDown: (_) => _scaleController.forward(),
                  onTapUp: (_) => _scaleController.reverse(),
                  onTapCancel: () => _scaleController.reverse(),
                  onTap: () => _changeAge(1),
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                size: 40,
                                color: Theme.of(context).primaryColor,
                              ),
                              SizedBox(height: 8),
                              ResponsiveText.responsiveText(
                                context,
                                AppLocalizations.of(context)!.older,
                                baseFontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DecadeButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DecadeButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isActive
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ResponsiveText.responsiveText(
          context,
          label,
          baseFontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.white : Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
