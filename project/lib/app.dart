import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/api/api_client.dart';
import 'core/auth/auth_service.dart';
import 'core/auth/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_service.dart';
import 'features/heatmap/data/exercise_repository.dart';
import 'features/workout/data/workout_repository.dart';
import 'features/workout/presentation/workout_view_model.dart';
import 'features/workout/router/app_router.dart';

/// Root application widget per SRS 3.3 and MVVM dependency injection per SRS 3.1.
class MuscleHeatmapApp extends StatefulWidget {
  final AuthService authService;
  final ApiClient apiClient;
  final TokenStorage tokenStorage;
  final ThemeService? themeService;

  const MuscleHeatmapApp({
    super.key,
    required this.authService,
    required this.apiClient,
    required this.tokenStorage,
    this.themeService,
  });

  @override
  State<MuscleHeatmapApp> createState() => _MuscleHeatmapAppState();
}

class _MuscleHeatmapAppState extends State<MuscleHeatmapApp> {
  late final GoRouter _router;
  late final ExerciseRepository _exerciseRepository;
  late final WorkoutRepository _workoutRepository;
  late final ThemeService _themeService;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.createRouter(widget.authService);
    _exerciseRepository = ExerciseRepository(apiClient: widget.apiClient);
    _workoutRepository = WorkoutRepository(apiClient: widget.apiClient);
    _themeService = widget.themeService ?? ThemeService();
    if (!_themeService.isInitialized) {
      _themeService.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: widget.authService),
        ChangeNotifierProvider<ThemeService>.value(value: _themeService),
        Provider<ApiClient>.value(value: widget.apiClient),
        Provider<TokenStorage>.value(value: widget.tokenStorage),
        Provider<ExerciseRepository>.value(value: _exerciseRepository),
        Provider<WorkoutRepository>.value(value: _workoutRepository),
        ChangeNotifierProvider<WorkoutViewModel>(
          create: (_) => WorkoutViewModel(
            workoutRepository: _workoutRepository,
            exerciseRepository: _exerciseRepository,
          ),
        ),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) {
          return MaterialApp.router(
            title: 'Muscle Heatmap',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.themeMode,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
