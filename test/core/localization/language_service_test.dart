import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/localization/language_service.dart';

class MockStorage extends FlutterSecureStorage {
  final Map<String, String> data = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      data[key] = value;
    } else {
      data.remove(key);
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return data[key];
  }
}

void main() {
  group('LanguageService Tests', () {
    late MockStorage storage;
    late LanguageService service;

    setUp(() {
      storage = MockStorage();
      service = LanguageService(storage: storage);
    });

    test('defaults to English (en) before initialization', () {
      expect(service.languageCode, equals('en'));
      expect(service.isEnglish, isTrue);
      expect(service.isThai, isFalse);
      expect(service.currentLanguageName, equals('English'));
      expect(service.currentFlag, equals('🇺🇸'));
    });

    test('setLanguage switches to Thai and persists to storage', () async {
      await service.setLanguage('th');
      expect(service.languageCode, equals('th'));
      expect(service.isThai, isTrue);
      expect(service.isEnglish, isFalse);
      expect(service.currentLanguageName, equals('ภาษาไทย'));
      expect(service.currentFlag, equals('🇹🇭'));
      expect(storage.data[LanguageService.keyLanguage], equals('th'));
    });

    test('toggleLanguage toggles between English and Thai', () async {
      expect(service.isEnglish, isTrue);

      await service.toggleLanguage();
      expect(service.isThai, isTrue);
      expect(storage.data[LanguageService.keyLanguage], equals('th'));

      await service.toggleLanguage();
      expect(service.isEnglish, isTrue);
      expect(storage.data[LanguageService.keyLanguage], equals('en'));
    });

    test('initialize restores saved language from storage', () async {
      storage.data[LanguageService.keyLanguage] = 'th';

      final restoredService = LanguageService(storage: storage);
      await restoredService.initialize();

      expect(restoredService.isInitialized, isTrue);
      expect(restoredService.isThai, isTrue);
      expect(restoredService.languageCode, equals('th'));
    });
  });
}
