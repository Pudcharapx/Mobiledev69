import 'package:go_router/go_router.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/callback_screen.dart';
import '../../views/main_navigation_shell.dart';
import '../../views/home/home_screen.dart';
import '../../views/expenses/expense_screen.dart';
import '../../views/expenses/expense_detail_screen.dart';
import '../../views/maintenance/maintenance_screen.dart';
import '../../views/maintenance/create_maintenance_screen.dart';
import '../../views/maintenance/maintenance_detail_screen.dart';
import '../../views/announcements/announcement_screen.dart';
import '../../views/announcements/announcement_detail_screen.dart';
import '../../views/profile/profile_screen.dart';
import '../../views/parcels/parcel_screen.dart';
import '../../views/facility/facility_screen.dart';
import '../../views/expenses/utility_analytics_screen.dart';
import '../../views/profile/resident_guide_screen.dart';

GoRouter createDormMateRouter(AuthViewModel authViewModel) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: authViewModel,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final isLoggingIn = loc == '/login';
      final isCallback = loc == '/callback' || loc == '/callback/' || state.uri.path.startsWith('/callback');
      final isAuth = authViewModel.isAuthenticated;

      if (isCallback) {
        return null;
      }
      if (!isAuth && !isLoggingIn) {
        return '/login';
      }
      if (isAuth && isLoggingIn) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/callback',
        builder: (context, state) => const CallbackScreen(),
      ),
      GoRoute(
        path: '/parcels',
        builder: (context, state) => const ParcelScreen(),
      ),
      GoRoute(
        path: '/facilities',
        builder: (context, state) => const FacilityScreen(),
      ),
      GoRoute(
        path: '/resident-guide',
        builder: (context, state) => const ResidentGuideScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Expenses
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/expenses',
                builder: (context, state) => const ExpenseScreen(),
                routes: [
                  GoRoute(
                    path: 'analytics',
                    builder: (context, state) => const UtilityAnalyticsScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                      return ExpenseDetailScreen(expenseId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Maintenance
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/maintenance',
                builder: (context, state) => const MaintenanceScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    builder: (context, state) => const CreateMaintenanceScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                      return MaintenanceDetailScreen(requestId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Announcements
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/announcements',
                builder: (context, state) => const AnnouncementScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                      return AnnouncementDetailScreen(announcementId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
