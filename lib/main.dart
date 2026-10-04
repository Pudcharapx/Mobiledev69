import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/dormmate_theme.dart';
import 'core/theme/dormmate_theme_presets.dart';
import 'core/theme/dormmate_theme_service.dart';
import 'core/localization/language_service.dart';
import 'core/widgets/ambient_mesh_background.dart';
import 'core/routing/dormmate_router.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'repositories/auth_repository.dart';
import 'repositories/room_repository.dart';
import 'repositories/expense_repository.dart';
import 'repositories/maintenance_repository.dart';
import 'repositories/announcement_repository.dart';
import 'repositories/profile_repository.dart';
import 'repositories/parcel_repository.dart';
import 'repositories/facility_repository.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/expense_viewmodel.dart';
import 'viewmodels/maintenance_viewmodel.dart';
import 'viewmodels/announcement_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'viewmodels/parcel_viewmodel.dart';
import 'viewmodels/facility_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Services layer (stateless HTTP, storage, themes & localization)
  final apiService = ApiService();
  final authService = AuthService(apiService: apiService);
  final themeService = DormMateThemeService();
  await themeService.initialize();
  final languageService = LanguageService();
  await languageService.initialize();

  // 2. Repositories layer (constructor injection)
  final authRepo = AuthRepositoryImpl(authService);
  final roomRepo = RoomRepositoryImpl(apiService);
  final expenseRepo = ExpenseRepositoryImpl(apiService);
  final maintenanceRepo = MaintenanceRepositoryImpl(apiService);
  final announcementRepo = AnnouncementRepositoryImpl(apiService);
  final profileRepo = ProfileRepositoryImpl(apiService);
  final parcelRepo = ParcelRepositoryImpl();
  final facilityRepo = FacilityRepositoryImpl();

  // 3. ViewModels layer (receives repositories via constructor)
  final authViewModel = AuthViewModel(authRepo);
  final homeViewModel = HomeViewModel(
    roomRepository: roomRepo,
    expenseRepository: expenseRepo,
    maintenanceRepository: maintenanceRepo,
    announcementRepository: announcementRepo,
    authRepository: authRepo,
  );
  final expenseViewModel = ExpenseViewModel(expenseRepo);
  final maintenanceViewModel = MaintenanceViewModel(maintenanceRepo);
  final announcementViewModel = AnnouncementViewModel(announcementRepo);
  final profileViewModel = ProfileViewModel(
    profileRepository: profileRepo,
    authRepository: authRepo,
  );
  final parcelViewModel = ParcelViewModel(parcelRepo);
  final facilityViewModel = FacilityViewModel(facilityRepo);

  // Check saved credentials / OIDC token
  await authViewModel.checkAuthStatus();

  // 4. Router
  final router = createDormMateRouter(authViewModel);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeService),
        ChangeNotifierProvider.value(value: languageService),
        ChangeNotifierProvider.value(value: authViewModel),
        ChangeNotifierProvider.value(value: homeViewModel),
        ChangeNotifierProvider.value(value: expenseViewModel),
        ChangeNotifierProvider.value(value: maintenanceViewModel),
        ChangeNotifierProvider.value(value: announcementViewModel),
        ChangeNotifierProvider.value(value: profileViewModel),
        ChangeNotifierProvider.value(value: parcelViewModel),
        ChangeNotifierProvider.value(value: facilityViewModel),
      ],
      child: DormMateApp(
        router: router,
        themeService: themeService,
        languageService: languageService,
      ),
    ),
  );
}

class DormMateApp extends StatelessWidget {
  final dynamic router;
  final DormMateThemeService? themeService;
  final LanguageService? languageService;

  const DormMateApp({
    super.key,
    required this.router,
    this.themeService,
    this.languageService,
  });

  @override
  Widget build(BuildContext context) {
    DormMateThemeService? svc = themeService;
    LanguageService? langSvc = languageService;
    try {
      svc ??= Provider.of<DormMateThemeService>(context, listen: false);
    } catch (_) {}
    try {
      langSvc ??= Provider.of<LanguageService>(context, listen: false);
    } catch (_) {}

    Widget buildApp(DormMateThemeService? s, LanguageService? l) {
      final lightTheme = s?.lightTheme ?? buildDormMateTheme();
      final darkTheme = s?.darkTheme ?? buildDormMateTheme(preset: DormMateThemePreset.dark);
      final themeMode = s?.themeMode ?? ThemeMode.light;
      final locale = l?.locale ?? const Locale('en');

      return MaterialApp.router(
        title: 'DormMate',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeMode,
        locale: locale,
        supportedLocales: const [
          Locale('en'),
          Locale('th'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: router,
        builder: (context, child) => AmbientMeshBackground(
          child: child ?? const SizedBox.shrink(),
        ),
      );
    }

    final listenables = <Listenable>[
      if (svc != null) svc,
      if (langSvc != null) langSvc,
    ];

    if (listenables.isNotEmpty) {
      return ListenableBuilder(
        listenable: Listenable.merge(listenables),
        builder: (context, _) => buildApp(svc, langSvc),
      );
    }

    return buildApp(null, null);
  }
}
