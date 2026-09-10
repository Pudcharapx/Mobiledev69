import 'package:go_router/go_router.dart';
import '../../../core/auth/auth_service.dart';
import '../../auth/presentation/callback_screen.dart';
import '../../auth/presentation/home_screen.dart';
import '../../auth/presentation/login_screen.dart';
import '../../heatmap/presentation/heatmap_screen.dart';
import '../presentation/log_form.dart';
import '../presentation/log_screen.dart';

/// App Router with OIDC Route Guard using `go_router` per SRS 3.2, 3.3, and 9.1.
class AppRouter {
  AppRouter._();

  static GoRouter createRouter(AuthService authService) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authService,
      redirect: (context, state) {
        final initialized = authService.isInitialized;
        final authenticated = authService.isAuthenticated;

        final location = state.matchedLocation;
        final isLoggingIn = location == '/login';
        final isCallback = location == '/callback';

        // Allow app initialization to complete
        if (!initialized) return null;

        // Route guard: Block unauthenticated users from content screens
        if (!authenticated) {
          if (isLoggingIn || isCallback) {
            return null;
          }
          return '/login';
        }

        // If already authenticated and visiting login or callback, redirect to content home
        if (isLoggingIn || isCallback) {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/callback',
          name: 'callback',
          builder: (context, state) => const CallbackScreen(),
        ),
        GoRoute(
          path: '/',
          name: 'heatmap',
          builder: (context, state) => const HeatmapScreen(),
        ),
        GoRoute(
          path: '/workouts',
          name: 'workouts',
          builder: (context, state) => const LogScreen(),
        ),
        GoRoute(
          path: '/workouts/new',
          name: 'new-workout',
          builder: (context, state) => const LogForm(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          redirect: (context, state) => '/profile',
        ),
      ],
    );
  }
}
