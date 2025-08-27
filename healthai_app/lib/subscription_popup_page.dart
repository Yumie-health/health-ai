import 'package:flutter/material.dart';
import 'utils/constants.dart';
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';
import 'subscription_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/subscription_service.dart';
import 'l10n/app_localizations.dart';
import 'services/dialog_coordinator.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionPopupPage extends StatefulWidget {
  final VoidCallback? onDismiss;
  final bool isOnboardingComplete;
  
  const SubscriptionPopupPage({
    Key? key, 
    this.onDismiss,
    this.isOnboardingComplete = false,
  }) : super(key: key);

  @override
  State<SubscriptionPopupPage> createState() => _SubscriptionPopupPageState();

  // Show using DialogCoordinator to avoid overlapping with other modals
  static Future<bool> showPopup(BuildContext context, {bool isOnboardingComplete = false, VoidCallback? onDismiss}) async {
    final result = await DialogCoordinator.instance.showExclusiveDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SubscriptionPopupPage(
        isOnboardingComplete: isOnboardingComplete,
        onDismiss: onDismiss,
      ),
    );
    return result ?? false;
  }

  static Future<bool> shouldShowPopup({bool isPostOnboarding = false}) async {
    try {
      final subscriptionService = SubscriptionService();
      final isPremium = await subscriptionService.isPremiumUser();
      
      print('🔍 POPUP CHECK: isPremium=$isPremium, isPostOnboarding=$isPostOnboarding');
      
      if (isPremium) {
        print('❌ POPUP CHECK: User is premium, not showing popup');
        return false; // Don't show for premium users
      }
      
      // ALWAYS show popup immediately after onboarding completion
      if (isPostOnboarding) {
        print('✅ POPUP CHECK: Post-onboarding for non-premium user, showing popup');
        return true;
      }
      
      // If user previously had premium but lost it, encourage re-subscribe more often
      if ((await SharedPreferences.getInstance()).getBool('hadPremiumEver') == true) {
        return true;
      }

      // For regular app launches, use the existing occasional logic
      final prefs = await SharedPreferences.getInstance();
      final showCount = prefs.getInt('subscription_popup_shown_count') ?? 0;
      final lastShown = prefs.getInt('last_subscription_popup_timestamp') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Show popup if:
      // 1. Never shown before
      // 2. Shown less than 3 times AND last shown more than 3 days ago
      if (showCount == 0) return true;
      
      const threeDaysInMs = 3 * 24 * 60 * 60 * 1000;
      if (showCount < 3 && (now - lastShown) > threeDaysInMs) {
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error checking popup show condition: $e');
      return false;
    }
  }
}

class _SubscriptionPopupPageState extends State<SubscriptionPopupPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Product details for pricing
  List<ProductDetails> _products = [];
  bool _isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.bounceOut,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _scaleController.forward();
    });

    // Load product details
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final InAppPurchase iap = InAppPurchase.instance;
      final bool available = await iap.isAvailable();
      
      if (available) {
        final Set<String> productIds = {'premium_monthly', 'premium_yearly'};
        final ProductDetailsResponse response = await iap.queryProductDetails(productIds);
        
        if (response.error == null && response.productDetails.isNotEmpty) {
          setState(() {
            _products = response.productDetails;
            _isLoadingProducts = false;
          });
        } else {
          setState(() {
            _isLoadingProducts = false;
          });
        }
      } else {
        setState(() {
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        _isLoadingProducts = false;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _dismissPopup() {
    if (!mounted) return;
    
    if (widget.onDismiss != null) {
      widget.onDismiss!();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _markPopupShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('subscription_popup_shown_count', 
        (prefs.getInt('subscription_popup_shown_count') ?? 0) + 1);
    await prefs.setInt('last_subscription_popup_timestamp', 
        DateTime.now().millisecondsSinceEpoch);
  }

  void _navigateToSubscription() async {
    await _markPopupShown();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SubscriptionPage()),
    );
  }

  // Helper method to get product price
  String _getProductPrice(String productId) {
    final product = _products.firstWhere(
      (p) => p.id == productId,
      orElse: () => ProductDetails(
        id: productId,
        title: '',
        description: '',
        price: productId == 'premium_monthly' ? '\$7.99' : '\$49.99', // Fallback price
        rawPrice: productId == 'premium_monthly' ? 7.99 : 49.99, // Fallback raw price
        currencyCode: 'USD', // Fallback currency
      ),
    );
    return product.price;
  }

  // Helper method to get localized price string
  String _getLocalizedPriceString(String productId) {
    final price = _getProductPrice(productId);
    final localizations = AppLocalizations.of(context)!;
    
    if (productId == 'premium_yearly') {
      return localizations.yearPrice.replaceAll('{price}', price);
    } else {
      return localizations.monthPrice.replaceAll('{price}', price);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400 || screenSize.height < 700;
    final isVerySmallScreen = screenSize.width < 350 || screenSize.height < 600;
    
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.7),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Center(
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  margin: EdgeInsets.all(isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 16)),
                  padding: EdgeInsets.all(isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 20)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isVerySmallScreen ? 16 : 24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  constraints: BoxConstraints(
                    maxHeight: screenSize.height * 0.85,
                    maxWidth: screenSize.width * 0.85,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                    // Close button
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () async {
                          await _markPopupShown();
                          _dismissPopup();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // App logo
                    SizedBox(
                      height: isVerySmallScreen ? 80 : (isSmallScreen ? 100 : 120),
                      child: Image.asset(
                        'assets/logo.png',
                        width: isVerySmallScreen ? 80 : (isSmallScreen ? 100 : 120),
                        height: isVerySmallScreen ? 80 : (isSmallScreen ? 100 : 120),
                        fit: BoxFit.contain,
                      ),
                    ),
                    
                    SizedBox(height: isVerySmallScreen ? 6 : 12),
                    
                    // Title
                    Text(
                      widget.isOnboardingComplete 
                        ? AppLocalizations.of(context)!.welcomeToYumie 
                        : AppLocalizations.of(context)!.unlockPremiumFeatures,
                      style: TextStyle(
                        fontSize: isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 20),
                        fontWeight: FontWeight.bold,
                        color: kPrimaryGreen,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: isVerySmallScreen ? 6 : 12),
                    
                    // Subtitle
                    Text(
                      widget.isOnboardingComplete
                        ? AppLocalizations.of(context)!.getMostOutOfHealthJourney
                        : AppLocalizations.of(context)!.unlimitedScansAICoaching,
                      style: TextStyle(
                        fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16),
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: isVerySmallScreen ? 10 : 16),
                    
                    // Features list
                    _buildFeaturesList(isVerySmallScreen, isSmallScreen),
                    
                    SizedBox(height: isVerySmallScreen ? 10 : 16),
                    
                    // Premium buttons
                    _buildPremiumButtons(isVerySmallScreen, isSmallScreen),
                    
                    // Legal links: EULA and Privacy
                    SizedBox(height: isVerySmallScreen ? 6 : 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        TextButton(
                          onPressed: () async {
                            final url = Platform.isIOS
                                ? 'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'
                                : 'https://yumie.me/terms';
                            final uri = Uri.parse(url);
                            if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppLocalizations.of(context)!.couldNotOpenTermsOfService)),
                              );
                            }
                          },
                          child: const Text('Terms of Use (EULA)'),
                        ),
                        TextButton(
                          onPressed: () async {
                            final uri = Uri.parse('https://yumie.me/privacy');
                            if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppLocalizations.of(context)!.couldNotOpenPrivacyPolicy)),
                              );
                            }
                          },
                          child: Text(AppLocalizations.of(context)!.privacyPolicy),
                        ),
                      ],
                    ),
                    // Bottom spacer trimmed to avoid scrolling
                    SizedBox(height: isVerySmallScreen ? 4 : 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesList(bool isVerySmallScreen, bool isSmallScreen) {
    final localizations = AppLocalizations.of(context)!;
    final features = [
      {'icon': '🔍', 'text': localizations.unlimitedFoodScanning},
      {'icon': '🤖', 'text': localizations.aiNutritionCoach},
      {'icon': '📊', 'text': localizations.detailedAnalytics},
      {'icon': '🍽️', 'text': localizations.personalizedMealPlans},
      {'icon': '🚫', 'text': localizations.noAdvertisements},
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: isVerySmallScreen ? 2 : 4),
          child: Row(
            children: [
              Container(
                width: isVerySmallScreen ? 24 : 32,
                height: isVerySmallScreen ? 24 : 32,
                decoration: BoxDecoration(
                  color: kPrimaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    feature['icon']!,
                    style: TextStyle(fontSize: isVerySmallScreen ? 12 : 16),
                  ),
                ),
              ),
              SizedBox(width: isVerySmallScreen ? 8 : 12),
              Expanded(
                child: Text(
                  feature['text']!,
                  style: TextStyle(
                    fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 13 : 15),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPremiumButtons(bool isVerySmallScreen, bool isSmallScreen) {
    return Column(
      children: [
        // Yearly plan (highlighted)
        _buildPlanButton(
          title: AppLocalizations.of(context)!.yearlyPremium,
          price: _getLocalizedPriceString('premium_yearly'),
          savings: AppLocalizations.of(context)!.save37,
          isPopular: true,
          onTap: _navigateToSubscription,
          isVerySmallScreen: isVerySmallScreen,
          isSmallScreen: isSmallScreen,
        ),
        
        SizedBox(height: isVerySmallScreen ? 4 : 8),
        
        // Monthly plan
        _buildPlanButton(
          title: AppLocalizations.of(context)!.monthlyPremium,
          price: _getLocalizedPriceString('premium_monthly'),
          savings: null,
          isPopular: false,
          onTap: _navigateToSubscription,
          isVerySmallScreen: isVerySmallScreen,
          isSmallScreen: isSmallScreen,
        ),
      ],
    );
  }

  Widget _buildPlanButton({
    required String title,
    required String price,
    String? savings,
    required bool isPopular,
    required VoidCallback onTap,
    required bool isVerySmallScreen,
    required bool isSmallScreen,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16)),
        decoration: BoxDecoration(
          color: isPopular ? kPrimaryGreen : Colors.white,
          border: Border.all(
            color: isPopular ? kPrimaryGreen : Colors.grey[300]!,
            width: isPopular ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isPopular
              ? [
                  BoxShadow(
                    color: kPrimaryGreen.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16),
                          fontWeight: FontWeight.bold,
                          color: isPopular ? Colors.white : Colors.black,
                        ),
                      ),
                      if (isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.popular,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                                      Text(
                    price,
                    style: TextStyle(
                      fontSize: isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 14),
                      color: isPopular ? Colors.white.withOpacity(0.9) : Colors.grey[600],
                    ),
                  ),
                  if (savings != null) ...[
                    const SizedBox(height: 2),
                                          Text(
                      savings,
                      style: TextStyle(
                        fontSize: isVerySmallScreen ? 9 : (isSmallScreen ? 10 : 12),
                        fontWeight: FontWeight.bold,
                        color: isPopular ? Colors.white : kPrimaryGreen,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isPopular ? Colors.white : Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
