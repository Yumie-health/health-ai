// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get settings => '設定';

  @override
  String get preferences => '設定';

  @override
  String get darkMode => 'ダークモード';

  @override
  String get enableDarkTheme => 'ダークテーマを有効にする';

  @override
  String get useMetricUnits => 'メートル法を使用';

  @override
  String get unitsSubtitle => 'kg/cm（オン）またはlb/ft（オフ）を使用';

  @override
  String get language => '言語';

  @override
  String get selectLanguage => 'アプリの言語を選択';

  @override
  String get habitNotifications => '習慣通知';

  @override
  String get mealLoggingPrompts => '食事記録のプロンプト';

  @override
  String get mealLoggingPromptsSubtitle => '食事を記録するリマインダーを受け取る';

  @override
  String get waterIntakeReminders => '水分摂取リマインダー';

  @override
  String get waterIntakeRemindersSubtitle => '水を飲むリマインダーを受け取る';

  @override
  String get mindfulWalksReminders => 'マインドフルウォークリマインダー';

  @override
  String get mindfulWalksRemindersSubtitle => 'マインドフルウォークのリマインダーを受け取る';

  @override
  String get momentOfCalmAfterMeals => '食事後の落ち着きの時間';

  @override
  String get momentOfCalmAfterMealsSubtitle => '食事を記録した後に落ち着くポップアップを表示';

  @override
  String get welcomeBack => 'おかえりなさい！';

  @override
  String get trackNutritionToday => '今日の栄養を追跡しましょう';

  @override
  String get subtitleAfternoon => '昼食を記録してバランスを保つのに最適な時間です。';

  @override
  String get subtitleEvening => '今夜も継続しましょう—食事を記録してください。';

  @override
  String get subtitleNight => '一日を締めくくりましょう—今日の食事の記録をお忘れなく。';

  @override
  String get streakNearEndingTitle => '連続記録を守ろう 🔥';

  @override
  String get streakNearEndingBody => '連続記録が途切れそうです。今日は食事を記録して続けましょう！';

  @override
  String get streakNearEndingTitle2 => 'あと少し！ 🔥';

  @override
  String get streakNearEndingBody2 => '残り数時間です。食事を記録して記録を守りましょう！';

  @override
  String get streakEndedTitle => '連続記録が終了しました';

  @override
  String get streakEndedBody => '連続記録が途切れました。食事を記録して再スタートしましょう！';

  @override
  String get streakActive => '連続記録: アクティブ';

  @override
  String get streakInactive => '連続記録: 非アクティブ';

  @override
  String get currentStreak => '現在の連続日数';

  @override
  String get entriesInStreak => '連続期間のエントリー数';

  @override
  String get days => '日';

  @override
  String get startedOn => '開始日';

  @override
  String get logMealToStartStreak => '連続記録を始めるには、今日の食事を記録しましょう';

  @override
  String get nutritionSummary => '栄養サマリー';

  @override
  String get setCalorieAndMacroGoals => '栄養計画ページでカロリーとマクロの目標を設定してください。';

  @override
  String get protein => 'タンパク質';

  @override
  String get carbs => '炭水化物';

  @override
  String get fat => '脂質';

  @override
  String get calories => 'カロリー';

  @override
  String get quickActions => 'クイックアクション';

  @override
  String get logMeal => '食事を記録';

  @override
  String get trackYourFood => '食べ物を追跡';

  @override
  String get scan => 'スキャン';

  @override
  String get barcode => 'バーコード';

  @override
  String get analyzeYourFood => '食べ物を分析';

  @override
  String get todaysMeals => '今日の食事';

  @override
  String get viewAll => 'すべて表示';

  @override
  String get noMealsLoggedForThisDay => 'この日の食事記録はありません。';

  @override
  String get nutritionalPlan => '栄養計画';

  @override
  String get weightAnalytics => '体重分析';

  @override
  String get toGoal => '目標まで';

  @override
  String get remaining => '残り';

  @override
  String get weeklyRate => '週間ペース';

  @override
  String get weeklyLoss => '週あたりの減少';

  @override
  String get starting => '開始';

  @override
  String get current => '現在';

  @override
  String get today => '今日';

  @override
  String get targetLabel => '目標';

  @override
  String get goalWeight => '目標体重';

  @override
  String get eta => 'ETA';

  @override
  String get sinceStart => '開始以来';

  @override
  String get expectationsDisclaimer => 'これらの予測は最近の傾向に基づいており、新しい体重を記録すると変化する可能性があります。';

  @override
  String get loseVerb => '減らす';

  @override
  String get gainVerb => '増やす';

  @override
  String expectationBlurb(Object direction, Object eta, Object rate, Object remaining, Object unit) {
    return '最近の傾向に基づくと、1週間あたり約 $rate $unit を$direction見込みです。このペースでは、目標に到達するまでおよそ $eta かかります。残りは $remaining $unit です。';
  }

  @override
  String get healthAwareness => '健康意識';

  @override
  String get planSettings => '計画設定';

  @override
  String get featureComingSoon => 'この機能は近日公開予定です！';

  @override
  String get ok => 'OK';

  @override
  String get rateUsOnGoogle => 'Googleで評価する';

  @override
  String get comingSoon => '近日公開！';

  @override
  String get ratingOnGoogleAvailableAfterRelease => 'Googleでの評価はリリース後に利用可能になります。';

  @override
  String get shareWithFriends => '友達と共有';

  @override
  String get sharingAvailableAfterRelease => '共有はリリース後に利用可能になります。';

  @override
  String get resetPassword => 'パスワードをリセット';

  @override
  String get close => '閉じる';

  @override
  String get sendResetLink => 'リセットリンクを送信';

  @override
  String get send => '送信';

  @override
  String get resend => '再送信';

  @override
  String get helpSupport => 'ヘルプ＆サポート';

  @override
  String get legal => '法的情報';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get termsOfService => '利用規約';

  @override
  String get apiDocumentation => 'APIドキュメント';

  @override
  String get needAssistanceContactSupport => 'サポートが必要ですか？サポートチームにお問い合わせください：';

  @override
  String get testWebURL => 'テストWeb URL';

  @override
  String get testSimpleMailto => 'テストシンプルメール';

  @override
  String get logOut => 'ログアウト';

  @override
  String get areYouSureYouWantToLogOut => 'ログアウトしてもよろしいですか？';

  @override
  String get no => 'いいえ';

  @override
  String get yes => 'はい';

  @override
  String get commonQuestions => 'よくある質問';

  @override
  String get momentOfCalm => '落ち着きの時間';

  @override
  String get practiceMindfulEating => '食事を味わい、マインドフルイーティングを実践する時間を取りましょう。';

  @override
  String get howOldAreYou => 'あなたは何歳ですか？';

  @override
  String get personalizeExperience => 'これにより、あなたの体験をパーソナライズできます';

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
  String get yourHeight => 'あなたの身長';

  @override
  String get yourGoalWeight => 'あなたの目標体重';

  @override
  String get setRealisticGoal => 'あなたの旅の現実的な目標を設定してください';

  @override
  String get allSet => '準備完了です！🎉';

  @override
  String get personalizedNutritionPlan => 'あなたのパーソナライズされた栄養計画です。Yumieとの健康の旅へようこそ！';

  @override
  String get whatIsYourBloodType => 'あなたの血液型は何ですか？';

  @override
  String get personalizeHealthInsights => 'これにより、あなたの健康インサイトをパーソナライズできます。';

  @override
  String get whatIsYourSex => 'あなたの性別は何ですか？';

  @override
  String get personalizeNutritionPlan => 'これにより、あなたの栄養計画をパーソナライズできます。';

  @override
  String get home => 'ホーム';

  @override
  String get food => '食事';

  @override
  String get coach => 'コーチ';

  @override
  String get profile => 'プロフィール';

  @override
  String get log => '記録';

  @override
  String get myMeals => '私の食事';

  @override
  String get suggestedMeals => '推奨食事';

  @override
  String get monthly => '月次';

  @override
  String get weekly => '週次';

  @override
  String get breakfast => '朝食';

  @override
  String get lunch => '昼食';

  @override
  String get dinner => '夕食';

  @override
  String get snack => 'スナック';

  @override
  String get reviewMeal => '食事を確認';

  @override
  String get chat => 'チャット';

  @override
  String get insights => 'インサイト';

  @override
  String get clearChat => 'チャットをクリア';

  @override
  String get coachWelcome => 'こんにちは！私はYumie、あなたの栄養コーチです。今日はどのようにお手伝いできますか？\n\n健康的なレシピ、食事計画、または栄養のヒントについてYumieに聞いてください！';

  @override
  String get refreshInsight => 'インサイトを更新';

  @override
  String get healthInsights => '健康インサイト';

  @override
  String get noInsightAvailable => '利用可能なインサイトはありません。';

  @override
  String get dinnerIdeas => '夕食のアイデア';

  @override
  String get calorieCheck => 'カロリーチェック';

  @override
  String get proteinSnacks => 'タンパク質スナック';

  @override
  String get dietTips => 'ダイエットのヒント';

  @override
  String get typeYourMessage => 'メッセージを入力...';

  @override
  String get yumie => 'Yumie';

  @override
  String get askAboutMeals => '食事と栄養について質問';

  @override
  String get coachQuick1 => '今日は何を食べるべきですか？';

  @override
  String get coachQuick2 => '私の最後の食事を分析してください';

  @override
  String get coachQuick3 => '週の計画を立てるのを手伝ってください';

  @override
  String get yumieThinking => 'Yumieが考え中...';

  @override
  String get bmi => 'BMI';

  @override
  String get target => '目標';

  @override
  String get weight => '体重';

  @override
  String get age => '年齢';

  @override
  String get height => '身長';

  @override
  String get targetWeight => '目標体重';

  @override
  String get calorieGoal => 'カロリー目標';

  @override
  String get proteinGoal => 'タンパク質目標';

  @override
  String get carbGoal => '炭水化物目標';

  @override
  String get fatGoal => '脂質目標';

  @override
  String get waterIntake => '水分摂取';

  @override
  String get save => '保存';

  @override
  String get cancel => 'キャンセル';

  @override
  String get undo => '元に戻す';

  @override
  String get notSet => '未設定';

  @override
  String get uploadNew => '新規アップロード';

  @override
  String get delete => '削除';

  @override
  String get editName => '名前を編集';

  @override
  String get bloodType => '血液型';

  @override
  String get areYouDiabetic => 'あなたは糖尿病ですか？';

  @override
  String get healthAwarenessUpdated => '健康意識が更新されました！';

  @override
  String get takeMomentToAppreciate => '食事を味わい、マインドフルイーティングを実践する時間を取りましょう。';

  @override
  String get continueButton => '続行';

  @override
  String get mealSaved => '食事が保存されました！';

  @override
  String get noRecentFoods => '最近の食べ物はありません。';

  @override
  String get buildCustomMeal => 'カスタム食事を作成';

  @override
  String get mealName => '食事名';

  @override
  String get searchOrEnterFoodName => '検索または食べ物の名前を入力';

  @override
  String get ingredients => '材料';

  @override
  String get addIngredient => '材料を追加';

  @override
  String get myFoods => '私の食べ物';

  @override
  String get noCustomFoods => 'まだカスタム食べ物を保存していません';

  @override
  String get addCustomFood => 'カスタム食べ物を追加';

  @override
  String get editCustomMeal => 'カスタム食事を編集';

  @override
  String get clearAll => 'すべてクリア';

  @override
  String get foodName => '食べ物名';

  @override
  String get saveMeal => '食事を保存';

  @override
  String get customizeMeal => '食事をカスタマイズ';

  @override
  String get hideIngredients => '材料を隠す';

  @override
  String get showIngredients => '材料を表示';

  @override
  String get ingredientsColon => '材料：';

  @override
  String get noIngredientsListed => '材料が記載されていません。';

  @override
  String get recent => '最近';

  @override
  String get meal => '食事';

  @override
  String get fridge => '冷蔵庫';

  @override
  String get placeFoodInFrame => '食べ物をフレーム内に配置してください';

  @override
  String get placeBarcodeInFrame => '枠内にバーコードを合わせてください';

  @override
  String get placeFridgeInFrame => '枠内に冷蔵庫を合わせてください';

  @override
  String get productNotFound => '商品が見つかりません';

  @override
  String get safetyUnsafe => '安全ではありません';

  @override
  String get safetyGood => '問題ありません';

  @override
  String get badgeNutriScore => 'Nutri-Score';

  @override
  String get badgeNova => 'NOVA';

  @override
  String get allergensTitle => 'アレルゲン';

  @override
  String get contains => '含有';

  @override
  String get allergensNone => 'アレルゲンの記載なし';

  @override
  String get serving => 'サービング';

  @override
  String get kcalPer100g => 'kcal/100g';

  @override
  String get sugar => '砂糖';

  @override
  String get satFat => '飽和脂肪';

  @override
  String get salt => '塩';

  @override
  String get ingredientsTitle => '材料';

  @override
  String get riskAllergen => 'アレルゲンリスク';

  @override
  String get riskUltraProcessed => '超加工食品 (NOVA 4)';

  @override
  String get riskHighAdditives => '添加物が多い';

  @override
  String get riskLowNutri => '低いNutri‑Score';

  @override
  String get riskVegan => 'ヴィーガン対応';

  @override
  String get riskVegetarian => 'ベジタリアン';

  @override
  String get riskLooksGood => '良さそう';

  @override
  String get retakeScan => 'スキャンを再実行';

  @override
  String get previewFullImage => 'フル画像をプレビュー';

  @override
  String get discard => '破棄';

  @override
  String get upgradeToPremium => 'プレミアムにアップグレード';

  @override
  String get getUnlimitedScans => '無制限のスキャンとその他を取得！';

  @override
  String get getUnlimitedSearches => '無制限の検索とその他を取得！';

  @override
  String get upgradePlan => 'プランをアップグレード';

  @override
  String get watchAdForScan => 'スキャンのために広告を見る';

  @override
  String get watchAdForSearch => '検索のために広告を見る';

  @override
  String get generateMeal => '食事を生成';

  @override
  String get detectedFridgeItems => '検出された冷蔵庫アイテム';

  @override
  String get noFridgeItemsDetected => '冷蔵庫アイテムが検出されませんでした。';

  @override
  String get searchResults => '検索結果';

  @override
  String get searchingFor => '検索中';

  @override
  String get noResultsFoundFor => '見つかりませんでした';

  @override
  String get count => '数';

  @override
  String get servings => 'サービング';

  @override
  String get fluidOunces => '液量オンス';

  @override
  String get quantity => '数量';

  @override
  String get confirm => '確認';

  @override
  String get ingredient => '材料';

  @override
  String get drink => '飲み物';

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
  String get ft => 'ft';

  @override
  String get inches => 'インチ';

  @override
  String get cup => 'カップ';

  @override
  String get tbsp => '大さじ';

  @override
  String get tsp => '小さじ';

  @override
  String get ml => 'ml';

  @override
  String get l => 'l';

  @override
  String get upgradeToPremiumTitle => 'プレミアムにアップグレード';

  @override
  String get premiumFeatures => 'プレミアム機能';

  @override
  String get unlimitedScans => '無制限のスキャン';

  @override
  String get aiNutritionCoach => 'AI栄養コーチ';

  @override
  String get detailedAnalytics => '詳細分析';

  @override
  String get personalizedMealPlans => 'パーソナライズされた食事計画';

  @override
  String get noAdvertisements => '広告なし';

  @override
  String get yearlyPremium => '年間プレミアム';

  @override
  String get monthlyPremium => '月間プレミアム';

  @override
  String savePercent(Object percent) {
    return '$percent%節約';
  }

  @override
  String get perYear => '/年';

  @override
  String get perMonth => '/月';

  @override
  String get popular => '人気';

  @override
  String get maybeLater => '後で';

  @override
  String get welcomeToYumie => '🎉 Yumieへようこそ！';

  @override
  String get unlockPremiumFeatures => 'プレミアム機能をアンロック';

  @override
  String get getMostOutOfHealthJourney => '無制限アクセスで健康の旅を最大限に活用しましょう！';

  @override
  String get unlimitedScansAICoaching => '無制限のスキャン、AIコーチング、パーソナライズされた食事計画をアンロック！';

  @override
  String get subscribe => '購読';

  @override
  String get foodNameLabel => '食べ物名';

  @override
  String get managePermissions => '権限を管理';

  @override
  String get cameraNotificationsAndMore => 'カメラ、通知など';

  @override
  String get deleteMeal => '食事を削除';

  @override
  String get areYouSureDeleteMeal => 'この食事を削除してもよろしいですか？';

  @override
  String get unknown => '不明';

  @override
  String get servings1 => 'サービング 1';

  @override
  String get edit => '編集';

  @override
  String get ignoreFood => '食べ物を無視';

  @override
  String get addComponent => 'コンポーネントを追加';

  @override
  String get components => 'コンポーネント';

  @override
  String get recentFoods => '最近の食べ物';

  @override
  String get logWeightChange => '体重';

  @override
  String get lost => '減少';

  @override
  String get gained => '増加';

  @override
  String get googleSignInHelp => 'Googleサインインヘルプ';

  @override
  String get couldNotOpenTermsOfService => '利用規約を開けませんでした';

  @override
  String get couldNotOpenPrivacyPolicy => 'プライバシーポリシーを開けませんでした';

  @override
  String get errorSavingProfile => 'プロフィールの保存エラー';

  @override
  String get completeYourProfile => 'プロフィールを完成させる';

  @override
  String get saveAndContinue => '保存して続行';

  @override
  String get pleasSignIn => 'サインインしてください。';

  @override
  String get noFoodLogsYet => 'まだ食べ物ログはありません。';

  @override
  String get healthAIFoodLog => 'HealthAI - 食べ物ログ';

  @override
  String get addLog => 'ログを追加';

  @override
  String get unableToShareAtThisTime => '現在共有できません。後でもう一度お試しください。';

  @override
  String get failedToUpdatePhoto => '写真の更新に失敗しました';

  @override
  String get changeProfileName => 'プロフィール名を変更';

  @override
  String get failedToUpdateName => '名前の更新に失敗しました';

  @override
  String get profileUpdatedSuccessfully => 'プロフィールが正常に更新されました';

  @override
  String get errorUpdatingProfile => 'プロフィールの更新エラー';

  @override
  String get editGoals => '目標を編集';

  @override
  String get goalsUpdatedSuccessfully => '目標が正常に更新されました';

  @override
  String get errorUpdatingGoals => '目標の更新エラー';

  @override
  String get couldNotOpenWebsite => 'ウェブサイトを開けませんでした';

  @override
  String get errorOpeningWebsite => 'ウェブサイトを開くエラー';

  @override
  String get english => '英語';

  @override
  String get arabic => 'アラビア語';

  @override
  String get spanish => 'スペイン語';

  @override
  String get reviewMealTitle => '食事を確認';

  @override
  String get startingWeight => '開始体重';

  @override
  String get appPermissions => 'アプリ権限';

  @override
  String get permissionStatus => '権限ステータス';

  @override
  String get manageAppPermissions => 'すべての機能が正常に動作するようにアプリ権限を管理';

  @override
  String get camera => 'カメラ';

  @override
  String get scanFoodItems => '食べ物をスキャンして食事の写真を撮る';

  @override
  String get photoLibrary => '写真';

  @override
  String get saveScannedImages => 'スキャンした画像を保存して写真を選択';

  @override
  String get notifications => '通知';

  @override
  String get sendMealReminders => '食事リマインダーと健康アラートを送信';

  @override
  String get needHelp => 'ヘルプが必要ですか？';

  @override
  String get permanentlyDeniedHelp => '権限が永続的に拒否されている場合、デバイス設定で有効にできます';

  @override
  String get openDeviceSettings => 'デバイス設定を開く';

  @override
  String get goodMorning => 'おはようございます';

  @override
  String get goodAfternoon => 'こんにちは';

  @override
  String get goodEvening => 'こんばんは';

  @override
  String get goodNight => 'おやすみなさい';

  @override
  String get ounces => 'オンス';

  @override
  String get january => '1月';

  @override
  String get february => '2月';

  @override
  String get march => '3月';

  @override
  String get april => '4月';

  @override
  String get may => '5月';

  @override
  String get june => '6月';

  @override
  String get july => '7月';

  @override
  String get august => '8月';

  @override
  String get september => '9月';

  @override
  String get october => '10月';

  @override
  String get november => '11月';

  @override
  String get december => '12月';

  @override
  String get trackYourNutrition => '栄養を追跡';

  @override
  String get messages => 'メッセージ';

  @override
  String get subscribeForDailyInsights => 'デイリーインサイトを購読';

  @override
  String get getPersonalizedHealthInsights => '完全なプロフィールに基づいてパーソナライズされた健康インサイトを取得';

  @override
  String get upgradeDescription => '無制限のスキャン、検索、AI駆動のインサイトを取得';

  @override
  String get unlimitedFoodScans => '無制限の食べ物スキャン';

  @override
  String get unlimitedFoodSearches => '無制限の食べ物検索';

  @override
  String get unlimitedAICoachMessages => '無制限のAIコーチメッセージ';

  @override
  String get dailyHealthInsights => 'デイリーヘルスインサイト';

  @override
  String get logWaterIntake => '水分';

  @override
  String get add => '追加';

  @override
  String get freemium => 'フリーミアム';

  @override
  String get premium => 'プレミアム';

  @override
  String get chooseYourPlan => 'プランを選択';

  @override
  String get water => '水';

  @override
  String get resetPasswordDescription => 'パスワードリセットリンクがメールで送信されます';

  @override
  String get deleteAccount => 'アカウントを削除';

  @override
  String get deleteAccountDescription => 'アカウントとすべてのデータを永続的に削除';

  @override
  String get confirmDeleteAccount => 'アカウントを削除してもよろしいですか？';

  @override
  String get deleteAccountWarning => 'この操作は元に戻せません。食事、進捗、設定を含むすべてのデータが永続的に削除されます。';

  @override
  String get typeDeleteToConfirm => '確認するには「削除」と入力してください';

  @override
  String get deleteAccountFinalConfirmation => '削除';

  @override
  String get accountDeleted => 'アカウント削除済み';

  @override
  String get errorDeletingAccount => 'アカウント削除エラー';

  @override
  String get totalNutrition => '総栄養';

  @override
  String get unlockUnlimitedScans => '無制限のスキャン、AIコーチング、\nパーソナライズされた食事計画をアンロック';

  @override
  String get unlimitedFoodScanning => '無制限の食べ物スキャン';

  @override
  String get yearPrice => '年/\$49.99';

  @override
  String get monthPrice => '月/\$7.99';

  @override
  String get save37 => '37%節約';

  @override
  String get youArePremium => 'プレミアムです！';

  @override
  String get yumiePremiumMonthly => 'Yumie™月間プレミアム';

  @override
  String get yumiePremiumYearly => 'Yumie™年間プレミアム';

  @override
  String get restorePurchases => '購入を復元';

  @override
  String get checkingForPurchases => '既存の購入を確認中...';

  @override
  String get purchasesRestored => '購入が正常に復元されました！';

  @override
  String get noPurchasesFound => '以前の購入が見つかりませんでした';

  @override
  String get restoreFailed => '購入の復元に失敗しました。もう一度お試しください。';

  @override
  String get restoreInProgress => '購入を復元中...';

  @override
  String get bySubscribing => '購読することで、利用規約とプライバシーポリシーに同意します。キャンセルしない限り、サブスクリプションは自動的に更新されます';

  @override
  String get permissionsComplete => '権限完了！';

  @override
  String get whyWeAskForPermissions => '権限をお願いする理由';

  @override
  String get permissionsWhyBody => '食べ物やバーコードをスキャンするためにカメラを使用し、画像をアップロードする際に写真へアクセスし、食事の記録や水分補給を促す通知を送るために使用します。';

  @override
  String get permissionsNextScreen => '次の画面でアクセス許可のシステムダイアログが表示されます。設定からいつでも変更できます。';

  @override
  String get references => '参考文献:';

  @override
  String get cdcAboutBmi => 'CDC: BMIについて';

  @override
  String get usdaDietaryGuidelines => 'USDA 食事ガイドライン';

  @override
  String get termsOfUseEula => '利用規約 (EULA)';

  @override
  String get enterYourPassword => 'パスワードを入力';

  @override
  String get manageSessions => 'セッションを管理';

  @override
  String get selectLanguageTitle => '言語を選択';

  @override
  String get chooseYourPreferredLanguage => 'アプリの希望する言語を選択してください';

  @override
  String get languageChangedTo => '言語が変更されました';

  @override
  String get activeSessions => 'アクティブセッション';

  @override
  String get thisDevice => 'このデバイス';

  @override
  String get sessionRevoked => 'セッションが取り消されました';

  @override
  String get allOtherSessionsSignedOut => '他のすべてのセッションがサインアウトされました';

  @override
  String get signOutAllOthers => '他のすべてをサインアウト';

  @override
  String get noSecurityAlerts => 'セキュリティアラートはありません';

  @override
  String get passwordStrengthWeak => '弱い';

  @override
  String get passwordStrengthFair => '普通';

  @override
  String get passwordStrengthGood => '良い';

  @override
  String get passwordStrengthStrong => '強い';

  @override
  String get passwordStrengthVeryStrong => '非常に強い';

  @override
  String get addLowercaseLetters => '小文字を追加';

  @override
  String get addUppercaseLetters => '大文字を追加';

  @override
  String get addNumbers => '数字を追加';

  @override
  String get addSpecialCharacters => '特殊文字を追加 (!@#\$%^&*)';

  @override
  String get avoidCommonPatterns => '一般的なパターンを避ける';

  @override
  String get requiresAtLeast8Characters => '最低8文字必要';

  @override
  String get tooManySignInAttempts => 'サインイン試行回数が多すぎます。後でもう一度お試しください。';

  @override
  String get tooManySignUpAttempts => 'サインアップ試行回数が多すぎます。後でもう一度お試しください。';

  @override
  String get tooManyPasswordResetRequests => 'パスワードリセット要求が多すぎます。後でもう一度お試しください。';

  @override
  String get multipleFailedSignInAttempts => '複数のサインイン失敗試行';

  @override
  String get excessivePasswordResetRequests => '過度のパスワードリセット要求';

  @override
  String get suspiciousActivityDetected => '不審な活動が検出されました';

  @override
  String get riskLevelMedium => '中';

  @override
  String get riskLevelHigh => '高';

  @override
  String get welcomeToYumiePermissions => 'Yumieへようこそ';

  @override
  String get provideBestExperience => '最高の体験を提供するために、いくつかの権限が必要です';

  @override
  String get grantPermissions => '権限を付与';

  @override
  String get skipForNow => '今はスキップ';

  @override
  String get denied => '拒否';

  @override
  String get granted => '付与';

  @override
  String get createAccount => 'アカウントを作成';

  @override
  String get signUpToGetStarted => 'Yumieを始めるためにサインアップ';

  @override
  String get fullName => 'フルネーム';

  @override
  String get email => 'メール';

  @override
  String get password => 'パスワード';

  @override
  String get agreeToTerms => 'と利用規約 プライバシーポリシーに同意します';

  @override
  String get alreadyHaveAccount => 'すでにアカウントをお持ちですか？';

  @override
  String get signIn => 'サインイン';

  @override
  String get signUp => 'サインアップ';

  @override
  String get signInToAccessAccount => 'アカウントにアクセスするためにサインイン';

  @override
  String get forgotPassword => 'パスワードを忘れましたか？';

  @override
  String get dontHaveAccount => 'アカウントをお持ちでないですか？';

  @override
  String get signUpWithGoogle => 'Googleでサインアップ';

  @override
  String get signInWithGoogle => 'Googleでサインイン';

  @override
  String get signUpWithApple => 'Appleでサインアップ';

  @override
  String get signInWithApple => 'Appleでサインイン';

  @override
  String get resetPasswordTitle => 'パスワードをリセット';

  @override
  String get enterEmailForReset => 'パスワードリセットリンクを受け取るためにメールアドレスを入力してください';

  @override
  String get emailAddress => 'メールアドレス';

  @override
  String get rateUsOn => '評価してください';

  @override
  String get deleteAccountTitle => 'アカウントを削除';

  @override
  String get deleteAccountWarningTitle => 'この操作は永続的で元に戻せません';

  @override
  String get deleteAccountDataList => 'アカウントを削除すると、以下を永続的に削除します：';

  @override
  String get allMealLogsAndNutrition => 'すべての食事ログと栄養データ';

  @override
  String get profileAndPersonalInfo => 'プロフィールと個人情報';

  @override
  String get allUploadedPhotos => 'アップロードされたすべての写真とファイル';

  @override
  String get customMealsAndRecipes => 'カスタム食事とレシピ';

  @override
  String get allAppPreferences => 'すべてのアプリ設定とプリファレンス';

  @override
  String get activeSessionsAllDevices => 'すべてのデバイスのアクティブセッション';

  @override
  String get exportDataWarning => '続行する前に保持したいデータをエクスポートしてください';

  @override
  String get understandActionPermanent => 'この操作が永続的であることを理解しています';

  @override
  String get typeDeleteHere => 'ここに削除と入力';

  @override
  String get deleteForever => '永遠に削除';

  @override
  String get noSecurityAlertsFound => 'セキュリティアラートはありません';

  @override
  String get yourAccountLooksGood => 'アカウントは良好です！不審な活動は検出されませんでした。';

  @override
  String get manageActiveSessionsAcrossDevices => '異なるデバイス間でアクティブセッションを管理';

  @override
  String get noActiveSessionsFound => 'アクティブセッションが見つかりません';

  @override
  String get signOutAllOtherSessions => '他のすべてをサインアウト';

  @override
  String get aiSearch => 'AI検索';

  @override
  String get aiSearchDescription => 'AIを使用して食べ物を検索';

  @override
  String get noIngredientsListedText => '材料が記載されていません';

  @override
  String get breakfastTime => '朝食時間';

  @override
  String get lunchTime => '昼食時間';

  @override
  String get dinnerTime => '夕食時間';

  @override
  String get snackTime => 'スナック時間';

  @override
  String get deletingYourAccount => 'アカウントを削除中...';

  @override
  String get thisMayTakeAFewMoments => 'これには少し時間がかかる場合があります';

  @override
  String get redirectingToSignIn => 'サインインにリダイレクト中...';

  @override
  String weightTrendNoData(Object remaining, Object unit) {
    return '体重データが不足しています。';
  }

  @override
  String weightTrendHealthyRate(Object eta, Object rate, Object remaining, Object unit) {
    return '健康的なペース: $rate$unit/週';
  }

  @override
  String get accountSuccessfullyDeleted => 'アカウントが正常に削除されました';

  @override
  String get pleaseCloseAndRestartApp => '続行するにはアプリを閉じて再起動してください。';

  @override
  String get exportData => 'データをエクスポート';

  @override
  String get exportDataDescription => 'すべてのデータをPDFファイルとしてエクスポート';

  @override
  String get exportComplete => 'エクスポート完了';

  @override
  String get exportCompleteMessage => 'データが正常にエクスポートされました！';

  @override
  String get exportCompleteDescription => 'PDFファイルがデバイスに保存され、共有または表示できます。';

  @override
  String get exportFailed => 'エクスポート失敗';

  @override
  String get exportingData => 'データをエクスポート中...';

  @override
  String get exportingDataDescription => 'これには数分かかる場合があります';

  @override
  String get restartApp => 'アプリを再起動';

  @override
  String get cameraAccess => 'カメラアクセス';

  @override
  String get cameraAccessMessage => 'Yumieは食べ物をスキャンし、食事を正確に記録するためにカメラアクセスが必要です。';

  @override
  String get photoLibraryAccess => '写真ライブラリアクセス';

  @override
  String get photoLibraryAccessMessage => 'Yumieはスキャンした画像を保存し、食事記録用の写真を選択するために写真ライブラリアクセスが必要です。';

  @override
  String get notificationAccess => '通知アクセス';

  @override
  String get notificationAccessMessage => 'Yumieは食事リマインダー、水分摂取アラート、マインドフルウォークプロンプトを送信するために通知アクセスが必要です。';

  @override
  String get notNow => '今はしない';

  @override
  String get permissionsCompleted => '権限完了！';

  @override
  String get allPermissionsGranted => 'すべての権限が付与されました！Yumieを使用する準備が整いました。';

  @override
  String get whatIsYourMainGoal => 'あなたの主な目標は何ですか？';

  @override
  String get chooseGoalDescription => 'あなたの旅に最も適した目標を選択してください';

  @override
  String get loseBodyWeight => '体重を減らす';

  @override
  String get gainWeight => '体重を増やす';

  @override
  String get buildMuscle => '筋肉をつける';

  @override
  String get eatHealthier => 'より健康的に食べる';

  @override
  String get maintainBodyWeight => '体重を維持する';

  @override
  String get setRealisticGoalForJourney => 'あなたの旅のための現実的な目標を設定してください';

  @override
  String get targetWeightSetToCurrent => '目標体重が現在の体重に設定されています';

  @override
  String get iAcceptThe => '私は以下に同意します';

  @override
  String get and => 'と';

  @override
  String get johnDoe => '山田太郎';

  @override
  String get yourEmailExample => 'あなたのメール@例.com';

  @override
  String get byContinuingYouAgreeToOur => '続行することで、以下に同意します';

  @override
  String get whatMotivatesYou => 'あなたを動機づけるものは何ですか？';

  @override
  String get chooseWhatDrivesYou => '目標を達成するためにあなたを駆り立てるものを選択してください';

  @override
  String get feelEnergeticEveryDay => '毎日エネルギッシュに感じる';

  @override
  String get achievePersonalMilestone => '個人的なマイルストーンを達成する';

  @override
  String get boostMyConfidence => '自信を高める';

  @override
  String get longTermHealth => '長期的な健康';

  @override
  String get trackYourMealsWithEase => '食事を簡単に追跡';

  @override
  String get caloriesLeft => '残りカロリー';

  @override
  String get thisHelpsUsPersonalizeNutrition => 'これは栄養計画をパーソナライズするのに役立ちます';

  @override
  String get male => '男性';

  @override
  String get female => '女性';

  @override
  String get other => 'その他';

  @override
  String get thisHelpsUsPersonalizeExperience => 'これはあなたの体験をパーソナライズするのに役立ちます';

  @override
  String get older => '年上';

  @override
  String get younger => '年下';

  @override
  String get yearsOld => '歳';

  @override
  String get selected => '選択済み';

  @override
  String get teens => 'ティーン';

  @override
  String get yourCurrentWeight => 'あなたの現在の体重';

  @override
  String get activityLevel => '活動レベル';

  @override
  String get diabetic => '糖尿病ですか？';

  @override
  String get howMuchWaterADay => '1日にどのくらいの水を飲みますか？';

  @override
  String get fitnessProfile => 'フィットネスプロフィール';

  @override
  String get dueToCurrentAnswers => '現在の回答により';

  @override
  String get remindersWouldYouLike => 'どのリマインダーを受け取りたいですか？';

  @override
  String get yumieIsCookingUp => 'Yumieがあなたのパーソナライズされた栄養計画を作成中...';

  @override
  String get yourAllSet => '準備完了です！';

  @override
  String get google => 'Google';

  @override
  String get fiftyPlus => '50+';

  @override
  String get forties => '40代';

  @override
  String get thirties => '30代';

  @override
  String get twenties => '20代';

  @override
  String get weightUnit => 'kg';

  @override
  String get heightUnit => 'cm';

  @override
  String get feetUnit => 'ft';

  @override
  String get inchesUnit => 'インチ';

  @override
  String get poundsUnit => 'lbs';

  @override
  String get whatIsYourAge => 'あなたの年齢は何ですか？';

  @override
  String get whatIsYourHeight => 'あなたの身長は何ですか？';

  @override
  String get whatIsYourWeight => 'あなたの現在の体重は何ですか？';

  @override
  String get whatIsYourGoalWeight => 'あなたの目標体重は何ですか？';

  @override
  String get whatIsYourActivityLevel => 'あなたの活動レベルは何ですか？';

  @override
  String get howMuchWaterDaily => '1日にどのくらいの水を飲みますか？';

  @override
  String get sedentary => '座りがち';

  @override
  String get lightlyActive => '軽度の活動';

  @override
  String get moderatelyActive => '中程度の活動';

  @override
  String get veryActive => '非常に活動的';

  @override
  String get extremelyActive => '極めて活動的';

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
  String get dontKnow => '分からない';

  @override
  String get oneToTwoGlasses => '1-2杯';

  @override
  String get threeToFourGlasses => '3-4杯';

  @override
  String get fiveToSixGlasses => '5-6杯';

  @override
  String get sevenToEightGlasses => '7-8杯';

  @override
  String get moreThanEightGlasses => '8杯以上';

  @override
  String get mealReminders => '食事リマインダー';

  @override
  String get waterReminders => '水分リマインダー';

  @override
  String get workoutReminders => 'ワークアウトリマインダー';

  @override
  String get progressUpdates => '進捗更新';

  @override
  String get dailyTips => 'デイリータイプ';

  @override
  String get youAreAllSet => '準備完了です！';

  @override
  String get welcomeToYourHealthJourney => '健康の旅へようこそ';

  @override
  String get letsGetStarted => '始めましょう！';

  @override
  String get pleaseWait => 'お待ちください...';

  @override
  String get cookingUpYourPlan => 'あなたのパーソナライズされた計画を作成中';

  @override
  String get analyzingYourData => 'データを分析中';

  @override
  String get creatingCustomPlan => 'カスタム栄養計画を作成中';

  @override
  String get almostDone => 'ほぼ完了！';

  @override
  String get subscriptionRequired => 'サブスクリプションが必要';

  @override
  String get upgradeToUnlock => 'すべての機能をアンロックするためにアップグレード';

  @override
  String get startFreeTrial => '無料トライアルを開始';

  @override
  String get month => '月';

  @override
  String get year => '年';

  @override
  String get free => '無料';

  @override
  String get mostPopular => '最も人気';

  @override
  String get skip => 'スキップ';

  @override
  String get next => '次へ';

  @override
  String get back => '戻る';

  @override
  String get done => '完了';

  @override
  String get error => 'エラー';

  @override
  String get success => '成功';

  @override
  String get warning => '警告';

  @override
  String get info => '情報';

  @override
  String get retry => '再試行';

  @override
  String get loading => '読み込み中...';

  @override
  String get noDataAvailable => 'データが利用できません';

  @override
  String get tryAgain => 'もう一度試す';

  @override
  String get somethingWentWrong => '何か問題が発生しました';

  @override
  String get internetConnectionRequired => 'インターネット接続が必要';

  @override
  String get pleaseCheckConnection => 'インターネット接続を確認してください';

  @override
  String get restartOnboarding => 'オンボーディングを再開';

  @override
  String get getStarted => '始める';

  @override
  String get couldNotOpenPlayStore => 'Play Storeを開けませんでした';

  @override
  String get errorOpeningPlayStore => 'Play Storeを開くエラー';

  @override
  String get remove => '削除';

  @override
  String get couldNotOpenLink => 'リンクを開けませんでした';

  @override
  String get nothingFoundInScan => 'スキャンで何も見つかりませんでした';

  @override
  String get errorOpeningLink => 'リンクを開くエラー';

  @override
  String get help => 'ヘルプ';

  @override
  String get name => '名前';

  @override
  String get dailyCalorieGoal => '1日のカロリー目標';

  @override
  String get manageSubscription => 'サブスクリプションを管理';

  @override
  String get deletionFailed => '削除に失敗しました';

  @override
  String get dismiss => '却下';

  @override
  String get grantPermission => '権限を付与';

  @override
  String get littleOrNoExercise => '運動不足または運動なし';

  @override
  String get lightExercise => '軽い運動/スポーツ 週1-3日';

  @override
  String get moderateExercise => '中程度の運動/スポーツ 週3-5日';

  @override
  String get hardExercise => '激しい運動/スポーツ 週6-7日';

  @override
  String get share => '共有';

  @override
  String get openSettings => '設定を開く';

  @override
  String get notificationsForMealLogging => '食事記録リマインダーの通知';

  @override
  String get notificationsForWaterIntake => '水分摂取リマインダーの通知';

  @override
  String get notificationsForMindfulWalk => 'マインドフルウォークリマインダーの通知';

  @override
  String get increment => '増加';

  @override
  String get enterNewName => '新しい名前を入力';

  @override
  String get readOurPrivacyPolicy => 'プライバシーポリシーをお読みください';

  @override
  String get readOurTermsOfService => '利用規約をお読みください';

  @override
  String get helpUsCalculateYourHealthGoals => '健康目標の計算を手伝ってください';

  @override
  String get thisHelpsUsTrackYourProgress => 'これは進捗を追跡するのに役立ちます';

  @override
  String get setARealisticGoalForYourJourney => 'あなたの旅のための現実的な目標を設定してください';

  @override
  String get thisHelpsUsPersonalizeYourPlan => 'これはあなたの計画をパーソナライズするのに役立ちます';

  @override
  String get stayingHydratedIsKeyToYourHealth => '水分補給は健康の鍵です';

  @override
  String get yourFitnessProfileDueToYourAnswers => 'あなたの回答によるフィットネスプロフィール';

  @override
  String get currentBMI => '現在のBMI';

  @override
  String get obese => '肥満';

  @override
  String get activityLevelLabel => '活動レベル';

  @override
  String get bloodTypeLabel => '血液型';

  @override
  String get diabeticLabel => '糖尿病';

  @override
  String get waterIntakeLabel => '水分摂取';

  @override
  String get heresYourPersonalizedNutritionPlan => 'あなたのパーソナライズされた栄養計画です。Yumieとの健康の旅へようこそ';

  @override
  String get caloriesGoal => 'カロリー目標';

  @override
  String get carbsGoal => '炭水化物目標';

  @override
  String get startNow => '今すぐ開始';

  @override
  String get underweight => '低体重';

  @override
  String get normalWeight => '正常体重';

  @override
  String get healthy => '健康的';

  @override
  String get overweight => '過体重';

  @override
  String get avocadoToast => 'アボカドトースト';

  @override
  String get italianSalad => 'イタリアンサラダ';

  @override
  String get chickenKatsuRiceBowl => 'チキンカツ丼';

  @override
  String get yourTargetWeightIsSetToCurrent => '目標体重が現在の体重に設定されています';

  @override
  String get couldNotGenerateYourPlan => '計画を生成できませんでした。もう一度お試しください。';

  @override
  String get somethingWentWrongRestart => '問題が発生しました。オンボーディングプロセスを再開してください。';

  @override
  String get yourBMI => 'あなたのBMI：';

  @override
  String get lbs => 'lbs';

  @override
  String get yourActivityLevel => 'あなたの活動レベル';

  @override
  String get analyzingFridge => '冷蔵庫を分析中...';

  @override
  String get aiDetectingFoodItems => 'AIが食品を検出中';

  @override
  String get tryClearerPhoto => '冷蔵庫のより鮮明な写真を撮ってみてください';

  @override
  String get generating => '生成中...';

  @override
  String get premiumStatus => 'プレミアムステータス';

  @override
  String get thankYouForSupport => 'ご支援ありがとうございます！💚';

  @override
  String get yourPremiumFeatures => 'プレミアム機能';

  @override
  String get subscriptionError => 'サブスクリプションエラー';

  @override
  String get unknownErrorOccurred => '不明なエラーが発生しました';

  @override
  String get privacyAndAds => 'プライバシーと広告';

  @override
  String get reviewAdPreferences => '広告設定を確認';

  @override
  String get privacyOptionsNotAvailable => 'お住まいの地域ではプライバシーオプションが利用できません。';

  @override
  String get consentFlowCompleted => '同意フローが完了しました！';

  @override
  String get appleSignInFailed => 'Appleサインインに失敗しました';

  @override
  String get adFailedToShow => '広告の表示に失敗しました。もう一度お試しください。';

  @override
  String get adNotLoadedYet => '広告がまだ読み込まれていません。もう一度お試しください。';

  @override
  String get errorRequestingPermissions => '権限の要求エラー';

  @override
  String get showMore => 'もっと見る';

  @override
  String get showLess => '表示を減らす';

  @override
  String get noSavedCustomMeals => '保存されたカスタム食事がありません。';

  @override
  String get savedCustomMealsPlus => '保存されたカスタム食事 +';

  @override
  String get customBuilding => 'カスタム食事を作成';

  @override
  String get enterName => '名前を入力';

  @override
  String get enterFoodName => '食品名を入力';

  @override
  String get congratulationsGoalReached => '🎉 おめでとうございます！';

  @override
  String get youReachedGoalWeight => '目標体重に到達しました！';

  @override
  String get switchToMaintenancePlan => '維持プランに切り替えましょう！';

  @override
  String get letsDoIt => 'やってみよう！';

  @override
  String get keepUpGreatWork => 'その調子です！';

  @override
  String get generatingMaintenancePlan => '維持プランを生成中...';

  @override
  String get maintenancePlanUpdated => '🎉 維持プランに更新されました！';

  @override
  String get failedToGenerateMaintenancePlan => '維持プランの生成に失敗しました。もう一度お試しください。';

  @override
  String get heresYourMaintenancePlan => '新しい維持プランはこちら！';

  @override
  String get keepThisPlan => 'このプランにする';

  @override
  String get chooseDifferentGoal => '別の目標を選ぶ';

  @override
  String get whatsYourNewGoal => '新しい目標は何ですか？';

  @override
  String get whatsYourNewTargetWeight => '新しい目標体重は？';

  @override
  String get yumieGeneratingNewPlan => 'Yumie が新しいパーソナルプランを生成しています...';

  @override
  String get yourNewPlanReady => '新しいプランの準備ができました！';

  @override
  String get startWithNewPlan => '新しいプランで開始';

  @override
  String get generateNewPlan => '新しいプランを生成';

  @override
  String get planGenerationLimitReached => 'この期間での 2 回のプラン生成を使い切りました。';

  @override
  String get waterGoal => '水分目標';

  @override
  String get glasses => 'コップ';

  @override
  String planGenerationInfo(int remaining) {
    return '今後14日間であと$remaining件のパーソナライズドプランを生成できます。';
  }

  @override
  String nextPlanAvailable(int days) {
    return '$days日後に再試行してください';
  }

  @override
  String get decline => '辞退';

  @override
  String get planDeclined => 'プランを辞退しました';

  @override
  String get accountDeletionWarning => 'あなたのアカウントは48時間後に削除されます。48時間以内に再度ログインすると、アカウントが再アクティブ化され、削除がキャンセルされます。';

  @override
  String get accountScheduledForDeletion => 'アカウント削除が予定されています';

  @override
  String get reactivateAccount => 'アカウントを再アクティブ化';

  @override
  String get accountReactivated => 'おかえりなさい！アカウントが再アクティブ化されました。';

  @override
  String get accountDeletionCancelled => 'アカウント削除がキャンセルされました。';

  @override
  String get emailVerificationRequired => 'メール認証が必要です';

  @override
  String get pleaseVerifyEmail => '続行するためにメールアドレスを認証してください';

  @override
  String get verificationEmailSent => '認証リンクをメールで送信しました。受信ボックスを確認し、リンクをクリックしてアカウントを認証してください。';

  @override
  String get waitingForVerification => 'メール認証を待っています...';

  @override
  String get checkYourEmail => 'メールを確認し、認証リンクをクリックしてください';

  @override
  String get resendVerificationEmail => '認証メールを再送信';

  @override
  String get verificationLinkAlreadySent => 'このメールアドレスにはすでに認証リンクが送信されています。受信ボックスを確認するか、数分待ってから新しいリンクをリクエストしてください。';

  @override
  String get emailVerified => 'メールが正常に認証されました！';

  @override
  String get emailNotVerified => 'メールがまだ認証されていません。受信ボックスを確認してください。';

  @override
  String get changeEmail => 'メールを変更';

  @override
  String get continueToApp => 'アプリを続ける';

  @override
  String get failedToSendVerificationEmail => '認証メールの送信に失敗しました';

  @override
  String get failedToResendVerificationEmail => '認証メールの再送信に失敗しました';

  @override
  String get errorCheckingVerification => '認証状態の確認エラー';

  @override
  String get helloIAmYumie => 'こんにちは、私はYumieです！今日からストリークを始めるために食事を記録してください！';

  @override
  String get happyBirthday => '🎉 お誕生日おめでとう！';

  @override
  String birthdayMessage(int age) {
    return '素晴らしい一日をお過ごしください！あなたは今$age歳になりました。';
  }

  @override
  String get selectBirthday => '誕生日を選択してください';

  @override
  String get day => '日';

  @override
  String get accountAlreadyExists => 'アカウントは既に存在します';

  @override
  String get accountExistsMessage => 'このメールアドレスのアカウントは既に存在します。代わりにサインインしますか？';

  @override
  String get accountUsesDifferentSignIn => 'アカウントは異なるサインイン方法を使用しています';

  @override
  String get emailSignedUpWithGoogle => 'このメールは既にGoogleで登録されています。代わりに「Googleでサインイン」を使用してください。';

  @override
  String get emailSignedUpWithPassword => 'このメールは既にメールとパスワードで登録されています。パスワードを使用してサインインしてください。';

  @override
  String get useGoogleSignIn => 'Googleサインインを使用';

  @override
  String get signInWithEmail => 'メールでサインイン';

  @override
  String get signInSuccessful => 'サインインに成功しました！';

  @override
  String get signUpSuccessful => 'サインアップに成功しました！';

  @override
  String get emailVerifiedWelcome => 'メールが認証されました！ようこそ！';

  @override
  String get premiumCancelledTitle => 'You have cancelled your subscription';

  @override
  String premiumCancelledWillEndOn(String date) {
    return 'Your premium access will end on $date';
  }

  @override
  String get manageSubscriptions => 'Manage Subscriptions';
}
