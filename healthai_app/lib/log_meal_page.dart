import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/meal.dart';
import 'services/meal_service.dart';
import 'services/streak_notification_service.dart';
import 'models/custom_meal.dart';
import 'l10n/app_localizations.dart';

import 'services/ai_service.dart';
import 'providers/preferences_provider.dart';
import 'utils/constants.dart';
import 'widgets/quantity_selection_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/subscription_service.dart';
import 'dart:async';
import 'search_paywall_page.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'config/ad_config.dart';
import 'services/consent_service.dart';
import 'services/connectivity_service.dart';


// Searchable meal input with dropdown suggestions
class SearchableMealInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String name, int calories, int protein, int carbs, int fat, String? foodType, int? quantity, String? quantityUnit)? onMealSelected;
  final String hintText;
  final String selectedFoodType; // ingredient, meal, drink

  const SearchableMealInput({
    Key? key,
    required this.controller,
    this.onMealSelected,
    required this.hintText,
    required this.selectedFoodType,
  }) : super(key: key);

  @override
  State<SearchableMealInput> createState() => _SearchableMealInputState();
}

class _SearchableMealInputState extends State<SearchableMealInput> {
  final FocusNode _focusNode = FocusNode();
  final AIService _aiService = AIService();
  bool _isFocused = false;
  bool _showDropdown = false;
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoaded = false;
  
  // Search limit tracking
  Future<bool> _shouldShowSearchPaywall() async {
    // Check if user is premium first
    final subscriptionService = SubscriptionService();
    final isPremium = await subscriptionService.isPremiumUser();
    if (isPremium) {
      return false; // Premium users don't see paywall
    }
    
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final lastSearchDate = prefs.getString('lastSearchDate');
    final searchesToday = prefs.getInt('searchesToday') ?? 0;
    final todayStr = '${today.year}-${today.month}-${today.day}';
    
    // Reset counter if it's a new day
    if (lastSearchDate != todayStr) {
      await prefs.setString('lastSearchDate', todayStr);
      await prefs.setInt('searchesToday', 0);
      return false; // first search of the day
    }
    
    // Show paywall after 1 free search per day
    return searchesToday >= 1;
  }

  Future<void> _incrementSearchCount() async {
    final prefs = await SharedPreferences.getInstance();
    final searchesToday = prefs.getInt('searchesToday') ?? 0;
    await prefs.setInt('searchesToday', searchesToday + 1);
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChanged);
    _loadRewardedAd(() {});
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
      // Only hide dropdown if we lose focus AND we're not currently searching
      if (!_focusNode.hasFocus && !_isSearching) {
        _showDropdown = false;
      }
    });
  }

  void _onTextChanged() {
    // No-op: do not reset dropdown or results on text change
  }

  void _loadRewardedAd(VoidCallback onAdLoaded) {
    debugPrint('Loading rewarded ad for search with unit ID: ${AdConfig.rewardedAdUnitId}');
    RewardedAd.load(
      adUnitId: AdConfig.rewardedAdUnitId,
      request: ConsentService.instance.buildAdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('✅ Search rewarded ad loaded successfully!');
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          onAdLoaded();
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ Search rewarded ad failed to load: $error');
          _isRewardedAdLoaded = false;
          _rewardedAd = null;
        },
      ),
    );
  }

  Future<void> _showRewardedAd(BuildContext context, VoidCallback onRewardEarned) async {
    if (_isRewardedAdLoaded && _rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('Search ad dismissed');
          ad.dispose();
          _isRewardedAdLoaded = false;
          _rewardedAd = null;
          _loadRewardedAd(() {}); // Preload next ad
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Search ad failed to show: $error');
          ad.dispose();
          _isRewardedAdLoaded = false;
          _rewardedAd = null;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.adFailedToShow)),
          );
          _loadRewardedAd(() {});
        },
      );

      try {
        await _rewardedAd!.show(
          onUserEarnedReward: (ad, reward) {
            debugPrint('User earned reward from search ad');
            onRewardEarned();
          },
        );
      } catch (e) {
        debugPrint('Error showing search ad: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.adFailedToShow)),
        );
        onRewardEarned(); // Continue anyway
      }
    } else {
      debugPrint('Search ad not loaded, continuing without ad');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.adNotLoadedYet)),
      );
      // Try to load ad for next time
      _loadRewardedAd(() {});
      // Continue with the action
      onRewardEarned();
    }
  }

  Future<void> _performSearch(String query) async {
    if (_isSearching) return; // Prevent multiple simultaneous searches
    
    // Check search limit before performing search
    final bool showPaywall = await _shouldShowSearchPaywall();
    if (showPaywall) {
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SearchPaywallPage(
            onUpgrade: () {
              Navigator.of(context).pop();
            },
            onWatchAd: (paywallContext) async {
              await _showRewardedAd(paywallContext, () async {
                await _incrementSearchCount();
                Navigator.of(paywallContext).pop();
                // Continue with search after watching ad
                _performSearchAfterAd(query);
              });
            },
            onDiscard: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      );
      return;
    }

    await _incrementSearchCount();
    await _performSearchAfterAd(query);
  }

  Future<void> _performSearchAfterAd(String query) async {
    // Starting search
    
    setState(() {
      _isSearching = true;
      _showDropdown = true; // Always show dropdown when starting search
    });

    try {
      final prefs = Provider.of<PreferencesProvider>(context, listen: false);
      final results = await _aiService.searchFoodItemsFast(query, foodType: widget.selectedFoodType, language: prefs.language);
      
      if (mounted) {
        setState(() {
          _searchResults = results;
          _showDropdown = true; // Keep dropdown visible even if no results
          _isSearching = false;
        });

      }
    } catch (e) {
      // Search error occurred
      if (mounted) {
        setState(() {
          _searchResults = [];
          _showDropdown = true; // Keep dropdown visible to show error state
          _isSearching = false;
        });
      }
    }
  }

  void _selectMeal(Map<String, dynamic> meal) {
    widget.controller.text = meal['name'];
    
    // Show quantity selection dialog
    _showQuantityDialog(meal);
    
    setState(() {
      _showDropdown = false; // Only hide when a result is selected
      _searchResults = [];
    });
    _focusNode.unfocus(); // Only unfocus when a result is selected
  }

  void _showQuantityDialog(Map<String, dynamic> meal) {
    // Use the selected food type from the widget instead of determining from name
    String foodType = widget.selectedFoodType;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuantitySelectionDialog(
        foodName: meal['name'],
        foodType: foodType,
        baseCalories: (meal['calories'] as num).toInt(),
        baseProtein: (meal['protein'] as num).toInt(),
        baseCarbs: (meal['carbs'] as num).toInt(),
        baseFat: (meal['fat'] as num).toInt(),
      ),
    ).then((result) {
      if (result != null) {
        // Update the meal with calculated values
        widget.onMealSelected?.call(
          meal['name'],
          result['calories'],
          result['protein'],
          result['carbs'],
          result['fat'],
          foodType,
          result['quantity'],
          result['unit'],
        );
      }
    });
  }

  String _determineFoodType(String foodName) {
    final name = foodName.toLowerCase();
    
    // Drink keywords
    final drinkKeywords = [
      'juice', 'smoothie', 'shake', 'milk', 'coffee', 'tea', 'water', 'soda', 
      'beverage', 'drink', 'latte', 'cappuccino', 'espresso', 'hot chocolate',
      'lemonade', 'iced tea', 'energy drink', 'protein shake', 'green tea'
    ];
    
    // Ingredient keywords (raw, single items)
    final ingredientKeywords = [
      'apple', 'banana', 'orange', 'strawberry', 'blueberry', 'grape', 'pear',
      'carrot', 'broccoli', 'spinach', 'lettuce', 'tomato', 'cucumber',
      'almond', 'walnut', 'cashew', 'peanut', 'sunflower seed',
      'egg', 'chicken breast', 'salmon', 'tuna', 'beef', 'pork',
      'rice', 'quinoa', 'oat', 'bread', 'pasta'
    ];
    
    // Check if it's a drink
    for (final keyword in drinkKeywords) {
      if (name.contains(keyword)) {
        return 'drink';
      }
    }
    
    // Check if it's an ingredient
    for (final keyword in ingredientKeywords) {
      if (name.contains(keyword)) {
        return 'ingredient';
      }
    }
    
    // Default to meal (prepared dishes)
    return 'meal';
  }

  void _onCheckmarkTap() {
    final query = widget.controller.text.trim();
    if (query.length >= 2) {
      // Checkmark tapped
      _performSearch(query);
    }
    // Do not unfocus here - keep focus to maintain dropdown visibility
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Close dropdown when tapping outside
        if (_showDropdown && !_isSearching) {
          setState(() {
            _showDropdown = false;
            _searchResults = [];
          });
        }
      },
      child: Column(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: ConnectivityService.instance.online,
            builder: (context, isOnline, _) {
              return TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: _isFocused && isOnline
                      ? Container(
                          margin: EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: _onCheckmarkTap,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: kPrimaryGreen,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: kPrimaryGreen.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.aiSearch,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.search,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : null,
                ),
              );
            },
          ),
        if (_showDropdown)
          Container(
            margin: EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kPrimaryGreen.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            constraints: BoxConstraints(maxHeight: 200),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with close button
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: kPrimaryGreen.withOpacity(0.05),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.searchResults,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: kPrimaryGreen,
                          fontSize: 12,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey[600], size: 16),
                        onPressed: () {
                          setState(() {
                            _showDropdown = false;
                            _searchResults = [];
                            _isSearching = false;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(minWidth: 24, minHeight: 24),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: _isSearching
                      ? Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: kPrimaryGreen,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)!.searchingFor + ' "${widget.controller.text.trim()}"...',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : _searchResults.isEmpty
                          ? Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                AppLocalizations.of(context)!.noResultsFoundFor + ' "${widget.controller.text.trim()}"',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final meal = _searchResults[index];
                                return ListTile(
                                  title: Text(
                                    meal['name'],
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    '${meal['calories']} cal • ${meal['protein']}g protein • ${meal['carbs']}g carbs • ${meal['fat']}g fat',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: kPrimaryGreen.withOpacity(0.1),
                                    child: Icon(Icons.restaurant, color: kPrimaryGreen, size: 20),
                                  ),
                                  onTap: () => _selectMeal(meal),
                                );
                              },
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
    if (_focusNode.hasFocus) {
      if (widget.controller.text == '0') {
        widget.controller.selection = TextSelection(baseOffset: 0, extentOffset: widget.controller.text.length);
      }
    }
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
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      enabled: widget.enabled,
      onTap: () {
        if (widget.controller.text == '0') {
          widget.controller.selection = TextSelection(baseOffset: 0, extentOffset: widget.controller.text.length);
        }
      },
      onChanged: (value) {
        String sanitized = value;
        // Collapse multiple leading zeros
        if (sanitized.length > 1 && sanitized.startsWith('0')) {
          sanitized = sanitized.replaceFirst(RegExp(r'^0+'), '');
          if (sanitized.isEmpty) sanitized = '0';
          final pos = sanitized.length;
          widget.controller.value = TextEditingValue(text: sanitized, selection: TextSelection.collapsed(offset: pos));
        }
        if (widget.onChanged != null) widget.onChanged!(sanitized);
      },
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

class LogMealPage extends StatefulWidget {
  const LogMealPage({Key? key}) : super(key: key);

  @override
  State<LogMealPage> createState() => _LogMealPageState();
}

class _LogMealPageState extends State<LogMealPage> with TickerProviderStateMixin {
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController(text: '0');
  final TextEditingController _proteinController = TextEditingController(text: '0');
  final TextEditingController _carbsController = TextEditingController(text: '0');
  final TextEditingController _fatController = TextEditingController(text: '0');
  final TextEditingController _ingredientController = TextEditingController();
  List<String> _ingredients = [];

  String _selectedMealType = 'breakfast';
  String _selectedFoodType = 'meal'; // ingredient, meal, drink
  bool _isSaving = false;
  String? _error;

  // Quantity tracking
  String? _foodType;
  int? _quantity;
  String? _quantityUnit;

  final List<String> _mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];

  late AnimationController _tabsController;
  late AnimationController _foodNameControllerAnim;
  late AnimationController _macrosController;
  late AnimationController _recentController;

  int _foodTabIndex = 1; // Default to My Foods (Recent removed)

  @override
  void initState() {
    super.initState();
    _tabsController = AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _foodNameControllerAnim = AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _macrosController = AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _recentController = AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _autoSelectMealType();
    _playEntranceAnimations();
    _foodNameController.addListener(() => setState(() {}));
  }

  void _autoSelectMealType() {
    final now = DateTime.now();
    final hour = now.hour;
    
    if (hour >= 5 && hour < 11) {
      _selectedMealType = 'breakfast';
    } else if (hour >= 11 && hour < 16) {
      _selectedMealType = 'lunch';
    } else if (hour >= 16 && hour < 21) {
      _selectedMealType = 'dinner';
    } else {
      _selectedMealType = 'snack';
    }
  }

  void _playEntranceAnimations() async {
    await Future.delayed(Duration(milliseconds: 80));
    _tabsController.forward();
    await Future.delayed(Duration(milliseconds: 80));
    _foodNameControllerAnim.forward();
    await Future.delayed(Duration(milliseconds: 80));
    _macrosController.forward();
    await Future.delayed(Duration(milliseconds: 80));
    _recentController.forward();
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _ingredientController.dispose();
    _tabsController.dispose();
    _foodNameControllerAnim.dispose();
    _macrosController.dispose();
    _recentController.dispose();
    super.dispose();
  }

  Future<void> _showCalmPopupIfNeeded(VoidCallback onContinue) async {
    final prefs = Provider.of<PreferencesProvider>(context, listen: false);
    if (prefs.momentOfCalmEnabled) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE8F5E9),
                  Color(0xFFF1F8E9),
            ],
          ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
            mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                  // Animated breathing circle with emoji
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.85, end: 1.15),
                    duration: Duration(seconds: 3),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kPrimaryGreen.withOpacity(0.13),
                          ),
                          child: Center(
                            child: Text(
                              '🧘‍♀️',
                              style: TextStyle(fontSize: 48),
                            ),
                          ),
                        ),
                      );
                    },
                    // Loop the animation
                    onEnd: () {
                      // Rebuild to loop
                      (context as Element).markNeedsBuild();
                    },
                  ),
              SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)!.momentOfCalm,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kPrimaryGreen,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: 18),
                  Text(
                    AppLocalizations.of(context)!.takeMomentToAppreciate,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black87,
                      height: 1.5,
                    ),
          ),
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryGreen,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      child: Text(AppLocalizations.of(context)!.continueButton),
                    ),
            ),
          ],
              ),
            ),
          ),
        ),
      );
    }
    onContinue();
  }

  Future<void> _saveMeal() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not signed in');
      final meal = Meal(
        id: '',
        name: _foodNameController.text.trim(),
        calories: int.tryParse(_caloriesController.text.trim()) ?? 0,
        protein: int.tryParse(_proteinController.text.trim()) ?? 0,
        carbs: int.tryParse(_carbsController.text.trim()) ?? 0,
        fat: int.tryParse(_fatController.text.trim()) ?? 0,
        timestamp: DateTime.now(),
        mealType: _selectedMealType,
        userId: user.uid,
        ingredients: List<String>.from(_ingredients),
        foodType: _foodType,
        quantity: _quantity,
        quantityUnit: _quantityUnit,
      );
      bool queued = false;
      try {
        await MealService().addMeal(meal).timeout(const Duration(seconds: 3));
        queued = true;
      } on TimeoutException {
        // Treat as queued locally (offline). Firestore will sync later.
        queued = true;
      }
      if (!queued) throw Exception('Failed to queue meal');
      // Cancel streak nudges for today since a meal was logged
      try { await StreakNotificationService.onMealLoggedToday(); } catch (_) {}
      final isOnline = ConnectivityService.instance.online.value;
      if (!mounted) return;
      setState(() { 
        _ingredients.clear();
        _foodType = null;
        _quantity = null;
        _quantityUnit = null;
        _isSaving = false;
      });
      if (!isOnline) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.mealSaved),
            backgroundColor: Colors.black87,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      await _showCalmPopupIfNeeded(() {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.mealSaved),
            backgroundColor: Colors.black87,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: Duration(seconds: 2),
          ),
        );
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildMealTypeTabs(Map<String, String> mealTypeLabels) {
    return FadeTransition(
      opacity: _tabsController,
      child: SlideTransition(
        position: Tween<Offset>(begin: Offset(0, 0.12), end: Offset.zero).animate(CurvedAnimation(parent: _tabsController, curve: Curves.easeOutCubic)),
        child: Column(
          children: [
            // Meal type selection (breakfast/lunch/dinner/snack)
            Row(
              children: _mealTypes.asMap().entries.map((entry) {
                final index = entry.key;
                final type = entry.value;
                final selected = _selectedMealType == type;
                final color = selected ? kPrimaryGreen : Colors.grey[200];
                final textColor = selected ? Colors.white : Colors.grey[600];
                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedMealType = type),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: selected
                                  ? [BoxShadow(color: kPrimaryGreen.withOpacity(0.08), blurRadius: 8, offset: Offset(0, 2))]
                                  : [],
                            ),
                            child: Center(
                              child: Text(
                                mealTypeLabels[type]!,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: textColor,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (index < _mealTypes.length - 1) SizedBox(width: 8),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Food type selection (ingredient/meal/drink)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFoodTypeButton('ingredient', '🥕', AppLocalizations.of(context)!.ingredient),
                _buildFoodTypeButton('meal', '🍽️', AppLocalizations.of(context)!.meal),
                _buildFoodTypeButton('drink', '🥤', AppLocalizations.of(context)!.drink),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodTypeButton(String type, String emoji, String label) {
    final selected = _selectedFoodType == type;
    final color = selected ? kPrimaryGreen : Colors.grey[200];
    final textColor = selected ? Colors.white : Colors.grey[600];
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFoodType = type),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: selected
                ? [BoxShadow(color: kPrimaryGreen.withOpacity(0.08), blurRadius: 8, offset: Offset(0, 2))]
                : [],
          ),
          child: Column(
            children: [
              Text(emoji, style: TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacrosInputs() {
    final localizations = AppLocalizations.of(context)!;
    return FadeTransition(
      opacity: _macrosController,
      child: SlideTransition(
        position: Tween<Offset>(begin: Offset(0, 0.10), end: Offset.zero).animate(CurvedAnimation(parent: _macrosController, curve: Curves.easeOutCubic)),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _macroField('calories', localizations.calories, _caloriesController),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _macroField('protein', localizations.protein + ' (g)', _proteinController),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _macroField('carbs', localizations.carbs + ' (g)', _carbsController),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _macroField('fat', localizations.fat + ' (g)', _fatController),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _macroField(String macroType, String label, TextEditingController controller) {
    Color color;
    switch (macroType) {
      case 'protein':
        color = kSecondaryBlue;
        break;
      case 'carbs':
        color = kAccentOrange;
        break;
      case 'fat':
        color = kWarningRed;
        break;
      case 'calories':
      default:
        color = kPrimaryGreen;
        break;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        _NumericTextField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            filled: true,
            fillColor: color.withOpacity(0.07),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  // Recent foods removed from Log Meal page per requirement
  // Widget _buildRecentFoods() {}

  Widget _recentFoodTile(Meal meal) {
    return _ExpandableMealTile(
      name: meal.name.isNotEmpty ? meal.name : 'Unknown Food',
      protein: meal.protein.clamp(0, 999),
      carbs: meal.carbs.clamp(0, 999),
      fat: meal.fat.clamp(0, 999),
      calories: meal.calories.clamp(0, 9999),
      ingredients: meal.ingredients.where((ingredient) => ingredient.trim().isNotEmpty).toList(),
      icon: Icons.restaurant_menu,
      iconColor: kPrimaryGreen,
      onAdd: () {
            setState(() {
              _foodNameController.text = meal.name.isNotEmpty ? meal.name : 'Unknown Food';
              _caloriesController.text = meal.calories.clamp(0, 9999).toString();
              _proteinController.text = meal.protein.clamp(0, 999).toString();
              _carbsController.text = meal.carbs.clamp(0, 999).toString();
              _fatController.text = meal.fat.clamp(0, 999).toString();
              _ingredients = List<String>.from(meal.ingredients.where((ingredient) => ingredient.trim().isNotEmpty));
            });
          },
      isCustomMeal: false,
      imageUrl: meal.imageUrl,
    );
  }

  // For custom meal creation
  Future<void> _showCustomMealDialog() async {
    final nameController = TextEditingController();
    final caloriesController = TextEditingController(text: '0');
    final proteinController = TextEditingController(text: '0');
    final carbsController = TextEditingController(text: '0');
    final fatController = TextEditingController(text: '0');
    final ingredientController = TextEditingController();
    List<String> ingredients = [];
    bool isSaving = false;
    String? error;
    String selectedType = _selectedFoodType;

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim1.value),
          child: Opacity(
            opacity: anim1.value,
            child: StatefulBuilder(
              builder: (context, setDialogState) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
              title: Text('Custom Building', style: TextStyle(fontWeight: FontWeight.bold, color: kPrimaryGreen)),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.92,
                  ),
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: kPrimaryGreen)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter name',
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                  ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Food type selection (ingredient/meal/drink) – same styling as Log Meal page
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setDialogState(() => selectedType = 'ingredient'),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: selectedType == 'ingredient' ? kPrimaryGreen : Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: selectedType == 'ingredient'
                                    ? [BoxShadow(color: kPrimaryGreen.withOpacity(0.08), blurRadius: 8, offset: Offset(0, 2))]
                                    : [],
                              ),
                              child: Column(
                                children: [
                                  Text('🥕', style: TextStyle(fontSize: 20)),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppLocalizations.of(context)!.ingredient,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: selectedType == 'ingredient' ? Colors.white : Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setDialogState(() => selectedType = 'meal'),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: selectedType == 'meal' ? kPrimaryGreen : Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: selectedType == 'meal'
                                    ? [BoxShadow(color: kPrimaryGreen.withOpacity(0.08), blurRadius: 8, offset: Offset(0, 2))]
                                    : [],
                              ),
                              child: Column(
                                children: [
                                  Text('🍽️', style: TextStyle(fontSize: 20)),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppLocalizations.of(context)!.meal,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: selectedType == 'meal' ? Colors.white : Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setDialogState(() => selectedType = 'drink'),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: selectedType == 'drink' ? kPrimaryGreen : Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: selectedType == 'drink'
                                    ? [BoxShadow(color: kPrimaryGreen.withOpacity(0.08), blurRadius: 8, offset: Offset(0, 2))]
                                    : [],
                              ),
                              child: Column(
                                children: [
                                  Text('🥤', style: TextStyle(fontSize: 20)),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppLocalizations.of(context)!.drink,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: selectedType == 'drink' ? Colors.white : Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _macroField('calories', AppLocalizations.of(context)!.calories, caloriesController)),
                        const SizedBox(width: 16),
                        Expanded(child: _macroField('protein', AppLocalizations.of(context)!.protein + ' (g)', proteinController)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _macroField('carbs', AppLocalizations.of(context)!.carbs + ' (g)', carbsController)),
                        const SizedBox(width: 16),
                        Expanded(child: _macroField('fat', AppLocalizations.of(context)!.fat + ' (g)', fatController)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(AppLocalizations.of(context)!.ingredients, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: kPrimaryGreen)),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ingredientController,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.addIngredient,
                              filled: true,
                              fillColor: const Color(0xFFF5F5F5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: kPrimaryGreen),
                          onPressed: () {
                            if (ingredientController.text.trim().isNotEmpty) {
                              setDialogState(() {
                                ingredients.add(ingredientController.text.trim());
                                ingredientController.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 6,
                      children: ingredients.map((ing) => Chip(
                        label: Text(ing),
                        onDeleted: () => setState(() => ingredients.remove(ing)),
                        backgroundColor: kPrimaryGreen.withOpacity(0.13),
                        labelStyle: TextStyle(color: kPrimaryGreen),
                      )).toList(),
                    ),
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                          child: Text(error!, style: TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
              ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(minimumSize: const Size(96, 44), padding: const EdgeInsets.symmetric(horizontal: 16)),
                  child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: kPrimaryGreen)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen, minimumSize: const Size(110, 44), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                  onPressed: isSaving
                      ? null
                      : () async {
                          setDialogState(() => isSaving = true);
                          try {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) throw Exception('Not signed in');
                           final customMeal = CustomMeal(
                              id: '',
                              name: nameController.text.trim(),
                              calories: int.tryParse(caloriesController.text) ?? 0,
                              protein: int.tryParse(proteinController.text) ?? 0,
                              carbs: int.tryParse(carbsController.text) ?? 0,
                              fat: int.tryParse(fatController.text) ?? 0,
                              ingredients: ingredients,
                              userId: user.uid,
                            );
                            await MealService().addCustomMeal(customMeal);
                           // Pre-fill the main Log Meal form so the user can save immediately
                           if (mounted) {
                             setState(() {
                               _foodNameController.text = customMeal.name;
                               _caloriesController.text = customMeal.calories.toString();
                               _proteinController.text = customMeal.protein.toString();
                               _carbsController.text = customMeal.carbs.toString();
                               _fatController.text = customMeal.fat.toString();
                               _ingredients = List<String>.from(customMeal.ingredients);
                               _selectedFoodType = selectedType; // carry type
                               _foodType = selectedType;
                             });
                           }
                            Navigator.pop(context);
                          } catch (e) {
                            setDialogState(() {
                              error = e.toString();
                              isSaving = false;
                            });
                          }
                        },
                  child: isSaving ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(AppLocalizations.of(context)!.save),
                ),
              ],
            ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFoodTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _foodTabIndex = 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.recent,
                      style: TextStyle(
                        color: _foodTabIndex == 0 ? kPrimaryGreen : Colors.grey[500],
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _foodTabIndex = 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.myFoods,
                      style: TextStyle(
                        color: _foodTabIndex == 1 ? kPrimaryGreen : Colors.grey[500],
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
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

  Widget _buildMyFoods() {
    return StreamBuilder<List<CustomMeal>>(
      stream: MealService().getCustomMeals(),
      builder: (context, snapshot) {
        final customMeals = snapshot.data ?? [];
        if (customMeals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                 Text('You don\'t have any saved customs.', style: TextStyle(color: Colors.grey[500], fontSize: 18)),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: _showCustomMealDialog,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kPrimaryGreen,
                    side: BorderSide(color: kPrimaryGreen.withOpacity(0.18)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                   child: Text('Saved customs  +', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
             Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 OutlinedButton(
                   onPressed: _showCustomMealDialog,
                   style: OutlinedButton.styleFrom(
                     foregroundColor: kPrimaryGreen,
                     side: BorderSide(color: kPrimaryGreen.withOpacity(0.18)),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                     padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                   ),
                   child: Text('Custom building', style: TextStyle(fontSize: 18)),
                 ),
               ],
             ),
            const SizedBox(height: 12),
            ...customMeals.map((meal) => _customMealTile(meal)).toList(),
          ],
        );
      },
    );
  }

  Widget _customMealTile(CustomMeal meal) {
    return _ExpandableMealTile(
      name: meal.name,
      protein: meal.protein,
      carbs: meal.carbs,
      fat: meal.fat,
      calories: meal.calories,
      ingredients: meal.ingredients,
      icon: Icons.star,
      iconColor: kPrimaryGreen,
      onAdd: () {
            setState(() {
              _foodNameController.text = meal.name;
              _caloriesController.text = meal.calories.toString();
              _proteinController.text = meal.protein.toString();
              _carbsController.text = meal.carbs.toString();
              _fatController.text = meal.fat.toString();
          _ingredients = List<String>.from(meal.ingredients);
            });
          },
      onCustomize: () async {
        final nameController = TextEditingController(text: meal.name);
        final caloriesController = TextEditingController(text: meal.calories.toString());
        final proteinController = TextEditingController(text: meal.protein.toString());
        final carbsController = TextEditingController(text: meal.carbs.toString());
        final fatController = TextEditingController(text: meal.fat.toString());
        final ingredientController = TextEditingController();
        List<String> ingredients = List<String>.from(meal.ingredients);
        bool isSaving = false;
        String? error;

        await showGeneralDialog(
            context: context,
          barrierDismissible: true,
          barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
          transitionDuration: const Duration(milliseconds: 320),
          pageBuilder: (context, anim1, anim2) {
            return const SizedBox.shrink();
          },
          transitionBuilder: (context, anim1, anim2, child) {
            return Transform.scale(
              scale: Curves.easeOutBack.transform(anim1.value),
              child: Opacity(
                opacity: anim1.value,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                   title: Text('Custom Building', style: TextStyle(fontWeight: FontWeight.bold, color: kPrimaryGreen)),
                   insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                   content: SingleChildScrollView(
                     child: ConstrainedBox(
                       constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.92),
                       child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                        Text('Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: kPrimaryGreen)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: 'Enter food name',
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                     ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(child: _macroField('calories', AppLocalizations.of(context)!.calories, caloriesController)),
                            const SizedBox(width: 16),
                            Expanded(child: _macroField('protein', AppLocalizations.of(context)!.protein + ' (g)', proteinController)),
                          ],
                        ),
                  const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _macroField('carbs', AppLocalizations.of(context)!.carbs + ' (g)', carbsController)),
                            const SizedBox(width: 16),
                            Expanded(child: _macroField('fat', AppLocalizations.of(context)!.fat + ' (g)', fatController)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(AppLocalizations.of(context)!.ingredients, style: TextStyle(fontWeight: FontWeight.w600)),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: ingredientController,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!.addIngredient,
                                  filled: true,
                                  fillColor: const Color(0xFFF5F5F5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add, color: kPrimaryGreen),
                              onPressed: () {
                                if (ingredientController.text.trim().isNotEmpty) {
                                  setState(() {
                                    ingredients.add(ingredientController.text.trim());
                                    ingredientController.clear();
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        Wrap(
                          spacing: 6,
                          children: ingredients.map((ing) => Chip(
                            label: Text(ing),
                            onDeleted: () => setState(() => ingredients.remove(ing)),
                            backgroundColor: kPrimaryGreen.withOpacity(0.13),
                            labelStyle: TextStyle(color: kPrimaryGreen),
                          )).toList(),
                        ),
                        if (error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(error!, style: TextStyle(color: Colors.red)),
                          ),
                ],
                    ),
              ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: kPrimaryGreen)),
                ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen),
                      onPressed: isSaving
                          ? null
                          : () async {
                              setState(() => isSaving = true);
                              try {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user == null) throw Exception('Not signed in');
                                final updatedMeal = CustomMeal(
                                  id: meal.id,
                                  name: nameController.text.trim(),
                                  calories: int.tryParse(caloriesController.text) ?? 0,
                                  protein: int.tryParse(proteinController.text) ?? 0,
                                  carbs: int.tryParse(carbsController.text) ?? 0,
                                  fat: int.tryParse(fatController.text) ?? 0,
                                  ingredients: ingredients,
                                  userId: user.uid,
                                );
                                await MealService().updateCustomMeal(updatedMeal);
                                // Reflect updated values back into main form for immediate save if desired
                                if (mounted) {
                                  setState(() {
                                    _foodNameController.text = updatedMeal.name;
                                    _caloriesController.text = updatedMeal.calories.toString();
                                    _proteinController.text = updatedMeal.protein.toString();
                                    _carbsController.text = updatedMeal.carbs.toString();
                                    _fatController.text = updatedMeal.fat.toString();
                                    _ingredients = List<String>.from(updatedMeal.ingredients);
                                  });
                                }
                                Navigator.pop(context);
                              } catch (e) {
                                setState(() {
                                  error = e.toString();
                                  isSaving = false;
                                });
                              }
                            },
                      child: isSaving ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(AppLocalizations.of(context)!.save),
                ),
              ],
                ),
            ),
          );
        },
        );
      },
      onDelete: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.delete),
            content: Text(AppLocalizations.of(context)!.areYouSureDeleteMeal),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c, false), child: Text(AppLocalizations.of(context)!.cancel)),
              TextButton(onPressed: () => Navigator.pop(c, true), child: Text(AppLocalizations.of(context)!.delete)),
            ],
          ),
        );
        if (confirmed == true) {
          await MealService().deleteCustomMeal(meal.id);
        }
      },
      isCustomMeal: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final Map<String, String> _mealTypeLabels = {
      'breakfast': localizations.breakfast,
      'lunch': localizations.lunch,
      'dinner': localizations.dinner,
      'snack': localizations.snack,
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.logMeal, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 22)),
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.arrow_back, color: kPrimaryGreen, size: 28, weight: 800),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: kPrimaryGreen,
        elevation: 0.5,
      ),
      backgroundColor: kBackgroundWhite,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildMealTypeTabs(_mealTypeLabels),
            const SizedBox(height: 24),
            // --- FORM SECTION: always visible, no tabs ---
            FadeTransition(
              opacity: _foodNameControllerAnim,
              child: SlideTransition(
                position: Tween<Offset>(begin: Offset(0, 0.10), end: Offset.zero).animate(CurvedAnimation(parent: _foodNameControllerAnim, curve: Curves.easeOutCubic)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocalizations.of(context)!.foodName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                        OutlinedButton.icon(
                          onPressed: () {
                            _foodNameController.clear();
                            _caloriesController.text = '0';
                            _proteinController.text = '0';
                            _carbsController.text = '0';
                            _fatController.text = '0';
                            setState(() {
                              _ingredients.clear();
                            });
                          },
                          icon: Icon(Icons.delete_outline, color: kPrimaryGreen, size: 18),
                          label: Text(AppLocalizations.of(context)!.clearAll, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: kPrimaryGreen)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: kPrimaryGreen, width: 1.4),
                            shape: StadiumBorder(),
                            foregroundColor: kPrimaryGreen,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            minimumSize: Size(0, 36),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SearchableMealInput(
                      controller: _foodNameController,
                      hintText: AppLocalizations.of(context)!.searchOrEnterFoodName,
                      selectedFoodType: _selectedFoodType,
                      onMealSelected: (name, calories, protein, carbs, fat, foodType, quantity, quantityUnit) {
                        setState(() {
                          _foodNameController.text = name;
                          _caloriesController.text = calories.toString();
                          _proteinController.text = protein.toString();
                          _carbsController.text = carbs.toString();
                          _fatController.text = fat.toString();
                          _foodType = foodType;
                          _quantity = quantity;
                          _quantityUnit = quantityUnit;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildMacrosInputs(),
            const SizedBox(height: 24),
            // Ingredient input section
            Text(AppLocalizations.of(context)!.ingredients, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: kPrimaryGreen)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ingredientController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.addIngredient,
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: kPrimaryGreen),
                  onPressed: () {
                    final text = _ingredientController.text.trim();
                    if (text.isNotEmpty) {
                      setState(() {
                        _ingredients.add(text);
                        _ingredientController.clear();
                      });
                    }
                  },
                ),
              ],
            ),
            Wrap(
              spacing: 6,
              children: _ingredients.map((ing) => Chip(
                label: Text(ing),
                onDeleted: () => setState(() => _ingredients.remove(ing)),
                backgroundColor: kPrimaryGreen.withOpacity(0.13),
                labelStyle: TextStyle(color: kPrimaryGreen),
              )).toList(),
            ),
            const SizedBox(height: 24),
            // Food picker (Recent removed; show only My Foods)
            _buildMyFoods(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: ElevatedButton(
          onPressed: _foodNameController.text.trim().isEmpty || _isSaving
              ? null
              : _saveMeal,
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryGreen,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 2,
            shadowColor: kPrimaryGreen.withOpacity(0.18),
          ),
          child: _isSaving
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(AppLocalizations.of(context)!.saveMeal, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

// Macro Tag widget for macros display
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

class _ExpandableMealTile extends StatefulWidget {
  final String name;
  final int protein;
  final int carbs;
  final int fat;
  final int calories;
  final List<String> ingredients;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onAdd;
  final VoidCallback? onCustomize;
  final VoidCallback? onDelete;
  final bool isCustomMeal;
  final String? imageUrl;
  const _ExpandableMealTile({
    required this.name,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.calories,
    required this.ingredients,
    required this.icon,
    required this.iconColor,
    required this.onAdd,
    this.onCustomize,
    this.onDelete,
    this.isCustomMeal = false,
    this.imageUrl,
    Key? key,
  }) : super(key: key);
  @override
  State<_ExpandableMealTile> createState() => _ExpandableMealTileState();
}

class _ExpandableMealTileState extends State<_ExpandableMealTile> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kPrimaryGreen.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: kPrimaryGreen.withOpacity(0.06),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
                backgroundColor: kPrimaryGreen.withOpacity(0.13),
                child: Icon(widget.icon, color: widget.iconColor),
              ),
            title: Text(
              widget.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: AppLocalizations.of(context)!.localeName.startsWith('ar') ? TextDirection.rtl : TextDirection.ltr,
            ),
            subtitle: widget.isCustomMeal ? null : Wrap(
              spacing: 6,
              runSpacing: 2,
              children: [
                _MacroTag(label: 'P', value: '${widget.protein}g', color: kSecondaryBlue),
                _MacroTag(label: 'C', value: '${widget.carbs}g', color: kAccentOrange),
                _MacroTag(label: 'F', value: '${widget.fat}g', color: kWarningRed),
              ],
            ),
             trailing: Flexible(
               child: Wrap(
                spacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (!widget.isCustomMeal)
                    Text('${widget.calories} cal', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: kPrimaryGreen, size: 26),
                    onPressed: widget.onAdd,
                    constraints: BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                   if (widget.isCustomMeal && widget.onDelete != null)
                     IconButton(
                       icon: Icon(Icons.delete, color: Colors.redAccent, size: 22),
                       tooltip: AppLocalizations.of(context)!.delete,
                       onPressed: widget.onDelete,
                       constraints: BoxConstraints(),
                       padding: EdgeInsets.zero,
                     ),
                  if (widget.onCustomize != null)
                    IconButton(
                      icon: Icon(Icons.edit, color: kPrimaryGreen, size: 22),
                      tooltip: AppLocalizations.of(context)!.customizeMeal,
                      onPressed: widget.onCustomize,
                      constraints: BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  IconButton(
                    icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: kPrimaryGreen, size: 24),
                    tooltip: _expanded ? AppLocalizations.of(context)!.hideIngredients : AppLocalizations.of(context)!.showIngredients,
                    onPressed: () => setState(() => _expanded = !_expanded),
                    constraints: BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 18, right: 18),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Builder(
                  builder: (context) {
                    final ingredients = widget.ingredients;
                    if (ingredients.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.ingredientsColon, style: TextStyle(fontWeight: FontWeight.w600, color: kPrimaryGreen)),
                          ...ingredients.map((ing) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: 6, height: 6, margin: const EdgeInsets.only(top: 6, right: 8), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle)),
                                Expanded(child: Text(ing, style: const TextStyle(color: Colors.black87))),
                              ],
                            ),
                          )).toList(),
                        ],
                      );
                    } else {
                      return Text(AppLocalizations.of(context)!.noIngredientsListed, style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic));
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