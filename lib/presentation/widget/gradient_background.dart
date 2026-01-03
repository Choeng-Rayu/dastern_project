import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Reusable gradient background widget for consistent screen backgrounds
class GradientBackground extends StatelessWidget {
  final Widget child;
  final bool isDarkMode;

  const GradientBackground({
    super.key,
    required this.child,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppTheme.getBackgroundGradient(isDarkMode),
        ),
      ),
      child: child,
    );
  }
}
