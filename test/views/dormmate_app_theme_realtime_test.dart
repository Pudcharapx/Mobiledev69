import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:project/core/theme/dormmate_theme_service.dart';
import 'package:project/main.dart';

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
  testWidgets('DormMateApp updates themeMode in real-time when theme changes', (tester) async {
    final storage = MockStorage();
    final themeService = DormMateThemeService(storage: storage);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Scaffold(
              body: Center(
                child: Text(isDark ? 'CURRENT_MODE:DARK' : 'CURRENT_MODE:LIGHT'),
              ),
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(
      DormMateApp(
        router: router,
        themeService: themeService,
      ),
    );

    await tester.pumpAndSettle();

    // Verify initial mode is light
    expect(find.text('CURRENT_MODE:LIGHT'), findsOneWidget);

    // Change to Dark Mode in real-time
    await themeService.toggleDarkMode(true);
    await tester.pumpAndSettle();

    // Verify app immediately updated to dark in real-time
    expect(find.text('CURRENT_MODE:DARK'), findsOneWidget);
    expect(themeService.isDarkMode, isTrue);

    // Switch back to Light Mode in real-time
    await themeService.toggleDarkMode(false);
    await tester.pumpAndSettle();

    // Verify app immediately updated back to light in real-time
    expect(find.text('CURRENT_MODE:LIGHT'), findsOneWidget);
    expect(themeService.isDarkMode, isFalse);
  });
}
