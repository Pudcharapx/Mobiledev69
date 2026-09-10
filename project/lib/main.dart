import 'package:flutter/material.dart';
import 'app.dart';
import 'core/api/api_client.dart';
import 'core/auth/auth_service.dart';
import 'core/auth/token_storage.dart';
import 'core/theme/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStorage = TokenStorage();
  final authService = AuthService(tokenStorage: tokenStorage);
  final themeService = ThemeService();

  final apiClient = ApiClient(
    tokenStorage: tokenStorage,
    onUnauthorized: () {
      authService.logout();
    },
  );

  // Initialize and restore existing session from secure storage (SRS 3.2)
  await authService.initialize();

  // Initialize and restore saved theme preference (SRS 8.3)
  await themeService.initialize();

  runApp(
    MuscleHeatmapApp(
      authService: authService,
      apiClient: apiClient,
      tokenStorage: tokenStorage,
      themeService: themeService,
    ),
  );
}
