import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LanguageProvider() {
    _loadLanguage();
  }

  bool get isArabic => _locale.languageCode == 'ar';

  void toggleLanguage() {
    if (_locale.languageCode == 'en') {
      _locale = const Locale('ar');
    } else {
      _locale = const Locale('en');
    }
    _saveLanguage();
    notifyListeners();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code') ?? 'en';
    _locale = Locale(langCode);
    notifyListeners();
  }

  Future<void> _saveLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', _locale.languageCode);
  }
}

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'profile_settings': 'Profile & Settings',
      'user_account': 'User Account',
      'preferences': 'Preferences',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'english': 'English',
      'arabic': 'Arabic',
      'account': 'Account',
      'logout': 'Logout',
      'home': 'Home',
      'history': 'History',
      'profile': 'Profile',
      'analyze_fruit': 'Analyze Fruit Quality',
      'upload_photo': 'Upload a photo to get AI-powered insights.',
      'take_photo': 'Take Photo',
      'gallery': 'Gallery',
      'recent_scans': 'Recent Scans',
      'view_all': 'View All History',
      'fruite_ai': 'Fruite AI',
      'create_account': 'Create Account',
      'full_name': 'Full Name',
      'email': 'Email',
      'password': 'Password',
      'login': 'Login',
      'register': 'Register',
      'need_account': 'Need an account? Register',
      'have_account': 'Have an account? Login',
    },
    'ar': {
      'profile_settings': 'الملف الشخصي والإعدادات',
      'user_account': 'حساب المستخدم',
      'preferences': 'التفضيلات',
      'dark_mode': 'الوضع الليلي',
      'language': 'اللغة',
      'english': 'الإنجليزية',
      'arabic': 'العربية',
      'account': 'الحساب',
      'logout': 'تسجيل الخروج',
      'home': 'الرئيسية',
      'history': 'السجل',
      'profile': 'حسابي',
      'analyze_fruit': 'تحليل جودة الفاكهة',
      'upload_photo': 'ارفع صورة للحصول على تحليل ذكي.',
      'take_photo': 'التقاط صورة',
      'gallery': 'المعرض',
      'recent_scans': 'الفحوصات الأخيرة',
      'view_all': 'عرض كل السجل',
      'fruite_ai': 'فروت الذكاء الاصطناعي',
      'create_account': 'إنشاء حساب',
      'full_name': 'الاسم الكامل',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'login': 'تسجيل الدخول',
      'register': 'تسجيل جديد',
      'need_account': 'ليس لديك حساب؟ سجل الآن',
      'have_account': 'لديك حساب؟ سجل الدخول',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}
