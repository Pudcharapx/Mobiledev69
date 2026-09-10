import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/auth/auth_service.dart';
import 'package:project/core/auth/token_storage.dart';
import 'package:project/core/auth/user_session.dart';
import 'package:project/features/workout/router/app_router.dart';

class MockSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _data = {};

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
      _data[key] = value;
    } else {
      _data.remove(key);
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
    return _data[key];
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.remove(key);
  }

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.clear();
  }
}

void main() {
  group('TokenStorage & Session Persistence Tests', () {
    late TokenStorage storage;
    late MockSecureStorage mockStorage;

    setUp(() {
      mockStorage = MockSecureStorage();
      storage = TokenStorage(storage: mockStorage);
    });

    test('Save and retrieve tokens', () async {
      await storage.saveTokens(
        accessToken: 'access-123',
        idToken: 'id-456',
        refreshToken: 'refresh-789',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      expect(await storage.getAccessToken(), 'access-123');
      expect(await storage.getIdToken(), 'id-456');
      expect(await storage.getRefreshToken(), 'refresh-789');
      expect(await storage.hasValidToken(), isTrue);
    });

    test('Clear tokens completely on logout', () async {
      await storage.saveTokens(
        accessToken: 'access-123',
        idToken: 'id-456',
      );
      expect(await storage.hasValidToken(), isTrue);

      await storage.clearTokens();
      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getIdToken(), isNull);
      expect(await storage.hasValidToken(), isFalse);
    });

    test('isTokenExpired detects expired token', () async {
      await storage.saveTokens(
        accessToken: 'expired-access',
        expiresAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );
      expect(await storage.isTokenExpired(), isTrue);
      expect(await storage.hasValidToken(), isFalse);
    });
  });

  group('AuthService & Route Guard Tests', () {
    late TokenStorage storage;
    late AuthService authService;

    setUp(() {
      storage = TokenStorage(storage: MockSecureStorage());
      authService = AuthService(tokenStorage: storage);
    });

    test('Initial unauthenticated state', () {
      expect(authService.isAuthenticated, isFalse);
      expect(authService.currentUser, isNull);
    });

    test('Logout clears session and notifies listeners', () async {
      await storage.saveTokens(accessToken: 'token');
      var notified = false;
      authService.addListener(() => notified = true);

      await authService.logout();
      expect(authService.isAuthenticated, isFalse);
      expect(notified, isTrue);
      expect(await storage.hasValidToken(), isFalse);
    });

    test('UserSession parsing from claims', () {
      final session = UserSession.fromClaims({
        'sub': 'user-123',
        'preferred_username': 'john_doe',
        'email': 'john@example.com',
      });

      expect(session.userId, 'user-123');
      expect(session.username, 'john_doe');
      expect(session.email, 'john@example.com');
    });

    testWidgets('Route guard redirects unauthenticated user to /login',
        (tester) async {
      await authService.initialize();
      final router = AppRouter.createRouter(authService);

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();

      // Should be redirected to /login
      expect(find.text('Muscle Heatmap'), findsOneWidget);
      expect(find.text('Sign in with OIDC'), findsOneWidget);
    });
  });
}
