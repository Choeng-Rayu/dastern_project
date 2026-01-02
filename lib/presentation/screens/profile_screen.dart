import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '/l10n/app_localizations.dart';
import '/presentation/providers/settings_provider.dart';
import '/presentation/providers/auth_provider.dart';
import '/services/notification_service.dart';

/// Profile screen - User settings and preferences
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF4DD0E1), // Light blue/cyan
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Text(
                  l10n.profile,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                if (authProvider.userName != null)
                  Text(
                    '${l10n.hello}, ${authProvider.userName}!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                const SizedBox(height: 32),

                // User Info Card
                if (authProvider.userPhone != null)
                  Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading:
                          const Icon(Icons.phone, color: Color(0xFF4DD0E1)),
                      title: Text(l10n.phoneNumber),
                      subtitle: Text(authProvider.userPhone!),
                    ),
                  ),
                const SizedBox(height: 16),

                // Theme Toggle
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SwitchListTile(
                    title: Text(l10n.theme),
                    subtitle: Text(
                      settingsProvider.isDarkMode
                          ? l10n.darkMode
                          : l10n.lightMode,
                    ),
                    secondary: Icon(
                      settingsProvider.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: const Color(0xFF4DD0E1),
                    ),
                    value: settingsProvider.isDarkMode,
                    onChanged: (bool value) {
                      settingsProvider.setThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Language Selector
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.language, color: Color(0xFF4DD0E1)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            l10n.language,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        DropdownButton<String>(
                          value: settingsProvider.locale.languageCode,
                          underline: const SizedBox(),
                          items: [
                            DropdownMenuItem(
                              value: 'en',
                              child: Text(l10n.english),
                            ),
                            DropdownMenuItem(
                              value: 'km',
                              child: Text(l10n.khmer),
                            ),
                          ],
                          onChanged: (String? value) {
                            if (value != null) {
                              settingsProvider.setLocale(Locale(value));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Test Notification Button (for development)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final notificationService =
                          Provider.of<NotificationService>(
                        context,
                        listen: false,
                      );
                      await notificationService.showNotification(
                        title: '💊 Test Notification',
                        body:
                            'This is a test medication reminder! Check your notification bar.',
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Test notification sent! Check your notification bar.'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.notifications_active),
                    label: const Text('Test Notification'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4DD0E1),
                      side: const BorderSide(color: Color(0xFF4DD0E1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Show confirmation dialog
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l10n.logout),
                          content: Text(l10n.logoutConfirmation),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(l10n.cancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text(l10n.logout),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && context.mounted) {
                        await authProvider.logout();
                        if (context.mounted) {
                          context.go('/');
                        }
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: Text(
                      l10n.logout,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
