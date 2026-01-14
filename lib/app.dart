import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:device_preview/device_preview.dart';

import 'l10n/app_localizations.dart';
import 'services/settings_service.dart';
import 'services/auth_service.dart';
import 'services/reminder_service.dart';
import 'services/medication_service.dart';
import 'services/intake_history_service.dart';
import 'services/notification_service.dart';
import 'presentation/theme/theme.dart';
import 'presentation/screens/main_navigation_screen.dart';
import 'presentation/screens/welcome_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/intake_history_screen.dart';
import 'presentation/screens/today_reminders_screen.dart';
import 'presentation/widget/in_app_notification.dart';

/// Main application widget with theming and localization setup
class DasternApp extends StatefulWidget {
  final NotificationService notificationService;
  final SettingsService settingsService;
  final AuthService authService;
  final MedicationService medicationService;
  final ReminderService reminderService;
  final IntakeHistoryService intakeHistoryService;

  const DasternApp({
    super.key,
    required this.notificationService,
    required this.settingsService,
    required this.authService,
    required this.medicationService,
    required this.reminderService,
    required this.intakeHistoryService,
  });

  @override
  State<DasternApp> createState() => _DasternAppState();
}

class _DasternAppState extends State<DasternApp> with WidgetsBindingObserver {
  OverlayEntry? _currentNotificationOverlay;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  // Local state for theme and locale
  late ThemeMode _themeMode;
  late Locale _locale;
  late bool _isLoggedIn;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize local state from services
    _themeMode = widget.settingsService.themeMode;
    _locale = widget.settingsService.locale;
    _isLoggedIn = widget.authService.isLoggedIn;
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

  /// Update theme mode and refresh UI
  void updateThemeMode(ThemeMode mode) async {
    await widget.settingsService.setThemeMode(mode);
    setState(() {
      _themeMode = mode;
    });
  }

  /// Update locale and refresh UI
  void updateLocale(Locale locale) async {
    await widget.settingsService.setLocale(locale);
    setState(() {
      _locale = locale;
    });
  }

  /// Update login state and navigate accordingly
  void updateLoginState(bool isLoggedIn) {
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
    
    // Navigate based on login state
    if (isLoggedIn) {
      _navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => _buildMainNavigation()),
        (route) => false,
      );
    } else {
      _navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => _buildWelcomeScreen()),
        (route) => false,
      );
    }
  }

  /// Check for reminders that are due now and show in-app notifications
  void _checkForDueReminders() {
    if (!mounted) return;

    if (!widget.authService.isLoggedIn) return;

    final now = DateTime.now();
    const Duration checkWindow = Duration(minutes: 10); // Check last 10 minutes

    // Find reminders that are due (within last 10 minutes and not yet in the future)
    final dueReminders = widget.reminderService.reminders.where((reminder) {
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
          widget.medicationService.medications.cast<dynamic>().firstWhere(
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
        intakeHistoryService: widget.intakeHistoryService,
        medicationService: widget.medicationService,
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

  /// Build Welcome Screen
  Widget _buildWelcomeScreen() {
    return WelcomeScreen(
      settingsService: widget.settingsService,
      onLocaleChanged: updateLocale,
    );
  }

  /// Build Main Navigation Screen
  Widget _buildMainNavigation() {
    return MainNavigationScreen(
      authService: widget.authService,
      medicationService: widget.medicationService,
      reminderService: widget.reminderService,
      intakeHistoryService: widget.intakeHistoryService,
      settingsService: widget.settingsService,
      notificationService: widget.notificationService,
      onThemeChanged: updateThemeMode,
      onLocaleChanged: updateLocale,
      onLogout: () => updateLoginState(false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Application metadata
      title: 'DasTern',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,

      // Locale - use our state directly (DevicePreview can override in debug)
      locale: _locale,
      builder: DevicePreview.appBuilder,

      // Localization configuration
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
      themeMode: _themeMode,

      // Initial screen based on login state
      home: _isLoggedIn ? _buildMainNavigation() : _buildWelcomeScreen(),

      // Named routes for navigation
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(
              builder: (_) => LoginScreen(
                authService: widget.authService,
                medicationService: widget.medicationService,
                reminderService: widget.reminderService,
                intakeHistoryService: widget.intakeHistoryService,
                onLoginSuccess: () => updateLoginState(true),
              ),
            );
          case '/register':
            return MaterialPageRoute(
              builder: (_) => RegisterScreen(
                authService: widget.authService,
                onRegisterSuccess: () => updateLoginState(true),
              ),
            );
          case '/today-reminders':
            return MaterialPageRoute(
              builder: (_) => TodayRemindersScreen(
                reminderService: widget.reminderService,
                medicationService: widget.medicationService,
                intakeHistoryService: widget.intakeHistoryService,
              ),
            );
          case '/intake-history':
            return MaterialPageRoute(
              builder: (_) => IntakeHistoryScreen(
                medicationService: widget.medicationService,
                intakeHistoryService: widget.intakeHistoryService,
              ),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => _isLoggedIn 
                ? _buildMainNavigation() 
                : _buildWelcomeScreen(),
            );
        }
      },
    );
  }
}

