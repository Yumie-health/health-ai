// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get settings => '설정';

  @override
  String get preferences => '설정';

  @override
  String get darkMode => '다크 모드';

  @override
  String get enableDarkTheme => '다크 테마 활성화';

  @override
  String get useMetricUnits => '미터법 단위 사용';

  @override
  String get unitsSubtitle => 'kg/cm (켜기) 또는 lb/ft (끄기) 사용';

  @override
  String get language => '언어';

  @override
  String get selectLanguage => '앱 언어 선택';

  @override
  String get habitNotifications => '습관 알림';

  @override
  String get mealLoggingPrompts => '식사 기록 알림';

  @override
  String get mealLoggingPromptsSubtitle => '식사 기록 알림 받기';

  @override
  String get waterIntakeReminders => '수분 섭취 알림';

  @override
  String get waterIntakeRemindersSubtitle => '물 마시기 알림 받기';

  @override
  String get mindfulWalksReminders => '마음챙김 걷기 알림';

  @override
  String get mindfulWalksRemindersSubtitle => '마음챙김 걷기 알림 받기';

  @override
  String get momentOfCalmAfterMeals => '식사 후 평온의 순간';

  @override
  String get momentOfCalmAfterMealsSubtitle => '식사 기록 후 차분한 팝업 표시';

  @override
  String get welcomeBack => '다시 오신 것을 환영합니다!';

  @override
  String get trackNutritionToday => '오늘 영양을 추적해 봅시다';

  @override
  String get subtitleAfternoon => '점심을 기록하고 균형을 유지하기에 딱 좋은 시간이에요.';

  @override
  String get subtitleEvening => '오늘 저녁도 꾸준히—식사를 기록해 보세요.';

  @override
  String get subtitleNight => '하루를 마무리해요—오늘의 식사를 기록하는 것을 잊지 마세요.';

  @override
  String get streakNearEndingTitle => '연속 기록을 지켜요 🔥';

  @override
  String get streakNearEndingBody => '연속 기록이 곧 끝나요. 오늘 식사를 기록해 유지하세요!';

  @override
  String get streakNearEndingTitle2 => '거의 다 왔어요! 🔥';

  @override
  String get streakNearEndingBody2 => '몇 시간만 남았어요. 식사를 기록해 연속 기록을 지키세요!';

  @override
  String get streakEndedTitle => '연속 기록 종료';

  @override
  String get streakEndedBody => '연속 기록이 종료되었어요. 식사를 기록해 다시 시작해 보세요!';

  @override
  String get streakActive => '연속 기록 활성';

  @override
  String get streakInactive => '연속 기록 비활성';

  @override
  String get currentStreak => '현재 연속 일수';

  @override
  String get entriesInStreak => '연속 기간의 기록 수';

  @override
  String get days => '일';

  @override
  String get startedOn => '시작일';

  @override
  String get logMealToStartStreak => '연속 기록을 시작하려면 오늘 식사를 기록하세요';

  @override
  String get nutritionSummary => '영양 요약';

  @override
  String get setCalorieAndMacroGoals => '영양 계획 페이지에서 칼로리와 매크로 목표를 설정하세요.';

  @override
  String get protein => '단백질';

  @override
  String get carbs => '탄수화물';

  @override
  String get fat => '지방';

  @override
  String get calories => '칼로리';

  @override
  String get quickActions => '빠른 작업';

  @override
  String get logMeal => '식사 기록';

  @override
  String get trackYourFood => '음식 추적';

  @override
  String get scan => '스캔';

  @override
  String get barcode => '바코드';

  @override
  String get analyzeYourFood => '음식 분석';

  @override
  String get todaysMeals => '오늘의 식사';

  @override
  String get viewAll => '모두 보기';

  @override
  String get noMealsLoggedForThisDay => '이 날에 기록된 식사가 없습니다.';

  @override
  String get nutritionalPlan => '영양 계획';

  @override
  String get weightAnalytics => '체중 분석';

  @override
  String get toGoal => '목표까지';

  @override
  String get remaining => '남음';

  @override
  String get weeklyRate => '주간 속도';

  @override
  String get weeklyLoss => '주간 감소';

  @override
  String get starting => '시작';

  @override
  String get current => '현재';

  @override
  String get today => '오늘';

  @override
  String get targetLabel => '목표';

  @override
  String get goalWeight => '목표 체중';

  @override
  String get eta => 'ETA';

  @override
  String get sinceStart => '시작 이후';

  @override
  String get expectationsDisclaimer => '이 예상은 최근 추세를 기반으로 하며, 새로운 몸무게를 기록할 때 변경될 수 있습니다.';

  @override
  String get loseVerb => '감량';

  @override
  String get gainVerb => '증가';

  @override
  String expectationBlurb(Object direction, Object eta, Object rate, Object remaining, Object unit) {
    return '최근 추세에 따르면 주당 약 $rate $unit를 $direction할 것으로 예상됩니다. 이 속도라면 목표에 도달하기까지 대략 $eta가 걸립니다. 남은 값은 $remaining $unit 입니다.';
  }

  @override
  String get healthAwareness => '건강 인식';

  @override
  String get planSettings => '계획 설정';

  @override
  String get featureComingSoon => '이 기능은 곧 출시됩니다!';

  @override
  String get ok => '확인';

  @override
  String get rateUsOnGoogle => 'Google에서 평가하기';

  @override
  String get comingSoon => '곧 출시!';

  @override
  String get ratingOnGoogleAvailableAfterRelease => 'Google 평가는 출시 후 이용 가능합니다.';

  @override
  String get shareWithFriends => '친구들과 공유';

  @override
  String get sharingAvailableAfterRelease => '공유는 출시 후 이용 가능합니다.';

  @override
  String get resetPassword => '비밀번호 재설정';

  @override
  String get close => '닫기';

  @override
  String get sendResetLink => '재설정 링크 보내기';

  @override
  String get send => '보내기';

  @override
  String get resend => '다시 보내기';

  @override
  String get helpSupport => '도움말 및 지원';

  @override
  String get legal => '법적 고지';

  @override
  String get privacyPolicy => '개인정보처리방침';

  @override
  String get termsOfService => '이용약관';

  @override
  String get apiDocumentation => 'API 문서';

  @override
  String get needAssistanceContactSupport => '도움이 필요하신가요? 지원팀에 문의하세요:';

  @override
  String get testWebURL => '테스트 웹 URL';

  @override
  String get testSimpleMailto => '테스트 간단 메일';

  @override
  String get logOut => '로그아웃';

  @override
  String get areYouSureYouWantToLogOut => '로그아웃하시겠습니까?';

  @override
  String get no => '아니오';

  @override
  String get yes => '예';

  @override
  String get commonQuestions => '자주 묻는 질문';

  @override
  String get momentOfCalm => '평온의 순간';

  @override
  String get practiceMindfulEating => '식사를 감사하며 마음챙김 식사를 연습하는 시간을 가지세요.';

  @override
  String get howOldAreYou => '나이는 몇 살인가요?';

  @override
  String get personalizeExperience => '이것은 경험을 개인화하는 데 도움이 됩니다';

  @override
  String get yourHeight => '키';

  @override
  String get yourGoalWeight => '목표 체중';

  @override
  String get setRealisticGoal => '여정을 위한 현실적인 목표를 설정하세요';

  @override
  String get allSet => '준비 완료! 🎉';

  @override
  String get personalizedNutritionPlan => '맞춤형 영양 계획입니다. Yumie와 함께하는 건강 여정에 오신 것을 환영합니다!';

  @override
  String get whatIsYourBloodType => '혈액형은 무엇인가요?';

  @override
  String get personalizeHealthInsights => '이것은 건강 인사이트를 개인화하는 데 도움이 됩니다.';

  @override
  String get whatIsYourSex => '성별은 무엇인가요?';

  @override
  String get personalizeNutritionPlan => '이것은 영양 계획을 개인화하는 데 도움이 됩니다.';

  @override
  String get home => '홈';

  @override
  String get food => '음식';

  @override
  String get coach => '코치';

  @override
  String get profile => '프로필';

  @override
  String get log => '기록';

  @override
  String get myMeals => '내 식사';

  @override
  String get suggestedMeals => '추천 식사';

  @override
  String get monthly => '월간';

  @override
  String get weekly => '주간';

  @override
  String get breakfast => '아침 식사';

  @override
  String get lunch => '점심 식사';

  @override
  String get dinner => '저녁 식사';

  @override
  String get snack => '간식';

  @override
  String get reviewMeal => '식사 검토';

  @override
  String get chat => '채팅';

  @override
  String get insights => '인사이트';

  @override
  String get clearChat => '채팅 지우기';

  @override
  String get coachWelcome => '안녕하세요! 저는 Yumie, 여러분의 영양 코치입니다. 오늘 어떻게 도와드릴까요?\n\n건강한 레시피, 식사 계획, 또는 영양 팁에 대해 Yumie에게 물어보세요!';

  @override
  String get refreshInsight => '인사이트 새로고침';

  @override
  String get healthInsights => '건강 인사이트';

  @override
  String get noInsightAvailable => '사용 가능한 인사이트가 없습니다.';

  @override
  String get dinnerIdeas => '저녁 식사 아이디어';

  @override
  String get calorieCheck => '칼로리 확인';

  @override
  String get proteinSnacks => '단백질 간식';

  @override
  String get dietTips => '다이어트 팁';

  @override
  String get typeYourMessage => '메시지를 입력하세요...';

  @override
  String get yumie => 'Yumie';

  @override
  String get askAboutMeals => '식사와 영양에 대해 질문하세요';

  @override
  String get coachQuick1 => '오늘 무엇을 먹어야 할까요?';

  @override
  String get coachQuick2 => '내 마지막 식사를 분석해주세요';

  @override
  String get coachQuick3 => '내 주간 계획을 도와주세요';

  @override
  String get yumieThinking => 'Yumie가 생각 중...';

  @override
  String get bmi => 'BMI';

  @override
  String get target => '목표';

  @override
  String get weight => '체중';

  @override
  String get age => '나이';

  @override
  String get height => '키';

  @override
  String get targetWeight => '목표 체중';

  @override
  String get calorieGoal => '칼로리 목표';

  @override
  String get proteinGoal => '단백질 목표';

  @override
  String get carbGoal => '탄수화물 목표';

  @override
  String get fatGoal => '지방 목표';

  @override
  String get waterIntake => '수분 섭취';

  @override
  String get save => '저장';

  @override
  String get cancel => '취소';

  @override
  String get undo => '실행 취소';

  @override
  String get notSet => '설정되지 않음';

  @override
  String get uploadNew => '새로 업로드';

  @override
  String get delete => '삭제';

  @override
  String get editName => '이름 편집';

  @override
  String get bloodType => '혈액형';

  @override
  String get areYouDiabetic => '당뇨병이 있나요?';

  @override
  String get healthAwarenessUpdated => '건강 인식이 업데이트되었습니다!';

  @override
  String get takeMomentToAppreciate => '식사를 감사하며 마음챙김 식사를 연습하는 시간을 가지세요.';

  @override
  String get continueButton => '계속';

  @override
  String get mealSaved => '식사가 저장되었습니다!';

  @override
  String get noRecentFoods => '최근 음식이 없습니다.';

  @override
  String get buildCustomMeal => '맞춤형 식사 만들기';

  @override
  String get mealName => '식사 이름';

  @override
  String get searchOrEnterFoodName => '음식 이름을 검색하거나 입력하세요';

  @override
  String get ingredients => '재료';

  @override
  String get addIngredient => '재료 추가';

  @override
  String get myFoods => '내 음식';

  @override
  String get noCustomFoods => '아직 맞춤형 음식을 저장하지 않았습니다';

  @override
  String get addCustomFood => '맞춤형 음식 추가';

  @override
  String get editCustomMeal => '맞춤형 식사 편집';

  @override
  String get clearAll => '모두 지우기';

  @override
  String get foodName => '음식 이름';

  @override
  String get saveMeal => '식사 저장';

  @override
  String get customizeMeal => '식사 맞춤화';

  @override
  String get hideIngredients => '재료 숨기기';

  @override
  String get showIngredients => '재료 보기';

  @override
  String get ingredientsColon => '재료:';

  @override
  String get noIngredientsListed => '재료가 나열되지 않았습니다.';

  @override
  String get recent => '최근';

  @override
  String get meal => '식사';

  @override
  String get fridge => '냉장고';

  @override
  String get placeFoodInFrame => '음식을 프레임 안에 놓으세요';

  @override
  String get placeBarcodeInFrame => '바코드를 프레임 안에 맞춰주세요';

  @override
  String get placeFridgeInFrame => '냉장고를 프레임 안에 맞춰주세요';

  @override
  String get productNotFound => '제품을 찾을 수 없습니다';

  @override
  String get safetyUnsafe => '안전하지 않음';

  @override
  String get safetyGood => '사용해도 됨';

  @override
  String get badgeNutriScore => 'Nutri-Score';

  @override
  String get badgeNova => 'NOVA';

  @override
  String get allergensTitle => '알레르겐';

  @override
  String get contains => '함유';

  @override
  String get allergensNone => '알레르겐 없음';

  @override
  String get serving => '서빙';

  @override
  String get kcalPer100g => 'kcal/100g';

  @override
  String get sugar => '설탕';

  @override
  String get satFat => '포화지방';

  @override
  String get salt => '소금';

  @override
  String get ingredientsTitle => '재료';

  @override
  String get riskAllergen => '알레르겐 위험';

  @override
  String get riskUltraProcessed => '초가공식품 (NOVA 4)';

  @override
  String get riskHighAdditives => '첨가물 많음';

  @override
  String get riskLowNutri => '낮은 Nutri‑Score';

  @override
  String get riskVegan => '비건 가능';

  @override
  String get riskVegetarian => '베지테리언';

  @override
  String get riskLooksGood => '좋아 보임';

  @override
  String get retakeScan => '다시 스캔';

  @override
  String get previewFullImage => '전체 이미지 미리보기';

  @override
  String get discard => '버리기';

  @override
  String get upgradeToPremium => '프리미엄으로 업그레이드';

  @override
  String get getUnlimitedScans => '무제한 스캔과 더 많은 기능을 얻으세요!';

  @override
  String get getUnlimitedSearches => '무제한 검색과 더 많은 기능을 얻으세요!';

  @override
  String get upgradePlan => '플랜 업그레이드';

  @override
  String get watchAdForScan => '스캔을 위해 광고 시청';

  @override
  String get watchAdForSearch => '검색을 위해 광고 시청';

  @override
  String get generateMeal => '식사 생성';

  @override
  String get detectedFridgeItems => '감지된 냉장고 아이템';

  @override
  String get noFridgeItemsDetected => '냉장고 아이템이 감지되지 않았습니다.';

  @override
  String get searchResults => '검색 결과';

  @override
  String get searchingFor => '검색 중';

  @override
  String get noResultsFoundFor => '다음에 대한 결과를 찾을 수 없습니다';

  @override
  String get count => '개수';

  @override
  String get servings => '인분';

  @override
  String get fluidOunces => '액량 온스';

  @override
  String get quantity => '수량';

  @override
  String get confirm => '확인';

  @override
  String get ingredient => '재료';

  @override
  String get drink => '음료';

  @override
  String get kg => 'kg';

  @override
  String get g => 'g';

  @override
  String get mg => 'mg';

  @override
  String get cm => 'cm';

  @override
  String get m => 'm';

  @override
  String get kcal => 'kcal';

  @override
  String get cal => 'cal';

  @override
  String get lb => 'lb';

  @override
  String get oz => 'oz';

  @override
  String get ft => '피트';

  @override
  String get inches => '인치';

  @override
  String get cup => '컵';

  @override
  String get tbsp => '큰술';

  @override
  String get tsp => '작은술';

  @override
  String get ml => 'ml';

  @override
  String get l => 'l';

  @override
  String get upgradeToPremiumTitle => '프리미엄으로 업그레이드';

  @override
  String get premiumFeatures => '프리미엄 기능';

  @override
  String get unlimitedScans => '무제한 스캔';

  @override
  String get aiNutritionCoach => 'AI 영양 코치';

  @override
  String get detailedAnalytics => '상세 분석';

  @override
  String get personalizedMealPlans => '맞춤형 식사 계획';

  @override
  String get noAdvertisements => '광고 없음';

  @override
  String get yearlyPremium => '연간 프리미엄';

  @override
  String get monthlyPremium => '월간 프리미엄';

  @override
  String savePercent(Object percent) {
    return '$percent% 절약';
  }

  @override
  String get perYear => '/년';

  @override
  String get perMonth => '/월';

  @override
  String get popular => '인기';

  @override
  String get maybeLater => '나중에';

  @override
  String get welcomeToYumie => '🎉 Yumie에 오신 것을 환영합니다!';

  @override
  String get unlockPremiumFeatures => '프리미엄 기능 잠금 해제';

  @override
  String get getMostOutOfHealthJourney => '무제한 접근으로 건강 여정을 최대한 활용하세요!';

  @override
  String get unlimitedScansAICoaching => '무제한 스캔, AI 코칭, 맞춤형 식사 계획을 잠금 해제하세요!';

  @override
  String get subscribe => '구독';

  @override
  String get foodNameLabel => '음식 이름';

  @override
  String get managePermissions => '권한 관리';

  @override
  String get cameraNotificationsAndMore => '카메라, 알림 등';

  @override
  String get deleteMeal => '식사 삭제';

  @override
  String get areYouSureDeleteMeal => '이 식사를 삭제하시겠습니까?';

  @override
  String get unknown => '알 수 없음';

  @override
  String get servings1 => '인분 1';

  @override
  String get edit => '편집';

  @override
  String get ignoreFood => '음식 무시';

  @override
  String get addComponent => '구성 요소 추가';

  @override
  String get components => '구성 요소';

  @override
  String get recentFoods => '최근 음식';

  @override
  String get logWeightChange => '체중';

  @override
  String get lost => '감량';

  @override
  String get gained => '증량';

  @override
  String get googleSignInHelp => 'Google 로그인 도움말';

  @override
  String get couldNotOpenTermsOfService => '이용약관을 열 수 없습니다';

  @override
  String get couldNotOpenPrivacyPolicy => '개인정보처리방침을 열 수 없습니다';

  @override
  String get errorSavingProfile => '프로필 저장 오류';

  @override
  String get completeYourProfile => '프로필 완성';

  @override
  String get saveAndContinue => '저장 및 계속';

  @override
  String get pleasSignIn => '로그인해 주세요.';

  @override
  String get noFoodLogsYet => '아직 음식 기록이 없습니다.';

  @override
  String get healthAIFoodLog => 'HealthAI - 음식 기록';

  @override
  String get addLog => '기록 추가';

  @override
  String get unableToShareAtThisTime => '현재 공유할 수 없습니다. 다시 시도해 주세요.';

  @override
  String get failedToUpdatePhoto => '사진 업데이트 실패';

  @override
  String get changeProfileName => '프로필 이름 변경';

  @override
  String get failedToUpdateName => '이름 업데이트 실패';

  @override
  String get profileUpdatedSuccessfully => '프로필이 성공적으로 업데이트되었습니다';

  @override
  String get errorUpdatingProfile => '프로필 업데이트 오류';

  @override
  String get editGoals => '목표 편집';

  @override
  String get goalsUpdatedSuccessfully => '목표가 성공적으로 업데이트되었습니다';

  @override
  String get errorUpdatingGoals => '목표 업데이트 오류';

  @override
  String get couldNotOpenWebsite => '웹사이트를 열 수 없습니다';

  @override
  String get errorOpeningWebsite => '웹사이트 열기 오류';

  @override
  String get english => '영어';

  @override
  String get arabic => '아랍어';

  @override
  String get spanish => '스페인어';

  @override
  String get reviewMealTitle => '식사 검토';

  @override
  String get startingWeight => '시작 체중';

  @override
  String get appPermissions => '앱 권한';

  @override
  String get permissionStatus => '권한 상태';

  @override
  String get manageAppPermissions => '모든 기능이 제대로 작동하도록 앱 권한을 관리하세요';

  @override
  String get camera => '카메라';

  @override
  String get scanFoodItems => '음식 아이템을 스캔하고 식사 사진을 찍으세요';

  @override
  String get photoLibrary => '사진';

  @override
  String get saveScannedImages => '스캔된 이미지를 저장하고 사진을 선택하세요';

  @override
  String get notifications => '알림';

  @override
  String get sendMealReminders => '식사 알림과 건강 경고를 보내세요';

  @override
  String get needHelp => '도움이 필요하신가요?';

  @override
  String get permanentlyDeniedHelp => '권한이 영구적으로 거부된 경우, 기기 설정에서 활성화할 수 있습니다';

  @override
  String get openDeviceSettings => '기기 설정 열기';

  @override
  String get goodMorning => '좋은 아침';

  @override
  String get goodAfternoon => '좋은 오후';

  @override
  String get goodEvening => '좋은 저녁';

  @override
  String get goodNight => '좋은 밤';

  @override
  String get ounces => '온스';

  @override
  String get january => '1월';

  @override
  String get february => '2월';

  @override
  String get march => '3월';

  @override
  String get april => '4월';

  @override
  String get may => '5월';

  @override
  String get june => '6월';

  @override
  String get july => '7월';

  @override
  String get august => '8월';

  @override
  String get september => '9월';

  @override
  String get october => '10월';

  @override
  String get november => '11월';

  @override
  String get december => '12월';

  @override
  String get trackYourNutrition => '영양을 추적하세요';

  @override
  String get messages => '메시지';

  @override
  String get subscribeForDailyInsights => '일일 인사이트 구독';

  @override
  String get getPersonalizedHealthInsights => '완전한 프로필을 기반으로 맞춤형 건강 인사이트를 받으세요';

  @override
  String get upgradeDescription => '무제한 스캔, 검색, AI 기반 인사이트를 받으세요';

  @override
  String get unlimitedFoodScans => '무제한 음식 스캔';

  @override
  String get unlimitedFoodSearches => '무제한 음식 검색';

  @override
  String get unlimitedAICoachMessages => '무제한 AI 코치 메시지';

  @override
  String get dailyHealthInsights => '일일 건강 인사이트';

  @override
  String get logWaterIntake => '수분';

  @override
  String get add => '추가';

  @override
  String get freemium => '프리미엄';

  @override
  String get premium => '프리미엄';

  @override
  String get chooseYourPlan => '플랜 선택';

  @override
  String get water => '물';

  @override
  String get resetPasswordDescription => '비밀번호 재설정 링크가 이메일로 전송됩니다';

  @override
  String get deleteAccount => '계정 삭제';

  @override
  String get deleteAccountDescription => '계정과 모든 데이터를 영구적으로 삭제';

  @override
  String get confirmDeleteAccount => '계정을 삭제하시겠습니까?';

  @override
  String get deleteAccountWarning => '이 작업은 되돌릴 수 없습니다. 식사, 진행 상황, 설정을 포함한 모든 데이터가 영구적으로 삭제됩니다.';

  @override
  String get typeDeleteToConfirm => '확인하려면 \"삭제\"를 입력하세요';

  @override
  String get deleteAccountFinalConfirmation => '삭제';

  @override
  String get accountDeleted => '계정 삭제됨';

  @override
  String get errorDeletingAccount => '계정 삭제 오류';

  @override
  String get totalNutrition => '총 영양';

  @override
  String get unlockUnlimitedScans => '무제한 스캔, AI 코칭, 맞춤형 식사 계획을 잠금 해제하세요';

  @override
  String get unlimitedFoodScanning => '무제한 음식 스캔';

  @override
  String get yearPrice => '년/\$49.99';

  @override
  String get monthPrice => '월/\$7.99';

  @override
  String get save37 => '37% 절약';

  @override
  String get youArePremium => '프리미엄입니다!';

  @override
  String get yumiePremiumMonthly => 'Yumie™ 프리미엄 월간';

  @override
  String get yumiePremiumYearly => 'Yumie™ 프리미엄 연간';

  @override
  String get restorePurchases => '구매 복원';

  @override
  String get checkingForPurchases => '기존 구매 확인 중...';

  @override
  String get purchasesRestored => '구매가 성공적으로 복원되었습니다!';

  @override
  String get noPurchasesFound => '이전 구매를 찾을 수 없습니다';

  @override
  String get restoreFailed => '구매 복원에 실패했습니다. 다시 시도해 주세요.';

  @override
  String get restoreInProgress => '구매 복원 중...';

  @override
  String get bySubscribing => '구독하면 이용약관과 개인정보처리방침에 동의하는 것입니다. 구독은 취소하지 않는 한 자동으로 갱신됩니다';

  @override
  String get permissionsComplete => '권한 완료!';

  @override
  String get whyWeAskForPermissions => '권한을 요청하는 이유';

  @override
  String get permissionsWhyBody => '카메라로 음식과 바코드를 스캔하고, 이미지를 업로드할 때 사진에 접근하며, 식사 기록 및 수분 섭취를 알리기 위해 알림을 사용합니다.';

  @override
  String get permissionsNextScreen => '다음 화면에서 시스템 권한 요청이 표시됩니다. 설정에서 언제든지 변경할 수 있습니다.';

  @override
  String get references => '참고 자료:';

  @override
  String get cdcAboutBmi => 'CDC: BMI 소개';

  @override
  String get usdaDietaryGuidelines => 'USDA 식이 가이드라인';

  @override
  String get termsOfUseEula => '이용 약관 (EULA)';

  @override
  String get enterYourPassword => '비밀번호를 입력하세요';

  @override
  String get manageSessions => '세션 관리';

  @override
  String get selectLanguageTitle => '언어 선택';

  @override
  String get chooseYourPreferredLanguage => '앱의 선호 언어를 선택하세요';

  @override
  String get languageChangedTo => '언어가 다음으로 변경되었습니다';

  @override
  String get activeSessions => '활성 세션';

  @override
  String get thisDevice => '이 기기';

  @override
  String get sessionRevoked => '세션이 취소되었습니다';

  @override
  String get allOtherSessionsSignedOut => '모든 다른 세션이 로그아웃되었습니다';

  @override
  String get signOutAllOthers => '모든 다른 세션 로그아웃';

  @override
  String get noSecurityAlerts => '보안 경고 없음';

  @override
  String get passwordStrengthWeak => '약함';

  @override
  String get passwordStrengthFair => '보통';

  @override
  String get passwordStrengthGood => '좋음';

  @override
  String get passwordStrengthStrong => '강함';

  @override
  String get passwordStrengthVeryStrong => '매우 강함';

  @override
  String get addLowercaseLetters => '소문자 추가';

  @override
  String get addUppercaseLetters => '대문자 추가';

  @override
  String get addNumbers => '숫자 추가';

  @override
  String get addSpecialCharacters => '특수 문자 추가 (!@#\$%^&*)';

  @override
  String get avoidCommonPatterns => '일반적인 패턴 피하기';

  @override
  String get requiresAtLeast8Characters => '최소 8자 이상 필요';

  @override
  String get tooManySignInAttempts => '로그인 시도가 너무 많습니다. 나중에 다시 시도해 주세요.';

  @override
  String get tooManySignUpAttempts => '회원가입 시도가 너무 많습니다. 나중에 다시 시도해 주세요.';

  @override
  String get tooManyPasswordResetRequests => '비밀번호 재설정 요청이 너무 많습니다. 나중에 다시 시도해 주세요.';

  @override
  String get multipleFailedSignInAttempts => '여러 번의 실패한 로그인 시도';

  @override
  String get excessivePasswordResetRequests => '과도한 비밀번호 재설정 요청';

  @override
  String get suspiciousActivityDetected => '의심스러운 활동 감지';

  @override
  String get riskLevelMedium => '보통';

  @override
  String get riskLevelHigh => '높음';

  @override
  String get welcomeToYumiePermissions => 'Yumie에 오신 것을 환영합니다';

  @override
  String get provideBestExperience => '최고의 경험을 제공하기 위해 몇 가지 권한이 필요합니다';

  @override
  String get grantPermissions => '권한 부여';

  @override
  String get skipForNow => '지금은 건너뛰기';

  @override
  String get denied => '거부됨';

  @override
  String get granted => '부여됨';

  @override
  String get createAccount => '계정 만들기';

  @override
  String get signUpToGetStarted => 'Yumie로 시작하려면 가입하세요';

  @override
  String get fullName => '전체 이름';

  @override
  String get email => '이메일';

  @override
  String get password => '비밀번호';

  @override
  String get agreeToTerms => '및 이용약관 개인정보처리방침에 동의합니다';

  @override
  String get alreadyHaveAccount => '이미 계정이 있나요?';

  @override
  String get signIn => '로그인';

  @override
  String get signUp => '가입';

  @override
  String get signInToAccessAccount => '계정에 접근하려면 로그인하세요';

  @override
  String get forgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get dontHaveAccount => '계정이 없나요?';

  @override
  String get signUpWithGoogle => 'Google로 가입';

  @override
  String get signInWithGoogle => 'Google로 로그인';

  @override
  String get signUpWithApple => 'Apple로 가입하기';

  @override
  String get signInWithApple => 'Apple로 로그인';

  @override
  String get resetPasswordTitle => '비밀번호 재설정';

  @override
  String get enterEmailForReset => '비밀번호 재설정 링크를 받으려면 이메일 주소를 입력하세요';

  @override
  String get emailAddress => '이메일 주소';

  @override
  String get rateUsOn => '평가하기';

  @override
  String get deleteAccountTitle => '계정 삭제';

  @override
  String get deleteAccountWarningTitle => '이 작업은 영구적이며 되돌릴 수 없습니다';

  @override
  String get deleteAccountDataList => '계정을 삭제하면 다음을 영구적으로 제거합니다:';

  @override
  String get allMealLogsAndNutrition => '모든 식사 기록과 영양 데이터';

  @override
  String get profileAndPersonalInfo => '프로필과 개인 정보';

  @override
  String get allUploadedPhotos => '모든 업로드된 사진과 파일';

  @override
  String get customMealsAndRecipes => '맞춤형 식사와 레시피';

  @override
  String get allAppPreferences => '모든 앱 설정과 환경설정';

  @override
  String get activeSessionsAllDevices => '모든 기기의 활성 세션';

  @override
  String get exportDataWarning => '진행하기 전에 유지하고 싶은 데이터를 내보내야 합니다';

  @override
  String get understandActionPermanent => '이 작업이 영구적임을 이해합니다';

  @override
  String get typeDeleteHere => '여기에 삭제를 입력하세요';

  @override
  String get deleteForever => '영구 삭제';

  @override
  String get noSecurityAlertsFound => '보안 경고 없음';

  @override
  String get yourAccountLooksGood => '계정이 좋아 보입니다! 의심스러운 활동이 감지되지 않았습니다.';

  @override
  String get manageActiveSessionsAcrossDevices => '다양한 기기의 활성 세션을 관리하세요';

  @override
  String get noActiveSessionsFound => '활성 세션을 찾을 수 없습니다';

  @override
  String get signOutAllOtherSessions => '모든 다른 세션 로그아웃';

  @override
  String get aiSearch => 'AI 검색';

  @override
  String get aiSearchDescription => 'AI를 사용하여 음식 아이템 검색';

  @override
  String get noIngredientsListedText => '재료가 나열되지 않음';

  @override
  String get breakfastTime => '아침 식사 시간';

  @override
  String get lunchTime => '점심 식사 시간';

  @override
  String get dinnerTime => '저녁 식사 시간';

  @override
  String get snackTime => '간식 시간';

  @override
  String get deletingYourAccount => '계정을 삭제하는 중...';

  @override
  String get thisMayTakeAFewMoments => '잠시만 기다려 주세요';

  @override
  String get redirectingToSignIn => '로그인으로 리디렉션 중...';

  @override
  String weightTrendNoData(Object remaining, Object unit) {
    return '체중 데이터가 충분하지 않습니다.';
  }

  @override
  String weightTrendHealthyRate(Object eta, Object rate, Object remaining, Object unit) {
    return '건강한 속도: $rate$unit/주';
  }

  @override
  String get accountSuccessfullyDeleted => '계정이 성공적으로 삭제되었습니다';

  @override
  String get pleaseCloseAndRestartApp => '계속하려면 앱을 닫고 다시 시작하세요.';

  @override
  String get exportData => '데이터 내보내기';

  @override
  String get exportDataDescription => '모든 데이터를 PDF 파일로 내보내기';

  @override
  String get exportComplete => '내보내기 완료';

  @override
  String get exportCompleteMessage => '데이터가 성공적으로 내보내졌습니다!';

  @override
  String get exportCompleteDescription => 'PDF 파일이 기기에 저장되었으며 공유하거나 볼 수 있습니다.';

  @override
  String get exportFailed => '내보내기 실패';

  @override
  String get exportingData => '데이터를 내보내는 중...';

  @override
  String get exportingDataDescription => '잠시 기다려 주세요';

  @override
  String get restartApp => '앱 다시 시작';

  @override
  String get cameraAccess => '카메라 접근';

  @override
  String get cameraAccessMessage => 'Yumie는 음식 아이템을 스캔하고 식사를 정확하게 기록하는 데 도움이 되도록 카메라 접근이 필요합니다.';

  @override
  String get photoLibraryAccess => '사진 라이브러리 접근';

  @override
  String get photoLibraryAccessMessage => 'Yumie는 스캔된 이미지를 저장하고 식사 기록을 위한 사진을 선택하기 위해 사진 라이브러리 접근이 필요합니다.';

  @override
  String get notificationAccess => '알림 접근';

  @override
  String get notificationAccessMessage => 'Yumie는 식사 알림, 수분 섭취 경고, 마음챙김 걷기 알림을 보내기 위해 알림 접근이 필요합니다.';

  @override
  String get notNow => '지금은 아님';

  @override
  String get permissionsCompleted => '권한 완료!';

  @override
  String get allPermissionsGranted => '모든 권한이 부여되었습니다! Yumie를 사용할 준비가 되었습니다.';

  @override
  String get whatIsYourMainGoal => '당신의 주요 목표는 무엇인가요?';

  @override
  String get chooseGoalDescription => '여정에 가장 잘 맞는 목표를 선택하세요';

  @override
  String get loseBodyWeight => '체중 감량';

  @override
  String get gainWeight => '체중 증가';

  @override
  String get buildMuscle => '근육 증가';

  @override
  String get eatHealthier => '더 건강하게 먹기';

  @override
  String get maintainBodyWeight => '체중 유지';

  @override
  String get setRealisticGoalForJourney => '여정을 위한 현실적인 목표를 설정하세요';

  @override
  String get targetWeightSetToCurrent => '목표 체중이 현재 체중으로 설정되었습니다';

  @override
  String get iAcceptThe => '다음에 동의합니다';

  @override
  String get and => '및';

  @override
  String get johnDoe => '홍길동';

  @override
  String get yourEmailExample => 'your.email@example.com';

  @override
  String get byContinuingYouAgreeToOur => '계속하면 다음에 동의하는 것입니다';

  @override
  String get whatMotivatesYou => '무엇이 당신을 동기부여하나요?';

  @override
  String get chooseWhatDrivesYou => '목표 달성을 위해 당신을 움직이는 것을 선택하세요';

  @override
  String get feelEnergeticEveryDay => '매일 활력 넘치게 느끼기';

  @override
  String get achievePersonalMilestone => '개인적인 이정표 달성';

  @override
  String get boostMyConfidence => '자신감 향상';

  @override
  String get longTermHealth => '장기 건강';

  @override
  String get trackYourMealsWithEase => '쉽게 식사를 추적하세요';

  @override
  String get caloriesLeft => '남은 칼로리';

  @override
  String get thisHelpsUsPersonalizeNutrition => '이것은 영양 계획을 개인화하는 데 도움이 됩니다';

  @override
  String get male => '남성';

  @override
  String get female => '여성';

  @override
  String get other => '기타';

  @override
  String get thisHelpsUsPersonalizeExperience => '이것은 경험을 개인화하는 데 도움이 됩니다';

  @override
  String get older => '더 나이 많음';

  @override
  String get younger => '더 젊음';

  @override
  String get yearsOld => '세';

  @override
  String get selected => '선택됨';

  @override
  String get teens => '청소년';

  @override
  String get yourCurrentWeight => '현재 체중';

  @override
  String get activityLevel => '활동 수준';

  @override
  String get diabetic => '당뇨병?';

  @override
  String get howMuchWaterADay => '하루에 물을 얼마나 마시나요?';

  @override
  String get fitnessProfile => '피트니스 프로필';

  @override
  String get dueToCurrentAnswers => '현재 답변으로 인해';

  @override
  String get remindersWouldYouLike => '어떤 알림을 받고 싶으신가요?';

  @override
  String get yumieIsCookingUp => 'Yumie가 맞춤형 영양 계획을 준비하고 있습니다...';

  @override
  String get yourAllSet => '준비 완료!';

  @override
  String get google => 'Google';

  @override
  String get fiftyPlus => '50+';

  @override
  String get forties => '40대';

  @override
  String get thirties => '30대';

  @override
  String get twenties => '20대';

  @override
  String get weightUnit => 'kg';

  @override
  String get heightUnit => 'cm';

  @override
  String get feetUnit => '피트';

  @override
  String get inchesUnit => '인치';

  @override
  String get poundsUnit => '파운드';

  @override
  String get whatIsYourAge => '나이는 몇 살인가요?';

  @override
  String get whatIsYourHeight => '키는 얼마인가요?';

  @override
  String get whatIsYourWeight => '현재 체중은 얼마인가요?';

  @override
  String get whatIsYourGoalWeight => '목표 체중은 얼마인가요?';

  @override
  String get whatIsYourActivityLevel => '활동 수준은 어떻게 되나요?';

  @override
  String get howMuchWaterDaily => '하루에 물을 얼마나 마시나요?';

  @override
  String get sedentary => '거의 운동하지 않음';

  @override
  String get lightlyActive => '가벼운 운동/스포츠 주 1-3일';

  @override
  String get moderatelyActive => '보통 운동/스포츠 주 3-5일';

  @override
  String get veryActive => '많은 운동/스포츠 주 6-7일';

  @override
  String get extremelyActive => '매우 많은 운동/스포츠';

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
  String get oneToTwoGlasses => '1-2잔';

  @override
  String get threeToFourGlasses => '3-4잔';

  @override
  String get fiveToSixGlasses => '5-6잔';

  @override
  String get sevenToEightGlasses => '7-8잔';

  @override
  String get moreThanEightGlasses => '8잔 이상';

  @override
  String get mealReminders => '식사 알림';

  @override
  String get waterReminders => '물 섭취 알림';

  @override
  String get workoutReminders => '운동 알림';

  @override
  String get progressUpdates => '진행 상황 업데이트';

  @override
  String get dailyTips => '일일 팁';

  @override
  String get youAreAllSet => '준비 완료!';

  @override
  String get welcomeToYourHealthJourney => '건강 여정에 오신 것을 환영합니다';

  @override
  String get letsGetStarted => '시작해 봅시다!';

  @override
  String get pleaseWait => '잠시만 기다려 주세요...';

  @override
  String get cookingUpYourPlan => '맞춤형 계획을 준비하는 중';

  @override
  String get analyzingYourData => '데이터를 분석하는 중';

  @override
  String get creatingCustomPlan => '맞춤형 영양 계획을 만드는 중';

  @override
  String get almostDone => '거의 완료!';

  @override
  String get subscriptionRequired => '구독 필요';

  @override
  String get upgradeToUnlock => '모든 기능을 잠금 해제하려면 업그레이드하세요';

  @override
  String get startFreeTrial => '무료 체험 시작';

  @override
  String get month => '월';

  @override
  String get year => '년';

  @override
  String get free => '무료';

  @override
  String get mostPopular => '가장 인기';

  @override
  String get skip => '건너뛰기';

  @override
  String get next => '다음';

  @override
  String get back => '뒤로';

  @override
  String get done => '완료';

  @override
  String get error => '오류';

  @override
  String get success => '성공';

  @override
  String get warning => '경고';

  @override
  String get info => '정보';

  @override
  String get retry => '다시 시도';

  @override
  String get loading => '로딩 중...';

  @override
  String get noDataAvailable => '사용 가능한 데이터 없음';

  @override
  String get tryAgain => '다시 시도';

  @override
  String get somethingWentWrong => '문제가 발생했습니다';

  @override
  String get internetConnectionRequired => '인터넷 연결 필요';

  @override
  String get pleaseCheckConnection => '인터넷 연결을 확인해 주세요';

  @override
  String get restartOnboarding => '온보딩 다시 시작';

  @override
  String get getStarted => '시작하기';

  @override
  String get couldNotOpenPlayStore => 'Play Store를 열 수 없습니다';

  @override
  String get errorOpeningPlayStore => 'Play Store 열기 오류';

  @override
  String get remove => '제거';

  @override
  String get couldNotOpenLink => '링크를 열 수 없습니다';

  @override
  String get errorOpeningLink => '링크 열기 오류';

  @override
  String get help => '도움말';

  @override
  String get name => '이름';

  @override
  String get dailyCalorieGoal => '일일 칼로리 목표';

  @override
  String get manageSubscription => '구독 관리';

  @override
  String get deletionFailed => '삭제 실패';

  @override
  String get dismiss => '해제';

  @override
  String get grantPermission => '권한 부여';

  @override
  String get littleOrNoExercise => '운동을 거의 하지 않거나 하지 않음';

  @override
  String get lightExercise => '가벼운 운동/스포츠 주 1-3일';

  @override
  String get moderateExercise => '보통 운동/스포츠 주 3-5일';

  @override
  String get hardExercise => '많은 운동/스포츠 주 6-7일';

  @override
  String get share => '공유';

  @override
  String get openSettings => '설정 열기';

  @override
  String get notificationsForMealLogging => '식사 기록 알림';

  @override
  String get notificationsForWaterIntake => '수분 섭취 알림';

  @override
  String get notificationsForMindfulWalk => '마음챙김 걷기 알림';

  @override
  String get increment => '증가';

  @override
  String get enterNewName => '새 이름 입력';

  @override
  String get readOurPrivacyPolicy => '개인정보처리방침 읽기';

  @override
  String get readOurTermsOfService => '이용약관 읽기';

  @override
  String get helpUsCalculateYourHealthGoals => '건강 목표 계산을 도와주세요';

  @override
  String get thisHelpsUsTrackYourProgress => '이것은 진행 상황을 추적하는 데 도움이 됩니다';

  @override
  String get setARealisticGoalForYourJourney => '여정을 위한 현실적인 목표를 설정하세요';

  @override
  String get thisHelpsUsPersonalizeYourPlan => '이것은 계획을 개인화하는 데 도움이 됩니다';

  @override
  String get stayingHydratedIsKeyToYourHealth => '수분 유지는 건강의 핵심입니다';

  @override
  String get yourFitnessProfileDueToYourAnswers => '답변으로 인한 피트니스 프로필';

  @override
  String get currentBMI => '현재 BMI';

  @override
  String get obese => '비만';

  @override
  String get activityLevelLabel => '활동 수준';

  @override
  String get bloodTypeLabel => '혈액형';

  @override
  String get diabeticLabel => '당뇨병';

  @override
  String get waterIntakeLabel => '수분 섭취';

  @override
  String get heresYourPersonalizedNutritionPlan => '맞춤형 영양 계획입니다. Yumie와 함께하는 건강 여정에 오신 것을 환영합니다';

  @override
  String get caloriesGoal => '칼로리 목표';

  @override
  String get carbsGoal => '탄수화물 목표';

  @override
  String get startNow => '지금 시작';

  @override
  String get underweight => '저체중';

  @override
  String get normalWeight => '정상 체중';

  @override
  String get healthy => '건강함';

  @override
  String get overweight => '과체중';

  @override
  String get avocadoToast => '아보카도 토스트';

  @override
  String get italianSalad => '이탈리안 샐러드';

  @override
  String get chickenKatsuRiceBowl => '치킨 카츠 라이스 볼';

  @override
  String get yourTargetWeightIsSetToCurrent => '목표 체중이 현재 체중으로 설정되었습니다';

  @override
  String get couldNotGenerateYourPlan => '계획을 생성할 수 없습니다. 다시 시도해 주세요.';

  @override
  String get somethingWentWrongRestart => '문제가 발생했습니다. 온보딩 과정을 다시 시작해 주세요.';

  @override
  String get yourBMI => 'BMI:';

  @override
  String get lbs => '파운드';

  @override
  String get yourActivityLevel => '활동 수준';

  @override
  String get analyzingFridge => '냉장고 분석 중...';

  @override
  String get aiDetectingFoodItems => 'AI가 식품을 감지 중';

  @override
  String get tryClearerPhoto => '냉장고의 더 선명한 사진을 찍어보세요';

  @override
  String get generating => '생성 중...';

  @override
  String get premiumStatus => '프리미엄 상태';

  @override
  String get thankYouForSupport => '지원해주셔서 감사합니다! 💚';

  @override
  String get yourPremiumFeatures => '프리미엄 기능';

  @override
  String get subscriptionError => '구독 오류';

  @override
  String get unknownErrorOccurred => '알 수 없는 오류가 발생했습니다';

  @override
  String get privacyAndAds => '개인정보 및 광고';

  @override
  String get reviewAdPreferences => '광고 기본 설정 검토';

  @override
  String get privacyOptionsNotAvailable => '귀하의 지역에서는 개인정보 옵션을 사용할 수 없습니다.';

  @override
  String get consentFlowCompleted => '동의 절차가 완료되었습니다!';

  @override
  String get appleSignInFailed => 'Apple 로그인 실패';

  @override
  String get adFailedToShow => '광고 표시에 실패했습니다. 다시 시도해 주세요.';

  @override
  String get adNotLoadedYet => '광고가 아직 로드되지 않았습니다. 다시 시도해 주세요.';

  @override
  String get errorRequestingPermissions => '권한 요청 오류';

  @override
  String get showMore => '더 보기';

  @override
  String get showLess => '간단히 보기';

  @override
  String get noSavedCustomMeals => '저장된 맞춤 식사가 없습니다.';

  @override
  String get savedCustomMealsPlus => '저장된 맞춤 식사 +';

  @override
  String get customBuilding => '맞춤 식사 만들기';

  @override
  String get enterName => '이름 입력';

  @override
  String get enterFoodName => '음식 이름 입력';

  @override
  String get congratulationsGoalReached => '🎉 축하합니다!';

  @override
  String get youReachedGoalWeight => '목표 체중에 도달했습니다!';

  @override
  String get switchToMaintenancePlan => '이제 유지 계획으로 전환합시다!';

  @override
  String get letsDoIt => '시작합시다!';

  @override
  String get keepUpGreatWork => '아주 잘하고 있어요!';

  @override
  String get generatingMaintenancePlan => '유지 계획을 생성하는 중...';

  @override
  String get maintenancePlanUpdated => '🎉 영양 계획이 유지 모드로 업데이트되었습니다!';

  @override
  String get failedToGenerateMaintenancePlan => '유지 계획 생성에 실패했습니다. 다시 시도하세요.';

  @override
  String get heresYourMaintenancePlan => '새로운 유지 계획입니다!';

  @override
  String get keepThisPlan => '이 플랜 유지';

  @override
  String get chooseDifferentGoal => '다른 목표 선택';

  @override
  String get whatsYourNewGoal => '새로운 목표는 무엇인가요?';

  @override
  String get whatsYourNewTargetWeight => '새로운 목표 체중은?';

  @override
  String get yumieGeneratingNewPlan => 'Yumie가 새 맞춤 계획을 생성 중...';

  @override
  String get yourNewPlanReady => '새로운 계획이 준비되었습니다!';

  @override
  String get startWithNewPlan => '새 계획으로 시작';

  @override
  String get generateNewPlan => '새 계획 생성';

  @override
  String get planGenerationLimitReached => '이 기간의 계획 생성 2회를 모두 사용했습니다.';

  @override
  String get waterGoal => '물 섭취 목표';

  @override
  String get glasses => '잔';

  @override
  String planGenerationInfo(int remaining) {
    return '앞으로 14일 동안 $remaining개의 개인화된 계획을 더 생성할 수 있습니다.';
  }

  @override
  String nextPlanAvailable(int days) {
    return '$days일 후에 다시 시도하세요';
  }

  @override
  String get decline => '거절';

  @override
  String get planDeclined => '계획이 거절되었습니다';

  @override
  String get accountDeletionWarning => '계정이 48시간 후에 삭제됩니다. 48시간 내에 다시 로그인하면 계정이 재활성화되고 삭제가 취소됩니다.';

  @override
  String get accountScheduledForDeletion => '계정 삭제 예약됨';

  @override
  String get reactivateAccount => '계정 재활성화';

  @override
  String get accountReactivated => '다시 오신 것을 환영합니다! 계정이 재활성화되었습니다.';

  @override
  String get accountDeletionCancelled => '계정 삭제가 취소되었습니다.';

  @override
  String get emailVerificationRequired => '이메일 인증 필요';

  @override
  String get pleaseVerifyEmail => '계속하려면 이메일 주소를 인증해 주세요';

  @override
  String get verificationEmailSent => '이메일로 인증 링크를 보냈습니다. 받은 편지함을 확인하고 링크를 클릭하여 계정을 인증해 주세요.';

  @override
  String get waitingForVerification => '이메일 인증을 기다리는 중...';

  @override
  String get checkYourEmail => '이메일을 확인하고 인증 링크를 클릭하세요';

  @override
  String get resendVerificationEmail => '인증 이메일 재전송';

  @override
  String get verificationLinkAlreadySent => '이 이메일 주소로 이미 인증 링크가 전송되었습니다. 받은 편지함을 확인하거나 몇 분 기다린 후 새 링크를 요청해 주세요.';

  @override
  String get emailVerified => '이메일이 성공적으로 인증되었습니다!';

  @override
  String get emailNotVerified => '이메일이 아직 인증되지 않았습니다. 받은 편지함을 확인해 주세요.';

  @override
  String get changeEmail => '이메일 변경';

  @override
  String get continueToApp => '앱 계속하기';

  @override
  String get failedToSendVerificationEmail => '인증 이메일 전송 실패';

  @override
  String get failedToResendVerificationEmail => '인증 이메일 재전송 실패';

  @override
  String get errorCheckingVerification => '인증 상태 확인 오류';

  @override
  String get helloIAmYumie => '안녕하세요, 저는 Yumie입니다! 오늘 스트릭을 시작하기 위해 식사를 기록해주세요!';

  @override
  String get happyBirthday => '🎉 생일 축하해요!';

  @override
  String birthdayMessage(int age) {
    return '멋진 하루 보내세요! 이제 $age살이 되셨습니다.';
  }

  @override
  String get selectBirthday => '생일을 선택하세요';

  @override
  String get day => '일';

  @override
  String get accountAlreadyExists => '계정이 이미 존재합니다';

  @override
  String get accountExistsMessage => '이 이메일 주소로 계정이 이미 존재합니다. 대신 로그인하시겠습니까?';

  @override
  String get accountUsesDifferentSignIn => '계정이 다른 로그인 방법을 사용합니다';

  @override
  String get emailSignedUpWithGoogle => '이 이메일은 이미 Google로 등록되어 있습니다. 대신 \"Google로 로그인\"을 사용하세요.';

  @override
  String get emailSignedUpWithPassword => '이 이메일은 이미 이메일과 비밀번호로 등록되어 있습니다. 비밀번호를 사용하여 로그인하세요.';

  @override
  String get useGoogleSignIn => 'Google 로그인 사용';

  @override
  String get signInWithEmail => '이메일로 로그인';
}
