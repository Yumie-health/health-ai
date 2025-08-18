// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get settings => 'Paramètres';

  @override
  String get preferences => 'Préférences';

  @override
  String get darkMode => 'Mode Sombre';

  @override
  String get enableDarkTheme => 'Activer le thème sombre';

  @override
  String get useMetricUnits => 'Utiliser les Unités Métriques';

  @override
  String get unitsSubtitle => 'Utiliser kg/cm (activé) ou lb/ft (désactivé)';

  @override
  String get language => 'Langue';

  @override
  String get selectLanguage => 'Sélectionner la langue de l\'application';

  @override
  String get habitNotifications => 'Notifications d\'Habitudes';

  @override
  String get mealLoggingPrompts => 'Rappels de Journalisation des Repas';

  @override
  String get mealLoggingPromptsSubtitle => 'Recevoir des rappels pour enregistrer vos repas';

  @override
  String get waterIntakeReminders => 'Rappels de Consommation d\'Eau';

  @override
  String get waterIntakeRemindersSubtitle => 'Recevoir des rappels pour boire de l\'eau';

  @override
  String get mindfulWalksReminders => 'Rappels de Marches Conscientes';

  @override
  String get mindfulWalksRemindersSubtitle => 'Recevoir des rappels pour faire une marche consciente';

  @override
  String get momentOfCalmAfterMeals => 'Moment de Calme Après les Repas';

  @override
  String get momentOfCalmAfterMealsSubtitle => 'Afficher une popup apaisante après avoir enregistré un repas';

  @override
  String get welcomeBack => 'Bon retour !';

  @override
  String get trackNutritionToday => 'Suivons votre nutrition aujourd\'hui';

  @override
  String get subtitleAfternoon => 'Moment idéal pour enregistrer votre déjeuner et garder l\'équilibre.';

  @override
  String get subtitleEvening => 'Restez sur la bonne voie ce soir — enregistrez vos repas.';

  @override
  String get subtitleNight => 'Terminez votre journée — n\'oubliez pas d\'enregistrer vos repas d\'aujourd\'hui.';

  @override
  String get streakNearEndingTitle => 'Gardez votre série 🔥';

  @override
  String get streakNearEndingBody => 'Votre série est sur le point de se terminer. Enregistrez un repas aujourd\'hui pour la garder !';

  @override
  String get streakNearEndingTitle2 => 'Presque là ! 🔥';

  @override
  String get streakNearEndingBody2 => 'Il ne reste que quelques heures. Enregistrez un repas pour sauver votre série !';

  @override
  String get streakEndedTitle => 'Série terminée';

  @override
  String get streakEndedBody => 'Votre série s\'est terminée. Enregistrez un repas pour la redémarrer et la reconstruire !';

  @override
  String get streakActive => 'Série active';

  @override
  String get streakInactive => 'Série inactive';

  @override
  String get currentStreak => 'Série actuelle';

  @override
  String get entriesInStreak => 'Entrées dans la série';

  @override
  String get days => 'jours';

  @override
  String get startedOn => 'Commencée le';

  @override
  String get logMealToStartStreak => 'Enregistrez un repas aujourd\'hui pour démarrer votre série';

  @override
  String get nutritionSummary => 'Résumé Nutritionnel';

  @override
  String get setCalorieAndMacroGoals => 'Définissez vos objectifs caloriques et macronutriments dans la page Plan Nutritionnel.';

  @override
  String get protein => 'Protéines';

  @override
  String get carbs => 'Glucides';

  @override
  String get fat => 'Lipides';

  @override
  String get calories => 'Calories';

  @override
  String get quickActions => 'Actions Rapides';

  @override
  String get logMeal => 'Enregistrer un Repas';

  @override
  String get trackYourFood => 'Suivre votre alimentation';

  @override
  String get scan => 'Scanner';

  @override
  String get barcode => 'Code-barres';

  @override
  String get analyzeYourFood => 'Analyser votre alimentation';

  @override
  String get todaysMeals => 'Repas d\'Aujourd\'hui';

  @override
  String get viewAll => 'Voir Tout';

  @override
  String get noMealsLoggedForThisDay => 'Aucun repas enregistré pour cette journée.';

  @override
  String get nutritionalPlan => 'Plan Nutritionnel';

  @override
  String get weightAnalytics => 'Analytique du poids';

  @override
  String get toGoal => 'VERS L\'OBJECTIF';

  @override
  String get remaining => 'restant';

  @override
  String get weeklyRate => 'RYTHME HEBDOMADAIRE';

  @override
  String get weeklyLoss => 'perte hebdomadaire';

  @override
  String get starting => 'DÉPART';

  @override
  String get current => 'ACTUEL';

  @override
  String get today => 'aujourd\'hui';

  @override
  String get targetLabel => 'OBJECTIF';

  @override
  String get goalWeight => 'poids cible';

  @override
  String get eta => 'ETA';

  @override
  String get sinceStart => 'depuis le début';

  @override
  String get expectationsDisclaimer => 'Ces attentes sont basées sur votre tendance récente et peuvent changer au fur et à mesure que vous enregistrez de nouveaux poids.';

  @override
  String get loseVerb => 'perdre';

  @override
  String get gainVerb => 'gagner';

  @override
  String expectationBlurb(Object direction, Object eta, Object rate, Object remaining, Object unit) {
    return 'Selon votre tendance récente, vous êtes en bonne voie pour $direction environ $rate $unit par semaine. À ce rythme, il faudra environ $eta pour atteindre votre objectif. Il vous reste $remaining $unit.';
  }

  @override
  String get healthAwareness => 'Conscience de la Santé';

  @override
  String get planSettings => 'Paramètres du Plan';

  @override
  String get featureComingSoon => 'Cette fonctionnalité arrive bientôt !';

  @override
  String get ok => 'OK';

  @override
  String get rateUsOnGoogle => 'Évaluez-nous sur Google';

  @override
  String get comingSoon => 'Bientôt Disponible !';

  @override
  String get ratingOnGoogleAvailableAfterRelease => 'L\'évaluation sur Google sera disponible après la sortie.';

  @override
  String get shareWithFriends => 'Partager avec des Amis';

  @override
  String get sharingAvailableAfterRelease => 'Le partage sera disponible après la sortie.';

  @override
  String get resetPassword => 'Réinitialiser le Mot de Passe';

  @override
  String get close => 'Fermer';

  @override
  String get sendResetLink => 'Envoyer le Lien de Réinitialisation';

  @override
  String get send => 'Envoyer';

  @override
  String get resend => 'Renvoyer';

  @override
  String get helpSupport => 'Aide & Support';

  @override
  String get legal => 'Mentions Légales';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get apiDocumentation => 'Documentation API';

  @override
  String get needAssistanceContactSupport => 'Besoin d\'aide ? Contactez notre équipe de support :';

  @override
  String get testWebURL => 'URL Web de Test';

  @override
  String get testSimpleMailto => 'Test Mailto Simple';

  @override
  String get logOut => 'Se Déconnecter';

  @override
  String get areYouSureYouWantToLogOut => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get no => 'No';

  @override
  String get yes => 'Yes';

  @override
  String get commonQuestions => 'Questions Fréquentes';

  @override
  String get momentOfCalm => 'Moment de Calme';

  @override
  String get practiceMindfulEating => 'Prenez un moment pour apprécier votre repas et pratiquer l\'alimentation consciente.';

  @override
  String get howOldAreYou => 'How old are you?';

  @override
  String get personalizeExperience => 'Cela nous aide à personnaliser votre expérience';

  @override
  String get yourHeight => 'Your height';

  @override
  String get yourGoalWeight => 'Votre poids objectif';

  @override
  String get setRealisticGoal => 'Définissez un objectif réaliste pour votre parcours';

  @override
  String get allSet => 'Vous êtes prêt ! 🎉';

  @override
  String get personalizedNutritionPlan => 'Voici votre plan nutritionnel personnalisé. Bienvenue dans votre parcours de santé avec Yumie !';

  @override
  String get whatIsYourBloodType => 'What is your blood type?';

  @override
  String get personalizeHealthInsights => 'Cela nous aide à personnaliser vos insights de santé.';

  @override
  String get whatIsYourSex => 'What is your sex?';

  @override
  String get personalizeNutritionPlan => 'Cela nous aide à personnaliser votre plan nutritionnel.';

  @override
  String get home => 'Accueil';

  @override
  String get food => 'Alimentation';

  @override
  String get coach => 'Coach';

  @override
  String get profile => 'Profil';

  @override
  String get log => 'Journal';

  @override
  String get myMeals => 'Mes Repas';

  @override
  String get suggestedMeals => 'Repas Suggérés';

  @override
  String get monthly => 'Mensuel';

  @override
  String get weekly => 'Hebdomadaire';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Dinner';

  @override
  String get snack => 'Collation';

  @override
  String get reviewMeal => 'Examiner le Repas';

  @override
  String get chat => 'Chat';

  @override
  String get insights => 'Insights';

  @override
  String get clearChat => 'Effacer le Chat';

  @override
  String get coachWelcome => 'Bonjour ! Je suis Yumie, votre coach nutritionnel. Comment puis-je vous aider aujourd\'hui ?\n\nDemandez à Yumie des recettes saines, des plans de repas ou des conseils nutritionnels !';

  @override
  String get refreshInsight => 'Actualiser l\'Insight';

  @override
  String get healthInsights => 'Insights de Santé';

  @override
  String get noInsightAvailable => 'Aucun insight disponible.';

  @override
  String get dinnerIdeas => 'Idées de dîner';

  @override
  String get calorieCheck => 'Vérification des calories';

  @override
  String get proteinSnacks => 'Collations protéinées';

  @override
  String get dietTips => 'Conseils alimentaires';

  @override
  String get typeYourMessage => 'Tapez votre message...';

  @override
  String get yumie => 'Yumie';

  @override
  String get askAboutMeals => 'Demandez sur les repas et nutrition';

  @override
  String get coachQuick1 => 'Que devrais-je manger aujourd\'hui ?';

  @override
  String get coachQuick2 => 'Analysez mon dernier repas';

  @override
  String get coachQuick3 => 'Aidez-moi à planifier ma semaine';

  @override
  String get yumieThinking => 'Yumie réfléchit...';

  @override
  String get bmi => 'IMC';

  @override
  String get target => 'Objectif';

  @override
  String get weight => 'Poids';

  @override
  String get age => 'Âge';

  @override
  String get height => 'Taille';

  @override
  String get targetWeight => 'Poids Objectif';

  @override
  String get calorieGoal => 'Objectif Calorique';

  @override
  String get proteinGoal => 'Objectif Protéines';

  @override
  String get carbGoal => 'Objectif Glucides';

  @override
  String get fatGoal => 'Objectif Lipides';

  @override
  String get waterIntake => 'Consommation d\'Eau';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Annuler';

  @override
  String get undo => 'Annuler';

  @override
  String get notSet => 'Non défini';

  @override
  String get uploadNew => 'Télécharger Nouveau';

  @override
  String get delete => 'Supprimer';

  @override
  String get editName => 'Modifier le nom';

  @override
  String get bloodType => 'Blood type';

  @override
  String get areYouDiabetic => 'Are you diabetic?';

  @override
  String get healthAwarenessUpdated => 'Conscience de la santé mise à jour !';

  @override
  String get takeMomentToAppreciate => 'Prenez un moment pour apprécier votre repas et pratiquer l\'alimentation consciente.';

  @override
  String get continueButton => 'Continuer';

  @override
  String get mealSaved => 'Repas enregistré !';

  @override
  String get noRecentFoods => 'Aucun aliment récent.';

  @override
  String get buildCustomMeal => 'Créer un Repas Personnalisé';

  @override
  String get mealName => 'Nom du Repas';

  @override
  String get searchOrEnterFoodName => 'Rechercher ou saisir le nom de l\'aliment';

  @override
  String get ingredients => 'Ingrédients';

  @override
  String get addIngredient => 'Ajouter un ingrédient';

  @override
  String get myFoods => 'Mes Aliments';

  @override
  String get noCustomFoods => 'Vous n\'avez pas encore sauvegardé d\'aliments personnalisés';

  @override
  String get addCustomFood => 'Ajouter un Aliment Personnalisé';

  @override
  String get editCustomMeal => 'Modifier le Repas Personnalisé';

  @override
  String get clearAll => 'Tout Effacer';

  @override
  String get foodName => 'Nom de l\'Aliment';

  @override
  String get saveMeal => 'Enregistrer le Repas';

  @override
  String get customizeMeal => 'Personnaliser le repas';

  @override
  String get hideIngredients => 'Masquer les ingrédients';

  @override
  String get showIngredients => 'Afficher les ingrédients';

  @override
  String get ingredientsColon => 'Ingrédients :';

  @override
  String get noIngredientsListed => 'Aucun ingrédient listé.';

  @override
  String get recent => 'Récent';

  @override
  String get meal => 'REPAS';

  @override
  String get fridge => 'Réfrigérateur';

  @override
  String get placeFoodInFrame => 'Placez l\'aliment à l\'intérieur du cadre';

  @override
  String get placeBarcodeInFrame => 'Placez le code dans le cadre';

  @override
  String get placeFridgeInFrame => 'Alignez le réfrigérateur dans le cadre';

  @override
  String get productNotFound => 'Produit introuvable';

  @override
  String get safetyUnsafe => 'Non sûr';

  @override
  String get safetyGood => 'Bon à consommer';

  @override
  String get badgeNutriScore => 'Nutri-Score';

  @override
  String get badgeNova => 'NOVA';

  @override
  String get allergensTitle => 'Allergènes';

  @override
  String get contains => 'Contient';

  @override
  String get allergensNone => 'Aucun allergène indiqué';

  @override
  String get serving => 'Portion';

  @override
  String get kcalPer100g => 'kcal/100g';

  @override
  String get sugar => 'Sucre';

  @override
  String get satFat => 'Graisses sat.';

  @override
  String get salt => 'Sel';

  @override
  String get ingredientsTitle => 'Ingrédients';

  @override
  String get riskAllergen => 'Risque d\'allergènes';

  @override
  String get riskUltraProcessed => 'Ultra-transformé (NOVA 4)';

  @override
  String get riskHighAdditives => 'Beaucoup d\'additifs';

  @override
  String get riskLowNutri => 'Nutri‑Score faible';

  @override
  String get riskVegan => 'Convient aux végétaliens';

  @override
  String get riskVegetarian => 'Végétarien';

  @override
  String get riskLooksGood => 'Ça semble bon';

  @override
  String get retakeScan => 'Refaire le Scan';

  @override
  String get previewFullImage => 'Aperçu de l\'Image Complète';

  @override
  String get discard => 'Supprimer';

  @override
  String get upgradeToPremium => 'Passer à Premium';

  @override
  String get getUnlimitedScans => 'Obtenez des scans illimités et plus encore !';

  @override
  String get getUnlimitedSearches => 'Obtenez des recherches illimitées et plus encore !';

  @override
  String get upgradePlan => 'Plan Premium';

  @override
  String get watchAdForScan => 'Regarder une Pub pour Scanner';

  @override
  String get watchAdForSearch => 'Regarder une Pub pour Rechercher';

  @override
  String get generateMeal => 'Générer un Repas';

  @override
  String get detectedFridgeItems => 'Éléments du Réfrigérateur Détectés';

  @override
  String get noFridgeItemsDetected => 'Aucun élément du réfrigérateur détecté.';

  @override
  String get searchResults => 'Résultats de Recherche';

  @override
  String get searchingFor => 'Recherche de';

  @override
  String get noResultsFoundFor => 'Aucun résultat trouvé pour';

  @override
  String get count => 'compteur';

  @override
  String get servings => 'portions';

  @override
  String get fluidOunces => 'Onces Fluides';

  @override
  String get quantity => 'Quantité';

  @override
  String get confirm => 'Confirmer';

  @override
  String get ingredient => 'INGRÉDIENT';

  @override
  String get drink => 'BOISSON';

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
  String get inches => 'pouces';

  @override
  String get cup => 'tasse';

  @override
  String get tbsp => 'c. à soupe';

  @override
  String get tsp => 'c. à café';

  @override
  String get ml => 'ml';

  @override
  String get l => 'l';

  @override
  String get upgradeToPremiumTitle => 'Passer à Premium';

  @override
  String get premiumFeatures => 'Fonctionnalités Premium';

  @override
  String get unlimitedScans => 'Scans illimités';

  @override
  String get aiNutritionCoach => 'Coach nutritionnel IA';

  @override
  String get detailedAnalytics => 'Analyses détaillées';

  @override
  String get personalizedMealPlans => 'Plans de repas personnalisés';

  @override
  String get noAdvertisements => 'Aucune publicité';

  @override
  String get yearlyPremium => 'Premium Annuel';

  @override
  String get monthlyPremium => 'Premium Mensuel';

  @override
  String savePercent(Object percent) {
    return 'Économisez $percent%';
  }

  @override
  String get perYear => '/an';

  @override
  String get perMonth => '/mois';

  @override
  String get popular => 'POPULAIRE';

  @override
  String get maybeLater => 'Peut-être plus tard';

  @override
  String get welcomeToYumie => '🎉 Bienvenue sur Yumie !';

  @override
  String get unlockPremiumFeatures => 'Débloquer les Fonctionnalités Premium';

  @override
  String get getMostOutOfHealthJourney => 'Tirez le meilleur parti de votre parcours de santé avec un accès illimité !';

  @override
  String get unlimitedScansAICoaching => 'Débloquez des scans illimités, un coaching IA et des plans de repas personnalisés !';

  @override
  String get subscribe => 'S\'abonner';

  @override
  String get foodNameLabel => 'Nom de l\'Aliment';

  @override
  String get managePermissions => 'Gérer les Permissions';

  @override
  String get cameraNotificationsAndMore => 'Caméra, notifications et plus';

  @override
  String get deleteMeal => 'Supprimer le repas';

  @override
  String get areYouSureDeleteMeal => 'Êtes-vous sûr de vouloir supprimer ce repas ?';

  @override
  String get unknown => 'Unknown';

  @override
  String get servings1 => 'portions 1';

  @override
  String get edit => 'Modifier';

  @override
  String get ignoreFood => 'Ignorer l\'Aliment';

  @override
  String get addComponent => 'Ajouter un Composant';

  @override
  String get components => 'Composants';

  @override
  String get recentFoods => 'Aliments Récents';

  @override
  String get logWeightChange => 'Poids';

  @override
  String get lost => 'Perdu';

  @override
  String get gained => 'Gagné';

  @override
  String get googleSignInHelp => 'Aide pour la Connexion Google';

  @override
  String get couldNotOpenTermsOfService => 'Impossible d\'ouvrir les Conditions d\'Utilisation';

  @override
  String get couldNotOpenPrivacyPolicy => 'Impossible d\'ouvrir la Politique de Confidentialité';

  @override
  String get errorSavingProfile => 'Erreur lors de la sauvegarde du profil';

  @override
  String get completeYourProfile => 'Complétez Votre Profil';

  @override
  String get saveAndContinue => 'Enregistrer et Continuer';

  @override
  String get pleasSignIn => 'Veuillez vous connecter.';

  @override
  String get noFoodLogsYet => 'Aucun journal alimentaire pour le moment.';

  @override
  String get healthAIFoodLog => 'HealthAI - Journal Alimentaire';

  @override
  String get addLog => 'Ajouter un Journal';

  @override
  String get unableToShareAtThisTime => 'Impossible de partager pour le moment. Veuillez réessayer.';

  @override
  String get failedToUpdatePhoto => 'Échec de la mise à jour de la photo';

  @override
  String get changeProfileName => 'Modifier le Nom du Profil';

  @override
  String get failedToUpdateName => 'Échec de la mise à jour du nom';

  @override
  String get profileUpdatedSuccessfully => 'Profil mis à jour avec succès';

  @override
  String get errorUpdatingProfile => 'Erreur lors de la mise à jour du profil';

  @override
  String get editGoals => 'Modifier les Objectifs';

  @override
  String get goalsUpdatedSuccessfully => 'Objectifs mis à jour avec succès';

  @override
  String get errorUpdatingGoals => 'Erreur lors de la mise à jour des objectifs';

  @override
  String get couldNotOpenWebsite => 'Impossible d\'ouvrir le site web';

  @override
  String get errorOpeningWebsite => 'Erreur lors de l\'ouverture du site web';

  @override
  String get english => 'Anglais';

  @override
  String get arabic => 'Arabe';

  @override
  String get spanish => 'Espagnol';

  @override
  String get reviewMealTitle => 'Examiner le Repas';

  @override
  String get startingWeight => 'Poids de Départ';

  @override
  String get appPermissions => 'Permissions de l\'Application';

  @override
  String get permissionStatus => 'Statut des Permissions';

  @override
  String get manageAppPermissions => 'Gérez les permissions de l\'application pour garantir le bon fonctionnement de toutes les fonctionnalités';

  @override
  String get camera => 'Camera';

  @override
  String get scanFoodItems => 'Scanner les aliments et prendre des photos des repas';

  @override
  String get photoLibrary => 'Photos';

  @override
  String get saveScannedImages => 'Sauvegarder les images scannées et sélectionner des photos';

  @override
  String get notifications => 'Notifications';

  @override
  String get sendMealReminders => 'Envoyer des rappels de repas et des alertes de santé';

  @override
  String get needHelp => 'Besoin d\'Aide ?';

  @override
  String get permanentlyDeniedHelp => 'Si les permissions sont définitivement refusées, vous pouvez les activer dans les paramètres de votre appareil';

  @override
  String get openDeviceSettings => 'Ouvrir les Paramètres de l\'Appareil';

  @override
  String get goodMorning => 'Bonjour';

  @override
  String get goodAfternoon => 'Bon après-midi';

  @override
  String get goodEvening => 'Bonsoir';

  @override
  String get goodNight => 'Bonne nuit';

  @override
  String get ounces => 'onces';

  @override
  String get january => 'Janvier';

  @override
  String get february => 'Février';

  @override
  String get march => 'Mars';

  @override
  String get april => 'Avril';

  @override
  String get may => 'Mai';

  @override
  String get june => 'Juin';

  @override
  String get july => 'Juillet';

  @override
  String get august => 'Août';

  @override
  String get september => 'Septembre';

  @override
  String get october => 'Octobre';

  @override
  String get november => 'Novembre';

  @override
  String get december => 'Décembre';

  @override
  String get trackYourNutrition => 'Suivez votre nutrition';

  @override
  String get messages => 'Messages';

  @override
  String get subscribeForDailyInsights => 'Abonnez-vous aux Insights Quotidiens';

  @override
  String get getPersonalizedHealthInsights => 'Obtenez des insights de santé personnalisés basés sur votre profil complet';

  @override
  String get upgradeDescription => 'Obtenez des scans illimités, des recherches et des insights alimentés par l\'IA';

  @override
  String get unlimitedFoodScans => 'Scans d\'Aliments Illimités';

  @override
  String get unlimitedFoodSearches => 'Recherches d\'Aliments Illimitées';

  @override
  String get unlimitedAICoachMessages => 'Messages du Coach IA Illimités';

  @override
  String get dailyHealthInsights => 'Insights de Santé Quotidiens';

  @override
  String get logWaterIntake => 'Eau';

  @override
  String get add => 'Ajouter';

  @override
  String get freemium => 'Freemium';

  @override
  String get premium => 'Premium';

  @override
  String get chooseYourPlan => 'Choisissez Votre Plan';

  @override
  String get water => 'Eau';

  @override
  String get resetPasswordDescription => 'Un lien de réinitialisation sera envoyé à votre email';

  @override
  String get deleteAccount => 'Supprimer le Compte';

  @override
  String get deleteAccountDescription => 'Supprimer définitivement votre compte et toutes les données';

  @override
  String get confirmDeleteAccount => 'Êtes-vous sûr de vouloir supprimer votre compte ?';

  @override
  String get deleteAccountWarning => 'Cette action ne peut pas être annulée. Toutes vos données, y compris les repas, les progrès et les paramètres, seront définitivement supprimées.';

  @override
  String get typeDeleteToConfirm => 'Type \"DELETE\" to confirm';

  @override
  String get deleteAccountFinalConfirmation => 'SUPPRIMER';

  @override
  String get accountDeleted => 'Account Deleted';

  @override
  String get errorDeletingAccount => 'Erreur lors de la suppression du compte';

  @override
  String get totalNutrition => 'Nutrition Totale';

  @override
  String get unlockUnlimitedScans => 'Débloquez des scans illimités, un coaching IA et\ndes plans de repas personnalisés';

  @override
  String get unlimitedFoodScanning => 'Scan d\'aliments illimité';

  @override
  String get yearPrice => 'an/49,99€';

  @override
  String get monthPrice => 'mois/7,99€';

  @override
  String get save37 => 'Économisez 37%';

  @override
  String get youArePremium => 'Vous êtes Premium !';

  @override
  String get yumiePremiumMonthly => 'Yumie™ Premium Mensuel';

  @override
  String get yumiePremiumYearly => 'Yumie™ Premium Annuel';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get checkingForPurchases => 'Recherche d\'achats existants...';

  @override
  String get purchasesRestored => 'Achats restaurés avec succès !';

  @override
  String get noPurchasesFound => 'Aucun achat précédent trouvé';

  @override
  String get restoreFailed => 'Échec de la restauration des achats. Veuillez réessayer.';

  @override
  String get restoreInProgress => 'Restauration des achats...';

  @override
  String get bySubscribing => 'En vous abonnant, vous acceptez nos Conditions d\'Utilisation et notre Politique de Confidentialité. Les abonnements se renouvellent automatiquement sauf annulation';

  @override
  String get permissionsComplete => 'Permissions Complete!';

  @override
  String get whyWeAskForPermissions => 'Pourquoi nous demandons des autorisations';

  @override
  String get permissionsWhyBody => 'Nous utilisons votre appareil photo pour scanner les aliments et les codes‑barres, accéder aux photos lorsque vous importez des images et envoyer des notifications pour vous rappeler d’enregistrer vos repas et de vous hydrater.';

  @override
  String get permissionsNextScreen => 'À l’écran suivant, vous verrez les invites système pour accorder l’accès. Vous pouvez modifier cela à tout moment dans Réglages.';

  @override
  String get references => 'Références :';

  @override
  String get cdcAboutBmi => 'CDC : À propos de l’IMC';

  @override
  String get usdaDietaryGuidelines => 'Recommandations alimentaires de l’USDA';

  @override
  String get termsOfUseEula => 'Conditions d’utilisation (EULA)';

  @override
  String get enterYourPassword => 'Entrez votre mot de passe';

  @override
  String get manageSessions => 'Gérer les Sessions';

  @override
  String get selectLanguageTitle => 'Sélectionner la Langue';

  @override
  String get chooseYourPreferredLanguage => 'Choisissez votre langue préférée pour l\'application';

  @override
  String get languageChangedTo => 'Langue changée vers';

  @override
  String get activeSessions => 'Sessions Actives';

  @override
  String get thisDevice => 'Cet appareil';

  @override
  String get sessionRevoked => 'Session révoquée';

  @override
  String get allOtherSessionsSignedOut => 'Toutes les autres sessions déconnectées';

  @override
  String get signOutAllOthers => 'Déconnecter Tous les Autres';

  @override
  String get noSecurityAlerts => 'Aucune alerte de sécurité';

  @override
  String get passwordStrengthWeak => 'Faible';

  @override
  String get passwordStrengthFair => 'Moyen';

  @override
  String get passwordStrengthGood => 'Bon';

  @override
  String get passwordStrengthStrong => 'Fort';

  @override
  String get passwordStrengthVeryStrong => 'Très Fort';

  @override
  String get addLowercaseLetters => 'Ajouter des lettres minuscules';

  @override
  String get addUppercaseLetters => 'Ajouter des lettres majuscules';

  @override
  String get addNumbers => 'Ajouter des chiffres';

  @override
  String get addSpecialCharacters => 'Ajouter des caractères spéciaux (!@#\$%^&*)';

  @override
  String get avoidCommonPatterns => 'Éviter les motifs courants';

  @override
  String get requiresAtLeast8Characters => 'Nécessite au moins 8 caractères';

  @override
  String get tooManySignInAttempts => 'Trop de tentatives de connexion. Veuillez réessayer plus tard.';

  @override
  String get tooManySignUpAttempts => 'Trop de tentatives d\'inscription. Veuillez réessayer plus tard.';

  @override
  String get tooManyPasswordResetRequests => 'Trop de demandes de réinitialisation de mot de passe. Veuillez réessayer plus tard.';

  @override
  String get multipleFailedSignInAttempts => 'Tentatives de Connexion Échouées Multiples';

  @override
  String get excessivePasswordResetRequests => 'Demandes de Réinitialisation de Mot de Passe Excessives';

  @override
  String get suspiciousActivityDetected => 'Activité Suspecte Détectée';

  @override
  String get riskLevelMedium => 'MOYEN';

  @override
  String get riskLevelHigh => 'ÉLEVÉ';

  @override
  String get welcomeToYumiePermissions => 'Bienvenue sur Yumie';

  @override
  String get provideBestExperience => 'Pour vous offrir la meilleure expérience, nous avons besoin de quelques permissions';

  @override
  String get grantPermissions => 'Accorder les Permissions';

  @override
  String get skipForNow => 'Passer pour l\'Instant';

  @override
  String get denied => 'Refusé';

  @override
  String get granted => 'Accordé';

  @override
  String get createAccount => 'Créer un Compte';

  @override
  String get signUpToGetStarted => 'Inscrivez-vous pour commencer avec Yumie';

  @override
  String get fullName => 'Nom Complet';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de Passe';

  @override
  String get agreeToTerms => 'et Conditions d\'Utilisation J\'accepte la Politique de Confidentialité';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get signIn => 'Se Connecter';

  @override
  String get signUp => 'S\'Inscrire';

  @override
  String get signInToAccessAccount => 'Connectez-vous pour accéder à votre compte';

  @override
  String get forgotPassword => 'Mot de Passe Oublié ?';

  @override
  String get dontHaveAccount => 'Vous n\'avez pas de compte ?';

  @override
  String get signUpWithGoogle => 'S\'inscrire avec Google';

  @override
  String get signInWithGoogle => 'Se connecter avec Google';

  @override
  String get signUpWithApple => 'S\'inscrire avec Apple';

  @override
  String get signInWithApple => 'Sign in with Apple';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get enterEmailForReset => 'Enter your email address to receive a password reset link';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get rateUsOn => 'Rate us on';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String get deleteAccountWarningTitle => 'This action is permanent and cannot be undone';

  @override
  String get deleteAccountDataList => 'When you delete your account, we will permanently remove:';

  @override
  String get allMealLogsAndNutrition => 'All your meal logs and nutrition data';

  @override
  String get profileAndPersonalInfo => 'Your profile and personal information';

  @override
  String get allUploadedPhotos => 'All uploaded photos and files';

  @override
  String get customMealsAndRecipes => 'Your custom meals and recipes';

  @override
  String get allAppPreferences => 'All app preferences and settings';

  @override
  String get activeSessionsAllDevices => 'Active sessions on all devices';

  @override
  String get exportDataWarning => 'Make sure to export any data you want to keep before proceeding';

  @override
  String get understandActionPermanent => 'I understand this action is permanent';

  @override
  String get typeDeleteHere => 'Type DELETE here';

  @override
  String get deleteForever => 'Delete Forever';

  @override
  String get noSecurityAlertsFound => 'No security alerts';

  @override
  String get yourAccountLooksGood => 'Your account looks good! No suspicious activity detected.';

  @override
  String get manageActiveSessionsAcrossDevices => 'Manage your active sessions across different devices';

  @override
  String get noActiveSessionsFound => 'No active sessions found';

  @override
  String get signOutAllOtherSessions => 'Sign Out All Others';

  @override
  String get aiSearch => 'AI Search';

  @override
  String get aiSearchDescription => 'Search for food items using AI';

  @override
  String get noIngredientsListedText => 'No ingredients listed';

  @override
  String get breakfastTime => 'Breakfast Time';

  @override
  String get lunchTime => 'Lunch Time';

  @override
  String get dinnerTime => 'Dinner Time';

  @override
  String get snackTime => 'Snack Time';

  @override
  String get deletingYourAccount => 'Deleting your account...';

  @override
  String get thisMayTakeAFewMoments => 'This may take a few moments';

  @override
  String get redirectingToSignIn => 'Redirecting to sign-in...';

  @override
  String weightTrendNoData(Object remaining, Object unit) {
    return 'Pas assez de données de poids.';
  }

  @override
  String weightTrendHealthyRate(Object eta, Object rate, Object remaining, Object unit) {
    return 'Rythme sain : $rate$unit/semaine';
  }

  @override
  String get accountSuccessfullyDeleted => 'Account Successfully Deleted';

  @override
  String get pleaseCloseAndRestartApp => 'Please close and restart the app to continue.';

  @override
  String get exportData => 'Exporter les Données';

  @override
  String get exportDataDescription => 'Exporter toutes vos données en fichier PDF';

  @override
  String get exportComplete => 'Export Terminé';

  @override
  String get exportCompleteMessage => 'Vos données ont été exportées avec succès !';

  @override
  String get exportCompleteDescription => 'Le fichier PDF a été sauvegardé sur votre appareil et peut être partagé ou visualisé.';

  @override
  String get exportFailed => 'Échec de l\'Export';

  @override
  String get exportingData => 'Exportation de vos données...';

  @override
  String get exportingDataDescription => 'Cela peut prendre quelques instants';

  @override
  String get restartApp => 'Restart App';

  @override
  String get cameraAccess => 'Camera Access';

  @override
  String get cameraAccessMessage => 'Yumie needs camera access to scan food items and help you log your meals accurately.';

  @override
  String get photoLibraryAccess => 'Photo Library Access';

  @override
  String get photoLibraryAccessMessage => 'Yumie needs access to your photo library to save scanned images and select photos for meal logging.';

  @override
  String get notificationAccess => 'Notification Access';

  @override
  String get notificationAccessMessage => 'Yumie needs notification access to send you meal reminders, water intake alerts, and mindful walk prompts.';

  @override
  String get notNow => 'Not Now';

  @override
  String get permissionsCompleted => 'Permissions Complete!';

  @override
  String get allPermissionsGranted => 'All permissions granted! You\'re all set to use Yumie.';

  @override
  String get whatIsYourMainGoal => 'What is your main goal?';

  @override
  String get chooseGoalDescription => 'Choose the goal that best aligns with your journey';

  @override
  String get loseBodyWeight => 'Lose body weight';

  @override
  String get gainWeight => 'Gain weight';

  @override
  String get buildMuscle => 'Build muscle';

  @override
  String get eatHealthier => 'Eat healthier';

  @override
  String get maintainBodyWeight => 'Maintain body weight';

  @override
  String get setRealisticGoalForJourney => 'Set a realistic goal for your journey';

  @override
  String get targetWeightSetToCurrent => 'Your target weight is set to your current weight';

  @override
  String get iAcceptThe => 'I accept the';

  @override
  String get and => 'and';

  @override
  String get johnDoe => 'John Doe';

  @override
  String get yourEmailExample => 'your.email@example.com';

  @override
  String get byContinuingYouAgreeToOur => 'By continuing, you agree to our';

  @override
  String get whatMotivatesYou => 'What motivates you?';

  @override
  String get chooseWhatDrivesYou => 'Choose what drives you to achieve your goals';

  @override
  String get feelEnergeticEveryDay => 'Feel energetic every day';

  @override
  String get achievePersonalMilestone => 'Achieve a personal milestone';

  @override
  String get boostMyConfidence => 'Boost my confidence';

  @override
  String get longTermHealth => 'Long term health';

  @override
  String get trackYourMealsWithEase => 'Track your meals with ease';

  @override
  String get caloriesLeft => 'calories left';

  @override
  String get thisHelpsUsPersonalizeNutrition => 'This helps us personalize your nutrition plan';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get other => 'Other';

  @override
  String get thisHelpsUsPersonalizeExperience => 'This helps us personalize your experience';

  @override
  String get older => 'Older';

  @override
  String get younger => 'Younger';

  @override
  String get yearsOld => 'years old';

  @override
  String get selected => 'Selected';

  @override
  String get teens => 'Teens';

  @override
  String get yourCurrentWeight => 'Your current weight';

  @override
  String get activityLevel => 'Activity level';

  @override
  String get diabetic => 'Diabetic?';

  @override
  String get howMuchWaterADay => 'How much water a day?';

  @override
  String get fitnessProfile => 'Fitness profile';

  @override
  String get dueToCurrentAnswers => 'Due to current answers';

  @override
  String get remindersWouldYouLike => 'Reminders would you like to receive?';

  @override
  String get yumieIsCookingUp => 'Yumie is cooking up your personalized nutrition plan...';

  @override
  String get yourAllSet => 'You\'re all set!';

  @override
  String get google => 'Google';

  @override
  String get fiftyPlus => '50+';

  @override
  String get forties => '40s';

  @override
  String get thirties => '30s';

  @override
  String get twenties => '20s';

  @override
  String get weightUnit => 'kg';

  @override
  String get heightUnit => 'cm';

  @override
  String get feetUnit => 'ft';

  @override
  String get inchesUnit => 'in';

  @override
  String get poundsUnit => 'lbs';

  @override
  String get whatIsYourAge => 'What is your age?';

  @override
  String get whatIsYourHeight => 'What is your height?';

  @override
  String get whatIsYourWeight => 'What is your current weight?';

  @override
  String get whatIsYourGoalWeight => 'What is your goal weight?';

  @override
  String get whatIsYourActivityLevel => 'What is your activity level?';

  @override
  String get howMuchWaterDaily => 'How much water do you drink daily?';

  @override
  String get sedentary => 'Sedentary';

  @override
  String get lightlyActive => 'Lightly Active';

  @override
  String get moderatelyActive => 'Moderately Active';

  @override
  String get veryActive => 'Very Active';

  @override
  String get extremelyActive => 'Extremely Active';

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
  String get oneToTwoGlasses => '1-2 glasses';

  @override
  String get threeToFourGlasses => '3-4 glasses';

  @override
  String get fiveToSixGlasses => '5-6 glasses';

  @override
  String get sevenToEightGlasses => '7-8 glasses';

  @override
  String get moreThanEightGlasses => 'More than 8 glasses';

  @override
  String get mealReminders => 'Meal reminders';

  @override
  String get waterReminders => 'Water reminders';

  @override
  String get workoutReminders => 'Workout reminders';

  @override
  String get progressUpdates => 'Progress updates';

  @override
  String get dailyTips => 'Daily tips';

  @override
  String get youAreAllSet => 'You are all set!';

  @override
  String get welcomeToYourHealthJourney => 'Welcome to your health journey';

  @override
  String get letsGetStarted => 'Let\'s get started!';

  @override
  String get pleaseWait => 'Please wait...';

  @override
  String get cookingUpYourPlan => 'Cooking up your personalized plan';

  @override
  String get analyzingYourData => 'Analyzing your data';

  @override
  String get creatingCustomPlan => 'Creating your custom nutrition plan';

  @override
  String get almostDone => 'Almost done!';

  @override
  String get subscriptionRequired => 'Subscription Required';

  @override
  String get upgradeToUnlock => 'Upgrade to unlock all features';

  @override
  String get startFreeTrial => 'Start Free Trial';

  @override
  String get month => 'Mois';

  @override
  String get year => 'year';

  @override
  String get free => 'Free';

  @override
  String get mostPopular => 'Most Popular';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get back => 'Retour';

  @override
  String get done => 'Terminé';

  @override
  String get error => 'Erreur';

  @override
  String get success => 'Succès';

  @override
  String get warning => 'Avertissement';

  @override
  String get info => 'Info';

  @override
  String get retry => 'Réessayer';

  @override
  String get loading => 'Chargement...';

  @override
  String get noDataAvailable => 'Aucune donnée disponible';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get somethingWentWrong => 'Quelque chose s\'est mal passé';

  @override
  String get internetConnectionRequired => 'Connexion Internet requise';

  @override
  String get pleaseCheckConnection => 'Veuillez vérifier votre connexion Internet';

  @override
  String get restartOnboarding => 'Redémarrer l\'Intégration';

  @override
  String get getStarted => 'Commencer';

  @override
  String get couldNotOpenPlayStore => 'Impossible d\'ouvrir le Play Store';

  @override
  String get errorOpeningPlayStore => 'Erreur lors de l\'ouverture du Play Store';

  @override
  String get remove => 'Supprimer';

  @override
  String get couldNotOpenLink => 'Impossible d\'ouvrir le lien';

  @override
  String get errorOpeningLink => 'Erreur lors de l\'ouverture du lien';

  @override
  String get help => 'Aide';

  @override
  String get name => 'Nom';

  @override
  String get dailyCalorieGoal => 'Objectif Calorique Quotidien';

  @override
  String get manageSubscription => 'Gérer l\'Abonnement';

  @override
  String get deletionFailed => 'Échec de la Suppression';

  @override
  String get dismiss => 'Fermer';

  @override
  String get grantPermission => 'Accorder la Permission';

  @override
  String get littleOrNoExercise => 'Peu ou pas d\'exercice';

  @override
  String get lightExercise => 'Exercice léger/sport 1-3 jours/semaine';

  @override
  String get moderateExercise => 'Exercice modéré/sport 3-5 jours/semaine';

  @override
  String get hardExercise => 'Exercice intense/sport 6-7 jours/semaine';

  @override
  String get share => 'Partager';

  @override
  String get openSettings => 'Ouvrir les Paramètres';

  @override
  String get notificationsForMealLogging => 'Notifications pour les rappels de journalisation des repas';

  @override
  String get notificationsForWaterIntake => 'Notifications pour les rappels de consommation d\'eau';

  @override
  String get notificationsForMindfulWalk => 'Notifications pour les rappels de marche consciente';

  @override
  String get increment => 'Incrémenter';

  @override
  String get enterNewName => 'Entrer le nouveau nom';

  @override
  String get readOurPrivacyPolicy => 'Lire notre politique de confidentialité';

  @override
  String get readOurTermsOfService => 'Lire nos conditions d\'utilisation';

  @override
  String get helpUsCalculateYourHealthGoals => 'Aidez-nous à calculer vos objectifs de santé';

  @override
  String get thisHelpsUsTrackYourProgress => 'Cela nous aide à suivre vos progrès';

  @override
  String get setARealisticGoalForYourJourney => 'Définissez un objectif réaliste pour votre parcours';

  @override
  String get thisHelpsUsPersonalizeYourPlan => 'Cela nous aide à personnaliser votre plan';

  @override
  String get stayingHydratedIsKeyToYourHealth => 'Rester hydraté est essentiel pour votre santé';

  @override
  String get yourFitnessProfileDueToYourAnswers => 'Votre profil de forme physique basé sur vos réponses';

  @override
  String get currentBMI => 'IMC Actuel';

  @override
  String get obese => 'Obèse';

  @override
  String get activityLevelLabel => 'Niveau d\'Activité';

  @override
  String get bloodTypeLabel => 'Groupe Sanguin';

  @override
  String get diabeticLabel => 'Diabétique';

  @override
  String get waterIntakeLabel => 'Consommation d\'Eau';

  @override
  String get heresYourPersonalizedNutritionPlan => 'Voici votre plan nutritionnel personnalisé. Bienvenue dans votre parcours de santé avec Yumie';

  @override
  String get caloriesGoal => 'Objectif Calories';

  @override
  String get carbsGoal => 'Objectif Glucides';

  @override
  String get startNow => 'Commencer Maintenant';

  @override
  String get underweight => 'Insuffisance pondérale';

  @override
  String get normalWeight => 'Poids normal';

  @override
  String get healthy => 'Sain';

  @override
  String get overweight => 'Surpoids';

  @override
  String get avocadoToast => 'Toast à l\'Avocat';

  @override
  String get italianSalad => 'Salade Italienne';

  @override
  String get chickenKatsuRiceBowl => 'Bol de Riz au Poulet Katsu';

  @override
  String get yourTargetWeightIsSetToCurrent => 'Votre poids objectif est défini à votre poids actuel';

  @override
  String get couldNotGenerateYourPlan => 'Impossible de générer votre plan. Veuillez réessayer.';

  @override
  String get somethingWentWrongRestart => 'Quelque chose s\'est mal passé. Veuillez redémarrer le processus d\'intégration.';

  @override
  String get yourBMI => 'Votre IMC :';

  @override
  String get lbs => 'lbs';

  @override
  String get yourActivityLevel => 'Votre niveau d\'activité';

  @override
  String get analyzingFridge => 'Analyse de votre réfrigérateur...';

  @override
  String get aiDetectingFoodItems => 'L\'IA détecte les aliments';

  @override
  String get tryClearerPhoto => 'Essayez de prendre une photo plus claire de votre réfrigérateur';

  @override
  String get generating => 'Génération...';

  @override
  String get premiumStatus => 'Statut Premium';

  @override
  String get thankYouForSupport => 'Merci pour votre soutien ! 💚';

  @override
  String get yourPremiumFeatures => 'Vos fonctionnalités Premium';

  @override
  String get subscriptionError => 'Erreur d\'abonnement';

  @override
  String get unknownErrorOccurred => 'Une erreur inconnue s\'est produite';

  @override
  String get privacyAndAds => 'Confidentialité et publicités';

  @override
  String get reviewAdPreferences => 'Examiner vos préférences publicitaires';

  @override
  String get privacyOptionsNotAvailable => 'Les options de confidentialité ne sont pas disponibles dans votre région.';

  @override
  String get consentFlowCompleted => 'Flux de consentement terminé!';

  @override
  String get appleSignInFailed => 'Échec de la connexion Apple';

  @override
  String get adFailedToShow => 'Échec de l\'affichage de l\'annonce. Veuillez réessayer.';

  @override
  String get adNotLoadedYet => 'L\'annonce n\'est pas encore chargée. Veuillez réessayer.';

  @override
  String get errorRequestingPermissions => 'Erreur lors de la demande de permissions';

  @override
  String get showMore => 'Voir plus';

  @override
  String get showLess => 'Voir moins';

  @override
  String get noSavedCustomMeals => 'Vous n\'avez pas de repas personnalisés sauvegardés.';

  @override
  String get savedCustomMealsPlus => 'Repas personnalisés sauvegardés +';

  @override
  String get customBuilding => 'Créer un Repas Personnalisé';

  @override
  String get enterName => 'Entrez le nom';

  @override
  String get enterFoodName => 'Entrez le nom de l\'aliment';

  @override
  String get congratulationsGoalReached => '🎉 Félicitations !';

  @override
  String get youReachedGoalWeight => 'Vous avez atteint votre poids objectif !';

  @override
  String get switchToMaintenancePlan => 'Maintenant que vous avez atteint votre poids objectif, changeons votre plan nutritionnel pour maintenir votre poids !';

  @override
  String get letsDoIt => 'ALLONS-Y !';

  @override
  String get keepUpGreatWork => 'Continuez votre excellent travail !';

  @override
  String get generatingMaintenancePlan => 'Génération de votre plan de maintenance...';

  @override
  String get maintenancePlanUpdated => '🎉 Votre plan nutritionnel a été mis à jour pour le maintien du poids !';

  @override
  String get failedToGenerateMaintenancePlan => 'Échec de la génération du plan de maintenance. Veuillez réessayer.';

  @override
  String get heresYourMaintenancePlan => 'Voici votre nouveau plan de maintenance !';

  @override
  String get keepThisPlan => 'Garder Ce Plan';

  @override
  String get chooseDifferentGoal => 'Choisir Un Objectif Différent';

  @override
  String get whatsYourNewGoal => 'Quel est votre nouvel objectif ?';

  @override
  String get whatsYourNewTargetWeight => 'Quel est votre nouveau poids objectif ?';

  @override
  String get yumieGeneratingNewPlan => 'Yumie génère votre nouveau plan personnalisé...';

  @override
  String get yourNewPlanReady => 'Votre nouveau plan est prêt !';

  @override
  String get startWithNewPlan => 'Commencer Avec Le Nouveau Plan';

  @override
  String get generateNewPlan => 'Générer Un Nouveau Plan';

  @override
  String get planGenerationLimitReached => 'Vous avez utilisé vos 2 générations de plan pour cette période.';

  @override
  String get waterGoal => 'Objectif d\'Eau';

  @override
  String get glasses => 'verres';

  @override
  String planGenerationInfo(int remaining) {
    return 'Vous pouvez générer $remaining plans personnalisés de plus dans les 14 prochains jours.';
  }

  @override
  String nextPlanAvailable(int days) {
    return 'Réessayez dans $days jours';
  }

  @override
  String get decline => 'Décliner';

  @override
  String get planDeclined => 'Plan décliné';

  @override
  String get accountDeletionWarning => 'Votre compte sera supprimé dans 48 heures. Si vous vous reconnectez à ce compte dans les 48 heures, cela réactivera votre compte et annulera la suppression.';

  @override
  String get accountScheduledForDeletion => 'Compte programmé pour suppression';

  @override
  String get reactivateAccount => 'Réactiver le Compte';

  @override
  String get accountReactivated => 'Bon retour ! Votre compte a été réactivé.';

  @override
  String get accountDeletionCancelled => 'La suppression du compte a été annulée.';

  @override
  String get emailVerificationRequired => 'Vérification Email Requise';

  @override
  String get pleaseVerifyEmail => 'Veuillez vérifier votre adresse email pour continuer';

  @override
  String get verificationEmailSent => 'Nous avons envoyé un lien de vérification à votre email. Veuillez vérifier votre boîte de réception et cliquer sur le lien pour vérifier votre compte.';

  @override
  String get waitingForVerification => 'En attente de vérification email...';

  @override
  String get checkYourEmail => 'Vérifiez votre email et cliquez sur le lien de vérification';

  @override
  String get resendVerificationEmail => 'Renvoyer l\'Email de Vérification';

  @override
  String get verificationLinkAlreadySent => 'Un lien de vérification a déjà été envoyé à cette adresse email. Veuillez vérifier votre boîte de réception ou attendre quelques minutes avant d\'en demander un nouveau.';

  @override
  String get emailVerified => 'Email vérifié avec succès!';

  @override
  String get emailNotVerified => 'Email pas encore vérifié. Veuillez vérifier votre boîte de réception.';

  @override
  String get changeEmail => 'Changer l\'Email';

  @override
  String get continueToApp => 'Continuer vers l\'App';

  @override
  String get failedToSendVerificationEmail => 'Échec de l\'envoi de l\'email de vérification';

  @override
  String get failedToResendVerificationEmail => 'Échec du renvoi de l\'email de vérification';

  @override
  String get errorCheckingVerification => 'Erreur lors de la vérification du statut';

  @override
  String get helloIAmYumie => 'Bonjour, je suis Yumie ! Enregistrez un repas pour commencer votre série aujourd\'hui !';

  @override
  String get happyBirthday => '🎉 Joyeux Anniversaire !';

  @override
  String birthdayMessage(int age) {
    return 'J\'espère que vous passez une merveilleuse journée ! Vous avez maintenant $age ans.';
  }

  @override
  String get selectBirthday => 'Sélectionnez votre anniversaire';

  @override
  String get day => 'Jour';

  @override
  String get accountAlreadyExists => 'Le compte existe déjà';

  @override
  String get accountExistsMessage => 'Un compte avec cette adresse e-mail existe déjà. Voulez-vous vous connecter à la place ?';

  @override
  String get accountUsesDifferentSignIn => 'Le compte utilise une méthode de connexion différente';

  @override
  String get emailSignedUpWithGoogle => 'Cet e-mail est déjà inscrit avec Google. Veuillez utiliser \"Se connecter avec Google\" à la place.';

  @override
  String get emailSignedUpWithPassword => 'Cet e-mail est déjà inscrit avec e-mail et mot de passe. Veuillez vous connecter en utilisant votre mot de passe.';

  @override
  String get useGoogleSignIn => 'Utiliser la connexion Google';

  @override
  String get signInWithEmail => 'Se connecter avec e-mail';

  @override
  String get signInSuccessful => 'Connexion réussie !';

  @override
  String get signUpSuccessful => 'Inscription réussie !';

  @override
  String get emailVerifiedWelcome => 'Email vérifié ! Bienvenue !';
}
