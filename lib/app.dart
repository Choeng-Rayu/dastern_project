import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'l10n/app_localizations.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/reminder_provider.dart';
import 'presentation/providers/medication_provider.dart';
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
import 'presentation/widgets/in_app_notification.dart';

/// Main application widget with theming and localization setup
class DasternApp extends StatefulWidget {
  const DasternApp({super.key});

  @override
  State<DasternApp> createState() => _DasternAppState();
}

class _DasternAppState extends State<DasternApp> with WidgetsBindingObserver {
  OverlayEntry? _currentNotificationOverlay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Check for due reminders when app is resumed/opened
    if (state == AppLifecycleState.resumed) {
      _checkForDueReminders();
    }
  }

  /// Check for reminders that are due now and show in-app notifications
  void _checkForDueReminders() {
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) return;

    final reminderProvider = context.read<ReminderProvider>();
    final medicationProvider = context.read<MedicationProvider>();

    final now = DateTime.now();
    const Duration checkWindow = Duration(minutes: 10); // Check last 10 minutes

    // Find reminders that are due (within last 10 minutes and not yet in the future)
    final dueReminders = reminderProvider.reminders.where((reminder) {
      if (!reminder.isActive) return false;

      final reminderTime = DateTime(
        now.year,
        now.month,
        now.day,
        reminder.time.hour,
        reminder.time.minute,
      );

      // Check if reminder is due (within last 10 minutes)
      final difference = now.difference(reminderTime);
      return difference.isNegative == false &&
          difference.inMinutes <= checkWindow.inMinutes;
    }).toList();

    // Show in-app notification for each due reminder
    for (final reminder in dueReminders) {
      final medication =
          medicationProvider.medications.cast<dynamic>().firstWhere(
                (med) => med.id == reminder.medicationId,
                orElse: () => null,
              );

      if (medication != null) {
        _showInAppNotification(reminder, medication);
        break; // Show only one notification at a time
      }
    }
  }

  /// Show in-app notification overlay
  void _showInAppNotification(dynamic reminder, dynamic medication) {
    if (!mounted) return;

    // Dismiss any existing notification
    _currentNotificationOverlay?.remove();
    _currentNotificationOverlay = null;

    final overlay = Overlay.of(context);

    _currentNotificationOverlay = OverlayEntry(
      builder: (context) => InAppNotification(
        medicationId: medication.id,
        medicationName: medication.name,
        dosageInfo:
            '${reminder.dosageAmount} ${_getUnitString(medication.dosage.unit)}',
        onDismiss: () {
          _currentNotificationOverlay?.remove();
          _currentNotificationOverlay = null;
        },
      ),
    );

    overlay.insert(_currentNotificationOverlay!);
  }

  String _getUnitString(dynamic unit) {
    final unitStr = unit.toString().split('.').last;
    switch (unitStr) {
      case 'tablet':
        return 'tablet(s)';
      case 'ml':
        return 'ml';
      case 'mg':
        return 'mg';
      case 'other':
        return 'dose(s)';
      default:
        return '';
    }
  }

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
