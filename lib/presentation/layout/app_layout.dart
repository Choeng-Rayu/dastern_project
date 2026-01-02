import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';
import '../theme/theme.dart';

/// Base layout widget that provides consistent theming across all screens
/// Handles light/dark mode backgrounds and adaptive colors
class AppLayout extends StatelessWidget {
  final Widget child;
  final bool useGradientBackground;
  final Color? customBackgroundColor;
  final bool showAppBar;
  final String? appBarTitle;
  final List<Widget>? appBarActions;
  final Widget? floatingActionButton;
  final bool extendBodyBehindAppBar;
  final PreferredSizeWidget? customAppBar;
  final Widget? bottomNavigationBar;

  const AppLayout({
    super.key,
    required this.child,
    this.useGradientBackground = false,
    this.customBackgroundColor,
    this.showAppBar = false,
    this.appBarTitle,
    this.appBarActions,
    this.floatingActionButton,
    this.extendBodyBehindAppBar = false,
    this.customAppBar,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Determine background
    Color backgroundColor;
    if (customBackgroundColor != null) {
      backgroundColor = customBackgroundColor!;
    } else if (useGradientBackground) {
      backgroundColor = isDarkMode
          ? const Color(0xFF1A3A3F) // Dark teal
          : AppTheme.primaryColor;
    } else {
      backgroundColor = theme.scaffoldBackgroundColor;
    }

    Widget body = child;

    // Wrap with gradient if needed
    if (useGradientBackground) {
      body = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    const Color(0xFF1A3A3F),
                    const Color(0xFF0D2026),
                  ]
                : [
                    AppTheme.primaryColor,
                    AppTheme.primaryDark,
                  ],
          ),
        ),
        child: child,
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: customAppBar ??
          (showAppBar
              ? AppBar(
                  title: appBarTitle != null ? Text(appBarTitle!) : null,
                  actions: appBarActions,
                  backgroundColor: isDarkMode
                      ? theme.appBarTheme.backgroundColor
                      : AppTheme.primaryColor,
                )
              : null),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

/// Extension methods for theme-aware colors
extension ThemeContext on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get primaryColor => AppTheme.primaryColor;

  Color get cardColor => isDarkMode ? const Color(0xFF2C2C2C) : Colors.white;

  Color get surfaceColor => isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

  Color get textPrimaryColor =>
      isDarkMode ? Colors.white : const Color(0xFF1A1A1A);

  Color get textSecondaryColor =>
      isDarkMode ? Colors.white70 : const Color(0xFF666666);

  Color get dividerColor =>
      isDarkMode ? const Color(0xFF404040) : Colors.grey[300]!;

  Color get overlayColor => isDarkMode
      ? Colors.white.withOpacity(0.1)
      : Colors.white.withOpacity(0.3);

  // Status colors that work well in both modes
  Color get takenColor => AppTheme.takenColor;
  Color get missedColor => AppTheme.missedColor;
  Color get skippedColor => AppTheme.skippedColor;
  Color get pendingColor => AppTheme.pendingColor;
  Color get delayedColor => AppTheme.delayedColor;
}

/// Theme-aware card widget
class ThemedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final VoidCallback? onTap;

  const ThemedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: elevation ?? 2,
      color: color ?? theme.cardTheme.color,
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

/// Theme-aware status badge
class StatusBadge extends StatelessWidget {
  final String status;
  final bool isSmall;

  const StatusBadge({
    super.key,
    required this.status,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = AppTheme.getStatusColor(status);

    String label;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'taken':
        label = l10n.taken;
        icon = Icons.check_circle;
        break;
      case 'missed':
        label = l10n.missed;
        icon = Icons.cancel;
        break;
      case 'skipped':
        label = l10n.skipped;
        icon = Icons.remove_circle_outline;
        break;
      case 'delayed':
        label = l10n.delayed;
        icon = Icons.watch_later;
        break;
      case 'pending':
      default:
        label = l10n.pending;
        icon = Icons.schedule;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isSmall ? 14 : 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Theme-aware section header
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Theme-aware empty state widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: context.textSecondaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: context.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
