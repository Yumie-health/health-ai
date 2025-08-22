// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get settings => 'الإعدادات';

  @override
  String get preferences => 'التفضيلات';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get enableDarkTheme => 'تفعيل الوضع الداكن';

  @override
  String get useMetricUnits => 'استخدم الوحدات المترية';

  @override
  String get unitsSubtitle => 'استخدم كجم/سم (تشغيل) أو رطل/قدم (إيقاف)';

  @override
  String get language => 'اللغة';

  @override
  String get selectLanguage => 'اختر لغة التطبيق';

  @override
  String get habitNotifications => 'إشعارات العادات';

  @override
  String get mealLoggingPrompts => 'تذكيرات تسجيل الوجبات';

  @override
  String get mealLoggingPromptsSubtitle => 'احصل على تذكيرات لتسجيل وجباتك';

  @override
  String get waterIntakeReminders => 'تذكيرات شرب الماء';

  @override
  String get waterIntakeRemindersSubtitle => 'احصل على تذكيرات لشرب الماء';

  @override
  String get mindfulWalksReminders => 'تذكيرات المشي الواعي';

  @override
  String get mindfulWalksRemindersSubtitle => 'احصل على تذكيرات للمشي الواعي';

  @override
  String get momentOfCalmAfterMeals => 'لحظة هدوء بعد الوجبات';

  @override
  String get momentOfCalmAfterMealsSubtitle => 'اعرض نافذة هدوء بعد تسجيل وجبة';

  @override
  String get welcomeBack => 'مرحبًا بعودتك!';

  @override
  String get trackNutritionToday => 'لنقم بتتبع تغذيتك اليوم';

  @override
  String get subtitleAfternoon => 'وقت مثالي لتسجيل الغداء والحفاظ على التوازن.';

  @override
  String get subtitleEvening => 'استمر على المسار هذا المساء — سجّل وجباتك.';

  @override
  String get subtitleNight => 'اختم يومك — لا تنسَ تسجيل وجبات اليوم.';

  @override
  String get streakNearEndingTitle => 'حافظ على سلسلتك 🔥';

  @override
  String get streakNearEndingBody => 'سلسلتك على وشك الانتهاء. سجّل وجبة اليوم للحفاظ عليها!';

  @override
  String get streakNearEndingTitle2 => 'أوشكت على الوصول! 🔥';

  @override
  String get streakNearEndingBody2 => 'بقيت بضع ساعات فقط. سجّل وجبة لإنقاذ سلسلتك!';

  @override
  String get streakEndedTitle => 'انتهت السلسلة';

  @override
  String get streakEndedBody => 'انتهت سلسلتك. سجّل وجبة لتبدأ من جديد وتبنيها!';

  @override
  String get streakActive => 'سلسلة نشطة';

  @override
  String get streakInactive => 'سلسلة غير نشطة';

  @override
  String get currentStreak => 'السلسلة الحالية';

  @override
  String get entriesInStreak => 'المدخلات في السلسلة';

  @override
  String get days => 'أيام';

  @override
  String get startedOn => 'بدأت في';

  @override
  String get logMealToStartStreak => 'سجّل وجبة اليوم لبدء سلسلتك';

  @override
  String get nutritionSummary => 'ملخص التغذية';

  @override
  String get setCalorieAndMacroGoals => 'قم بتعيين أهداف السعرات والمغذيات في صفحة خطة التغذية.';

  @override
  String get protein => 'البروتين';

  @override
  String get carbs => 'الكربوهيدرات';

  @override
  String get fat => 'الدهون';

  @override
  String get calories => 'سعرات حرارية';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get logMeal => 'تسجيل وجبة';

  @override
  String get trackYourFood => 'تتبع طعامك';

  @override
  String get scan => 'مسح';

  @override
  String get barcode => 'باركود';

  @override
  String get analyzeYourFood => 'حلل طعامك';

  @override
  String get todaysMeals => 'وجبات اليوم';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get noMealsLoggedForThisDay => 'لا توجد وجبات مسجلة لهذا اليوم.';

  @override
  String get nutritionalPlan => 'خطة التغذية';

  @override
  String get weightAnalytics => 'تحليلات الوزن';

  @override
  String get toGoal => 'للهدف';

  @override
  String get remaining => 'المتبقي';

  @override
  String get weeklyRate => 'المعدل الأسبوعي';

  @override
  String get weeklyLoss => 'خسارة أسبوعية';

  @override
  String get starting => 'البداية';

  @override
  String get current => 'الحالي';

  @override
  String get today => 'اليوم';

  @override
  String get targetLabel => 'الهدف';

  @override
  String get goalWeight => 'وزن الهدف';

  @override
  String get eta => 'المدة';

  @override
  String get sinceStart => 'منذ البداية';

  @override
  String get expectationsDisclaimer => 'هذه التوقعات تعتمد على الاتجاه الأخير وقد تتغير مع تسجيل أوزان جديدة.';

  @override
  String get loseVerb => 'تخسر';

  @override
  String get gainVerb => 'تزيد';

  @override
  String expectationBlurb(Object direction, Object eta, Object rate, Object remaining, Object unit) {
    return 'استنادًا إلى اتجاهك الأخير، أنت على المسار لـ $direction حوالي $rate $unit في الأسبوع. بهذه الوتيرة، سيستغرق الأمر تقريبًا $eta للوصول إلى هدفك. تبقى لديك $remaining $unit.';
  }

  @override
  String get healthAwareness => 'الوعي الصحي';

  @override
  String get planSettings => 'إعدادات الخطة';

  @override
  String get featureComingSoon => 'هذه الميزة قادمة قريبًا!';

  @override
  String get ok => 'موافق';

  @override
  String get rateUsOnGoogle => 'قيّمنا على جوجل';

  @override
  String get comingSoon => 'قريبًا!';

  @override
  String get ratingOnGoogleAvailableAfterRelease => 'سيكون التقييم على جوجل متاحًا بعد الإصدار.';

  @override
  String get shareWithFriends => 'مشاركة مع الأصدقاء';

  @override
  String get sharingAvailableAfterRelease => 'ستكون المشاركة متاحة بعد الإصدار.';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get close => 'إغلاق';

  @override
  String get sendResetLink => 'إرسال رابط إعادة التعيين';

  @override
  String get send => 'إرسال';

  @override
  String get resend => 'إعادة إرسال';

  @override
  String get helpSupport => 'المساعدة والدعم';

  @override
  String get legal => 'قانوني';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get apiDocumentation => 'وثائق API';

  @override
  String get needAssistanceContactSupport => 'تحتاج مساعدة؟ تواصل مع فريق الدعم:';

  @override
  String get testWebURL => 'اختبار رابط ويب';

  @override
  String get testSimpleMailto => 'اختبار بريد إلكتروني بسيط';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get areYouSureYouWantToLogOut => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get no => 'لا';

  @override
  String get yes => 'نعم';

  @override
  String get commonQuestions => 'أسئلة شائعة';

  @override
  String get momentOfCalm => 'لحظة هدوء';

  @override
  String get practiceMindfulEating => 'خذ لحظة لتقدير وجبتك وممارسة الأكل الواعي.';

  @override
  String get howOldAreYou => 'كم عمرك؟';

  @override
  String get personalizeExperience => 'يساعدنا ذلك في تخصيص تجربتك';

  @override
  String get failedToOpenStore => 'Failed to open app store';

  @override
  String get updateAvailable => 'Update Available';

  @override
  String get newVersionAvailable => 'A new version of Yumie is available.';

  @override
  String get updateNow => 'Update Now';

  @override
  String get later => 'Later';

  @override
  String get whatsNew => 'What\'s New:';

  @override
  String get yourHeight => 'طولك';

  @override
  String get yourGoalWeight => 'وزنك المستهدف';

  @override
  String get setRealisticGoal => 'حدد هدفًا واقعيًا لرحلتك';

  @override
  String get allSet => 'تم كل شيء! 🎉';

  @override
  String get personalizedNutritionPlan => 'إليك خطة التغذية المخصصة لك. مرحبًا بك في رحلتك الصحية مع يومي!';

  @override
  String get whatIsYourBloodType => 'ما هي فصيلة دمك؟';

  @override
  String get personalizeHealthInsights => 'يساعدنا ذلك في تخصيص رؤى صحتك.';

  @override
  String get whatIsYourSex => 'ما هو جنسك؟';

  @override
  String get personalizeNutritionPlan => 'يساعدنا ذلك في تخصيص خطة التغذية الخاصة بك.';

  @override
  String get home => 'الرئيسية';

  @override
  String get food => 'الطعام';

  @override
  String get coach => 'المدرب';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get log => 'تسجيل';

  @override
  String get myMeals => 'وجباتي';

  @override
  String get suggestedMeals => 'وجبات مقترحة';

  @override
  String get monthly => 'شهري';

  @override
  String get weekly => 'أسبوعي';

  @override
  String get breakfast => 'الفطور';

  @override
  String get lunch => 'الغداء';

  @override
  String get dinner => 'العشاء';

  @override
  String get snack => 'وجبة خفيفة';

  @override
  String get reviewMeal => 'مراجعة الوجبة';

  @override
  String get chat => 'الدردشة';

  @override
  String get insights => 'الرؤى';

  @override
  String get clearChat => 'مسح الدردشة';

  @override
  String get coachWelcome => 'مرحبًا! أنا يومي، مدربك الغذائي. كيف يمكنني مساعدتك اليوم؟\n\nاسأل يومي عن وصفات صحية أو خطط وجبات أو نصائح غذائية!';

  @override
  String get refreshInsight => 'تحديث الرؤية';

  @override
  String get healthInsights => 'رؤى صحية';

  @override
  String get noInsightAvailable => 'لا توجد رؤى متاحة.';

  @override
  String get dinnerIdeas => 'أفكار للعشاء';

  @override
  String get calorieCheck => 'فحص السعرات';

  @override
  String get proteinSnacks => 'وجبات خفيفة غنية بالبروتين';

  @override
  String get dietTips => 'نصائح غذائية';

  @override
  String get typeYourMessage => 'اكتب رسالتك...';

  @override
  String get yumie => 'يومي';

  @override
  String get askAboutMeals => 'اسأل عن الوجبات والتغذية';

  @override
  String get coachQuick1 => 'ماذا يجب أن آكل اليوم؟';

  @override
  String get coachQuick2 => 'حلل وجبتي الأخيرة';

  @override
  String get coachQuick3 => 'ساعدني في تخطيط أسبوعي';

  @override
  String get yumieThinking => 'يومي يفكر...';

  @override
  String get bmi => 'مؤشر كتلة الجسم';

  @override
  String get target => 'الهدف';

  @override
  String get weight => 'الوزن';

  @override
  String get age => 'العمر';

  @override
  String get height => 'الطول';

  @override
  String get targetWeight => 'الوزن المستهدف';

  @override
  String get calorieGoal => 'هدف السعرات';

  @override
  String get proteinGoal => 'هدف البروتين';

  @override
  String get carbGoal => 'هدف الكربوهيدرات';

  @override
  String get fatGoal => 'هدف الدهون';

  @override
  String get waterIntake => 'شرب الماء';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get undo => 'تراجع';

  @override
  String get notSet => 'غير محدد';

  @override
  String get uploadNew => 'رفع صورة جديدة';

  @override
  String get delete => 'حذف';

  @override
  String get editName => 'تعديل الاسم';

  @override
  String get bloodType => 'فصيلة الدم';

  @override
  String get bloodTypeOptional => 'فصيلة الدم اختيارية ولا تؤثر على تتبع السعرات الحرارية أو التوصيات.';

  @override
  String get areYouDiabetic => 'هل أنت مريض بالسكري؟';

  @override
  String get healthAwarenessUpdated => 'تم تحديث الوعي الصحي!';

  @override
  String get takeMomentToAppreciate => 'خذ لحظة لتقدير وجبتك وممارسة الأكل الواعي.';

  @override
  String get continueButton => 'متابعة';

  @override
  String get mealSaved => '🎉 تم حفظ الوجبة!';

  @override
  String get noRecentFoods => 'لا توجد أطعمة حديثة.';

  @override
  String get buildCustomMeal => 'إنشاء وجبة مخصصة';

  @override
  String get mealName => 'اسم الوجبة';

  @override
  String get searchOrEnterFoodName => 'ابحث أو أدخل اسم الطعام';

  @override
  String get ingredients => 'المكونات';

  @override
  String get addIngredient => 'أضف مكونًا';

  @override
  String get myFoods => 'أطعمني';

  @override
  String get noCustomFoods => 'لم تقم بحفظ أي أطعمة مخصصة بعد';

  @override
  String get addCustomFood => 'أضف طعامًا مخصصًا';

  @override
  String get editCustomMeal => 'تعديل وجبة مخصصة';

  @override
  String get clearAll => 'مسح الكل';

  @override
  String get foodName => 'اسم الطعام';

  @override
  String get saveMeal => 'حفظ الوجبة';

  @override
  String get customizeMeal => 'تخصيص الوجبة';

  @override
  String get hideIngredients => 'إخفاء المكونات';

  @override
  String get showIngredients => 'إظهار المكونات';

  @override
  String get ingredientsColon => 'المكونات:';

  @override
  String get noIngredientsListed => 'لا توجد مكونات مدرجة.';

  @override
  String get recent => 'الأخيرة';

  @override
  String get meal => 'وجبة';

  @override
  String get fridge => 'ثلاجة';

  @override
  String get placeFoodInFrame => 'ضع الطعام داخل الإطار';

  @override
  String get placeBarcodeInFrame => 'ضع الباركود في الإطار واضغط على الكاميرا';

  @override
  String get placeFridgeInFrame => 'قم بمحاذاة الثلاجة داخل الإطار';

  @override
  String get productNotFound => 'لم يتم العثور على المنتج';

  @override
  String get safetyUnsafe => 'غير آمن';

  @override
  String get safetyGood => 'مناسب للاستهلاك';

  @override
  String get badgeNutriScore => 'نوتري‑سكور';

  @override
  String get badgeNova => 'NOVA';

  @override
  String get allergensTitle => 'المواد المسببة للحساسية';

  @override
  String get contains => 'يحتوي على';

  @override
  String get allergensNone => 'لا توجد مواد مُسجلة';

  @override
  String get serving => 'الحصة';

  @override
  String get kcalPer100g => 'كيلو كالوري/100غ';

  @override
  String get sugar => 'سكر';

  @override
  String get satFat => 'دهون مشبعة';

  @override
  String get salt => 'ملح';

  @override
  String get ingredientsTitle => 'المكونات';

  @override
  String get riskAllergen => 'خطر الحساسية';

  @override
  String get riskUltraProcessed => 'فائق المعالجة (NOVA 4)';

  @override
  String get riskHighAdditives => 'مضافات عالية';

  @override
  String get riskLowNutri => 'نوتري‑سكور منخفض';

  @override
  String get riskVegan => 'مناسب للنباتيين الصِرف';

  @override
  String get riskVegetarian => 'نباتي';

  @override
  String get riskLooksGood => 'يبدو جيدًا';

  @override
  String get retakeScan => 'إعادة المسح';

  @override
  String get previewFullImage => 'عرض الصورة كاملة';

  @override
  String get discard => 'تجاهل';

  @override
  String get upgradeToPremium => 'الترقية إلى بريميوم';

  @override
  String get getUnlimitedScans => 'احصل على عمليات مسح غير محدودة والمزيد!';

  @override
  String get getUnlimitedSearches => 'احصل على عمليات بحث غير محدودة والمزيد!';

  @override
  String get upgradePlan => 'ترقية الخطة';

  @override
  String get watchAdForScan => 'شاهد إعلان للمسح';

  @override
  String get watchAdForSearch => 'شاهد إعلان للبحث';

  @override
  String get generateMeal => 'إنشاء وجبة';

  @override
  String get detectedFridgeItems => 'العناصر المكتشفة في الثلاجة';

  @override
  String get noFridgeItemsDetected => 'لم يتم اكتشاف عناصر في الثلاجة.';

  @override
  String get searchResults => 'نتائج البحث';

  @override
  String get searchingFor => 'البحث عن';

  @override
  String get noResultsFoundFor => 'لم يتم العثور على نتائج لـ';

  @override
  String get count => 'عدد';

  @override
  String get servings => 'حصص';

  @override
  String get fluidOunces => 'أونصة سائلة';

  @override
  String get quantity => 'الكمية';

  @override
  String get confirm => 'تأكيد';

  @override
  String get ingredient => 'مكون';

  @override
  String get drink => 'مشروب';

  @override
  String get kg => 'كغ';

  @override
  String get g => 'غرام';

  @override
  String get mg => 'ميليغرام';

  @override
  String get cm => 'سم';

  @override
  String get m => 'متر';

  @override
  String get kcal => 'سعرة حرارية';

  @override
  String get cal => 'سعرة';

  @override
  String get lb => 'رطل';

  @override
  String get oz => 'أونصة';

  @override
  String get ft => 'قدم';

  @override
  String get inches => 'بوصة';

  @override
  String get cup => 'كوب';

  @override
  String get tbsp => 'ملعقة كبيرة';

  @override
  String get tsp => 'ملعقة صغيرة';

  @override
  String get ml => 'مل';

  @override
  String get l => 'لتر';

  @override
  String get upgradeToPremiumTitle => 'الترقية إلى بريميوم';

  @override
  String get premiumFeatures => 'ميزات البريميوم';

  @override
  String get unlimitedScans => 'مسح غير محدود';

  @override
  String get aiNutritionCoach => 'مدرب تغذية بالذكاء الاصطناعي';

  @override
  String get detailedAnalytics => 'تحليلات مفصلة';

  @override
  String get personalizedMealPlans => 'خطط وجبات شخصية';

  @override
  String get noAdvertisements => 'بدون إعلانات';

  @override
  String get yearlyPremium => 'بريميوم سنوي';

  @override
  String get monthlyPremium => 'بريميوم شهري';

  @override
  String savePercent(Object percent) {
    return 'وفر $percent%';
  }

  @override
  String get perYear => '/سنة';

  @override
  String get perMonth => '/شهر';

  @override
  String get popular => 'شائع';

  @override
  String get maybeLater => 'ربما لاحقاً';

  @override
  String get welcomeToYumie => 'مرحباً بك في يومي!';

  @override
  String get unlockPremiumFeatures => 'فتح ميزات البريميوم';

  @override
  String get getMostOutOfHealthJourney => 'احصل على أقصى استفادة من رحلتك الصحية مع وصول غير محدود!';

  @override
  String get unlimitedScansAICoaching => 'افتح المسح غير المحدود وتدريب الذكاء الاصطناعي وخطط الوجبات المخصصة!';

  @override
  String get subscribe => 'اشترك';

  @override
  String get foodNameLabel => 'اسم الطعام';

  @override
  String get managePermissions => 'إدارة الأذونات';

  @override
  String get cameraNotificationsAndMore => 'الكاميرا والإشعارات والمزيد';

  @override
  String get deleteMeal => 'حذف الوجبة';

  @override
  String get areYouSureDeleteMeal => 'هل أنت متأكد من أنك تريد حذف هذه الوجبة؟';

  @override
  String get unknown => 'غير معروف';

  @override
  String get servings1 => 'حصة واحدة';

  @override
  String get edit => 'تعديل';

  @override
  String get ignoreFood => 'تجاهل الطعام';

  @override
  String get addComponent => 'أضف مكونًا';

  @override
  String get components => 'المكونات';

  @override
  String get recentFoods => 'الأطعمة الحديثة';

  @override
  String get logWeightChange => 'الوزن';

  @override
  String get lost => 'فقدان';

  @override
  String get gained => 'زيادة';

  @override
  String get googleSignInHelp => 'مساعدة تسجيل الدخول بجوجل';

  @override
  String get couldNotOpenTermsOfService => 'لا يمكن فتح شروط الخدمة';

  @override
  String get couldNotOpenPrivacyPolicy => 'لا يمكن فتح سياسة الخصوصية';

  @override
  String get errorSavingProfile => 'خطأ في حفظ الملف الشخصي';

  @override
  String get completeYourProfile => 'أكمل ملفك الشخصي';

  @override
  String get saveAndContinue => 'حفظ ومتابعة';

  @override
  String get pleasSignIn => 'يرجى تسجيل الدخول.';

  @override
  String get noFoodLogsYet => 'لا توجد سجلات طعام بعد.';

  @override
  String get healthAIFoodLog => 'HealthAI - سجل الطعام';

  @override
  String get addLog => 'إضافة سجل';

  @override
  String get unableToShareAtThisTime => 'لا يمكن المشاركة في الوقت الحالي. يرجى المحاولة مرة أخرى.';

  @override
  String get failedToUpdatePhoto => 'فشل في تحديث الصورة';

  @override
  String get changeProfileName => 'تغيير اسم الملف الشخصي';

  @override
  String get failedToUpdateName => 'فشل في تحديث الاسم';

  @override
  String get profileUpdatedSuccessfully => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get errorUpdatingProfile => 'خطأ في تحديث الملف الشخصي';

  @override
  String get editGoals => 'تعديل الأهداف';

  @override
  String get goalsUpdatedSuccessfully => 'تم تحديث الأهداف بنجاح';

  @override
  String get errorUpdatingGoals => 'خطأ في تحديث الأهداف';

  @override
  String get couldNotOpenWebsite => 'لا يمكن فتح الموقع الإلكتروني';

  @override
  String get errorOpeningWebsite => 'خطأ في فتح الموقع الإلكتروني';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get spanish => 'الإسبانية';

  @override
  String get reviewMealTitle => 'مراجعة الوجبة';

  @override
  String get startingWeight => 'الوزن البداية';

  @override
  String get appPermissions => 'أذونات التطبيق';

  @override
  String get permissionStatus => 'حالة الأذونات';

  @override
  String get manageAppPermissions => 'إدارة أذونات التطبيق لضمان عمل جميع الميزات بشكل صحيح';

  @override
  String get camera => 'الكاميرا';

  @override
  String get scanFoodItems => 'مسح عناصر الطعام والتقاط صور للوجبات';

  @override
  String get photoLibrary => 'الصور';

  @override
  String get saveScannedImages => 'حفظ الصور الممسوحة واختيار الصور';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get sendMealReminders => 'إرسال تذكيرات الوجبات والتنبيهات الصحية';

  @override
  String get needHelp => 'تحتاج مساعدة؟';

  @override
  String get permanentlyDeniedHelp => 'إذا تم رفض الأذونات نهائياً، يمكنك تمكينها في إعدادات جهازك';

  @override
  String get openDeviceSettings => 'فتح إعدادات الجهاز';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'مساء الخير';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String get goodNight => 'تصبح على خير';

  @override
  String get ounces => 'أونصات';

  @override
  String get january => 'يناير';

  @override
  String get february => 'فبراير';

  @override
  String get march => 'مارس';

  @override
  String get april => 'أبريل';

  @override
  String get may => 'مايو';

  @override
  String get june => 'يونيو';

  @override
  String get july => 'يوليو';

  @override
  String get august => 'أغسطس';

  @override
  String get september => 'سبتمبر';

  @override
  String get october => 'أكتوبر';

  @override
  String get november => 'نوفمبر';

  @override
  String get december => 'ديسمبر';

  @override
  String get trackYourNutrition => 'تتبع تغذيتك';

  @override
  String get messages => 'الرسائل';

  @override
  String get subscribeForDailyInsights => 'اشترك للحصول على رؤى يومية';

  @override
  String get getPersonalizedHealthInsights => 'احصل على رؤى صحية مخصصة بناءً على ملفك الشخصي الكامل';

  @override
  String get upgradeDescription => 'احصل على عمليات مسح ومبحث غير محدودة ورؤى مدعومة بالذكاء الاصطناعي';

  @override
  String get unlimitedFoodScans => 'مسح غذاء غير محدود';

  @override
  String get unlimitedFoodSearches => 'بحث غذاء غير محدود';

  @override
  String get unlimitedAICoachMessages => 'رسائل مدرب ذكي غير محدودة';

  @override
  String get dailyHealthInsights => 'رؤى صحية يومية';

  @override
  String get logWaterIntake => 'الماء';

  @override
  String get add => 'أضف';

  @override
  String get freemium => 'فريميوم';

  @override
  String get premium => 'بريميوم';

  @override
  String get chooseYourPlan => 'اختر خطتك';

  @override
  String get water => 'ماء';

  @override
  String get resetPasswordDescription => 'سيتم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountDescription => 'حذف حسابك وجميع البيانات نهائياً';

  @override
  String get confirmDeleteAccount => 'هل أنت متأكد من أنك تريد حذف حسابك؟';

  @override
  String get deleteAccountWarning => 'لا يمكن التراجع عن هذا الإجراء. جميع بياناتك بما في ذلك الوجبات والتقدم والإعدادات ستُحذف نهائياً.';

  @override
  String get typeDeleteToConfirm => 'اكتب \"DELETE\" للتأكيد';

  @override
  String get deleteAccountFinalConfirmation => 'DELETE';

  @override
  String get accountDeleted => 'تم حذف الحساب';

  @override
  String get errorDeletingAccount => 'خطأ في حذف الحساب';

  @override
  String get totalNutrition => 'إجمالي التغذية';

  @override
  String get unlockUnlimitedScans => 'فتح المسح غير المحدود، التدريب بالذكاء الاصطناعي،\nوخطط الوجبات الشخصية';

  @override
  String get unlimitedFoodScanning => 'مسح طعام غير محدود';

  @override
  String get yearPrice => 'سنة/49.99\$';

  @override
  String get monthPrice => 'شهر/7.99\$';

  @override
  String get save37 => 'وفر 37%';

  @override
  String get youArePremium => 'أنت مميز!';

  @override
  String get yumiePremiumMonthly => 'يومي بريميوم شهري';

  @override
  String get yumiePremiumYearly => 'يومي بريميوم سنوي';

  @override
  String get restorePurchases => 'استعادة المشتريات';

  @override
  String get checkingForPurchases => 'البحث عن المشتريات الموجودة...';

  @override
  String get purchasesRestored => 'تمت استعادة المشتريات بنجاح!';

  @override
  String get noPurchasesFound => 'لم يتم العثور على مشتريات سابقة';

  @override
  String get restoreFailed => 'فشل في استعادة المشتريات. يرجى المحاولة مرة أخرى.';

  @override
  String get restoreInProgress => 'جاري استعادة المشتريات...';

  @override
  String get bySubscribing => 'بالاشتراك، فإنك توافق على شروط الخدمة وسياسة الخصوصية. تتجدد الاشتراكات تلقائياً ما لم يتم إلغاؤها';

  @override
  String get permissionsComplete => 'اكتملت الأذونات!';

  @override
  String get whyWeAskForPermissions => 'لماذا نطلب الأذونات';

  @override
  String get permissionsWhyBody => 'نحتاج إلى الكاميرا، والإشعارات، والموقع الاختياري لتحسين تجربتك.';

  @override
  String get permissionsNextScreen => 'في الشاشة التالية، يمكنك تمكين الأذونات.';

  @override
  String get references => 'المراجع';

  @override
  String get cdcAboutBmi => 'مركز السيطرة على الأمراض: حول مؤشر كتلة الجسم';

  @override
  String get usdaDietaryGuidelines => 'المبادئ التوجيهية الغذائية لوزارة الزراعة الأمريكية';

  @override
  String get termsOfUseEula => 'اتفاقية ترخيص المستخدم النهائي';

  @override
  String get enterYourPassword => 'أدخل كلمة المرور';

  @override
  String get manageSessions => 'إدارة الجلسات';

  @override
  String get selectLanguageTitle => 'اختر اللغة';

  @override
  String get chooseYourPreferredLanguage => 'اختر لغتك المفضلة للتطبيق';

  @override
  String get languageChangedTo => 'تم تغيير اللغة إلى';

  @override
  String get activeSessions => 'الجلسات النشطة';

  @override
  String get thisDevice => 'هذا الجهاز';

  @override
  String get sessionRevoked => 'تم إلغاء الجلسة';

  @override
  String get allOtherSessionsSignedOut => 'تم تسجيل الخروج من جميع الجلسات الأخرى';

  @override
  String get signOutAllOthers => 'تسجيل الخروج من الكل';

  @override
  String get noSecurityAlerts => 'لا توجد تنبيهات أمنية';

  @override
  String get passwordStrengthWeak => 'ضعيفة';

  @override
  String get passwordStrengthFair => 'مقبولة';

  @override
  String get passwordStrengthGood => 'جيدة';

  @override
  String get passwordStrengthStrong => 'قوية';

  @override
  String get passwordStrengthVeryStrong => 'قوية جداً';

  @override
  String get addLowercaseLetters => 'أضف أحرف صغيرة';

  @override
  String get addUppercaseLetters => 'أضف أحرف كبيرة';

  @override
  String get addNumbers => 'أضف أرقام';

  @override
  String get addSpecialCharacters => 'أضف رموز خاصة (!@#\$%^&*)';

  @override
  String get avoidCommonPatterns => 'تجنب الأنماط الشائعة';

  @override
  String get requiresAtLeast8Characters => 'يتطلب 8 أحرف على الأقل';

  @override
  String get tooManySignInAttempts => 'محاولات تسجيل دخول كثيرة. حاول مرة أخرى لاحقاً.';

  @override
  String get tooManySignUpAttempts => 'محاولات تسجيل كثيرة. حاول مرة أخرى لاحقاً.';

  @override
  String get tooManyPasswordResetRequests => 'طلبات إعادة تعيين كلمة مرور كثيرة. حاول مرة أخرى لاحقاً.';

  @override
  String get multipleFailedSignInAttempts => 'محاولات تسجيل دخول فاشلة متعددة';

  @override
  String get excessivePasswordResetRequests => 'طلبات إعادة تعيين كلمة مرور مفرطة';

  @override
  String get suspiciousActivityDetected => 'تم اكتشاف نشاط مشبوه';

  @override
  String get riskLevelMedium => 'متوسط';

  @override
  String get riskLevelHigh => 'عالي';

  @override
  String get welcomeToYumiePermissions => 'مرحباً بك في يومي';

  @override
  String get provideBestExperience => 'لتزويدك بأفضل تجربة، نحتاج إلى بعض الأذونات';

  @override
  String get grantPermissions => 'منح الأذونات';

  @override
  String get skipForNow => 'تخطي الآن';

  @override
  String get denied => 'مُرفوض';

  @override
  String get granted => 'مُمنوح';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get signUpToGetStarted => 'سجل للبدء مع يومي';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get agreeToTerms => 'وشروط الخدمة أوافق على سياسة الخصوصية';

  @override
  String get alreadyHaveAccount => 'هل لديك حساب بالفعل؟';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signUp => 'التسجيل';

  @override
  String get signInToAccessAccount => 'سجل الدخول للوصول إلى حسابك';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get signUpWithGoogle => 'التسجيل باستخدام جوجل';

  @override
  String get signInWithGoogle => 'تسجيل الدخول باستخدام جوجل';

  @override
  String get signUpWithApple => 'التسجيل مع Apple';

  @override
  String get signInWithApple => 'تسجيل الدخول باستخدام آبل';

  @override
  String get resetPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get enterEmailForReset => 'أدخل عنوان بريدك الإلكتروني لتلقي رابط إعادة تعيين كلمة المرور';

  @override
  String get emailAddress => 'عنوان البريد الإلكتروني';

  @override
  String get rateUsOn => 'قيّمنا على';

  @override
  String get deleteAccountTitle => 'حذف الحساب';

  @override
  String get deleteAccountWarningTitle => 'هذا الإجراء دائم ولا يمكن التراجع عنه';

  @override
  String get deleteAccountDataList => 'عند حذف حسابك، سنقوم بإزالة ما يلي نهائياً:';

  @override
  String get allMealLogsAndNutrition => 'جميع سجلات وجباتك وبيانات التغذية';

  @override
  String get profileAndPersonalInfo => 'ملفك الشخصي ومعلوماتك الشخصية';

  @override
  String get allUploadedPhotos => 'جميع الصور والملفات المرفوعة';

  @override
  String get customMealsAndRecipes => 'وجباتك ووصفاتك المخصصة';

  @override
  String get allAppPreferences => 'جميع تفضيلات وإعدادات التطبيق';

  @override
  String get activeSessionsAllDevices => 'الجلسات النشطة على جميع الأجهزة';

  @override
  String get exportDataWarning => 'تأكد من تصدير أي بيانات تريد الاحتفاظ بها قبل المتابعة';

  @override
  String get understandActionPermanent => 'أفهم أن هذا الإجراء دائم';

  @override
  String get typeDeleteHere => 'اكتب DELETE هنا';

  @override
  String get deleteForever => 'حذف نهائياً';

  @override
  String get noSecurityAlertsFound => 'لا توجد تنبيهات أمنية';

  @override
  String get yourAccountLooksGood => 'حسابك يبدو جيداً! لم يتم اكتشاف أي نشاط مشبوه.';

  @override
  String get manageActiveSessionsAcrossDevices => 'إدارة جلساتك النشطة عبر أجهزة مختلفة';

  @override
  String get noActiveSessionsFound => 'لم يتم العثور على جلسات نشطة';

  @override
  String get signOutAllOtherSessions => 'تسجيل الخروج من الكل';

  @override
  String get aiSearch => 'البحث بالذكاء الاصطناعي';

  @override
  String get aiSearchDescription => 'البحث عن عناصر الطعام باستخدام الذكاء الاصطناعي';

  @override
  String get noIngredientsListedText => 'لا توجد مكونات مدرجة';

  @override
  String get breakfastTime => 'وقت الفطور';

  @override
  String get lunchTime => 'وقت الغداء';

  @override
  String get dinnerTime => 'وقت العشاء';

  @override
  String get snackTime => 'وقت الوجبة الخفيفة';

  @override
  String get deletingYourAccount => 'حذف حسابك...';

  @override
  String get thisMayTakeAFewMoments => 'قد يستغرق هذا بضع لحظات';

  @override
  String get redirectingToSignIn => 'إعادة التوجيه إلى تسجيل الدخول...';

  @override
  String weightTrendNoData(Object remaining, Object unit) {
    return 'لا توجد بيانات وزن كافية.';
  }

  @override
  String weightTrendHealthyRate(Object eta, Object rate, Object remaining, Object unit) {
    return 'معدل صحي: $rate$unit/أسبوع';
  }

  @override
  String get accountSuccessfullyDeleted => 'تم حذف الحساب بنجاح';

  @override
  String get pleaseCloseAndRestartApp => 'يرجى إغلاق التطبيق وإعادة تشغيله للمتابعة.';

  @override
  String get exportData => 'تصدير البيانات';

  @override
  String get exportDataDescription => 'تصدير جميع بياناتك كملف PDF';

  @override
  String get exportComplete => 'اكتمل التصدير';

  @override
  String get exportCompleteMessage => 'تم تصدير بياناتك بنجاح!';

  @override
  String get exportCompleteDescription => 'تم حفظ ملف PDF في جهازك ويمكن مشاركته أو عرضه.';

  @override
  String get exportFailed => 'فشل التصدير';

  @override
  String get exportingData => 'جاري تصدير بياناتك...';

  @override
  String get exportingDataDescription => 'قد يستغرق هذا بضع لحظات';

  @override
  String get restartApp => 'إعادة تشغيل التطبيق';

  @override
  String get cameraAccess => 'الوصول للكاميرا';

  @override
  String get cameraAccessMessage => 'يحتاج يومي للوصول للكاميرا لمسح عناصر الطعام ومساعدتك في تسجيل وجباتك بدقة.';

  @override
  String get photoLibraryAccess => 'الوصول لمكتبة الصور';

  @override
  String get photoLibraryAccessMessage => 'يحتاج يومي للوصول لمكتبة الصور لحفظ الصور الممسوحة واختيار الصور لتسجيل الوجبات.';

  @override
  String get notificationAccess => 'الوصول للإشعارات';

  @override
  String get notificationAccessMessage => 'يحتاج يومي للوصول للإشعارات لإرسال تذكيرات الوجبات وتنبيهات شرب الماء ودعوات المشي الواعي.';

  @override
  String get notNow => 'ليس الآن';

  @override
  String get permissionsCompleted => 'اكتملت الأذونات!';

  @override
  String get allPermissionsGranted => 'تم منح جميع الأذونات! أنت مستعد لاستخدام يومي.';

  @override
  String get whatIsYourMainGoal => 'ما هو هدفك الرئيسي؟';

  @override
  String get chooseGoalDescription => 'اختر الهدف الذي يتماشى مع رحلتك';

  @override
  String get loseBodyWeight => 'إنقاص وزن الجسم';

  @override
  String get gainWeight => 'زيادة الوزن';

  @override
  String get buildMuscle => 'بناء العضلات';

  @override
  String get eatHealthier => 'تناول طعام أكثر صحة';

  @override
  String get maintainBodyWeight => 'الحفاظ على وزن الجسم';

  @override
  String get setRealisticGoalForJourney => 'حدد هدفاً واقعياً لرحلتك';

  @override
  String get targetWeightSetToCurrent => 'تم تعيين وزن هدفك إلى وزنك الحالي';

  @override
  String get iAcceptThe => 'أوافق على';

  @override
  String get and => 'و';

  @override
  String get johnDoe => 'أحمد محمد';

  @override
  String get yourEmailExample => 'your.email@example.com';

  @override
  String get byContinuingYouAgreeToOur => 'بالمتابعة، فإنك توافق على';

  @override
  String get whatMotivatesYou => 'ما الذي يحفزك؟';

  @override
  String get chooseWhatDrivesYou => 'اختر ما يدفعك لتحقيق أهدافك';

  @override
  String get feelEnergeticEveryDay => 'الشعور بالنشاط كل يوم';

  @override
  String get achievePersonalMilestone => 'تحقيق إنجاز شخصي';

  @override
  String get boostMyConfidence => 'تعزيز ثقتي بنفسي';

  @override
  String get longTermHealth => 'الصحة على المدى الطويل';

  @override
  String get trackYourMealsWithEase => 'تتبع وجباتك بسهولة';

  @override
  String get caloriesLeft => 'سعرة حرارية متبقية';

  @override
  String get thisHelpsUsPersonalizeNutrition => 'هذا يساعدنا على تخصيص خطة التغذية الخاصة بك';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get other => 'آخر';

  @override
  String get thisHelpsUsPersonalizeExperience => 'هذا يساعدنا على تخصيص تجربتك';

  @override
  String get older => 'أكبر';

  @override
  String get younger => 'أصغر';

  @override
  String get yearsOld => 'سنة';

  @override
  String get selected => 'مُختار';

  @override
  String get teens => 'المراهقون';

  @override
  String get yourCurrentWeight => 'وزنك الحالي';

  @override
  String get activityLevel => 'مستوى النشاط';

  @override
  String get diabetic => 'مريض بالسكري؟';

  @override
  String get howMuchWaterADay => 'كم كوب ماء يومياً؟';

  @override
  String get fitnessProfile => 'ملف اللياقة البدنية';

  @override
  String get dueToCurrentAnswers => 'بناءً على إجاباتك الحالية';

  @override
  String get remindersWouldYouLike => 'ما التذكيرات التي تود تلقيها؟';

  @override
  String get yumieIsCookingUp => 'يومي يحضر خطة التغذية الشخصية الخاصة بك...';

  @override
  String get yourAllSet => 'أنت جاهز تماماً!';

  @override
  String get google => 'Google';

  @override
  String get fiftyPlus => '50+';

  @override
  String get forties => 'الأربعينيات';

  @override
  String get thirties => 'الثلاثينيات';

  @override
  String get twenties => 'العشرينيات';

  @override
  String get weightUnit => 'كغ';

  @override
  String get heightUnit => 'سم';

  @override
  String get feetUnit => 'قدم';

  @override
  String get inchesUnit => 'بوصة';

  @override
  String get poundsUnit => 'رطل';

  @override
  String get whatIsYourAge => 'ما هو عمرك؟';

  @override
  String get whatIsYourHeight => 'ما هو طولك؟';

  @override
  String get whatIsYourWeight => 'ما هو وزنك الحالي؟';

  @override
  String get whatIsYourGoalWeight => 'ما هو وزن هدفك؟';

  @override
  String get whatIsYourActivityLevel => 'ما هو مستوى نشاطك؟';

  @override
  String get howMuchWaterDaily => 'كم كوب ماء تشرب يومياً؟';

  @override
  String get sedentary => 'خامل';

  @override
  String get lightlyActive => 'نشيط قليلاً';

  @override
  String get moderatelyActive => 'نشيط معتدل';

  @override
  String get veryActive => 'نشيط جداً';

  @override
  String get extremelyActive => 'نشيط للغاية';

  @override
  String get aPositive => 'A+';

  @override
  String get aNegative => 'A-';

  @override
  String get bPositive => 'B+';

  @override
  String get bNegative => 'B-';

  @override
  String get abPositive => 'AB+';

  @override
  String get abNegative => 'AB-';

  @override
  String get oPositive => 'O+';

  @override
  String get oNegative => 'O-';

  @override
  String get dontKnow => 'لا أعرف';

  @override
  String get oneToTwoGlasses => '1-2 كوب';

  @override
  String get threeToFourGlasses => '3-4 أكواب';

  @override
  String get fiveToSixGlasses => '5-6 أكواب';

  @override
  String get sevenToEightGlasses => '7-8 أكواب';

  @override
  String get moreThanEightGlasses => 'أكثر من 8 أكواب';

  @override
  String get mealReminders => 'تذكيرات الوجبات';

  @override
  String get waterReminders => 'تذكيرات الماء';

  @override
  String get workoutReminders => 'تذكيرات التمارين';

  @override
  String get progressUpdates => 'تحديثات التقدم';

  @override
  String get dailyTips => 'نصائح يومية';

  @override
  String get youAreAllSet => 'أنت جاهز تماماً!';

  @override
  String get welcomeToYourHealthJourney => 'مرحباً برحلتك الصحية';

  @override
  String get letsGetStarted => 'لنبدأ!';

  @override
  String get pleaseWait => 'يرجى الانتظار...';

  @override
  String get cookingUpYourPlan => 'نحضر خطتك الشخصية';

  @override
  String get analyzingYourData => 'نحلل بياناتك';

  @override
  String get creatingCustomPlan => 'ننشئ خطة التغذية المخصصة لك';

  @override
  String get almostDone => 'انتهينا تقريباً!';

  @override
  String get subscriptionRequired => 'اشتراك مطلوب';

  @override
  String get upgradeToUnlock => 'ترقية لفتح جميع الميزات';

  @override
  String get startFreeTrial => 'ابدأ التجربة المجانية';

  @override
  String get month => 'الشهر';

  @override
  String get year => 'سنة';

  @override
  String get free => 'مجاني';

  @override
  String get mostPopular => 'الأكثر شعبية';

  @override
  String get skip => 'تخطي';

  @override
  String get next => 'التالي';

  @override
  String get back => 'رجوع';

  @override
  String get done => 'تم';

  @override
  String get error => 'خطأ';

  @override
  String get success => 'نجح';

  @override
  String get warning => 'تحذير';

  @override
  String get info => 'معلومات';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get noDataAvailable => 'لا توجد بيانات متاحة';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get somethingWentWrong => 'حدث خطأ ما';

  @override
  String get internetConnectionRequired => 'مطلوب اتصال بالإنترنت';

  @override
  String get pleaseCheckConnection => 'يرجى التحقق من اتصالك بالإنترنت';

  @override
  String get restartOnboarding => 'إعادة تشغيل التهيئة';

  @override
  String get getStarted => 'ابدأ';

  @override
  String get couldNotOpenPlayStore => 'لا يمكن فتح متجر Play';

  @override
  String get errorOpeningPlayStore => 'خطأ في فتح متجر Play';

  @override
  String get remove => 'إزالة';

  @override
  String get couldNotOpenLink => 'لا يمكن فتح الرابط';

  @override
  String get nothingFoundInScan => 'لم يتم العثور على شيء في المسح';

  @override
  String get errorOpeningLink => 'خطأ في فتح الرابط';

  @override
  String get help => 'مساعدة';

  @override
  String get name => 'الاسم';

  @override
  String get dailyCalorieGoal => 'هدف السعرات الحرارية اليومي';

  @override
  String get manageSubscription => 'إدارة الاشتراك';

  @override
  String get deletionFailed => 'فشل الحذف';

  @override
  String get dismiss => 'إغلاق';

  @override
  String get grantPermission => 'منح الإذن';

  @override
  String get littleOrNoExercise => 'قليل أو لا يوجد تمارين';

  @override
  String get lightExercise => 'تمارين خفيفة/رياضة 1-3 أيام/أسبوع';

  @override
  String get moderateExercise => 'تمارين معتدلة/رياضة 3-5 أيام/أسبوع';

  @override
  String get hardExercise => 'تمارين شاقة/رياضة 6-7 أيام/أسبوع';

  @override
  String get share => 'مشاركة';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get notificationsForMealLogging => 'إشعارات لتذكيرات تسجيل الوجبات';

  @override
  String get notificationsForWaterIntake => 'إشعارات لتذكيرات شرب الماء';

  @override
  String get notificationsForMindfulWalk => 'إشعارات لتذكيرات المشي الواعي';

  @override
  String get increment => 'زيادة';

  @override
  String get enterNewName => 'أدخل اسم جديد';

  @override
  String get readOurPrivacyPolicy => 'اقرأ سياسة الخصوصية الخاصة بنا';

  @override
  String get readOurTermsOfService => 'اقرأ شروط الخدمة الخاصة بنا';

  @override
  String get helpUsCalculateYourHealthGoals => 'ساعدنا في حساب أهدافك الصحية';

  @override
  String get thisHelpsUsTrackYourProgress => 'هذا يساعدنا في تتبع تقدمك';

  @override
  String get setARealisticGoalForYourJourney => 'ضع هدفاً واقعياً لرحلتك';

  @override
  String get thisHelpsUsPersonalizeYourPlan => 'هذا يساعدنا في تخصيص خطتك';

  @override
  String get stayingHydratedIsKeyToYourHealth => 'البقاء رطباً هو مفتاح صحتك';

  @override
  String get yourFitnessProfileDueToYourAnswers => 'ملف اللياقة البدنية الخاص بك بناءً على إجاباتك';

  @override
  String get currentBMI => 'مؤشر كتلة الجسم الحالي';

  @override
  String get obese => 'سمنة';

  @override
  String get activityLevelLabel => 'مستوى النشاط';

  @override
  String get bloodTypeLabel => 'فصيلة الدم';

  @override
  String get diabeticLabel => 'مريض بالسكري';

  @override
  String get waterIntakeLabel => 'كمية الماء اليومية';

  @override
  String get heresYourPersonalizedNutritionPlan => 'إليك خطة التغذية الشخصية الخاصة بك. مرحباً برحلتك الصحية مع يومي';

  @override
  String get caloriesGoal => 'هدف السعرات الحرارية';

  @override
  String get carbsGoal => 'هدف الكربوهيدرات';

  @override
  String get startNow => 'ابدأ الآن';

  @override
  String get underweight => 'نقص في الوزن';

  @override
  String get normalWeight => 'وزن طبيعي';

  @override
  String get healthy => 'صحي';

  @override
  String get overweight => 'زيادة في الوزن';

  @override
  String get avocadoToast => 'توست الأفوكادو';

  @override
  String get italianSalad => 'سلطة إيطالية';

  @override
  String get chickenKatsuRiceBowl => 'وعاء أرز كاتسو بالدجاج';

  @override
  String get yourTargetWeightIsSetToCurrent => 'وزنك المستهدف محدد لوزنك الحالي';

  @override
  String get couldNotGenerateYourPlan => 'لم نتمكن من إنشاء خطتك. يرجى المحاولة مرة أخرى.';

  @override
  String get somethingWentWrongRestart => 'حدث خطأ ما. يرجى إعادة تشغيل عملية التهيئة.';

  @override
  String get yourBMI => 'مؤشر كتلة الجسم:';

  @override
  String get lbs => 'رطل';

  @override
  String get yourActivityLevel => 'مستوى نشاطك';

  @override
  String get analyzingFridge => 'تحليل ثلاجتك...';

  @override
  String get aiDetectingFoodItems => 'الذكاء الاصطناعي يكتشف عناصر الطعام';

  @override
  String get tryClearerPhoto => 'حاول التقاط صورة أوضح لثلاجتك';

  @override
  String get generating => 'جاري الإنشاء...';

  @override
  String get premiumStatus => 'حالة الاشتراك المميز';

  @override
  String get thankYouForSupport => 'شكراً لدعمك! 💚';

  @override
  String get yourPremiumFeatures => 'ميزاتك المميزة';

  @override
  String get subscriptionError => 'خطأ في الاشتراك';

  @override
  String get unknownErrorOccurred => 'حدث خطأ غير معروف';

  @override
  String get privacyAndAds => 'الخصوصية والإعلانات';

  @override
  String get reviewAdPreferences => 'مراجعة تفضيلات الإعلانات';

  @override
  String get privacyOptionsNotAvailable => 'خيارات الخصوصية غير متاحة في منطقتك.';

  @override
  String get consentFlowCompleted => 'اكتمل تدفق الموافقة!';

  @override
  String get appleSignInFailed => 'فشل تسجيل الدخول عبر Apple';

  @override
  String get adFailedToShow => 'فشل عرض الإعلان';

  @override
  String get adNotLoadedYet => 'لم يتم تحميل الإعلان بعد';

  @override
  String get errorRequestingPermissions => 'حدث خطأ أثناء طلب الأذونات';

  @override
  String get showMore => 'عرض المزيد';

  @override
  String get showLess => 'عرض أقل';

  @override
  String get noSavedCustomMeals => 'ليس لديك وجبات مخصصة محفوظة.';

  @override
  String get savedCustomMealsPlus => 'الوجبات المخصصة المحفوظة +';

  @override
  String get customBuilding => 'إنشاء وجبة مخصصة';

  @override
  String get enterName => 'أدخل الاسم';

  @override
  String get enterFoodName => 'أدخل اسم الطعام';

  @override
  String get congratulationsGoalReached => '🎉 تهانينا!';

  @override
  String get youReachedGoalWeight => 'لقد وصلت إلى وزنك المستهدف!';

  @override
  String get switchToMaintenancePlan => 'الآن بعد أن وصلت إلى وزنك المستهدف، دعنا نغير خطتك الغذائية للحفاظ على وزنك!';

  @override
  String get letsDoIt => 'هيا بنا!';

  @override
  String get keepUpGreatWork => 'استمر في العمل الرائع!';

  @override
  String get generatingMaintenancePlan => 'إنشاء خطة الصيانة الخاصة بك...';

  @override
  String get maintenancePlanUpdated => '🎉 تم تحديث خطتك الغذائية للحفاظ على الوزن!';

  @override
  String get failedToGenerateMaintenancePlan => 'فشل في إنشاء خطة الصيانة. يرجى المحاولة مرة أخرى.';

  @override
  String get heresYourMaintenancePlan => 'هذه خطتك الجديدة للصيانة!';

  @override
  String get keepThisPlan => 'الاحتفاظ بهذه الخطة';

  @override
  String get chooseDifferentGoal => 'اختيار هدف مختلف';

  @override
  String get whatsYourNewGoal => 'ما هو هدفك الجديد؟';

  @override
  String get whatsYourNewTargetWeight => 'ما هو وزنك المستهدف الجديد؟';

  @override
  String get yumieGeneratingNewPlan => 'يومي ينشئ خطتك الجديدة الشخصية...';

  @override
  String get yourNewPlanReady => 'خطتك الجديدة جاهزة!';

  @override
  String get startWithNewPlan => 'ابدأ بالخطة الجديدة';

  @override
  String get generateNewPlan => 'إنشاء خطة جديدة';

  @override
  String get planGenerationLimitReached => 'لقد استخدمت جيلي الخطة الخاصين بك لهذه الفترة.';

  @override
  String get waterGoal => 'هدف الماء';

  @override
  String get glasses => 'كؤوس';

  @override
  String planGenerationInfo(int remaining) {
    return 'يمكنك إنشاء $remaining خطط شخصية أكثر في الـ 14 يومًا القادمة.';
  }

  @override
  String nextPlanAvailable(int days) {
    return 'حاول مرة أخرى خلال $days أيام';
  }

  @override
  String get decline => 'رفض';

  @override
  String get planDeclined => 'تم رفض الخطة';

  @override
  String get accountDeletionWarning => 'سيتم حذف حسابك خلال 48 ساعة. إذا قمت بتسجيل الدخول مرة أخرى خلال 48 ساعة، سيتم إعادة تفعيل حسابك وإلغاء الحذف.';

  @override
  String get accountScheduledForDeletion => 'تم جدولة الحساب للحذف';

  @override
  String get reactivateAccount => 'إعادة تفعيل الحساب';

  @override
  String get accountReactivated => 'مرحباً بعودتك! تم إعادة تفعيل حسابك.';

  @override
  String get accountDeletionCancelled => 'تم إلغاء حذف الحساب.';

  @override
  String get emailVerificationRequired => 'مطلوب تأكيد البريد الإلكتروني';

  @override
  String get pleaseVerifyEmail => 'يرجى تأكيد عنوان بريدك الإلكتروني للمتابعة';

  @override
  String get verificationEmailSent => 'لقد أرسلنا رابط تأكيد إلى عنوان بريدك الإلكتروني. يرجى فحص صندوق الوارد والنقر على الرابط لتأكيد حسابك.';

  @override
  String get waitingForVerification => 'في انتظار تأكيد البريد الإلكتروني...';

  @override
  String get checkYourEmail => 'تحقق من بريدك الإلكتروني وانقر على رابط التأكيد';

  @override
  String get resendVerificationEmail => 'إعادة إرسال بريد التأكيد';

  @override
  String get verificationLinkAlreadySent => 'تم إرسال رابط تأكيد بالفعل إلى عنوان البريد هذا. يرجى فحص صندوق الوارد أو انتظار بضع دقائق قبل طلب واحد جديد.';

  @override
  String get emailVerified => 'تم تأكيد البريد بنجاح!';

  @override
  String get emailNotVerified => 'لم يتم تأكيد البريد بعد. يرجى فحص صندوق الوارد.';

  @override
  String get changeEmail => 'تغيير البريد';

  @override
  String get continueToApp => 'متابعة إلى التطبيق';

  @override
  String get failedToSendVerificationEmail => 'فشل في إرسال بريد التأكيد';

  @override
  String get failedToResendVerificationEmail => 'فشل في إعادة إرسال بريد التأكيد';

  @override
  String get errorCheckingVerification => 'خطأ في فحص التأكيد';

  @override
  String get helloIAmYumie => 'مرحباً، أنا يومي! سجل وجبة لتبدأ سلسلتك اليوم!';

  @override
  String get happyBirthday => '🎉 عيد ميلاد سعيد!';

  @override
  String birthdayMessage(int age) {
    return 'أتمنى لك يوماً رائعاً! أنت الآن عمرك $age سنة.';
  }

  @override
  String get selectBirthday => 'اختر تاريخ ميلادك';

  @override
  String get day => 'اليوم';

  @override
  String get accountAlreadyExists => 'الحساب موجود بالفعل';

  @override
  String get accountExistsMessage => 'حساب بهذا البريد الإلكتروني موجود بالفعل. هل تريد تسجيل الدخول بدلاً من ذلك؟';

  @override
  String get accountUsesDifferentSignIn => 'الحساب يستخدم طريقة تسجيل دخول مختلفة';

  @override
  String get emailSignedUpWithGoogle => 'هذا البريد الإلكتروني مسجل بالفعل مع جوجل. يرجى استخدام \"تسجيل الدخول مع جوجل\" بدلاً من ذلك.';

  @override
  String get emailSignedUpWithPassword => 'هذا البريد الإلكتروني مسجل بالفعل مع البريد الإلكتروني وكلمة المرور. يرجى تسجيل الدخول باستخدام كلمة المرور الخاصة بك.';

  @override
  String get useGoogleSignIn => 'استخدام تسجيل الدخول مع جوجل';

  @override
  String get signInWithEmail => 'تسجيل الدخول بالبريد الإلكتروني';

  @override
  String get signInSuccessful => 'تم تسجيل الدخول بنجاح!';

  @override
  String get signUpSuccessful => 'تم التسجيل بنجاح!';

  @override
  String get emailVerifiedWelcome => 'تم تأكيد البريد الإلكتروني! مرحباً بك!';

  @override
  String get premiumCancelledTitle => 'لقد قمت بإلغاء الاشتراك';

  @override
  String premiumCancelledWillEndOn(String date) {
    return 'ستنتهي ميزة بريميوم في $date';
  }

  @override
  String get manageSubscriptions => 'إدارة الاشتراكات';

  @override
  String get buildingMuscle => 'بناء العضلات';

  @override
  String get weightMaintained => 'تم الحفاظ على الوزن';

  @override
  String get eatingHealthier => 'تناول طعام أكثر صحة';

  @override
  String get goalReached => 'تم الوصول للهدف';

  @override
  String get noDataYet => 'لا توجد بيانات بعد';

  @override
  String get needMoreData => 'نحتاج المزيد من البيانات';

  @override
  String get weeklyGain => 'زيادة أسبوعية';

  @override
  String get onTrack => 'على المسار الصحيح';

  @override
  String get insufficientData => 'بيانات غير كافية';

  @override
  String get reached => 'تم الوصول';

  @override
  String get sinceGoalStart => 'منذ بداية الهدف';

  @override
  String get viewPreviousPlans => 'عرض الخطط السابقة';

  @override
  String get previousPlans => 'الخطط السابقة';

  @override
  String get yourWeightJourney => 'رحلة وزنك';

  @override
  String get trackProgressThroughGoals => 'تتبع تقدمك من خلال أهداف مختلفة';

  @override
  String get noPreviousPlans => 'لا توجد خطط سابقة';

  @override
  String get previousPlansWillAppear => 'ستظهر خططك السابقة هنا عند تغيير الأهداف.';

  @override
  String get completed => 'مكتمل';

  @override
  String get changed => 'تم التغيير';

  @override
  String get nutritionGoals => 'أهداف التغذية';

  @override
  String get weightEntries => 'إدخالات الوزن';

  @override
  String get noWeightEntriesRecorded => 'لم يتم تسجيل إدخالات وزن خلال هذه الفترة';

  @override
  String get months => 'شهور';

  @override
  String get unknownGoal => 'هدف غير معروف';

  @override
  String get failedToSavePlan => 'فشل في حفظ الخطة. يرجى المحاولة مرة أخرى.';

  @override
  String get failedToGeneratePlan => 'فشل في إنشاء الخطة. يرجى المحاولة مرة أخرى.';

  @override
  String get updateTargetAndRecalculate => 'تحديث الهدف وإعادة الحساب';

  @override
  String get neverMind => 'لا يهم';

  @override
  String get saveAndRecalculate => 'حفظ وإعادة حساب';

  @override
  String get targetUpdatedAndPlanRecalculated => 'تم تحديث الهدف وإعادة حساب الخطة';

  @override
  String get recalculateNote => 'سنعيد حساب السعرات الحرارية والعناصر الغذائية لهذا الهدف الجديد. يمكنك لا تزال إنشاء خطة ذكية جديدة لاحقاً.';

  @override
  String get startLoggingWeight => 'ابدأ في تسجيل وزنك لرؤية اتجاهات تقدمك.';

  @override
  String get logMoreWeights => 'سجل المزيد من الأوزان لرؤية اتجاهك.';

  @override
  String get weightTrendFlat => 'اتجاه وزنك مسطح حالياً. سجل المزيد من إدخالات الوزن لرؤية اتجاه تقدمك.';

  @override
  String get maintenanceRangeDrifted => 'انحرف وزنك عن نطاق الحفاظ عليه. سجل المزيد من الإدخالات لتقدير الوقت للعودة إلى وزنك.';

  @override
  String trendingBackMaintenance(String eta) {
    return 'أنت تتجه نحو وزن الحفاظ عليه. الوقت المقدر: $eta';
  }

  @override
  String get stayConsistentHealthy => 'حافظ على الاختيارات الصحية؛ مع توفر المزيد من البيانات سنقدر الوقت للعودة إلى نطاقك الصحي.';

  @override
  String trendingBackOnTrack(String eta) {
    return 'أنت تتجه للعودة إلى المسار الصحيح. الوقت المقدر: $eta';
  }

  @override
  String get strengthPhaseActive => 'مرحلة القوة نشطة. حافظ على البروتين والتدريب بشكل ثابت؛ سيظهر الجدول الزمني مع نمو البيانات.';

  @override
  String trendingTowardBuildGoal(String eta) {
    return 'أنت تتجه نحو هدف البناء. الوقت المقدر: $eta';
  }

  @override
  String get timeToGoal => 'الوقت للهدف';

  @override
  String get timeline => 'الجدول الزمني';

  @override
  String get allTime => 'كل الوقت';

  @override
  String get planToGoal => 'خطة للهدف';
}
