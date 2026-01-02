import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '/l10n/app_localizations.dart';
import '../providers/settings_provider.dart';

/// Welcome screen - First screen users see
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4DD0E1), // Light cyan
              Color(0xFF26C6DA), // Slightly darker cyan
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Settings Row at the top
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Language Selector
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: DropdownButton<String>(
                              value: settingsProvider.locale.languageCode,
                              underline: const SizedBox(),
                              dropdownColor: const Color(0xFF4DD0E1),
                              icon: const Icon(Icons.language,
                                  color: Colors.white),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
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
                          ),

                          // Theme Toggle
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  settingsProvider.isDarkMode
                                      ? Icons.dark_mode
                                      : Icons.light_mode,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                Switch(
                                  value: settingsProvider.isDarkMode,
                                  onChanged: (bool value) {
                                    settingsProvider.setThemeMode(
                                      value ? ThemeMode.dark : ThemeMode.light,
                                    );
                                  },
                                  activeColor: Colors.white,
                                  activeTrackColor:
                                      Colors.white.withOpacity(0.5),
                                  inactiveThumbColor:
                                      Colors.white.withOpacity(0.7),
                                  inactiveTrackColor:
                                      Colors.white.withOpacity(0.3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // App Logo/Icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.medication_liquid,
                          size: 60,
                          color: Color(0xFF4DD0E1),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // App Name
                      const Text(
                        'DasTern',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Tagline
                      Text(
                        l10n.welcomeMessage,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const Spacer(),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            context.push('/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF4DD0E1),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            l10n.login,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () {
                            context.push('/register');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side:
                                const BorderSide(color: Colors.white, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            l10n.register,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
