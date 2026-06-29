import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:splitly_member/repository/household_status_repository.dart';
import 'package:splitly_member/repository/quotas_repository.dart';
import 'repository/dashboard_repository.dart';
import 'repository/settings_repository.dart';
import 'repository/auth_repository.dart';
import 'bloc/household_status/household_status_bloc.dart';
import 'bloc/quotas/quotas_bloc.dart';
import 'bloc/dashboard/dashboard_bloc.dart';
import 'bloc/settings/settings_bloc.dart';
import 'bloc/auth_bloc.dart';
import 'db/local_database.dart';
import 'views/sign_in_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => LocalDatabase()),
        RepositoryProvider(
          create: (context) => QuotasRepository(
            localDatabase: context.read<LocalDatabase>(),
          ),
        ),
        RepositoryProvider(
          create: (context) => DashboardRepository(
            localDatabase: context.read<LocalDatabase>(),
          ),
        ),
        RepositoryProvider(
          create: (context) => HouseholdStatusRepository(
            localDatabase: context.read<LocalDatabase>(),
          ),
        ),
        RepositoryProvider(
          create: (context) => SettingsRepository(
            localDatabase: context.read<LocalDatabase>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
              localDatabase: context.read<LocalDatabase>(),
            ),
          ),
          BlocProvider(
            create: (context) => HouseholdStatusBloc(
              repository: context.read<HouseholdStatusRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => QuotasBloc(
              repository: context.read<QuotasRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => DashboardBloc(
              repository: context.read<DashboardRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => SettingsBloc(
              repository: context.read<SettingsRepository>(),
            )..add(LoadSettings()),
          ),
        ],
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
            bool isDark = false;
            if (settingsState is SettingsLoaded) {
              isDark = settingsState.data.darkMode;
            }
            return MaterialApp(
              title: 'Split House App',
              themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
              theme: ThemeData(
                brightness: Brightness.light,
                primaryColor: const Color(0xFF6366F1),
                scaffoldBackgroundColor: const Color(0xFFF8FAFC),
                cardColor: Colors.white,
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF6366F1),
                  surface: Colors.white,
                  background: Color(0xFFF8FAFC),
                ),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF1E293B),
                  elevation: 0,
                ),
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                primaryColor: const Color(0xFF6366F1),
                scaffoldBackgroundColor: const Color(0xFF0F172A),
                cardColor: const Color(0xFF1E293B),
                colorScheme: const ColorScheme.dark(
                  primary: Color(0xFF6366F1),
                  surface: Color(0xFF1E293B),
                  background: Color(0xFF0F172A),
                ),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color(0xFF1E293B),
                  foregroundColor: Color(0xFFF1F5F9),
                  elevation: 0,
                ),
              ),
              home: const SignInView(),
            );
          },
        ),
      ),
    );
  }
}