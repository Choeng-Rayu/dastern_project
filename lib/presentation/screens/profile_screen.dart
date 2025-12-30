import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/l10n/app_localizations.dart';
import '/presentation/providers/settings_provider.dart';

/// Profile screen - User settings and preferences
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF4DD0E1), // Light blue/cyan
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.profile,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),

            // Theme Toggle
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              child: SwitchListTile(
                title: Text(l10n.theme),
                subtitle: Text(
                  settingsProvider.isDarkMode ? l10n.darkMode : l10n.lightMode,
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
              margin: const EdgeInsets.symmetric(horizontal: 32),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.language,
                      style: const TextStyle(fontSize: 16),
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
          ],
        ),
      ),
    );
  }
}
