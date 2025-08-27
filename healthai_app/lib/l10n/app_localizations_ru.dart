// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get settings => 'Настройки';

  @override
  String get preferences => 'Настройки';

  @override
  String get darkMode => 'Темный режим';

  @override
  String get enableDarkTheme => 'Включить темную тему';

  @override
  String get useMetricUnits => 'Использовать метрические единицы';

  @override
  String get unitsSubtitle => 'Использовать кг/см (вкл) или фунт/фут (выкл)';

  @override
  String get language => 'Язык';

  @override
  String get selectLanguage => 'Выбрать язык приложения';

  @override
  String get habitNotifications => 'Уведомления о привычках';

  @override
  String get mealLoggingPrompts => 'Напоминания о записи приемов пищи';

  @override
  String get mealLoggingPromptsSubtitle => 'Получайте напоминания о записи приемов пищи';

  @override
  String get waterIntakeReminders => 'Напоминания о потреблении воды';

  @override
  String get waterIntakeRemindersSubtitle => 'Получайте напоминания о питье воды';

  @override
  String get mindfulWalksReminders => 'Напоминания о осознанных прогулках';

  @override
  String get mindfulWalksRemindersSubtitle => 'Получайте напоминания о осознанной прогулке';

  @override
  String get momentOfCalmAfterMeals => 'Момент спокойствия после еды';

  @override
  String get momentOfCalmAfterMealsSubtitle => 'Показывать успокаивающий всплывающий экран после записи приема пищи';

  @override
  String get welcomeBack => 'С возвращением!';

  @override
  String get trackNutritionToday => 'Давайте отслеживать ваше питание сегодня';

  @override
  String get subtitleAfternoon => 'Идеальное время записать обед и сохранить баланс.';

  @override
  String get subtitleEvening => 'Держитесь плана этим вечером — запишите свои приёмы пищи.';

  @override
  String get subtitleNight => 'Подведите итоги дня — не забудьте записать сегодняшние приёмы пищи.';

  @override
  String get streakNearEndingTitle => 'Сохрани свою серию 🔥';

  @override
  String get streakNearEndingBody => 'Ваша серия скоро закончится. Запишите приём пищи сегодня, чтобы сохранить её!';

  @override
  String get streakNearEndingTitle2 => 'Почти у цели! 🔥';

  @override
  String get streakNearEndingBody2 => 'Осталось всего пару часов. Запишите приём пищи, чтобы спасти серию!';

  @override
  String get streakEndedTitle => 'Серия закончилась';

  @override
  String get streakEndedBody => 'Ваша серия закончилась. Запишите приём пищи, чтобы начать заново и восстановить её!';

  @override
  String get streakActive => 'Серия активна';

  @override
  String get streakInactive => 'Серия неактивна';

  @override
  String get currentStreak => 'Текущая серия';

  @override
  String get entriesInStreak => 'Записей в серии';

  @override
  String get days => 'дни';

  @override
  String get startedOn => 'Началась';

  @override
  String get logMealToStartStreak => 'Запишите приём пищи сегодня, чтобы начать серию';

  @override
  String get nutritionSummary => 'Сводка по питанию';

  @override
  String get setCalorieAndMacroGoals => 'Установите цели по калориям и макронутриентам на странице План питания.';

  @override
  String get protein => 'Белок';

  @override
  String get carbs => 'Углеводы';

  @override
  String get fat => 'Жир';

  @override
  String get calories => 'Калории';

  @override
  String get quickActions => 'Быстрые действия';

  @override
  String get logMeal => 'Записать прием пищи';

  @override
  String get trackYourFood => 'Отслеживать вашу еду';

  @override
  String get scan => 'Скан';

  @override
  String get barcode => 'Код';

  @override
  String get analyzeYourFood => 'Анализировать вашу еду';

  @override
  String get todaysMeals => 'Сегодняшние приемы пищи';

  @override
  String get viewAll => 'Все';

  @override
  String get noMealsLoggedForThisDay => 'Нет записей о приемах пищи за этот день.';

  @override
  String get nutritionalPlan => 'План питания';

  @override
  String get weightAnalytics => 'Аналитика веса';

  @override
  String get toGoal => 'ДО ЦЕЛИ';

  @override
  String get remaining => 'осталось';

  @override
  String get weeklyRate => 'НЕДЕЛЬНЫЙ ТЕМП';

  @override
  String get weeklyLoss => 'недельная потеря';

  @override
  String get starting => 'СТАРТ';

  @override
  String get current => 'ТЕКУЩИЙ';

  @override
  String get today => 'сегодня';

  @override
  String get targetLabel => 'ЦЕЛЬ';

  @override
  String get goalWeight => 'целевой вес';

  @override
  String get eta => 'ETA';

  @override
  String get sinceStart => 'с начала';

  @override
  String get expectationsDisclaimer => 'Эти ожидания основаны на вашей недавней тенденции и могут измениться по мере записи новых весов.';

  @override
  String get loseVerb => 'снижать';

  @override
  String get gainVerb => 'набирать';

  @override
  String expectationBlurb(Object direction, Object eta, Object rate, Object remaining, Object unit) {
    return 'Согласно вашей недавней тенденции, вы на пути $direction примерно $rate $unit в неделю. В таком темпе потребуется примерно $eta, чтобы достичь цели. Осталось $remaining $unit.';
  }

  @override
  String get healthAwareness => 'Осведомленность о здоровье';

  @override
  String get planSettings => 'Настройки плана';

  @override
  String get featureComingSoon => 'Эта функция скоро появится!';

  @override
  String get ok => 'ОК';

  @override
  String get rateUsOnGoogle => 'Оцените нас в Google';

  @override
  String get comingSoon => 'Скоро!';

  @override
  String get ratingOnGoogleAvailableAfterRelease => 'Оценка в Google будет доступна после выпуска.';

  @override
  String get shareWithFriends => 'Поделиться с друзьями';

  @override
  String get sharingAvailableAfterRelease => 'Обмен будет доступен после выпуска.';

  @override
  String get resetPassword => 'Сбросить пароль';

  @override
  String get close => 'Закрыть';

  @override
  String get sendResetLink => 'Отправить ссылку для сброса';

  @override
  String get send => 'Отправить';

  @override
  String get resend => 'Отправить повторно';

  @override
  String get helpSupport => 'Помощь и поддержка';

  @override
  String get legal => 'Правовая информация';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get termsOfService => 'Условия использования';

  @override
  String get apiDocumentation => 'Документация API';

  @override
  String get needAssistanceContactSupport => 'Нужна помощь? Свяжитесь с нашей службой поддержки:';

  @override
  String get testWebURL => 'Тестовая веб-ссылка';

  @override
  String get testSimpleMailto => 'Простой тест mailto';

  @override
  String get logOut => 'Выйти';

  @override
  String get areYouSureYouWantToLogOut => 'Вы уверены, что хотите выйти?';

  @override
  String get no => 'Нет';

  @override
  String get yes => 'Да';

  @override
  String get commonQuestions => 'Частые вопросы';

  @override
  String get momentOfCalm => 'Момент спокойствия';

  @override
  String get practiceMindfulEating => 'Найдите момент, чтобы оценить вашу еду и практиковать осознанное питание.';

  @override
  String get howOldAreYou => 'Сколько вам лет?';

  @override
  String get personalizeExperience => 'Это помогает нам персонализировать ваш опыт';

  @override
  String get failedToOpenStore => 'Failed to open app store';

  @override
  String get updateAvailable => 'Доступно обновление';

  @override
  String get newVersionAvailable => 'Доступна новая версия Yumie.';

  @override
  String get updateNow => 'Обновить сейчас';

  @override
  String get later => 'Позже';

  @override
  String get whatsNew => 'What\'s New:';

  @override
  String get yourHeight => 'Ваш рост';

  @override
  String get yourGoalWeight => 'Ваш целевой вес';

  @override
  String get setRealisticGoal => 'Установите реалистичную цель для вашего путешествия';

  @override
  String get allSet => 'Вы готовы! 🎉';

  @override
  String get personalizedNutritionPlan => 'Вот ваш персонализированный план питания. Добро пожаловать в ваше путешествие к здоровью с Yumie!';

  @override
  String get whatIsYourBloodType => 'Какая у вас группа крови?';

  @override
  String get personalizeHealthInsights => 'Это помогает нам персонализировать ваши инсайты о здоровье.';

  @override
  String get whatIsYourSex => 'Какой у вас пол?';

  @override
  String get personalizeNutritionPlan => 'Это помогает нам персонализировать ваш план питания.';

  @override
  String get home => 'Главная';

  @override
  String get food => 'Еда';

  @override
  String get coach => 'Тренер';

  @override
  String get profile => 'Профиль';

  @override
  String get log => 'Журнал';

  @override
  String get myMeals => 'Мои приемы пищи';

  @override
  String get suggestedMeals => 'Рекомендуемые приемы пищи';

  @override
  String get monthly => 'Ежемесячно';

  @override
  String get weekly => 'Еженедельно';

  @override
  String get breakfast => 'Завтрак';

  @override
  String get lunch => 'Обед';

  @override
  String get dinner => 'Ужин';

  @override
  String get snack => 'Перекус';

  @override
  String get reviewMeal => 'Просмотреть прием пищи';

  @override
  String get chat => 'Чат';

  @override
  String get insights => 'Инсайты';

  @override
  String get clearChat => 'Очистить чат';

  @override
  String get coachWelcome => 'Привет! Я Yumie, ваш тренер по питанию. Как я могу помочь вам сегодня?\n\nСпросите Yumie о здоровых рецептах, планах питания или советах по питанию!';

  @override
  String get refreshInsight => 'Обновить инсайт';

  @override
  String get healthInsights => 'Инсайты о здоровье';

  @override
  String get noInsightAvailable => 'Инсайты недоступны.';

  @override
  String get dinnerIdeas => 'Идеи для ужина';

  @override
  String get calorieCheck => 'Проверка калорий';

  @override
  String get proteinSnacks => 'Протеиновые перекусы';

  @override
  String get dietTips => 'Советы по диете';

  @override
  String get typeYourMessage => 'Введите ваше сообщение...';

  @override
  String get yumie => 'Yumie';

  @override
  String get askAboutMeals => 'Спрашивайте о еде и питании';

  @override
  String get coachQuick1 => 'Что мне съесть сегодня?';

  @override
  String get coachQuick2 => 'Проанализируйте мой последний прием пищи';

  @override
  String get coachQuick3 => 'Помогите мне спланировать неделю';

  @override
  String get yumieThinking => 'Yumie думает...';

  @override
  String get bmi => 'ИМТ';

  @override
  String get target => 'Цель';

  @override
  String get weight => 'Вес';

  @override
  String get age => 'Возраст';

  @override
  String get height => 'Рост';

  @override
  String get targetWeight => 'Целевой вес';

  @override
  String get calorieGoal => 'Цель по калориям';

  @override
  String get proteinGoal => 'Цель по белку';

  @override
  String get carbGoal => 'Цель по углеводам';

  @override
  String get fatGoal => 'Цель по жирам';

  @override
  String get waterIntake => 'Потребление воды';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get undo => 'Отменить';

  @override
  String get notSet => 'Не установлено';

  @override
  String get uploadNew => 'Загрузить новое';

  @override
  String get delete => 'Удалить';

  @override
  String get editName => 'Редактировать имя';

  @override
  String get bloodType => 'Группа крови';

  @override
  String get bloodTypeOptional => 'Группа крови является необязательной и не влияет на отслеживание калорий или рекомендации.';

  @override
  String get areYouDiabetic => 'У вас диабет?';

  @override
  String get healthAwarenessUpdated => 'Осведомленность о здоровье обновлена!';

  @override
  String get takeMomentToAppreciate => 'Найдите момент, чтобы оценить свою еду и практиковать осознанное питание.';

  @override
  String get continueButton => 'Продолжить';

  @override
  String get mealSaved => '🎉 Еда сохранена!';

  @override
  String get noRecentFoods => 'Нет недавних продуктов.';

  @override
  String get buildCustomMeal => 'Создать индивидуальный прием пищи';

  @override
  String get mealName => 'Название приема пищи';

  @override
  String get searchOrEnterFoodName => 'Поиск или введите название продукта';

  @override
  String get ingredients => 'Ингредиенты';

  @override
  String get addIngredient => 'Добавить ингредиент';

  @override
  String get myFoods => 'Мои продукты';

  @override
  String get noCustomFoods => 'Вы еще не сохранили индивидуальные продукты';

  @override
  String get addCustomFood => 'Добавить индивидуальный продукт';

  @override
  String get editCustomMeal => 'Редактировать индивидуальный прием пищи';

  @override
  String get clearAll => 'Очистить все';

  @override
  String get foodName => 'Название продукта';

  @override
  String get saveMeal => 'Сохранить прием пищи';

  @override
  String get customizeMeal => 'Настроить прием пищи';

  @override
  String get hideIngredients => 'Скрыть ингредиенты';

  @override
  String get showIngredients => 'Показать ингредиенты';

  @override
  String get ingredientsColon => 'Ингредиенты:';

  @override
  String get noIngredientsListed => 'Ингредиенты не указаны.';

  @override
  String get recent => 'Недавние';

  @override
  String get meal => 'ПРИЕМ ПИЩИ';

  @override
  String get fridge => 'Холод';

  @override
  String get placeFoodInFrame => 'Поместите еду внутрь рамки';

  @override
  String get placeBarcodeInFrame => 'Совместите штрих‑код с рамкой';

  @override
  String get placeFridgeInFrame => 'Совместите холодильник с рамкой';

  @override
  String get productNotFound => 'Товар не найден';

  @override
  String get safetyUnsafe => 'Опасно';

  @override
  String get safetyGood => 'Можно';

  @override
  String get badgeNutriScore => 'Nutri-Score';

  @override
  String get badgeNova => 'NOVA';

  @override
  String get allergensTitle => 'Аллергены';

  @override
  String get contains => 'Содержит';

  @override
  String get allergensNone => 'Аллергены не указаны';

  @override
  String get serving => 'Порция';

  @override
  String get kcalPer100g => 'ккал/100г';

  @override
  String get sugar => 'Сахар';

  @override
  String get satFat => 'Насыщ. жир';

  @override
  String get salt => 'Соль';

  @override
  String get ingredientsTitle => 'Ингредиенты';

  @override
  String get riskAllergen => 'Риск аллергенов';

  @override
  String get riskUltraProcessed => 'Сильно обработан (NOVA 4)';

  @override
  String get riskHighAdditives => 'Много добавок';

  @override
  String get riskLowNutri => 'Низкий Nutri‑Score';

  @override
  String get riskVegan => 'Подходит для веганов';

  @override
  String get riskVegetarian => 'Вегетарианский';

  @override
  String get riskLooksGood => 'Выглядит хорошо';

  @override
  String get retakeScan => 'Повторить сканирование';

  @override
  String get previewFullImage => 'Предварительный просмотр полного изображения';

  @override
  String get discard => 'Отменить';

  @override
  String get upgradeToPremium => 'Обновить до Premium';

  @override
  String get getUnlimitedScans => 'Получите неограниченные сканирования и многое другое!';

  @override
  String get getUnlimitedSearches => 'Получите неограниченные поиски и многое другое!';

  @override
  String get upgradePlan => 'Обновить план';

  @override
  String get watchAdForScan => 'Посмотреть рекламу для сканирования';

  @override
  String get watchAdForSearch => 'Посмотреть рекламу для поиска';

  @override
  String get generateMeal => 'Создать прием пищи';

  @override
  String get detectedFridgeItems => 'Обнаруженные продукты в холодильнике';

  @override
  String get noFridgeItemsDetected => 'Продукты в холодильнике не обнаружены.';

  @override
  String get searchResults => 'Результаты поиска';

  @override
  String get searchingFor => 'Поиск';

  @override
  String get noResultsFoundFor => 'Ничего не найдено для';

  @override
  String get count => 'количество';

  @override
  String get servings => 'порции';

  @override
  String get fluidOunces => 'Жидкие унции';

  @override
  String get quantity => 'Количество';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get ingredient => 'ИНГРЕДИЕНТ';

  @override
  String get drink => 'НАПИТОК';

  @override
  String get kg => 'кг';

  @override
  String get g => 'г';

  @override
  String get mg => 'мг';

  @override
  String get cm => 'см';

  @override
  String get m => 'м';

  @override
  String get kcal => 'ккал';

  @override
  String get cal => 'кал';

  @override
  String get lb => 'фунт';

  @override
  String get oz => 'унция';

  @override
  String get ft => 'фут';

  @override
  String get inches => 'дюйм';

  @override
  String get cup => 'чашка';

  @override
  String get tbsp => 'ст.л.';

  @override
  String get tsp => 'ч.л.';

  @override
  String get ml => 'мл';

  @override
  String get l => 'л';

  @override
  String get upgradeToPremiumTitle => 'Обновить до Premium';

  @override
  String get premiumFeatures => 'Премиум функции';

  @override
  String get unlimitedScans => 'Неограниченные сканирования';

  @override
  String get aiNutritionCoach => 'ИИ-тренер по питанию';

  @override
  String get detailedAnalytics => 'Детальная аналитика';

  @override
  String get personalizedMealPlans => 'Персонализированные планы питания';

  @override
  String get noAdvertisements => 'Без рекламы';

  @override
  String get yearlyPremium => 'Годовой Premium';

  @override
  String get monthlyPremium => 'Месячный Premium';

  @override
  String savePercent(Object percent) {
    return 'Сэкономить $percent%';
  }

  @override
  String get perYear => '/год';

  @override
  String get perMonth => '/месяц';

  @override
  String get popular => 'ПОПУЛЯРНО';

  @override
  String get maybeLater => 'Может быть позже';

  @override
  String get welcomeToYumie => '🎉 Добро пожаловать в Yumie!';

  @override
  String get unlockPremiumFeatures => 'Разблокировать премиум функции';

  @override
  String get getMostOutOfHealthJourney => 'Получите максимум от вашего пути к здоровью с неограниченным доступом!';

  @override
  String get unlimitedScansAICoaching => 'Разблокируйте неограниченные сканирования, ИИ-коучинг и персонализированные планы питания!';

  @override
  String get subscribe => 'Подписаться';

  @override
  String get foodNameLabel => 'Название продукта';

  @override
  String get managePermissions => 'Управление разрешениями';

  @override
  String get cameraNotificationsAndMore => 'Камера, уведомления и многое другое';

  @override
  String get deleteMeal => 'Удалить прием пищи';

  @override
  String get areYouSureDeleteMeal => 'Вы уверены, что хотите удалить этот прием пищи?';

  @override
  String get unknown => 'Неизвестно';

  @override
  String get servings1 => 'порции 1';

  @override
  String get edit => 'Редактировать';

  @override
  String get ignoreFood => 'Игнорировать продукт';

  @override
  String get addComponent => 'Добавить компонент';

  @override
  String get components => 'Компоненты';

  @override
  String get recentFoods => 'Недавние продукты';

  @override
  String get logWeightChange => 'Вес';

  @override
  String get lost => 'потеряно';

  @override
  String get gained => 'набрано';

  @override
  String get googleSignInHelp => 'Помощь по входу через Google';

  @override
  String get couldNotOpenTermsOfService => 'Не удалось открыть условия использования';

  @override
  String get couldNotOpenPrivacyPolicy => 'Не удалось открыть политику конфиденциальности';

  @override
  String get errorSavingProfile => 'Ошибка сохранения профиля';

  @override
  String get completeYourProfile => 'Завершите ваш профиль';

  @override
  String get saveAndContinue => 'Сохранить и продолжить';

  @override
  String get pleasSignIn => 'Пожалуйста, войдите в систему.';

  @override
  String get noFoodLogsYet => 'Пока нет записей о еде.';

  @override
  String get healthAIFoodLog => 'HealthAI - Журнал питания';

  @override
  String get addLog => 'Добавить запись';

  @override
  String get unableToShareAtThisTime => 'Не удается поделиться в данный момент. Попробуйте еще раз.';

  @override
  String get failedToUpdatePhoto => 'Не удалось обновить фото';

  @override
  String get changeProfileName => 'Изменить имя профиля';

  @override
  String get failedToUpdateName => 'Не удалось обновить имя';

  @override
  String get profileUpdatedSuccessfully => 'Профиль успешно обновлен';

  @override
  String get errorUpdatingProfile => 'Ошибка обновления профиля';

  @override
  String get editGoals => 'Редактировать цели';

  @override
  String get goalsUpdatedSuccessfully => 'Цели успешно обновлены';

  @override
  String get errorUpdatingGoals => 'Ошибка обновления целей';

  @override
  String get couldNotOpenWebsite => 'Не удалось открыть веб-сайт';

  @override
  String get errorOpeningWebsite => 'Ошибка открытия веб-сайта';

  @override
  String get english => 'Английский';

  @override
  String get arabic => 'Арабский';

  @override
  String get spanish => 'Испанский';

  @override
  String get reviewMealTitle => 'Просмотр приема пищи';

  @override
  String get startingWeight => 'Начальный вес';

  @override
  String get appPermissions => 'Разрешения приложения';

  @override
  String get permissionStatus => 'Статус разрешений';

  @override
  String get manageAppPermissions => 'Управляйте разрешениями приложения, чтобы все функции работали правильно';

  @override
  String get camera => 'Камера';

  @override
  String get scanFoodItems => 'Сканировать продукты питания и делать фотографии приемов пищи';

  @override
  String get photoLibrary => 'Фотографии';

  @override
  String get saveScannedImages => 'Сохранять отсканированные изображения и выбирать фотографии';

  @override
  String get notifications => 'Уведомления';

  @override
  String get sendMealReminders => 'Отправлять напоминания о приемах пищи и предупреждения о здоровье';

  @override
  String get needHelp => 'Нужна помощь?';

  @override
  String get permanentlyDeniedHelp => 'Если разрешения постоянно отклонены, вы можете включить их в настройках устройства';

  @override
  String get openDeviceSettings => 'Открыть настройки устройства';

  @override
  String get goodMorning => 'Доброе утро';

  @override
  String get goodAfternoon => 'Добрый день';

  @override
  String get goodEvening => 'Добрый вечер';

  @override
  String get goodNight => 'Спокойной ночи';

  @override
  String get ounces => 'унции';

  @override
  String get january => 'Январь';

  @override
  String get february => 'Февраль';

  @override
  String get march => 'Март';

  @override
  String get april => 'Апрель';

  @override
  String get may => 'Май';

  @override
  String get june => 'Июнь';

  @override
  String get july => 'Июль';

  @override
  String get august => 'Август';

  @override
  String get september => 'Сентябрь';

  @override
  String get october => 'Октябрь';

  @override
  String get november => 'Ноябрь';

  @override
  String get december => 'Декабрь';

  @override
  String get trackYourNutrition => 'Отслеживайте ваше питание';

  @override
  String get messages => 'Сообщения';

  @override
  String get subscribeForDailyInsights => 'Подписаться на ежедневные инсайты';

  @override
  String get getPersonalizedHealthInsights => 'Получайте персонализированные инсайты о здоровье на основе вашего полного профиля';

  @override
  String get upgradeDescription => 'Получите неограниченные сканирования, поиски и инсайты на базе ИИ';

  @override
  String get unlimitedFoodScans => 'Неограниченные сканирования продуктов';

  @override
  String get unlimitedFoodSearches => 'Неограниченные поиски продуктов';

  @override
  String get unlimitedAICoachMessages => 'Неограниченные сообщения ИИ-тренера';

  @override
  String get dailyHealthInsights => 'Ежедневные инсайты о здоровье';

  @override
  String get logWaterIntake => 'Вода';

  @override
  String get add => 'Добавить';

  @override
  String get freemium => 'Freemium';

  @override
  String get premium => 'Premium';

  @override
  String get chooseYourPlan => 'Выберите ваш план';

  @override
  String get water => 'Вода';

  @override
  String get resetPasswordDescription => 'Ссылка для сброса пароля будет отправлена на ваш email';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get deleteAccountDescription => 'Навсегда удалить ваш аккаунт и все данные';

  @override
  String get confirmDeleteAccount => 'Вы уверены, что хотите удалить ваш аккаунт?';

  @override
  String get deleteAccountWarning => 'Это действие нельзя отменить. Все ваши данные, включая приемы пищи, прогресс и настройки, будут навсегда удалены.';

  @override
  String get typeDeleteToConfirm => 'Введите \"УДАЛИТЬ\" для подтверждения';

  @override
  String get deleteAccountFinalConfirmation => 'УДАЛИТЬ';

  @override
  String get accountDeleted => 'Аккаунт удален';

  @override
  String get errorDeletingAccount => 'Ошибка удаления аккаунта';

  @override
  String get totalNutrition => 'Общее питание';

  @override
  String get unlockUnlimitedScans => 'Разблокировать неограниченные сканирования, ИИ-коучинг и\nперсонализированные планы питания';

  @override
  String get unlimitedFoodScanning => 'Неограниченное сканирование продуктов';

  @override
  String yearPrice(String price) {
    return 'год/$price';
  }

  @override
  String monthPrice(String price) {
    return 'месяц/$price';
  }

  @override
  String get save37 => 'Сэкономить 37%';

  @override
  String get youArePremium => 'Вы премиум!';

  @override
  String get yumiePremiumMonthly => 'Yumie™ Premium Месячный';

  @override
  String get yumiePremiumYearly => 'Yumie™ Premium Годовой';

  @override
  String get restorePurchases => 'Восстановить покупки';

  @override
  String get checkingForPurchases => 'Проверка существующих покупок...';

  @override
  String get purchasesRestored => 'Покупки успешно восстановлены!';

  @override
  String get noPurchasesFound => 'Предыдущие покупки не найдены';

  @override
  String get restoreFailed => 'Не удалось восстановить покупки. Попробуйте еще раз.';

  @override
  String get restoreInProgress => 'Восстановление покупок...';

  @override
  String get bySubscribing => 'Подписываясь, вы соглашаетесь с нашими Условиями использования и Политикой конфиденциальности. Подписки автоматически продлеваются, если не отменены';

  @override
  String get permissionsComplete => 'Разрешения завершены!';

  @override
  String get whyWeAskForPermissions => 'Почему мы запрашиваем разрешения';

  @override
  String get permissionsWhyBody => 'Мы используем камеру для сканирования продуктов и штрих‑кодов, получаем доступ к фотографиям при загрузке изображений и отправляем уведомления, чтобы напоминать вам записывать приёмы пищи и пить воду.';

  @override
  String get permissionsNextScreen => 'На следующем экране появятся системные запросы на доступ. Вы можете изменить это в Настройках в любое время.';

  @override
  String get references => 'Ссылки:';

  @override
  String get cdcAboutBmi => 'CDC: Об ИМТ';

  @override
  String get usdaDietaryGuidelines => 'Диетические рекомендации USDA';

  @override
  String get termsOfUseEula => 'Условия использования (EULA)';

  @override
  String get enterYourPassword => 'Введите ваш пароль';

  @override
  String get manageSessions => 'Управление сессиями';

  @override
  String get selectLanguageTitle => 'Выбрать язык';

  @override
  String get chooseYourPreferredLanguage => 'Выберите предпочитаемый язык для приложения';

  @override
  String get languageChangedTo => 'Язык изменен на';

  @override
  String get activeSessions => 'Активные сессии';

  @override
  String get thisDevice => 'Это устройство';

  @override
  String get sessionRevoked => 'Сессия отозвана';

  @override
  String get allOtherSessionsSignedOut => 'Все другие сессии вышли из системы';

  @override
  String get signOutAllOthers => 'Выйти из всех других';

  @override
  String get noSecurityAlerts => 'Нет предупреждений безопасности';

  @override
  String get passwordStrengthWeak => 'Слабый';

  @override
  String get passwordStrengthFair => 'Средний';

  @override
  String get passwordStrengthGood => 'Хороший';

  @override
  String get passwordStrengthStrong => 'Сильный';

  @override
  String get passwordStrengthVeryStrong => 'Очень сильный';

  @override
  String get addLowercaseLetters => 'Добавить строчные буквы';

  @override
  String get addUppercaseLetters => 'Добавить заглавные буквы';

  @override
  String get addNumbers => 'Добавить цифры';

  @override
  String get addSpecialCharacters => 'Добавить специальные символы (!@#\$%^&*)';

  @override
  String get avoidCommonPatterns => 'Избегать общих шаблонов';

  @override
  String get requiresAtLeast8Characters => 'Требуется минимум 8 символов';

  @override
  String get tooManySignInAttempts => 'Слишком много попыток входа. Попробуйте позже.';

  @override
  String get tooManySignUpAttempts => 'Слишком много попыток регистрации. Попробуйте позже.';

  @override
  String get tooManyPasswordResetRequests => 'Слишком много запросов на сброс пароля. Попробуйте позже.';

  @override
  String get multipleFailedSignInAttempts => 'Множественные неудачные попытки входа';

  @override
  String get excessivePasswordResetRequests => 'Чрезмерные запросы на сброс пароля';

  @override
  String get suspiciousActivityDetected => 'Обнаружена подозрительная активность';

  @override
  String get riskLevelMedium => 'СРЕДНИЙ';

  @override
  String get riskLevelHigh => 'ВЫСОКИЙ';

  @override
  String get welcomeToYumiePermissions => 'Добро пожаловать в Yumie';

  @override
  String get provideBestExperience => 'Чтобы предоставить вам лучший опыт, нам нужно несколько разрешений';

  @override
  String get grantPermissions => 'Предоставить разрешения';

  @override
  String get skipForNow => 'Пропустить пока';

  @override
  String get denied => 'Отклонено';

  @override
  String get granted => 'Предоставлено';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get signUpToGetStarted => 'Зарегистрируйтесь, чтобы начать с Yumie';

  @override
  String get fullName => 'Полное имя';

  @override
  String get email => 'Email';

  @override
  String get password => 'Пароль';

  @override
  String get agreeToTerms => 'и Условия использования Я принимаю Политику конфиденциальности';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт?';

  @override
  String get signIn => 'Войти';

  @override
  String get signUp => 'Зарегистрироваться';

  @override
  String get signInToAccessAccount => 'Войдите, чтобы получить доступ к вашему аккаунту';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get dontHaveAccount => 'Нет аккаунта?';

  @override
  String get signUpWithGoogle => 'Зарегистрироваться через Google';

  @override
  String get signInWithGoogle => 'Войти через Google';

  @override
  String get signUpWithApple => 'Зарегистрироваться с Apple';

  @override
  String get signInWithApple => 'Войти через Apple';

  @override
  String get resetPasswordTitle => 'Сбросить пароль';

  @override
  String get enterEmailForReset => 'Введите ваш email адрес для получения ссылки сброса пароля';

  @override
  String get emailAddress => 'Email адрес';

  @override
  String get rateUsOn => 'Оцените нас на';

  @override
  String get deleteAccountTitle => 'Удалить аккаунт';

  @override
  String get deleteAccountWarningTitle => 'Это действие необратимо и не может быть отменено';

  @override
  String get deleteAccountDataList => 'Когда вы удалите ваш аккаунт, мы навсегда удалим:';

  @override
  String get allMealLogsAndNutrition => 'Все ваши записи о приемах пищи и данные о питании';

  @override
  String get profileAndPersonalInfo => 'Ваш профиль и личная информация';

  @override
  String get allUploadedPhotos => 'Все загруженные фотографии и файлы';

  @override
  String get customMealsAndRecipes => 'Ваши индивидуальные приемы пищи и рецепты';

  @override
  String get allAppPreferences => 'Все настройки и предпочтения приложения';

  @override
  String get activeSessionsAllDevices => 'Активные сессии на всех устройствах';

  @override
  String get exportDataWarning => 'Убедитесь, что экспортировали любые данные, которые хотите сохранить, прежде чем продолжить';

  @override
  String get understandActionPermanent => 'Я понимаю, что это действие необратимо';

  @override
  String get typeDeleteHere => 'Введите УДАЛИТЬ здесь';

  @override
  String get deleteForever => 'Удалить навсегда';

  @override
  String get noSecurityAlertsFound => 'Нет предупреждений безопасности';

  @override
  String get yourAccountLooksGood => 'Ваш аккаунт выглядит хорошо! Подозрительная активность не обнаружена.';

  @override
  String get manageActiveSessionsAcrossDevices => 'Управляйте вашими активными сессиями на разных устройствах';

  @override
  String get noActiveSessionsFound => 'Активные сессии не найдены';

  @override
  String get signOutAllOtherSessions => 'Выйти из всех других';

  @override
  String get aiSearch => 'ИИ поиск';

  @override
  String get aiSearchDescription => 'Поиск продуктов питания с помощью ИИ';

  @override
  String get noIngredientsListedText => 'Ингредиенты не указаны';

  @override
  String get breakfastTime => 'Время завтрака';

  @override
  String get lunchTime => 'Время обеда';

  @override
  String get dinnerTime => 'Время ужина';

  @override
  String get snackTime => 'Время перекуса';

  @override
  String get deletingYourAccount => 'Удаление вашего аккаунта...';

  @override
  String get thisMayTakeAFewMoments => 'Это может занять несколько моментов';

  @override
  String get redirectingToSignIn => 'Перенаправление на вход...';

  @override
  String weightTrendNoData(Object remaining, Object unit) {
    return 'Недостаточно данных веса.';
  }

  @override
  String weightTrendHealthyRate(Object eta, Object rate, Object remaining, Object unit) {
    return 'Здоровый темп: $rate$unit/нед.';
  }

  @override
  String get accountSuccessfullyDeleted => 'Аккаунт успешно удален';

  @override
  String get pleaseCloseAndRestartApp => 'Пожалуйста, закройте и перезапустите приложение для продолжения.';

  @override
  String get exportData => 'Экспорт Данных';

  @override
  String get exportDataDescription => 'Экспортировать все ваши данные в файл PDF';

  @override
  String get exportComplete => 'Экспорт Завершен';

  @override
  String get exportCompleteMessage => 'Ваши данные были успешно экспортированы!';

  @override
  String get exportCompleteDescription => 'PDF файл был сохранен на вашем устройстве и может быть поделен или просмотрен.';

  @override
  String get exportFailed => 'Экспорт Не Удался';

  @override
  String get exportingData => 'Экспорт ваших данных...';

  @override
  String get exportingDataDescription => 'Это может занять несколько моментов';

  @override
  String get restartApp => 'Перезапустить приложение';

  @override
  String get cameraAccess => 'Доступ к камере';

  @override
  String get cameraAccessMessage => 'Yumie нужен доступ к камере для сканирования продуктов питания и помощи в точном ведении записей о приемах пищи.';

  @override
  String get photoLibraryAccess => 'Доступ к библиотеке фотографий';

  @override
  String get photoLibraryAccessMessage => 'Yumie нужен доступ к вашей библиотеке фотографий для сохранения отсканированных изображений и выбора фотографий для записи приемов пищи.';

  @override
  String get notificationAccess => 'Доступ к уведомлениям';

  @override
  String get notificationAccessMessage => 'Yumie нужен доступ к уведомлениям для отправки напоминаний о приемах пищи, предупреждений о потреблении воды и подсказок для осознанных прогулок.';

  @override
  String get notNow => 'Не сейчас';

  @override
  String get permissionsCompleted => 'Разрешения завершены!';

  @override
  String get allPermissionsGranted => 'Все разрешения предоставлены! Вы готовы использовать Yumie.';

  @override
  String get whatIsYourMainGoal => 'Какова ваша основная цель?';

  @override
  String get chooseGoalDescription => 'Выберите цель, которая лучше всего соответствует вашему пути';

  @override
  String get loseBodyWeight => 'Похудеть';

  @override
  String get gainWeight => 'Набрать вес';

  @override
  String get buildMuscle => 'Нарастить мышцы';

  @override
  String get eatHealthier => 'Питаться здоровее';

  @override
  String get maintainBodyWeight => 'Поддерживать вес тела';

  @override
  String get setRealisticGoalForJourney => 'Установите реалистичную цель для вашего пути';

  @override
  String get targetWeightSetToCurrent => 'Ваш целевой вес установлен на ваш текущий вес';

  @override
  String get iAcceptThe => 'Я принимаю';

  @override
  String get and => 'и';

  @override
  String get johnDoe => 'Иван Иванов';

  @override
  String get yourEmailExample => 'ваш.email@пример.com';

  @override
  String get byContinuingYouAgreeToOur => 'Продолжая, вы соглашаетесь с нашими';

  @override
  String get whatMotivatesYou => 'Что вас мотивирует?';

  @override
  String get chooseWhatDrivesYou => 'Выберите, что движет вами для достижения целей';

  @override
  String get feelEnergeticEveryDay => 'Чувствовать энергию каждый день';

  @override
  String get achievePersonalMilestone => 'Достичь личной вехи';

  @override
  String get boostMyConfidence => 'Повысить мою уверенность';

  @override
  String get longTermHealth => 'Долгосрочное здоровье';

  @override
  String get trackYourMealsWithEase => 'Легко отслеживать ваши приемы пищи';

  @override
  String get caloriesLeft => 'калорий осталось';

  @override
  String get thisHelpsUsPersonalizeNutrition => 'Это помогает нам персонализировать ваш план питания';

  @override
  String get male => 'Мужской';

  @override
  String get female => 'Женский';

  @override
  String get other => 'Другой';

  @override
  String get thisHelpsUsPersonalizeExperience => 'Это помогает нам персонализировать ваш опыт';

  @override
  String get older => 'Старше';

  @override
  String get younger => 'Младше';

  @override
  String get yearsOld => 'лет';

  @override
  String get selected => 'Выбрано';

  @override
  String get teens => 'Подростки';

  @override
  String get yourCurrentWeight => 'Ваш текущий вес';

  @override
  String get activityLevel => 'Уровень активности';

  @override
  String get diabetic => 'Диабет?';

  @override
  String get howMuchWaterADay => 'Сколько воды в день?';

  @override
  String get fitnessProfile => 'Фитнес профиль';

  @override
  String get dueToCurrentAnswers => 'Из-за текущих ответов';

  @override
  String get remindersWouldYouLike => 'Какие напоминания вы хотели бы получать?';

  @override
  String get yumieIsCookingUp => 'Yumie готовит ваш персонализированный план питания...';

  @override
  String get yourAllSet => 'Вы готовы!';

  @override
  String get google => 'Google';

  @override
  String get fiftyPlus => '50+';

  @override
  String get forties => '40 лет';

  @override
  String get thirties => '30 лет';

  @override
  String get twenties => '20 лет';

  @override
  String get weightUnit => 'кг';

  @override
  String get heightUnit => 'см';

  @override
  String get feetUnit => 'фут';

  @override
  String get inchesUnit => 'дюйм';

  @override
  String get poundsUnit => 'фунт';

  @override
  String get whatIsYourAge => 'Сколько вам лет?';

  @override
  String get whatIsYourHeight => 'Какой у вас рост?';

  @override
  String get whatIsYourWeight => 'Какой у вас текущий вес?';

  @override
  String get whatIsYourGoalWeight => 'Какой у вас целевой вес?';

  @override
  String get whatIsYourActivityLevel => 'Какой у вас уровень активности?';

  @override
  String get howMuchWaterDaily => 'Сколько воды вы пьете ежедневно?';

  @override
  String get sedentary => 'Сидячий';

  @override
  String get lightlyActive => 'Легко активный';

  @override
  String get moderatelyActive => 'Умеренно активный';

  @override
  String get veryActive => 'Очень активный';

  @override
  String get extremelyActive => 'Крайне активный';

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
  String get dontKnow => 'Не знаю';

  @override
  String get oneToTwoGlasses => '1-2 стакана';

  @override
  String get threeToFourGlasses => '3-4 стакана';

  @override
  String get fiveToSixGlasses => '5-6 стаканов';

  @override
  String get sevenToEightGlasses => '7-8 стаканов';

  @override
  String get moreThanEightGlasses => 'Более 8 стаканов';

  @override
  String get mealReminders => 'Напоминания о приемах пищи';

  @override
  String get waterReminders => 'Напоминания о воде';

  @override
  String get workoutReminders => 'Напоминания о тренировках';

  @override
  String get progressUpdates => 'Обновления прогресса';

  @override
  String get dailyTips => 'Ежедневные советы';

  @override
  String get youAreAllSet => 'Вы готовы!';

  @override
  String get welcomeToYourHealthJourney => 'Добро пожаловать в ваше путешествие к здоровью';

  @override
  String get letsGetStarted => 'Давайте начнем!';

  @override
  String get pleaseWait => 'Пожалуйста, подождите...';

  @override
  String get cookingUpYourPlan => 'Готовим ваш персонализированный план';

  @override
  String get analyzingYourData => 'Анализируем ваши данные';

  @override
  String get creatingCustomPlan => 'Создаем ваш индивидуальный план питания';

  @override
  String get almostDone => 'Почти готово!';

  @override
  String get subscriptionRequired => 'Требуется подписка';

  @override
  String get upgradeToUnlock => 'Обновитесь, чтобы разблокировать все функции';

  @override
  String get startFreeTrial => 'Начать бесплатную пробную версию';

  @override
  String get month => 'Месяц';

  @override
  String get year => 'год';

  @override
  String get free => 'Бесплатно';

  @override
  String get mostPopular => 'Самое популярное';

  @override
  String get skip => 'Пропустить';

  @override
  String get next => 'Далее';

  @override
  String get back => 'Назад';

  @override
  String get done => 'Готово';

  @override
  String get error => 'Ошибка';

  @override
  String get success => 'Успех';

  @override
  String get warning => 'Предупреждение';

  @override
  String get info => 'Информация';

  @override
  String get retry => 'Повторить';

  @override
  String get loading => 'Загрузка...';

  @override
  String get noDataAvailable => 'Данные недоступны';

  @override
  String get tryAgain => 'Попробовать снова';

  @override
  String get somethingWentWrong => 'Что-то пошло не так';

  @override
  String get internetConnectionRequired => 'Требуется подключение к интернету';

  @override
  String get pleaseCheckConnection => 'Пожалуйста, проверьте ваше интернет-соединение';

  @override
  String get restartOnboarding => 'Перезапустить онбординг';

  @override
  String get getStarted => 'Начать';

  @override
  String get couldNotOpenPlayStore => 'Не удалось открыть Play Store';

  @override
  String get errorOpeningPlayStore => 'Ошибка открытия Play Store';

  @override
  String get remove => 'Удалить';

  @override
  String get couldNotOpenLink => 'Не удалось открыть ссылку';

  @override
  String get nothingFoundInScan => 'Ничего не найдено при сканировании';

  @override
  String get errorOpeningLink => 'Ошибка открытия ссылки';

  @override
  String get help => 'Помощь';

  @override
  String get name => 'Имя';

  @override
  String get dailyCalorieGoal => 'Ежедневная цель по калориям';

  @override
  String get manageSubscription => 'Управление подпиской';

  @override
  String get deletionFailed => 'Удаление не удалось';

  @override
  String get dismiss => 'Отклонить';

  @override
  String get grantPermission => 'Предоставить разрешение';

  @override
  String get littleOrNoExercise => 'Мало или нет упражнений';

  @override
  String get lightExercise => 'Легкие упражнения/спорт 1-3 дня/неделю';

  @override
  String get moderateExercise => 'Умеренные упражнения/спорт 3-5 дней/неделю';

  @override
  String get hardExercise => 'Тяжелые упражнения/спорт 6-7 дней/неделю';

  @override
  String get share => 'Поделиться';

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String get notificationsForMealLogging => 'Уведомления для напоминаний о записи приемов пищи';

  @override
  String get notificationsForWaterIntake => 'Уведомления для напоминаний о потреблении воды';

  @override
  String get notificationsForMindfulWalk => 'Уведомления для напоминаний об осознанных прогулках';

  @override
  String get increment => 'Увеличить';

  @override
  String get enterNewName => 'Введите новое имя';

  @override
  String get readOurPrivacyPolicy => 'Прочитайте нашу политику конфиденциальности';

  @override
  String get readOurTermsOfService => 'Прочитайте наши условия использования';

  @override
  String get helpUsCalculateYourHealthGoals => 'Помогите нам рассчитать ваши цели здоровья';

  @override
  String get thisHelpsUsTrackYourProgress => 'Это помогает нам отслеживать ваш прогресс';

  @override
  String get setARealisticGoalForYourJourney => 'Установите реалистичную цель для вашего пути';

  @override
  String get thisHelpsUsPersonalizeYourPlan => 'Это помогает нам персонализировать ваш план';

  @override
  String get stayingHydratedIsKeyToYourHealth => 'Поддержание водного баланса - ключ к вашему здоровью';

  @override
  String get yourFitnessProfileDueToYourAnswers => 'Ваш фитнес профиль из-за ваших ответов';

  @override
  String get currentBMI => 'Текущий ИМТ';

  @override
  String get obese => 'Ожирение';

  @override
  String get activityLevelLabel => 'Уровень активности';

  @override
  String get bloodTypeLabel => 'Группа крови';

  @override
  String get diabeticLabel => 'Диабет';

  @override
  String get waterIntakeLabel => 'Потребление воды';

  @override
  String get heresYourPersonalizedNutritionPlan => 'Вот ваш персонализированный план питания. Добро пожаловать в ваше путешествие к здоровью с Yumie';

  @override
  String get caloriesGoal => 'Цель по калориям';

  @override
  String get carbsGoal => 'Цель по углеводам';

  @override
  String get startNow => 'Начать сейчас';

  @override
  String get underweight => 'Недостаточный вес';

  @override
  String get normalWeight => 'Нормальный вес';

  @override
  String get healthy => 'Здоровый';

  @override
  String get overweight => 'Избыточный вес';

  @override
  String get avocadoToast => 'Тост с авокадо';

  @override
  String get italianSalad => 'Итальянский салат';

  @override
  String get chickenKatsuRiceBowl => 'Рисовая чаша с курицей кацу';

  @override
  String get yourTargetWeightIsSetToCurrent => 'Ваш целевой вес установлен на ваш текущий вес';

  @override
  String get couldNotGenerateYourPlan => 'Не удалось создать ваш план. Попробуйте снова.';

  @override
  String get somethingWentWrongRestart => 'Что-то пошло не так. Пожалуйста, перезапустите процесс онбординга.';

  @override
  String get yourBMI => 'Ваш ИМТ:';

  @override
  String get lbs => 'фунт';

  @override
  String get yourActivityLevel => 'Ваш уровень активности';

  @override
  String get analyzingFridge => 'Анализируем ваш холодильник...';

  @override
  String get aiDetectingFoodItems => 'ИИ обнаруживает продукты питания';

  @override
  String get tryClearerPhoto => 'Попробуйте сделать более четкое фото вашего холодильника';

  @override
  String get generating => 'Генерируем...';

  @override
  String get premiumStatus => 'Премиум статус';

  @override
  String get thankYouForSupport => 'Спасибо за вашу поддержку! 💚';

  @override
  String get yourPremiumFeatures => 'Ваши премиум функции';

  @override
  String get subscriptionError => 'Ошибка подписки';

  @override
  String get unknownErrorOccurred => 'Произошла неизвестная ошибка';

  @override
  String get privacyAndAds => 'Конфиденциальность и реклама';

  @override
  String get reviewAdPreferences => 'Просмотр настроек рекламы';

  @override
  String get privacyOptionsNotAvailable => 'Параметры конфиденциальности недоступны в вашем регионе.';

  @override
  String get consentFlowCompleted => 'Процесс согласия завершен!';

  @override
  String get appleSignInFailed => 'Ошибка входа через Apple';

  @override
  String get adFailedToShow => 'Не удалось показать рекламу';

  @override
  String get adNotLoadedYet => 'Реклама ещё не загружена';

  @override
  String get errorRequestingPermissions => 'Ошибка при запросе разрешений';

  @override
  String get showMore => 'Показать больше';

  @override
  String get showLess => 'Показать меньше';

  @override
  String get noSavedCustomMeals => 'У вас нет сохраненных пользовательских блюд.';

  @override
  String get savedCustomMealsPlus => 'Сохраненные пользовательские блюда +';

  @override
  String get customBuilding => 'Создать Пользовательское Блюдо';

  @override
  String get enterName => 'Введите название';

  @override
  String get enterFoodName => 'Введите название продукта';

  @override
  String get congratulationsGoalReached => '🎉 Поздравляем!';

  @override
  String get youReachedGoalWeight => 'Вы достигли целевого веса!';

  @override
  String get switchToMaintenancePlan => 'Пора перейти на план поддержания веса!';

  @override
  String get letsDoIt => 'ПОЕХАЛИ!';

  @override
  String get keepUpGreatWork => 'Так держать!';

  @override
  String get generatingMaintenancePlan => 'Генерируем план поддержания...';

  @override
  String get maintenancePlanUpdated => '🎉 Ваш план питания обновлён для поддержания веса!';

  @override
  String get failedToGenerateMaintenancePlan => 'Не удалось создать план поддержания. Повторите попытку.';

  @override
  String get heresYourMaintenancePlan => 'Вот ваш новый план поддержания!';

  @override
  String get keepThisPlan => 'Оставить этот план';

  @override
  String get chooseDifferentGoal => 'Выбрать другую цель';

  @override
  String get whatsYourNewGoal => 'Какая у вас новая цель?';

  @override
  String get whatsYourNewTargetWeight => 'Какой новый целевой вес?';

  @override
  String get yumieGeneratingNewPlan => 'Yumie генерирует ваш новый персональный план...';

  @override
  String get yourNewPlanReady => 'Ваш новый план готов!';

  @override
  String get startWithNewPlan => 'Начать с новым планом';

  @override
  String get generateNewPlan => 'Сгенерировать новый план';

  @override
  String get planGenerationLimitReached => 'Вы использовали 2 генерации планов за этот период.';

  @override
  String get waterGoal => 'Цель по воде';

  @override
  String get glasses => 'стаканов';

  @override
  String planGenerationInfo(int remaining) {
    return 'Вы можете создать ещё $remaining персонализированных планов в следующие 14 дней.';
  }

  @override
  String nextPlanAvailable(int days) {
    return 'Попробуйте снова через $days дней';
  }

  @override
  String get decline => 'Отклонить';

  @override
  String get planDeclined => 'План отклонён';

  @override
  String get accountDeletionWarning => 'Ваш аккаунт будет удалён через 48 часов. Если вы войдёте в этот аккаунт в течение 48 часов, он будет реактивирован и удаление отменено.';

  @override
  String get accountScheduledForDeletion => 'Аккаунт запланирован к удалению';

  @override
  String get reactivateAccount => 'Реактивировать Аккаунт';

  @override
  String get accountReactivated => 'Добро пожаловать обратно! Ваш аккаунт был реактивирован.';

  @override
  String get accountDeletionCancelled => 'Удаление аккаунта отменено.';

  @override
  String get emailVerificationRequired => 'Требуется Подтверждение Email';

  @override
  String get pleaseVerifyEmail => 'Пожалуйста, подтвердите ваш email адрес для продолжения';

  @override
  String get verificationEmailSent => 'Мы отправили ссылку подтверждения на ваш email. Пожалуйста, проверьте вашу почту и нажмите на ссылку для подтверждения.';

  @override
  String get waitingForVerification => 'Ожидание подтверждения email...';

  @override
  String get checkYourEmail => 'Проверьте ваш email и нажмите на ссылку подтверждения';

  @override
  String get resendVerificationEmail => 'Переотправить Email Подтверждения';

  @override
  String get verificationLinkAlreadySent => 'Ссылка подтверждения уже отправлена на этот email. Проверьте почту или подождите несколько минут.';

  @override
  String get emailVerified => 'Email успешно подтверждён!';

  @override
  String get emailNotVerified => 'Email ещё не подтверждён. Проверьте почту.';

  @override
  String get changeEmail => 'Изменить Email';

  @override
  String get continueToApp => 'Продолжить в Приложении';

  @override
  String get failedToSendVerificationEmail => 'Ошибка отправки email подтверждения';

  @override
  String get failedToResendVerificationEmail => 'Ошибка повторной отправки email';

  @override
  String get errorCheckingVerification => 'Ошибка проверки подтверждения';

  @override
  String get helloIAmYumie => 'Привет, я Yumie! Запишите приём пищи, чтобы начать свою серию сегодня!';

  @override
  String get happyBirthday => '🎉 С Днём Рождения!';

  @override
  String birthdayMessage(int age) {
    return 'Надеюсь, у вас замечательный день! Теперь вам $age лет.';
  }

  @override
  String get selectBirthday => 'Выберите свой день рождения';

  @override
  String get day => 'День';

  @override
  String get accountAlreadyExists => 'Аккаунт уже существует';

  @override
  String get accountExistsMessage => 'Аккаунт с этим email адресом уже существует. Хотите войти вместо этого?';

  @override
  String get accountUsesDifferentSignIn => 'Аккаунт использует другой способ входа';

  @override
  String get emailSignedUpWithGoogle => 'Этот email уже зарегистрирован с Google. Пожалуйста, используйте \"Войти через Google\" вместо этого.';

  @override
  String get emailSignedUpWithPassword => 'Этот email уже зарегистрирован с email и паролем. Пожалуйста, войдите, используя ваш пароль.';

  @override
  String get useGoogleSignIn => 'Использовать вход через Google';

  @override
  String get signInWithEmail => 'Войти с email';

  @override
  String get signInSuccessful => 'Вход выполнен успешно!';

  @override
  String get signUpSuccessful => 'Регистрация выполнена успешно!';

  @override
  String get emailVerifiedWelcome => 'Email подтвержден! Добро пожаловать!';

  @override
  String get premiumCancelledTitle => 'You have cancelled your subscription';

  @override
  String premiumCancelledWillEndOn(String date) {
    return 'Your premium access will end on $date';
  }

  @override
  String get manageSubscriptions => 'Manage Subscriptions';

  @override
  String get buildingMuscle => 'наращивание мышц';

  @override
  String get weightMaintained => 'вес поддерживается';

  @override
  String get eatingHealthier => 'питание более здоровое';

  @override
  String get goalReached => 'цель достигнута';

  @override
  String get noDataYet => 'данных пока нет';

  @override
  String get needMoreData => 'нужно больше данных';

  @override
  String get weeklyGain => 'еженедельный прирост';

  @override
  String get onTrack => 'на правильном пути';

  @override
  String get insufficientData => 'недостаточно данных';

  @override
  String get reached => 'Достигнуто';

  @override
  String get sinceGoalStart => 'с начала цели';

  @override
  String get viewPreviousPlans => 'Посмотреть Предыдущие Планы';

  @override
  String get previousPlans => 'Предыдущие Планы';

  @override
  String get yourWeightJourney => 'Ваш Путь Веса';

  @override
  String get trackProgressThroughGoals => 'Отслеживайте свой прогресс через разные цели';

  @override
  String get noPreviousPlans => 'Нет Предыдущих Планов';

  @override
  String get previousPlansWillAppear => 'Ваши предыдущие планы появятся здесь, когда вы измените цели.';

  @override
  String get completed => 'Завершено';

  @override
  String get changed => 'Изменено';

  @override
  String get nutritionGoals => 'Цели Питания';

  @override
  String get weightEntries => 'Записи Веса';

  @override
  String get noWeightEntriesRecorded => 'Не записано записей веса в этот период';

  @override
  String get months => 'месяцы';

  @override
  String get unknownGoal => 'Неизвестная Цель';

  @override
  String get failedToSavePlan => 'Не удалось сохранить план. Попробуйте снова.';

  @override
  String get failedToGeneratePlan => 'Не удалось создать план. Попробуйте снова.';

  @override
  String get updateTargetAndRecalculate => 'Обновить Цель и Пересчитать';

  @override
  String get neverMind => 'Неважно';

  @override
  String get saveAndRecalculate => 'Сохранить и Пересчитать';

  @override
  String get targetUpdatedAndPlanRecalculated => 'Цель обновлена и план пересчитан';

  @override
  String get recalculateNote => 'Мы пересчитаем калории и макросы для этой новой цели. Вы все еще можете создать совершенно новый ИИ план позже.';

  @override
  String get startLoggingWeight => 'Начните записывать свой вес, чтобы увидеть тенденции вашего прогресса.';

  @override
  String get logMoreWeights => 'Записывайте больше весов, чтобы увидеть вашу тенденцию.';

  @override
  String get weightTrendFlat => 'Ваша тенденция веса в настоящее время плоская. Записывайте больше записей веса, чтобы увидеть тенденцию вашего прогресса.';

  @override
  String get maintenanceRangeDrifted => 'Ваш вес отклонился от диапазона поддержания. Записывайте больше записей для оценки времени возврата к вашему весу.';

  @override
  String trendingBackMaintenance(String eta) {
    return 'Вы возвращаетесь к вашему весу поддержания. Расчетное время: $eta';
  }

  @override
  String get stayConsistentHealthy => 'Оставайтесь последовательными со здоровыми выборами; по мере поступления большего количества данных мы оценим время возврата к вашему здоровому диапазону.';

  @override
  String trendingBackOnTrack(String eta) {
    return 'Вы возвращаетесь на правильный путь. Расчетное время: $eta';
  }

  @override
  String get strengthPhaseActive => 'Фаза силы активна. Поддерживайте белок и тренировки последовательно; временная шкала появится по мере роста данных.';

  @override
  String trendingTowardBuildGoal(String eta) {
    return 'Вы движетесь к вашей цели строительства. Расчетное время: $eta';
  }

  @override
  String get timeToGoal => 'Время до Цели';

  @override
  String get timeline => 'Временная Шкала';

  @override
  String get allTime => 'Все Время';

  @override
  String get planToGoal => 'План к Цели';

  @override
  String get cameraInitializationError => 'Ошибка инициализации камеры. Проверьте разрешения камеры.';
}
