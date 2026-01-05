import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; //
import 'core/service_locator.dart' as sl;
import 'features/app_management/presentation/cubit/dashboard_cubit.dart';
import 'features/app_management/presentation/cubit/categorization_cubit.dart';
import 'features/app_management/presentation/cubit/settings_cubit.dart';
import 'features/app_management/presentation/pages/main_wrapper.dart';
import 'features/app_management/presentation/pages/screens.dart';
import 'core/routes.dart';
import 'core/services/notification_service.dart';
import 'core/services/background_service.dart';
import 'core/theme/app_visuals.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Ladda .env filen för att aktivera Gemini API-nyckeln
  await dotenv.load(fileName: "assets/.env");
  
  // 2. Initialize Hive
  await Hive.initFlutter();
  
  // 3. Initialize Service Locator (GetIt)
  await sl.init();
  
  // 4. Initialize Notifications
  await NotificationService.initialize(
    onBackgroundNotificationResponse: notificationTapBackground,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardCubit>(
          create: (context) => sl.sl<DashboardCubit>(),
        ),
        BlocProvider<CategorizationCubit>(
          create: (context) => sl.sl<CategorizationCubit>(),
        ),
        BlocProvider<SettingsCubit>(
          create: (context) => sl.sl<SettingsCubit>(),
        ),
      ],
      child: MaterialApp(
        title: 'ScreenTime',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            surface: AppColors.background,
          ),
          scaffoldBackgroundColor: AppColors.background,
          cardTheme: CardThemeData(
            color: AppColors.surface,
            elevation: 0,
            shape: const RoundedRectangleBorder(borderRadius: AppShapes.cardBorder),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppShapes.buttonRadius),
              ),
            ),
          ),
          textTheme: const TextTheme(
            displayMedium: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
            bodyMedium: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        initialRoute: AppRoutes.mainWrapper,
        routes: {
          AppRoutes.mainWrapper: (context) => const MainWrapper(),
          AppRoutes.preferences: (context) => const PreferencesScreen(),
          AppRoutes.categorization: (context) => const CategorizationScreen(),
          AppRoutes.settings: (context) => const SettingsScreen(),
        },
      ),
    );
  }
}