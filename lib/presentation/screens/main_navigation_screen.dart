import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../services/medication_service.dart';
import '../../services/reminder_service.dart';
import '../../services/intake_history_service.dart';
import '../../services/settings_service.dart';
import '../../services/notification_service.dart';
import './dashboard_screen.dart';
import './medications_screen.dart';
import './medicine_form_screen.dart';
import './profile_screen.dart';

/// App navigation tabs
enum AppTab { dashboard, medicineList, addMedicine, profile }

/// Main navigation screen with bottom navigation bar using IndexedStack
class MainNavigationScreen extends StatefulWidget {
  final AuthService authService;
  final MedicationService medicationService;
  final ReminderService reminderService;
  final IntakeHistoryService intakeHistoryService;
  final SettingsService settingsService;
  final NotificationService notificationService;
  final void Function(ThemeMode) onThemeChanged;
  final void Function(Locale) onLocaleChanged;
  final VoidCallback onLogout;

  const MainNavigationScreen({
    super.key,
    required this.authService,
    required this.medicationService,
    required this.reminderService,
    required this.intakeHistoryService,
    required this.settingsService,
    required this.notificationService,
    required this.onThemeChanged,
    required this.onLocaleChanged,
    required this.onLogout,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  AppTab _currentTab = AppTab.dashboard;
  bool _isShowingMedicineForm = false;
  
  // Navigator keys for nested navigation
  final _medicationsNavigatorKey = GlobalKey<NavigatorState>();

  void _onTabSelected(int index) {
    final selectedTab = AppTab.values[index];
    
    // If "Add Medicine" tab is selected, push the form screen in medications tab
    if (selectedTab == AppTab.addMedicine) {
      // Switch to medications tab content but highlight Add Medicine
      setState(() {
        _currentTab = AppTab.medicineList;
        _isShowingMedicineForm = true;
      });
      // Then push the form screen using the nested navigator
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _medicationsNavigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => MedicineFormScreen(
              medicationService: widget.medicationService,
              reminderService: widget.reminderService,
              notificationService: widget.notificationService,
              onSaved: () {
                setState(() {});
              },
            ),
          ),
        ).then((_) {
          // When form is popped, switch back to Medicine List highlight
          if (mounted) {
            setState(() {
              _isShowingMedicineForm = false;
            });
          }
        });
      });
      return;
    }

    // If clicking Medicine List tab while showing form, clear the nested navigation
    if (selectedTab == AppTab.medicineList && _isShowingMedicineForm) {
      _medicationsNavigatorKey.currentState?.popUntil((route) => route.isFirst);
      setState(() {
        _isShowingMedicineForm = false;
      });
      return;
    }

    // Pop to root when switching away from medications tab
    if (_currentTab == AppTab.medicineList && selectedTab != AppTab.medicineList) {
      _medicationsNavigatorKey.currentState?.popUntil((route) => route.isFirst);
      _isShowingMedicineForm = false;
    }

    setState(() {
      _currentTab = selectedTab;
      _isShowingMedicineForm = false;
    });
  }

  void _onMedicationChanged() {
    // Refresh UI when medications change
    setState(() {});
  }

  void _switchToMedicineList() {
    setState(() {
      _currentTab = AppTab.medicineList;
      _isShowingMedicineForm = false;
    });
  }

  /// Called when navigating to medicine form from medications screen
  void _onNavigateToForm() {
    setState(() {
      _isShowingMedicineForm = true;
    });
  }

  /// Called when returning from medicine form
  void _onReturnFromForm() {
    if (mounted) {
      setState(() {
        _isShowingMedicineForm = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentTab.index,
        children: [
          // Dashboard
          DashboardScreen(
            authService: widget.authService,
            medicationService: widget.medicationService,
            reminderService: widget.reminderService,
            intakeHistoryService: widget.intakeHistoryService,
            onViewAllMedications: _switchToMedicineList,
          ),
          // Medicine List with nested Navigator
          Navigator(
            key: _medicationsNavigatorKey,
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => MedicationsScreen(
                  medicationService: widget.medicationService,
                  reminderService: widget.reminderService,
                  notificationService: widget.notificationService,
                  onMedicationChanged: _onMedicationChanged,
                  navigatorKey: _medicationsNavigatorKey,
                  onNavigateToForm: _onNavigateToForm,
                  onReturnFromForm: _onReturnFromForm,
                ),
              );
            },
          ),
          // Placeholder for Add Medicine (handled by navigation)
          const SizedBox.shrink(),
          // Profile
          ProfileScreen(
            settingsService: widget.settingsService,
            authService: widget.authService,
            notificationService: widget.notificationService,
            onThemeChanged: widget.onThemeChanged,
            onLocaleChanged: widget.onLocaleChanged,
            onLogout: widget.onLogout,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _isShowingMedicineForm ? AppTab.addMedicine.index : _currentTab.index,
        onDestinationSelected: _onTabSelected,
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
        indicatorColor: theme.colorScheme.primary.withOpacity(0.3),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.dashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.medication_outlined),
            selectedIcon: const Icon(Icons.medication),
            label: l10n.medicineList,
          ),
          NavigationDestination(
            icon: const Icon(Icons.add_circle_outline),
            selectedIcon: const Icon(Icons.add_circle),
            label: l10n.addMedicine,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
