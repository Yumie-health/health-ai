// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get settings => 'Einstellungen';

  @override
  String get preferences => 'Präferenzen';

  @override
  String get darkMode => 'Dunkler Modus';

  @override
  String get enableDarkTheme => 'Dunkles Design aktivieren';

  @override
  String get useMetricUnits => 'Metrische Einheiten verwenden';

  @override
  String get unitsSubtitle => 'kg/cm verwenden (an) oder lb/ft (aus)';

  @override
  String get language => 'Sprache';

  @override
  String get selectLanguage => 'App-Sprache auswählen';

  @override
  String get habitNotifications => 'Gewohnheits-Benachrichtigungen';

  @override
  String get mealLoggingPrompts => 'Mahlzeiten-Protokollierung';

  @override
  String get mealLoggingPromptsSubtitle => 'Erhalten Sie Erinnerungen, Ihre Mahlzeiten zu protokollieren';

  @override
  String get waterIntakeReminders => 'Wasseraufnahme-Erinnerungen';

  @override
  String get waterIntakeRemindersSubtitle => 'Erhalten Sie Erinnerungen, Wasser zu trinken';

  @override
  String get mindfulWalksReminders => 'Achtsame Spaziergänge-Erinnerungen';

  @override
  String get mindfulWalksRemindersSubtitle => 'Erhalten Sie Erinnerungen, einen achtsamen Spaziergang zu machen';

  @override
  String get momentOfCalmAfterMeals => 'Moment der Ruhe nach Mahlzeiten';

  @override
  String get momentOfCalmAfterMealsSubtitle => 'Zeigen Sie ein beruhigendes Popup nach dem Protokollieren einer Mahlzeit';

  @override
  String get welcomeBack => 'Willkommen zurück!';

  @override
  String get trackNutritionToday => 'Lassen Sie uns heute Ihre Ernährung verfolgen';

  @override
  String get subtitleAfternoon => 'Perfekte Zeit, dein Mittagessen zu protokollieren und im Gleichgewicht zu bleiben.';

  @override
  String get subtitleEvening => 'Bleib heute Abend auf Kurs – protokolliere deine Mahlzeiten.';

  @override
  String get subtitleNight => 'Schließe deinen Tag ab – vergiss nicht, deine heutigen Mahlzeiten zu protokollieren.';

  @override
  String get streakNearEndingTitle => 'Halte deine Serie 🔥';

  @override
  String get streakNearEndingBody => 'Deine Serie endet bald. Protokolliere heute eine Mahlzeit, um sie zu erhalten!';

  @override
  String get streakNearEndingTitle2 => 'Fast geschafft! 🔥';

  @override
  String get streakNearEndingBody2 => 'Nur noch ein paar Stunden. Protokolliere eine Mahlzeit, um deine Serie zu retten!';

  @override
  String get streakEndedTitle => 'Serie beendet';

  @override
  String get streakEndedBody => 'Deine Serie ist beendet. Protokolliere eine Mahlzeit, um sie neu zu starten und wieder aufzubauen!';

  @override
  String get streakActive => 'Serie aktiv';

  @override
  String get streakInactive => 'Serie inaktiv';

  @override
  String get currentStreak => 'Aktuelle Serie';

  @override
  String get entriesInStreak => 'Einträge in der Serie';

  @override
  String get days => 'Tage';

  @override
  String get startedOn => 'Begonnen am';

  @override
  String get logMealToStartStreak => 'Protokolliere heute eine Mahlzeit, um deine Serie zu starten';

  @override
  String get nutritionSummary => 'Ernährungszusammenfassung';

  @override
  String get setCalorieAndMacroGoals => 'Setzen Sie Ihre Kalorien- und Makroziele auf der Ernährungsplan-Seite.';

  @override
  String get protein => 'Proteine';

  @override
  String get carbs => 'Kohlenhydrate';

  @override
  String get fat => 'Fett';

  @override
  String get calories => 'Kalorien';

  @override
  String get quickActions => 'Schnellaktionen';

  @override
  String get logMeal => 'Mahlzeit protokollieren';

  @override
  String get trackYourFood => 'Ihr Essen verfolgen';

  @override
  String get scan => 'Scannen';

  @override
  String get barcode => 'Barcode';

  @override
  String get analyzeYourFood => 'Ihr Essen analysieren';

  @override
  String get todaysMeals => 'Heutige Mahlzeiten';

  @override
  String get viewAll => 'Alle anzeigen';

  @override
  String get noMealsLoggedForThisDay => 'Keine Mahlzeiten für diesen Tag protokolliert.';

  @override
  String get nutritionalPlan => 'Ernährungsplan';

  @override
  String get weightAnalytics => 'Gewichts-Analytics';

  @override
  String get toGoal => 'ZUM ZIEL';

  @override
  String get remaining => 'verbleibend';

  @override
  String get weeklyRate => 'WÖCHENTLICHE RATE';

  @override
  String get weeklyLoss => 'wöchentlicher Verlust';

  @override
  String get starting => 'START';

  @override
  String get current => 'AKTUELL';

  @override
  String get today => 'heute';

  @override
  String get targetLabel => 'ZIEL';

  @override
  String get goalWeight => 'Zielgewicht';

  @override
  String get eta => 'ETA';

  @override
  String get sinceStart => 'seit Beginn';

  @override
  String get expectationsDisclaimer => 'Diese Erwartungen basieren auf deinem aktuellen Trend und können sich ändern, wenn du neue Gewichte protokollierst.';

  @override
  String get loseVerb => 'abnehmen';

  @override
  String get gainVerb => 'zunehmen';

  @override
  String expectationBlurb(Object direction, Object eta, Object rate, Object remaining, Object unit) {
    return 'Basierend auf deinem aktuellen Trend wirst du voraussichtlich etwa $rate $unit pro Woche $direction. In diesem Tempo dauert es ungefähr $eta, um dein Ziel zu erreichen. Es bleiben $remaining $unit übrig.';
  }

  @override
  String get healthAwareness => 'Gesundheitsbewusstsein';

  @override
  String get planSettings => 'Plan-Einstellungen';

  @override
  String get featureComingSoon => 'Diese Funktion kommt bald!';

  @override
  String get ok => 'OK';

  @override
  String get rateUsOnGoogle => 'Bewerten Sie uns auf Google';

  @override
  String get comingSoon => 'Demnächst verfügbar!';

  @override
  String get ratingOnGoogleAvailableAfterRelease => 'Bewertung auf Google wird nach dem Release verfügbar sein.';

  @override
  String get shareWithFriends => 'Mit Freunden teilen';

  @override
  String get sharingAvailableAfterRelease => 'Teilen wird nach dem Release verfügbar sein.';

  @override
  String get resetPassword => 'Passwort zurücksetzen';

  @override
  String get close => 'Schließen';

  @override
  String get sendResetLink => 'Reset-Link senden';

  @override
  String get send => 'Senden';

  @override
  String get resend => 'Erneut senden';

  @override
  String get helpSupport => 'Hilfe & Support';

  @override
  String get legal => 'Rechtliches';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get termsOfService => 'Nutzungsbedingungen';

  @override
  String get apiDocumentation => 'API-Dokumentation';

  @override
  String get needAssistanceContactSupport => 'Benötigen Sie Hilfe? Kontaktieren Sie unser Support-Team:';

  @override
  String get testWebURL => 'Test-Web-URL';

  @override
  String get testSimpleMailto => 'Einfacher Mailto-Test';

  @override
  String get logOut => 'Abmelden';

  @override
  String get areYouSureYouWantToLogOut => 'Sind Sie sicher, dass Sie sich abmelden möchten?';

  @override
  String get no => 'Nein';

  @override
  String get yes => 'Ja';

  @override
  String get commonQuestions => 'Häufige Fragen';

  @override
  String get momentOfCalm => 'Moment der Ruhe';

  @override
  String get practiceMindfulEating => 'Nehmen Sie sich einen Moment Zeit, um Ihre Mahlzeit zu schätzen und achtsames Essen zu praktizieren.';

  @override
  String get howOldAreYou => 'Wie alt sind Sie?';

  @override
  String get personalizeExperience => 'Dies hilft uns, Ihre Erfahrung zu personalisieren';

  @override
  String get yourHeight => 'Ihre Größe';

  @override
  String get yourGoalWeight => 'Ihr Zielgewicht';

  @override
  String get setRealisticGoal => 'Setzen Sie ein realistisches Ziel für Ihre Reise';

  @override
  String get allSet => 'Sie sind bereit! 🎉';

  @override
  String get personalizedNutritionPlan => 'Hier ist Ihr personalisierter Ernährungsplan. Willkommen zu Ihrer Gesundheitsreise mit Yumie!';

  @override
  String get whatIsYourBloodType => 'Welche Blutgruppe haben Sie?';

  @override
  String get personalizeHealthInsights => 'Dies hilft uns, Ihre Gesundheitserkenntnisse zu personalisieren.';

  @override
  String get whatIsYourSex => 'Was ist Ihr Geschlecht?';

  @override
  String get personalizeNutritionPlan => 'Dies hilft uns, Ihren Ernährungsplan zu personalisieren.';

  @override
  String get home => 'Startseite';

  @override
  String get food => 'Essen';

  @override
  String get coach => 'Coach';

  @override
  String get profile => 'Profil';

  @override
  String get log => 'Protokoll';

  @override
  String get myMeals => 'Meine Mahlzeiten';

  @override
  String get suggestedMeals => 'Vorgeschlagene Mahlzeiten';

  @override
  String get monthly => 'Monatlich';

  @override
  String get weekly => 'Wöchentlich';

  @override
  String get breakfast => 'Frühstück';

  @override
  String get lunch => 'Mittagessen';

  @override
  String get dinner => 'Abendessen';

  @override
  String get snack => 'Snack';

  @override
  String get reviewMeal => 'Mahlzeit überprüfen';

  @override
  String get chat => 'Chat';

  @override
  String get insights => 'Erkenntnisse';

  @override
  String get clearChat => 'Chat löschen';

  @override
  String get coachWelcome => 'Hallo! Ich bin Yumie, Ihr Ernährungscoach. Wie kann ich Ihnen heute helfen?\n\nFragen Sie Yumie nach gesunden Rezepten, Mahlzeitenplänen oder Ernährungstipps!';

  @override
  String get refreshInsight => 'Erkenntnis aktualisieren';

  @override
  String get healthInsights => 'Gesundheitserkenntnisse';

  @override
  String get noInsightAvailable => 'Keine Erkenntnis verfügbar.';

  @override
  String get dinnerIdeas => 'Abendessen-Ideen';

  @override
  String get calorieCheck => 'Kalorien-Check';

  @override
  String get proteinSnacks => 'Protein-Snacks';

  @override
  String get dietTips => 'Ernährungstipps';

  @override
  String get typeYourMessage => 'Geben Sie Ihre Nachricht ein...';

  @override
  String get yumie => 'Yumie';

  @override
  String get askAboutMeals => 'Fragen Sie nach Mahlzeiten & Ernährung';

  @override
  String get coachQuick1 => 'Was sollte ich heute essen?';

  @override
  String get coachQuick2 => 'Analysieren Sie meine letzte Mahlzeit';

  @override
  String get coachQuick3 => 'Helfen Sie mir, meine Woche zu planen';

  @override
  String get yumieThinking => 'Yumie denkt nach...';

  @override
  String get bmi => 'BMI';

  @override
  String get target => 'Ziel';

  @override
  String get weight => 'Gewicht';

  @override
  String get age => 'Alter';

  @override
  String get height => 'Größe';

  @override
  String get targetWeight => 'Zielgewicht';

  @override
  String get calorieGoal => 'Kalorienziel';

  @override
  String get proteinGoal => 'Proteinziel';

  @override
  String get carbGoal => 'Kohlenhydratziel';

  @override
  String get fatGoal => 'Fettziel';

  @override
  String get waterIntake => 'Wasseraufnahme';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get undo => 'Rückgängig';

  @override
  String get notSet => 'Nicht gesetzt';

  @override
  String get uploadNew => 'Neu hochladen';

  @override
  String get delete => 'Löschen';

  @override
  String get editName => 'Namen bearbeiten';

  @override
  String get bloodType => 'Blutgruppe';

  @override
  String get areYouDiabetic => 'Sind Sie diabetisch?';

  @override
  String get healthAwarenessUpdated => 'Gesundheitsbewusstsein aktualisiert!';

  @override
  String get takeMomentToAppreciate => 'Nehmen Sie sich einen Moment Zeit, um Ihre Mahlzeit zu schätzen und achtsames Essen zu praktizieren.';

  @override
  String get continueButton => 'Weiter';

  @override
  String get mealSaved => 'Mahlzeit gespeichert!';

  @override
  String get noRecentFoods => 'Keine kürzlichen Lebensmittel.';

  @override
  String get buildCustomMeal => 'Benutzerdefinierte Mahlzeit erstellen';

  @override
  String get mealName => 'Mahlzeitname';

  @override
  String get searchOrEnterFoodName => 'Suchen oder Lebensmittelname eingeben';

  @override
  String get ingredients => 'Zutaten';

  @override
  String get addIngredient => 'Zutat hinzufügen';

  @override
  String get myFoods => 'Meine Lebensmittel';

  @override
  String get noCustomFoods => 'Sie haben noch keine benutzerdefinierten Lebensmittel gespeichert';

  @override
  String get addCustomFood => 'Benutzerdefiniertes Lebensmittel hinzufügen';

  @override
  String get editCustomMeal => 'Benutzerdefinierte Mahlzeit bearbeiten';

  @override
  String get clearAll => 'Alles löschen';

  @override
  String get foodName => 'Lebensmittelname';

  @override
  String get saveMeal => 'Mahlzeit speichern';

  @override
  String get customizeMeal => 'Mahlzeit anpassen';

  @override
  String get hideIngredients => 'Zutaten ausblenden';

  @override
  String get showIngredients => 'Zutaten anzeigen';

  @override
  String get ingredientsColon => 'Zutaten:';

  @override
  String get noIngredientsListed => 'Keine Zutaten aufgelistet.';

  @override
  String get recent => 'Kürzlich';

  @override
  String get meal => 'MAHLZEIT';

  @override
  String get fridge => 'Kühlschrank';

  @override
  String get placeFoodInFrame => 'Platzieren Sie das Lebensmittel im Rahmen';

  @override
  String get placeBarcodeInFrame => 'Richte den Barcode innerhalb des Rahmens aus';

  @override
  String get placeFridgeInFrame => 'Richte den Kühlschrank innerhalb des Rahmens aus';

  @override
  String get productNotFound => 'Produkt nicht gefunden';

  @override
  String get safetyUnsafe => 'Nicht sicher';

  @override
  String get safetyGood => 'Alles gut';

  @override
  String get badgeNutriScore => 'Nutri-Score';

  @override
  String get badgeNova => 'NOVA';

  @override
  String get allergensTitle => 'Allergene';

  @override
  String get contains => 'Enthält';

  @override
  String get allergensNone => 'Keine Allergene aufgeführt';

  @override
  String get serving => 'Portion';

  @override
  String get kcalPer100g => 'kcal/100g';

  @override
  String get sugar => 'Sugar';

  @override
  String get satFat => 'Ges. Fett';

  @override
  String get salt => 'Salt';

  @override
  String get ingredientsTitle => 'Zutaten';

  @override
  String get riskAllergen => 'Allergenrisiko';

  @override
  String get riskUltraProcessed => 'Ultraverarbeitet (NOVA 4)';

  @override
  String get riskHighAdditives => 'Viele Zusatzstoffe';

  @override
  String get riskLowNutri => 'Niedriger Nutri‑Score';

  @override
  String get riskVegan => 'Vegan freundlich';

  @override
  String get riskVegetarian => 'Vegetarisch';

  @override
  String get riskLooksGood => 'Sieht gut aus';

  @override
  String get retakeScan => 'Scan wiederholen';

  @override
  String get previewFullImage => 'Vollbildvorschau';

  @override
  String get discard => 'Verwerfen';

  @override
  String get upgradeToPremium => 'Zu Premium upgraden';

  @override
  String get getUnlimitedScans => 'Erhalten Sie unbegrenzte Scans und mehr!';

  @override
  String get getUnlimitedSearches => 'Erhalten Sie unbegrenzte Suchen und mehr!';

  @override
  String get upgradePlan => 'Plan upgraden';

  @override
  String get watchAdForScan => 'Werbung für Scan ansehen';

  @override
  String get watchAdForSearch => 'Werbung für Suche ansehen';

  @override
  String get generateMeal => 'Mahlzeit generieren';

  @override
  String get detectedFridgeItems => 'Erkannte Kühlschrankartikel';

  @override
  String get noFridgeItemsDetected => 'Keine Kühlschrankartikel erkannt.';

  @override
  String get searchResults => 'Suchergebnisse';

  @override
  String get searchingFor => 'Suche nach';

  @override
  String get noResultsFoundFor => 'Keine Ergebnisse gefunden für';

  @override
  String get count => 'Anzahl';

  @override
  String get servings => 'Portionen';

  @override
  String get fluidOunces => 'Flüssigunzen';

  @override
  String get quantity => 'Menge';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get ingredient => 'ZUTAT';

  @override
  String get drink => 'GETRÄNK';

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
  String get inches => 'Zoll';

  @override
  String get cup => 'Tasse';

  @override
  String get tbsp => 'EL';

  @override
  String get tsp => 'TL';

  @override
  String get ml => 'ml';

  @override
  String get l => 'l';

  @override
  String get upgradeToPremiumTitle => 'Zu Premium upgraden';

  @override
  String get premiumFeatures => 'Premium-Funktionen';

  @override
  String get unlimitedScans => 'Unbegrenzte Scans';

  @override
  String get aiNutritionCoach => 'KI-Ernährungscoach';

  @override
  String get detailedAnalytics => 'Detaillierte Analysen';

  @override
  String get personalizedMealPlans => 'Personalisierte Mahlzeitenpläne';

  @override
  String get noAdvertisements => 'Keine Werbung';

  @override
  String get yearlyPremium => 'Jährliches Premium';

  @override
  String get monthlyPremium => 'Monatliches Premium';

  @override
  String savePercent(Object percent) {
    return 'Sparen Sie $percent%';
  }

  @override
  String get perYear => '/Jahr';

  @override
  String get perMonth => '/Monat';

  @override
  String get popular => 'BELIEBT';

  @override
  String get maybeLater => 'Vielleicht später';

  @override
  String get welcomeToYumie => '🎉 Willkommen bei Yumie!';

  @override
  String get unlockPremiumFeatures => 'Premium-Funktionen freischalten';

  @override
  String get getMostOutOfHealthJourney => 'Hol das Beste aus deiner Gesundheitsreise mit unbegrenztem Zugang!';

  @override
  String get unlimitedScansAICoaching => 'Schalte unbegrenzte Scans, KI-Coaching und personalisierte Mahlzeitenpläne frei!';

  @override
  String get subscribe => 'Abonnieren';

  @override
  String get foodNameLabel => 'Lebensmittelname';

  @override
  String get managePermissions => 'Berechtigungen verwalten';

  @override
  String get cameraNotificationsAndMore => 'Kamera, Benachrichtigungen und mehr';

  @override
  String get deleteMeal => 'Mahlzeit löschen';

  @override
  String get areYouSureDeleteMeal => 'Sind Sie sicher, dass Sie diese Mahlzeit löschen möchten?';

  @override
  String get unknown => 'Unbekannt';

  @override
  String get servings1 => 'Portionen 1';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get ignoreFood => 'Lebensmittel ignorieren';

  @override
  String get addComponent => 'Komponente hinzufügen';

  @override
  String get components => 'Komponenten';

  @override
  String get recentFoods => 'Kürzliche Lebensmittel';

  @override
  String get logWeightChange => 'Gewichtsänderung protokollieren';

  @override
  String get lost => 'Verloren';

  @override
  String get gained => 'Gewonnen';

  @override
  String get googleSignInHelp => 'Google-Anmeldung Hilfe';

  @override
  String get couldNotOpenTermsOfService => 'Nutzungsbedingungen konnten nicht geöffnet werden';

  @override
  String get couldNotOpenPrivacyPolicy => 'Datenschutzrichtlinie konnte nicht geöffnet werden';

  @override
  String get errorSavingProfile => 'Fehler beim Speichern des Profils';

  @override
  String get completeYourProfile => 'Vervollständigen Sie Ihr Profil';

  @override
  String get saveAndContinue => 'Speichern & Weiter';

  @override
  String get pleasSignIn => 'Bitte melden Sie sich an.';

  @override
  String get noFoodLogsYet => 'Noch keine Lebensmittelprotokolle.';

  @override
  String get healthAIFoodLog => 'HealthAI - Lebensmittelprotokoll';

  @override
  String get addLog => 'Protokoll hinzufügen';

  @override
  String get unableToShareAtThisTime => 'Teilen zu diesem Zeitpunkt nicht möglich. Bitte versuchen Sie es erneut.';

  @override
  String get failedToUpdatePhoto => 'Fehler beim Aktualisieren des Fotos';

  @override
  String get changeProfileName => 'Profilnamen ändern';

  @override
  String get failedToUpdateName => 'Fehler beim Aktualisieren des Namens';

  @override
  String get profileUpdatedSuccessfully => 'Profil erfolgreich aktualisiert';

  @override
  String get errorUpdatingProfile => 'Fehler beim Aktualisieren des Profils';

  @override
  String get editGoals => 'Ziele bearbeiten';

  @override
  String get goalsUpdatedSuccessfully => 'Ziele erfolgreich aktualisiert';

  @override
  String get errorUpdatingGoals => 'Fehler beim Aktualisieren der Ziele';

  @override
  String get couldNotOpenWebsite => 'Website konnte nicht geöffnet werden';

  @override
  String get errorOpeningWebsite => 'Fehler beim Öffnen der Website';

  @override
  String get english => 'Englisch';

  @override
  String get arabic => 'Arabisch';

  @override
  String get spanish => 'Spanisch';

  @override
  String get reviewMealTitle => 'Mahlzeit überprüfen';

  @override
  String get startingWeight => 'Anfangsgewicht';

  @override
  String get appPermissions => 'App-Berechtigungen';

  @override
  String get permissionStatus => 'Berechtigungsstatus';

  @override
  String get manageAppPermissions => 'Verwalten Sie App-Berechtigungen, um sicherzustellen, dass alle Funktionen ordnungsgemäß funktionieren';

  @override
  String get camera => 'Kamera';

  @override
  String get scanFoodItems => 'Lebensmittel scannen und Fotos von Mahlzeiten machen';

  @override
  String get photoLibrary => 'Fotos';

  @override
  String get saveScannedImages => 'Gescannte Bilder speichern und Fotos auswählen';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get sendMealReminders => 'Mahlzeiten-Erinnerungen und Gesundheitswarnungen senden';

  @override
  String get needHelp => 'Brauchen Sie Hilfe?';

  @override
  String get permanentlyDeniedHelp => 'Wenn Berechtigungen dauerhaft verweigert werden, können Sie sie in den Geräteeinstellungen aktivieren';

  @override
  String get openDeviceSettings => 'Geräteeinstellungen öffnen';

  @override
  String get goodMorning => 'Guten Morgen';

  @override
  String get goodAfternoon => 'Guten Tag';

  @override
  String get goodEvening => 'Guten Abend';

  @override
  String get goodNight => 'Gute Nacht';

  @override
  String get ounces => 'Unzen';

  @override
  String get january => 'Januar';

  @override
  String get february => 'Februar';

  @override
  String get march => 'März';

  @override
  String get april => 'April';

  @override
  String get may => 'Mai';

  @override
  String get june => 'Juni';

  @override
  String get july => 'Juli';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'Oktober';

  @override
  String get november => 'November';

  @override
  String get december => 'Dezember';

  @override
  String get trackYourNutrition => 'Verfolgen Sie Ihre Ernährung';

  @override
  String get messages => 'Nachrichten';

  @override
  String get subscribeForDailyInsights => 'Für tägliche Erkenntnisse abonnieren';

  @override
  String get getPersonalizedHealthInsights => 'Erhalten Sie personalisierte Gesundheitserkenntnisse basierend auf Ihrem vollständigen Profil';

  @override
  String get upgradeDescription => 'Erhalten Sie unbegrenzte Scans, Suchen und KI-gestützte Erkenntnisse';

  @override
  String get unlimitedFoodScans => 'Unbegrenzte Lebensmittel-Scans';

  @override
  String get unlimitedFoodSearches => 'Unbegrenzte Lebensmittel-Suchen';

  @override
  String get unlimitedAICoachMessages => 'Unbegrenzte KI-Coach-Nachrichten';

  @override
  String get dailyHealthInsights => 'Tägliche Gesundheitserkenntnisse';

  @override
  String get logWaterIntake => 'Wasseraufnahme protokollieren';

  @override
  String get add => 'Hinzufügen';

  @override
  String get freemium => 'Freemium';

  @override
  String get premium => 'Premium';

  @override
  String get chooseYourPlan => 'Wählen Sie Ihren Plan';

  @override
  String get water => 'Wasser';

  @override
  String get resetPasswordDescription => 'Ein Passwort-Reset-Link wird an Ihre E-Mail gesendet';

  @override
  String get deleteAccount => 'Konto löschen';

  @override
  String get deleteAccountDescription => 'Ihr Konto und alle Daten dauerhaft löschen';

  @override
  String get confirmDeleteAccount => 'Sind Sie sicher, dass Sie Ihr Konto löschen möchten?';

  @override
  String get deleteAccountWarning => 'Diese Aktion kann nicht rückgängig gemacht werden. Alle Ihre Daten einschließlich Mahlzeiten, Fortschritt und Einstellungen werden dauerhaft gelöscht.';

  @override
  String get typeDeleteToConfirm => 'Geben Sie \"LÖSCHEN\" ein, um zu bestätigen';

  @override
  String get deleteAccountFinalConfirmation => 'LÖSCHEN';

  @override
  String get accountDeleted => 'Konto gelöscht';

  @override
  String get errorDeletingAccount => 'Fehler beim Löschen des Kontos';

  @override
  String get totalNutrition => 'Gesamte Ernährung';

  @override
  String get unlockUnlimitedScans => 'Schalte unbegrenzte Scans, KI-Coaching und\npersonalisierte Mahlzeitenpläne frei';

  @override
  String get unlimitedFoodScanning => 'Unbegrenztes Lebensmittel-Scannen';

  @override
  String get yearPrice => 'Jahr/49,99€';

  @override
  String get monthPrice => 'Monat/7,99€';

  @override
  String get save37 => 'Sparen Sie 37%';

  @override
  String get youArePremium => 'Sie sind Premium!';

  @override
  String get yumiePremiumMonthly => 'Yumie™ Premium Monatlich';

  @override
  String get yumiePremiumYearly => 'Yumie™ Premium Jährlich';

  @override
  String get restorePurchases => 'Käufe wiederherstellen';

  @override
  String get checkingForPurchases => 'Suche nach vorhandenen Käufen...';

  @override
  String get purchasesRestored => 'Käufe erfolgreich wiederhergestellt!';

  @override
  String get noPurchasesFound => 'Keine vorherigen Käufe gefunden';

  @override
  String get restoreFailed => 'Wiederherstellung der Käufe fehlgeschlagen. Bitte versuchen Sie es erneut.';

  @override
  String get restoreInProgress => 'Käufe werden wiederhergestellt...';

  @override
  String get bySubscribing => 'Durch das Abonnieren stimmen Sie unseren Nutzungsbedingungen und der Datenschutzrichtlinie zu. Abonnements verlängern sich automatisch, es sei denn, sie werden gekündigt';

  @override
  String get permissionsComplete => 'Berechtigungen vollständig!';

  @override
  String get enterYourPassword => 'Geben Sie Ihr Passwort ein';

  @override
  String get securityAlerts => 'Sicherheitswarnungen';

  @override
  String get manageSessions => 'Sitzungen verwalten';

  @override
  String get selectLanguageTitle => 'Sprache auswählen';

  @override
  String get chooseYourPreferredLanguage => 'Wählen Sie Ihre bevorzugte Sprache für die App';

  @override
  String get languageChangedTo => 'Sprache geändert zu';

  @override
  String get activeSessions => 'Aktive Sitzungen';

  @override
  String get thisDevice => 'Dieses Gerät';

  @override
  String get sessionRevoked => 'Sitzung widerrufen';

  @override
  String get allOtherSessionsSignedOut => 'Alle anderen Sitzungen abgemeldet';

  @override
  String get signOutAllOthers => 'Alle anderen abmelden';

  @override
  String get noSecurityAlerts => 'Keine Sicherheitswarnungen';

  @override
  String get passwordStrengthWeak => 'Schwach';

  @override
  String get passwordStrengthFair => 'Mittel';

  @override
  String get passwordStrengthGood => 'Gut';

  @override
  String get passwordStrengthStrong => 'Stark';

  @override
  String get passwordStrengthVeryStrong => 'Sehr stark';

  @override
  String get addLowercaseLetters => 'Kleinbuchstaben hinzufügen';

  @override
  String get addUppercaseLetters => 'Großbuchstaben hinzufügen';

  @override
  String get addNumbers => 'Zahlen hinzufügen';

  @override
  String get addSpecialCharacters => 'Sonderzeichen hinzufügen (!@#\$%^&*)';

  @override
  String get avoidCommonPatterns => 'Häufige Muster vermeiden';

  @override
  String get requiresAtLeast8Characters => 'Erfordert mindestens 8 Zeichen';

  @override
  String get tooManySignInAttempts => 'Zu viele Anmeldeversuche. Bitte versuchen Sie es später erneut.';

  @override
  String get tooManySignUpAttempts => 'Zu viele Registrierungsversuche. Bitte versuchen Sie es später erneut.';

  @override
  String get tooManyPasswordResetRequests => 'Zu viele Passwort-Reset-Anfragen. Bitte versuchen Sie es später erneut.';

  @override
  String get multipleFailedSignInAttempts => 'Mehrere fehlgeschlagene Anmeldeversuche';

  @override
  String get excessivePasswordResetRequests => 'Übermäßige Passwort-Reset-Anfragen';

  @override
  String get suspiciousActivityDetected => 'Verdächtige Aktivität erkannt';

  @override
  String get riskLevelMedium => 'MITTEL';

  @override
  String get riskLevelHigh => 'HOCH';

  @override
  String get welcomeToYumiePermissions => 'Willkommen bei Yumie';

  @override
  String get provideBestExperience => 'Um Ihnen die beste Erfahrung zu bieten, benötigen wir einige Berechtigungen';

  @override
  String get grantPermissions => 'Berechtigungen gewähren';

  @override
  String get skipForNow => 'Für jetzt überspringen';

  @override
  String get denied => 'Verweigert';

  @override
  String get granted => 'Gewährt';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get signUpToGetStarted => 'Registrieren Sie sich, um mit Yumie zu beginnen';

  @override
  String get fullName => 'Vollständiger Name';

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get agreeToTerms => 'und Nutzungsbedingungen Ich akzeptiere die Datenschutzrichtlinie';

  @override
  String get alreadyHaveAccount => 'Haben Sie bereits ein Konto?';

  @override
  String get signIn => 'Anmelden';

  @override
  String get signUp => 'Registrieren';

  @override
  String get signInToAccessAccount => 'Melden Sie sich an, um auf Ihr Konto zuzugreifen';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get dontHaveAccount => 'Haben Sie kein Konto?';

  @override
  String get signUpWithGoogle => 'Mit Google registrieren';

  @override
  String get signInWithGoogle => 'Mit Google anmelden';

  @override
  String get signUpWithApple => 'Mit Apple registrieren';

  @override
  String get signInWithApple => 'Mit Apple anmelden';

  @override
  String get resetPasswordTitle => 'Passwort zurücksetzen';

  @override
  String get enterEmailForReset => 'Geben Sie Ihre E-Mail-Adresse ein, um einen Passwort-Reset-Link zu erhalten';

  @override
  String get emailAddress => 'E-Mail-Adresse';

  @override
  String get rateUsOn => 'Bewerten Sie uns auf';

  @override
  String get deleteAccountTitle => 'Konto löschen';

  @override
  String get deleteAccountWarningTitle => 'Diese Aktion ist dauerhaft und kann nicht rückgängig gemacht werden';

  @override
  String get deleteAccountDataList => 'Wenn Sie Ihr Konto löschen, werden wir dauerhaft entfernen:';

  @override
  String get allMealLogsAndNutrition => 'Alle Ihre Mahlzeitenprotokolle und Ernährungsdaten';

  @override
  String get profileAndPersonalInfo => 'Ihr Profil und persönliche Informationen';

  @override
  String get allUploadedPhotos => 'Alle hochgeladenen Fotos und Dateien';

  @override
  String get customMealsAndRecipes => 'Ihre benutzerdefinierten Mahlzeiten und Rezepte';

  @override
  String get allAppPreferences => 'Alle App-Einstellungen und Präferenzen';

  @override
  String get activeSessionsAllDevices => 'Aktive Sitzungen auf allen Geräten';

  @override
  String get exportDataWarning => 'Stellen Sie sicher, dass Sie alle Daten exportieren, die Sie behalten möchten, bevor Sie fortfahren';

  @override
  String get understandActionPermanent => 'Ich verstehe, dass diese Aktion dauerhaft ist';

  @override
  String get typeDeleteHere => 'Geben Sie LÖSCHEN hier ein';

  @override
  String get deleteForever => 'Für immer löschen';

  @override
  String get noSecurityAlertsFound => 'Keine Sicherheitswarnungen';

  @override
  String get yourAccountLooksGood => 'Ihr Konto sieht gut aus! Keine verdächtige Aktivität erkannt.';

  @override
  String get manageActiveSessionsAcrossDevices => 'Verwalten Sie Ihre aktiven Sitzungen auf verschiedenen Geräten';

  @override
  String get noActiveSessionsFound => 'Keine aktiven Sitzungen gefunden';

  @override
  String get signOutAllOtherSessions => 'Alle anderen abmelden';

  @override
  String get aiSearch => 'KI-Suche';

  @override
  String get aiSearchDescription => 'Suchen Sie nach Lebensmitteln mit KI';

  @override
  String get noIngredientsListedText => 'Keine Zutaten aufgelistet';

  @override
  String get breakfastTime => 'Frühstückszeit';

  @override
  String get lunchTime => 'Mittagszeit';

  @override
  String get dinnerTime => 'Abendessenszeit';

  @override
  String get snackTime => 'Snack-Zeit';

  @override
  String get deletingYourAccount => 'Ihr Konto wird gelöscht...';

  @override
  String get thisMayTakeAFewMoments => 'Dies kann einen Moment dauern';

  @override
  String get redirectingToSignIn => 'Weiterleitung zur Anmeldung...';

  @override
  String get accountSuccessfullyDeleted => 'Konto erfolgreich gelöscht';

  @override
  String get pleaseCloseAndRestartApp => 'Bitte schließen und starten Sie die App neu, um fortzufahren.';

  @override
  String get restartApp => 'App neu starten';

  @override
  String get cameraAccess => 'Kamerazugriff';

  @override
  String get cameraAccessMessage => 'Yumie benötigt Kamerazugriff, um Lebensmittel zu scannen und Ihnen beim genauen Protokollieren Ihrer Mahlzeiten zu helfen.';

  @override
  String get photoLibraryAccess => 'Fotobibliothek-Zugriff';

  @override
  String get photoLibraryAccessMessage => 'Yumie benötigt Zugriff auf Ihre Fotobibliothek, um gescannte Bilder zu speichern und Fotos für die Mahlzeitenprotokollierung auszuwählen.';

  @override
  String get notificationAccess => 'Benachrichtigungszugriff';

  @override
  String get notificationAccessMessage => 'Yumie benötigt Benachrichtigungszugriff, um Ihnen Mahlzeiten-Erinnerungen, Wasseraufnahme-Warnungen und Achtsamkeits-Spaziergang-Aufforderungen zu senden.';

  @override
  String get notNow => 'Nicht jetzt';

  @override
  String get permissionsCompleted => 'Berechtigungen vollständig!';

  @override
  String get allPermissionsGranted => 'Alle Berechtigungen erteilt! Sie sind bereit, Yumie zu verwenden.';

  @override
  String get whatIsYourMainGoal => 'Was ist Ihr Hauptziel?';

  @override
  String get chooseGoalDescription => 'Wählen Sie das Ziel, das am besten zu Ihrer Reise passt';

  @override
  String get loseBodyWeight => 'Körpergewicht verlieren';

  @override
  String get gainWeight => 'Gewicht zunehmen';

  @override
  String get buildMuscle => 'Muskeln aufbauen';

  @override
  String get eatHealthier => 'Gesünder essen';

  @override
  String get maintainBodyWeight => 'Körpergewicht halten';

  @override
  String get setRealisticGoalForJourney => 'Setzen Sie ein realistisches Ziel für Ihre Reise';

  @override
  String get targetWeightSetToCurrent => 'Ihr Zielgewicht ist auf Ihr aktuelles Gewicht eingestellt';

  @override
  String get iAcceptThe => 'Ich akzeptiere die';

  @override
  String get and => 'und';

  @override
  String get johnDoe => 'Max Mustermann';

  @override
  String get yourEmailExample => 'ihre.email@beispiel.com';

  @override
  String get byContinuingYouAgreeToOur => 'Durch das Fortfahren stimmen Sie unseren zu';

  @override
  String get whatMotivatesYou => 'Was motiviert Sie?';

  @override
  String get chooseWhatDrivesYou => 'Wählen Sie, was Sie antreibt, um Ihre Ziele zu erreichen';

  @override
  String get feelEnergeticEveryDay => 'Sich jeden Tag energiegeladen fühlen';

  @override
  String get achievePersonalMilestone => 'Einen persönlichen Meilenstein erreichen';

  @override
  String get boostMyConfidence => 'Mein Selbstvertrauen stärken';

  @override
  String get longTermHealth => 'Langfristige Gesundheit';

  @override
  String get trackYourMealsWithEase => 'Ihre Mahlzeiten mühelos verfolgen';

  @override
  String get caloriesLeft => 'Kalorien übrig';

  @override
  String get thisHelpsUsPersonalizeNutrition => 'Dies hilft uns, Ihren Ernährungsplan zu personalisieren';

  @override
  String get male => 'Männlich';

  @override
  String get female => 'Weiblich';

  @override
  String get other => 'Andere';

  @override
  String get thisHelpsUsPersonalizeExperience => 'Dies hilft uns, Ihre Erfahrung zu personalisieren';

  @override
  String get older => 'Älter';

  @override
  String get younger => 'Jünger';

  @override
  String get yearsOld => 'Jahre alt';

  @override
  String get selected => 'Ausgewählt';

  @override
  String get teens => 'Jugendliche';

  @override
  String get yourCurrentWeight => 'Ihr aktuelles Gewicht';

  @override
  String get activityLevel => 'Aktivitätsniveau';

  @override
  String get diabetic => 'Diabetiker?';

  @override
  String get howMuchWaterADay => 'Wie viel Wasser pro Tag?';

  @override
  String get fitnessProfile => 'Fitness-Profil';

  @override
  String get dueToCurrentAnswers => 'Aufgrund der aktuellen Antworten';

  @override
  String get remindersWouldYouLike => 'Welche Erinnerungen möchten Sie erhalten?';

  @override
  String get yumieIsCookingUp => 'Yumie erstellt Ihren personalisierten Ernährungsplan...';

  @override
  String get yourAllSet => 'Sie sind bereit!';

  @override
  String get google => 'Google';

  @override
  String get fiftyPlus => '50+';

  @override
  String get forties => '40er';

  @override
  String get thirties => '30er';

  @override
  String get twenties => '20er';

  @override
  String get weightUnit => 'kg';

  @override
  String get heightUnit => 'cm';

  @override
  String get feetUnit => 'ft';

  @override
  String get inchesUnit => 'Zoll';

  @override
  String get poundsUnit => 'lbs';

  @override
  String get whatIsYourAge => 'Wie alt sind Sie?';

  @override
  String get whatIsYourHeight => 'Wie groß sind Sie?';

  @override
  String get whatIsYourWeight => 'Wie viel wiegen Sie derzeit?';

  @override
  String get whatIsYourGoalWeight => 'Wie viel ist Ihr Zielgewicht?';

  @override
  String get whatIsYourActivityLevel => 'Wie ist Ihr Aktivitätsniveau?';

  @override
  String get howMuchWaterDaily => 'Wie viel Wasser trinken Sie täglich?';

  @override
  String get sedentary => 'Sitzend';

  @override
  String get lightlyActive => 'Leicht aktiv';

  @override
  String get moderatelyActive => 'Mäßig aktiv';

  @override
  String get veryActive => 'Sehr aktiv';

  @override
  String get extremelyActive => 'Extrem aktiv';

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
  String get oneToTwoGlasses => '1-2 Gläser';

  @override
  String get threeToFourGlasses => '3-4 Gläser';

  @override
  String get fiveToSixGlasses => '5-6 Gläser';

  @override
  String get sevenToEightGlasses => '7-8 Gläser';

  @override
  String get moreThanEightGlasses => 'Mehr als 8 Gläser';

  @override
  String get mealReminders => 'Mahlzeiten-Erinnerungen';

  @override
  String get waterReminders => 'Wasser-Erinnerungen';

  @override
  String get workoutReminders => 'Workout-Erinnerungen';

  @override
  String get progressUpdates => 'Fortschritts-Updates';

  @override
  String get dailyTips => 'Tägliche Tipps';

  @override
  String get youAreAllSet => 'Sie sind bereit!';

  @override
  String get welcomeToYourHealthJourney => 'Willkommen zu Ihrer Gesundheitsreise';

  @override
  String get letsGetStarted => 'Lassen Sie uns beginnen!';

  @override
  String get pleaseWait => 'Bitte warten...';

  @override
  String get cookingUpYourPlan => 'Erstelle Ihren personalisierten Plan';

  @override
  String get analyzingYourData => 'Analysiere Ihre Daten';

  @override
  String get creatingCustomPlan => 'Erstelle Ihren benutzerdefinierten Ernährungsplan';

  @override
  String get almostDone => 'Fast fertig!';

  @override
  String get subscriptionRequired => 'Abonnement erforderlich';

  @override
  String get upgradeToUnlock => 'Upgraden Sie, um alle Funktionen freizuschalten';

  @override
  String get startFreeTrial => 'Kostenlose Testversion starten';

  @override
  String get month => 'Monat';

  @override
  String get year => 'Jahr';

  @override
  String get free => 'Kostenlos';

  @override
  String get mostPopular => 'Am beliebtesten';

  @override
  String get skip => 'Überspringen';

  @override
  String get next => 'Weiter';

  @override
  String get back => 'Zurück';

  @override
  String get done => 'Fertig';

  @override
  String get error => 'Fehler';

  @override
  String get success => 'Erfolg';

  @override
  String get warning => 'Warnung';

  @override
  String get info => 'Info';

  @override
  String get retry => 'Wiederholen';

  @override
  String get loading => 'Laden...';

  @override
  String get noDataAvailable => 'Keine Daten verfügbar';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get somethingWentWrong => 'Etwas ist schiefgegangen';

  @override
  String get internetConnectionRequired => 'Internetverbindung erforderlich';

  @override
  String get pleaseCheckConnection => 'Bitte überprüfen Sie Ihre Internetverbindung';

  @override
  String get restartOnboarding => 'Onboarding neu starten';

  @override
  String get getStarted => 'Loslegen';

  @override
  String get couldNotOpenPlayStore => 'Play Store konnte nicht geöffnet werden';

  @override
  String get errorOpeningPlayStore => 'Fehler beim Öffnen des Play Store';

  @override
  String get remove => 'Entfernen';

  @override
  String get couldNotOpenLink => 'Link konnte nicht geöffnet werden';

  @override
  String get errorOpeningLink => 'Fehler beim Öffnen des Links';

  @override
  String get help => 'Hilfe';

  @override
  String get name => 'Name';

  @override
  String get dailyCalorieGoal => 'Tägliches Kalorienziel';

  @override
  String get manageSubscription => 'Abonnement verwalten';

  @override
  String get deletionFailed => 'Löschung fehlgeschlagen';

  @override
  String get dismiss => 'Schließen';

  @override
  String get grantPermission => 'Berechtigung erteilen';

  @override
  String get littleOrNoExercise => 'Wenig oder kein Training';

  @override
  String get lightExercise => 'Leichtes Training/Sport 1-3 Tage/Woche';

  @override
  String get moderateExercise => 'Mäßiges Training/Sport 3-5 Tage/Woche';

  @override
  String get hardExercise => 'Intensives Training/Sport 6-7 Tage/Woche';

  @override
  String get share => 'Teilen';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get notificationsForMealLogging => 'Benachrichtigungen für Mahlzeitenprotokollierung-Erinnerungen';

  @override
  String get notificationsForWaterIntake => 'Benachrichtigungen für Wasseraufnahme-Erinnerungen';

  @override
  String get notificationsForMindfulWalk => 'Benachrichtigungen für Achtsamkeits-Spaziergang-Erinnerungen';

  @override
  String get increment => 'Erhöhen';

  @override
  String get enterNewName => 'Neuen Namen eingeben';

  @override
  String get readOurPrivacyPolicy => 'Lesen Sie unsere Datenschutzrichtlinie';

  @override
  String get readOurTermsOfService => 'Lesen Sie unsere Nutzungsbedingungen';

  @override
  String get helpUsCalculateYourHealthGoals => 'Helfen Sie uns, Ihre Gesundheitsziele zu berechnen';

  @override
  String get thisHelpsUsTrackYourProgress => 'Dies hilft uns, Ihren Fortschritt zu verfolgen';

  @override
  String get setARealisticGoalForYourJourney => 'Setzen Sie ein realistisches Ziel für Ihre Reise';

  @override
  String get thisHelpsUsPersonalizeYourPlan => 'Dies hilft uns, Ihren Plan zu personalisieren';

  @override
  String get stayingHydratedIsKeyToYourHealth => 'Hydratisiert zu bleiben ist der Schlüssel zu Ihrer Gesundheit';

  @override
  String get yourFitnessProfileDueToYourAnswers => 'Ihr Fitness-Profil basierend auf Ihren Antworten';

  @override
  String get currentBMI => 'Aktueller BMI';

  @override
  String get obese => 'Fettleibig';

  @override
  String get activityLevelLabel => 'Aktivitätsniveau';

  @override
  String get bloodTypeLabel => 'Blutgruppe';

  @override
  String get diabeticLabel => 'Diabetiker';

  @override
  String get waterIntakeLabel => 'Wasseraufnahme';

  @override
  String get heresYourPersonalizedNutritionPlan => 'Hier ist Ihr personalisierter Ernährungsplan. Willkommen zu Ihrer Gesundheitsreise mit Yumie';

  @override
  String get caloriesGoal => 'Kalorienziel';

  @override
  String get carbsGoal => 'Kohlenhydratziel';

  @override
  String get startNow => 'Jetzt beginnen';

  @override
  String get underweight => 'Untergewicht';

  @override
  String get normalWeight => 'Normalgewicht';

  @override
  String get healthy => 'Gesund';

  @override
  String get overweight => 'Übergewicht';

  @override
  String get avocadoToast => 'Avocado-Toast';

  @override
  String get italianSalad => 'Italienischer Salat';

  @override
  String get chickenKatsuRiceBowl => 'Hähnchen-Katsu-Reisschüssel';

  @override
  String get yourTargetWeightIsSetToCurrent => 'Ihr Zielgewicht ist auf Ihr aktuelles Gewicht eingestellt';

  @override
  String get couldNotGenerateYourPlan => 'Ihr Plan konnte nicht generiert werden. Bitte versuchen Sie es erneut.';

  @override
  String get somethingWentWrongRestart => 'Etwas ist schiefgegangen. Bitte starten Sie den Onboarding-Prozess neu.';

  @override
  String get yourBMI => 'Ihr BMI:';

  @override
  String get lbs => 'lbs';

  @override
  String get yourActivityLevel => 'Ihr Aktivitätsniveau';

  @override
  String get analyzingFridge => 'Analysiere Ihren Kühlschrank...';

  @override
  String get aiDetectingFoodItems => 'KI erkennt Lebensmittel';

  @override
  String get tryClearerPhoto => 'Versuchen Sie, ein klareres Foto Ihres Kühlschranks zu machen';

  @override
  String get generating => 'Generiere...';

  @override
  String get premiumStatus => 'Premium Status';

  @override
  String get thankYouForSupport => 'Vielen Dank für Ihre Unterstützung! 💚';

  @override
  String get yourPremiumFeatures => 'Ihre Premium-Funktionen';

  @override
  String get subscriptionError => 'Abonnement-Fehler';

  @override
  String get unknownErrorOccurred => 'Ein unbekannter Fehler ist aufgetreten';

  @override
  String get privacyAndAds => 'Datenschutz und Werbung';

  @override
  String get reviewAdPreferences => 'Überprüfen Sie Ihre Werbeeinstellungen';

  @override
  String get privacyOptionsNotAvailable => 'Datenschutzoptionen sind in Ihrer Region nicht verfügbar.';

  @override
  String get consentFlowCompleted => 'Zustimmungsablauf abgeschlossen!';

  @override
  String get appleSignInFailed => 'Apple-Anmeldung fehlgeschlagen';

  @override
  String get adFailedToShow => 'Anzeige konnte nicht angezeigt werden. Bitte versuchen Sie es erneut.';

  @override
  String get adNotLoadedYet => 'Anzeige noch nicht geladen. Bitte versuchen Sie es erneut.';

  @override
  String get errorRequestingPermissions => 'Fehler beim Anfordern von Berechtigungen';

  @override
  String get showMore => 'Show more';

  @override
  String get showLess => 'Show less';
}
