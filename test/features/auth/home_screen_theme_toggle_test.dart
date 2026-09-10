import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/auth/auth_service.dart';
import 'package:project/core/auth/token_storage.dart';
import 'package:project/core/theme/theme_service.dart';
import 'package:project/features/auth/presentation/home_screen.dart';
import 'package:provider/provider.dart';

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
  group('HomeScreen Dark Mode Toggle Widget Tests (SRS 8.3 & 9.3 item 6)', () {
    late MockStorage storage;
    late ThemeService themeService;
    late AuthService authService;

    setUp(() {
      storage = MockStorage();
      themeService = ThemeService(storage: storage);
      authService = AuthService(tokenStorage: TokenStorage(storage: storage));
    });

    testWidgets('renders Appearance card with Dark Mode toggle and SegmentedButton', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>.value(value: authService),
            ChangeNotifierProvider<ThemeService>.value(value: themeService),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Dark mode with saved preference'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
    });

    testWidgets('toggling switch activates Dark Mode and persists preference', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>.value(value: authService),
            ChangeNotifierProvider<ThemeService>.value(value: themeService),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Tap Dark Mode switch
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(themeService.themeMode, equals(ThemeMode.dark));
      expect(storage.data[ThemeService.keyThemeMode], equals('dark'));
    });
  });
}
