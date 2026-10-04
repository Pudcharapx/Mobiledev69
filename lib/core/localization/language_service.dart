import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

/// Service managing the application's active locale and language preference.
/// Persists the selected language code across app restarts.
class LanguageService extends ChangeNotifier {
  static const String keyLanguage = 'dormmate_language_code';

  final FlutterSecureStorage _storage;
  Locale _locale = const Locale('en');
  bool _isInitialized = false;

  LanguageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;
  bool get isThai => _locale.languageCode == 'th';
  bool get isEnglish => _locale.languageCode == 'en';
  bool get isInitialized => _isInitialized;

  /// Display name of current language
  String get currentLanguageName => isThai ? 'ภาษาไทย' : 'English';

  /// Flag emoji for current language
  String get currentFlag => isThai ? '🇹🇭' : '🇺🇸';

  /// Opposite language code to switch to
  String get targetLanguageCode => isThai ? 'EN' : 'TH';

  /// Restore saved language preference from storage
  Future<void> initialize() async {
    try {
      final savedLang = await _storage.read(key: keyLanguage);
      if (savedLang != null && (savedLang == 'th' || savedLang == 'en')) {
        _locale = Locale(savedLang);
      } else {
        _locale = const Locale('en');
      }
    } catch (_) {
      _locale = const Locale('en');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Change active locale and persist
  Future<void> setLocale(Locale newLocale) async {
    if (_locale.languageCode == newLocale.languageCode) return;
    _locale = newLocale;
    notifyListeners();

    try {
      await _storage.write(key: keyLanguage, value: newLocale.languageCode);
    } catch (_) {
      // Gracefully handle storage failure
    }
  }

  /// Set by language code ('th' or 'en')
  Future<void> setLanguage(String code) async {
    final lower = code.toLowerCase();
    if (lower == 'th') {
      await setLocale(const Locale('th'));
    } else {
      await setLocale(const Locale('en'));
    }
  }

  /// Quick toggle between Thai and English
  Future<void> toggleLanguage() async {
    if (isThai) {
      await setLocale(const Locale('en'));
    } else {
      await setLocale(const Locale('th'));
    }
  }
}

/// Helper extension on [BuildContext] for easy localization access throughout the app
extension LocalizationExtension on BuildContext {
  LanguageService? get languageService {
    try {
      return Provider.of<LanguageService?>(this, listen: true);
    } catch (_) {
      return null;
    }
  }

  bool get isThai {
    try {
      return Provider.of<LanguageService?>(this, listen: true)?.isThai ?? false;
    } catch (_) {
      return false;
    }
  }

  String tr(String en, String th) => isThai ? th : en;
}
