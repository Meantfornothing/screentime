import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/service_locator.dart' as sl;
import 'features/app_management/presentation/cubit/dashboard_cubit.dart';
import 'features/app_management/presentation/cubit/categorization_cubit.dart';
import 'features/app_management/presentation/cubit/settings_cubit.dart';
import 'features/app_management/presentation/pages/main_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize Service Locator (GetIt)
  // Removed await because init() is defined as void in service_locator.dart
  sl.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // We provide the Cubits globally here so any screen (Dashboard, Settings, etc.)
      // can access them via context.read or context.watch.
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
          primarySwatch: Colors.blue,
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const MainWrapper(),
      ),
    );
  }
}