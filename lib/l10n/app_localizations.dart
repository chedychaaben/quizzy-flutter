import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'welcome_message': 'Welcome to Quizy!',  // Added
      'app_title': 'Quizy',
      'about_title': 'About',
      'about_description': 'This app is a Flutter quiz application using the Open Trivia Database API.',
      'quiz_title': 'Quiz',
      'question_label': 'Question',
      'name': 'Quizy',
      'time_label': 'Time',
      'start_quiz': 'Start Quiz',
      'retry': 'Retry',
      'select_parameters': 'Select Quiz Parameters',
      'category': 'Category',
      'difficulty': 'Difficulty',
      'num_questions': 'Number of Questions',
      'results_title': 'Quiz Results',
      'your_score': 'Your Score',
      'correct_answer': 'Correct Answer',
      'your_answer': 'Your Answer',
      'return_home': 'Return to Home',
      'replay_quiz': 'Replay Quiz',
      'settings': 'Settings',
      'dark_mode': 'Dark Mode',
      'sound_effects': 'Sound Effects',
      'notifications': 'Notifications',
      'language': 'Language',
      'ranking': 'Ranking',
      'reset_scores': 'Reset Scores',
      'confirm_reset': 'Are you sure you want to reset all scores?',
      'cancel': 'Cancel',
      'reset': 'Reset',
      'no_scores': 'No scores available',
      'best_score': 'Best Score',
      'error_loading': 'Error loading questions',
      'error_fetching': 'Error fetching data',
    },
    'fr': {
      'welcome_message': 'Bienvenue à Quizy!',  // Added
      'app_title': 'Application Quiz',
      'about_title': 'À propos',
      'about_description': 'Cette application est une application de quiz Flutter utilisant l\'API Open Trivia Database.',
      'quiz_title': 'Quiz',
      'question_label': 'Question',
      'name': 'Nom',
      'time_label': 'Temps',
      'start_quiz': 'Commencer le Quiz',
      'retry': 'Réessayer',
      'select_parameters': 'Sélectionner les Paramètres',
      'category': 'Catégorie',
      'difficulty': 'Difficulté',
      'num_questions': 'Nombre de Questions',
      'results_title': 'Résultats du Quiz',
      'your_score': 'Votre Score',
      'correct_answer': 'Bonne Réponse',
      'your_answer': 'Votre Réponse',
      'return_home': 'Retour à l\'Accueil',
      'replay_quiz': 'Rejouer le Quiz',
      'settings': 'Paramètres',
      'dark_mode': 'Mode Sombre',
      'sound_effects': 'Effets Sonores',
      'notifications': 'Notifications',
      'language': 'Langue',
      'ranking': 'Classement',
      'reset_scores': 'Réinitialiser les Scores',
      'confirm_reset': 'Êtes-vous sûr de vouloir réinitialiser tous les scores?',
      'cancel': 'Annuler',
      'reset': 'Réinitialiser',
      'no_scores': 'Aucun score disponible',
      'best_score': 'Meilleur Score',
      'error_loading': 'Erreur de chargement des questions',
      'error_fetching': 'Erreur de récupération des données',
    },
    'ar': {
      'welcome_message': 'مرحبا بكم في Quizy!',  // Added
      'app_title': 'تطبيق الاختبار',
      'about_title': 'حول',
      'about_description': 'هذا التطبيق هو تطبيق اختبار Flutter يستخدم واجهة برمجة تطبيقات Open Trivia Database.',
      'quiz_title': 'اختبار',
      'question_label': 'السؤال',
      'name': 'اسم',
      'time_label': 'الوقت',
      'start_quiz': 'بدء الاختبار',
      'retry': 'إعادة المحاولة',
      'select_parameters': 'اختر معايير الاختبار',
      'category': 'الفئة',
      'difficulty': 'الصعوبة',
      'num_questions': 'عدد الأسئلة',
      'results_title': 'نتائج الاختبار',
      'your_score': 'نقاطك',
      'correct_answer': 'الإجابة الصحيحة',
      'your_answer': 'إجابتك',
      'return_home': 'العودة للصفحة الرئيسية',
      'replay_quiz': 'إعادة الاختبار',
      'settings': 'الإعدادات',
      'dark_mode': 'الوضع المظلم',
      'sound_effects': 'التأثيرات الصوتية',
      'notifications': 'الإشعارات',
      'language': 'اللغة',
      'ranking': 'التصنيف',
      'reset_scores': 'إعادة تعيين النقاط',
      'confirm_reset': 'هل أنت متأكد أنك تريد إعادة تعيين جميع النقاط؟',
      'cancel': 'إلغاء',
      'reset': 'إعادة تعيين',
      'no_scores': 'لا توجد نقاط متاحة',
      'best_score': 'أفضل نتيجة',
      'error_loading': 'خطأ في تحميل الأسئلة',
      'error_fetching': 'خطأ في جلب البيانات',
    },
  };

  // Getter methods for all localized strings
  String get welcomeMessage => _localizedValues[locale.languageCode]?['welcome_message'] ?? 'Welcome!';  // Added
  String get appTitle => _localizedValues[locale.languageCode]?['app_title'] ?? 'Quiz App';
  String get aboutTitle => _localizedValues[locale.languageCode]?['about_title'] ?? 'About';
  String get aboutDescription => _localizedValues[locale.languageCode]?['about_description'] ?? '';
  String get quizTitle => _localizedValues[locale.languageCode]?['quiz_title'] ?? 'Quiz';
  String get questionLabel => _localizedValues[locale.languageCode]?['question_label'] ?? 'Question';
  String get name => _localizedValues[locale.languageCode]?['name'] ?? 'Name';
  String get timeLabel => _localizedValues[locale.languageCode]?['time_label'] ?? 'Time';
  String get startQuiz => _localizedValues[locale.languageCode]?['start_quiz'] ?? 'Start Quiz';
  String get retry => _localizedValues[locale.languageCode]?['retry'] ?? 'Retry';
  String get selectParameters => _localizedValues[locale.languageCode]?['select_parameters'] ?? 'Select Quiz Parameters';
  String get category => _localizedValues[locale.languageCode]?['category'] ?? 'Category';
  String get difficulty => _localizedValues[locale.languageCode]?['difficulty'] ?? 'Difficulty';
  String get numQuestions => _localizedValues[locale.languageCode]?['num_questions'] ?? 'Number of Questions';
  String get resultsTitle => _localizedValues[locale.languageCode]?['results_title'] ?? 'Quiz Results';
  String get yourScore => _localizedValues[locale.languageCode]?['your_score'] ?? 'Your Score';
  String get correctAnswer => _localizedValues[locale.languageCode]?['correct_answer'] ?? 'Correct Answer';
  String get yourAnswer => _localizedValues[locale.languageCode]?['your_answer'] ?? 'Your Answer';
  String get returnHome => _localizedValues[locale.languageCode]?['return_home'] ?? 'Return to Home';
  String get replayQuiz => _localizedValues[locale.languageCode]?['replay_quiz'] ?? 'Replay Quiz';
  String get settings => _localizedValues[locale.languageCode]?['settings'] ?? 'Settings';
  String get darkMode => _localizedValues[locale.languageCode]?['dark_mode'] ?? 'Dark Mode';
  String get soundEffects => _localizedValues[locale.languageCode]?['sound_effects'] ?? 'Sound Effects';
  String get notifications => _localizedValues[locale.languageCode]?['notifications'] ?? 'Notifications';
  String get language => _localizedValues[locale.languageCode]?['language'] ?? 'Language';
  String get ranking => _localizedValues[locale.languageCode]?['ranking'] ?? 'Ranking';
  String get resetScores => _localizedValues[locale.languageCode]?['reset_scores'] ?? 'Reset Scores';
  String get confirmReset => _localizedValues[locale.languageCode]?['confirm_reset'] ?? 'Are you sure you want to reset all scores?';
  String get cancel => _localizedValues[locale.languageCode]?['cancel'] ?? 'Cancel';
  String get reset => _localizedValues[locale.languageCode]?['reset'] ?? 'Reset';
  String get noScores => _localizedValues[locale.languageCode]?['no_scores'] ?? 'No scores available';
  String get bestScore => _localizedValues[locale.languageCode]?['best_score'] ?? 'Best Score';
  String get errorLoading => _localizedValues[locale.languageCode]?['error_loading'] ?? 'Error loading questions';
  String get errorFetching => _localizedValues[locale.languageCode]?['error_fetching'] ?? 'Error fetching data';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}