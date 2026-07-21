import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../l10n/translations.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  static const String _boxName = 'settings';
  static const String _localeKey = 'locale';

  Locale get locale => _locale;

  List<Locale> get supportedLocales => const [
    Locale('en'),
    Locale('hi'),
    Locale('gu'),
    Locale('es'),
    Locale('mr'),
    Locale('ta'),
    Locale('te'),
    Locale('ml'),
    Locale('or'),
    Locale('pa'),
    Locale('bn'),
    Locale('kn'),
  ];

  List<Map<String, String>> get availableLanguages => const [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'hi', 'name': 'Hindi', 'native': 'हिन्दी'},
    {'code': 'gu', 'name': 'Gujarati', 'native': 'ગુજરાતી'},
    {'code': 'es', 'name': 'Spanish', 'native': 'Español'},
    {'code': 'mr', 'name': 'Marathi', 'native': 'मराठी'},
    {'code': 'ta', 'name': 'Tamil', 'native': 'தமிழ்'},
    {'code': 'te', 'name': 'Telugu', 'native': 'తెలుగు'},
    {'code': 'ml', 'name': 'Malayalam', 'native': 'മലയാളം'},
    {'code': 'or', 'name': 'Odia', 'native': 'ଓଡ଼ିଆ'},
    {'code': 'pa', 'name': 'Punjabi', 'native': 'ਪੰਜਾਬੀ'},
    {'code': 'bn', 'name': 'Bengali', 'native': 'বাংলা'},
    {'code': 'kn', 'name': 'Kannada', 'native': 'ಕನ್ನಡ'},
  ];

  Future<void> init() async {
    final box = await Hive.openBox(_boxName);
    final savedLocale = box.get(_localeKey);
    if (savedLocale != null) {
      _locale = Locale(savedLocale);
    } else {
      _locale = _getDeviceLocale();
    }
    T.load(_locale.languageCode);
    notifyListeners();
  }

  Locale _getDeviceLocale() {
    final deviceLocale = PlatformDispatcher.instance.locale;
    final languageCode = deviceLocale.languageCode;
    final supported = supportedLocales.map((l) => l.languageCode).toList();
    if (supported.contains(languageCode)) {
      return Locale(languageCode);
    }
    return const Locale('en');
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;
    _locale = locale;
    T.load(locale.languageCode);
    final box = await Hive.openBox(_boxName);
    await box.put(_localeKey, locale.languageCode);
    notifyListeners();
  }

  String getLanguageName(String code) {
    for (final lang in availableLanguages) {
      if (lang['code'] == code) return lang['native'] ?? lang['name']!;
    }
    return code;
  }
}
