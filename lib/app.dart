import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'l10n/app_localizations.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/theme/theme.dart';
import 'presentation/screens/main_navigation_screen.dart';
import 'presentation/screens/welcome_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/medications_screen.dart';
import 'presentation/screens/medicine_form_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/intake_history_screen.dart';
import 'presentation/screens/today_reminders_screen.dart';

/// Main application widget with theming and localization setup
class DasternApp extends StatelessWidget {
  const DasternApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, AuthProvider>(
      builder: (context, settings, auth, child) {
        final router = _createRouter(auth);

        return MaterialApp.router(
          // Application metadata
          title: 'DasTern',
          debugShowCheckedModeBanner: false,

          // Localization configuration
          locale: settings.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('km'), // Khmer
          ],

          // Theme configuration - using centralized AppTheme
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,

          // Router configuration
          routerConfig: router,
        );
      },
    );
  }

  /// Create GoRouter configuration
  GoRouter _createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final isLoggedIn = authProvider.isLoggedIn;
        final isLoading = authProvider.isLoading;

        // Wait for auth to initialize
        if (isLoading) {
          return null;
        }

        final isAuthRoute = state.matchedLocation == '/' ||
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';

        // If not logged in and trying to access protected route, redirect to welcome
        if (!isLoggedIn && !isAuthRoute) {
          return '/';
        }

        // If logged in and on auth route, redirect to dashboard
        if (isLoggedIn && isAuthRoute) {
          return '/dashboard';
        }

        return null;
      },
      routes: [
        // Welcome Screen
        GoRoute(
          path: '/',
          builder: (context, state) => const WelcomeScreen(),
        ),

        // Login Screen
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),

        // Register Screen
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),

        // Main App Navigation (Dashboard, Medicine List, etc.)
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainNavigationScreen(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/dashboard',
                  builder: (context, state) => const DashboardScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/medicine-list',
                  builder: (context, state) => const MedicationsScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/medicine-form',
                  builder: (context, state) => const MedicineFormScreen(),
                ),
              ],
            ),
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

        // Standalone screens
        GoRoute(
          path: '/today-reminders',
          builder: (context, state) => const TodayRemindersScreen(),
        ),
        GoRoute(
          path: '/intake-history',
          builder: (context, state) => const IntakeHistoryScreen(),
        ),
      ],
    );
  }
}
