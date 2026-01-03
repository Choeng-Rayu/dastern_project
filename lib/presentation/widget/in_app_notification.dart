import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../providers/medication_provider.dart';
import '../providers/intake_history_provider.dart';
import '../../models/intakeHistory.dart';

/// In-app notification overlay that appears when a reminder is due
class InAppNotification extends StatefulWidget {
  final String medicationId;
  final String medicationName;
  final String dosageInfo;
  final VoidCallback onDismiss;

  const InAppNotification({
    super.key,
    required this.medicationId,
    required this.medicationName,
    required this.dosageInfo,
    required this.onDismiss,
  });

  @override
  State<InAppNotification> createState() => _InAppNotificationState();
}

class _InAppNotificationState extends State<InAppNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);

    _controller.forward();

    // Auto-dismiss after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  void _markAsTaken() async {
    final intakeHistoryProvider =
        Provider.of<IntakeHistoryProvider>(context, listen: false);
    final medicationProvider =
        Provider.of<MedicationProvider>(context, listen: false);

    final medication =
        medicationProvider.getMedicationById(widget.medicationId);
    if (medication != null) {
      final now = DateTime.now();

      // Try to find existing intake history for this time
      final todayIntakes = intakeHistoryProvider.getTodayHistories();
      final existingIntake = todayIntakes.cast<IntakeHistory?>().firstWhere(
            (intake) =>
                intake!.medicationId == widget.medicationId &&
                intake.status == IntakeStatus.pending,
            orElse: () => null,
          );

      if (existingIntake != null) {
        // Mark existing intake as taken
        await intakeHistoryProvider.markAsTaken(existingIntake.id);
      } else {
        // Create new intake history (fallback if no pending intake found)
        final intake = IntakeHistory(
          medicationId: widget.medicationId,
          reminderId: '', // Will be set if available
          scheduledTime: now,
          status: IntakeStatus.taken,
          takenAt: now,
        );

        await intakeHistoryProvider.addHistory(intake);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Marked ${medication.name} as taken'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    _dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4DD0E1).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.medication,
                          color: Color(0xFF4DD0E1),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '💊 ${l10n.reminder}',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.medicationName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.dosageInfo,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _dismiss,
                        icon: const Icon(Icons.close),
                        color: isDarkMode ? Colors.white70 : Colors.grey[600],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _dismiss,
                          icon: const Icon(Icons.remove_circle_outline),
                          label: Text(l10n.skip),
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                isDarkMode ? Colors.white70 : Colors.grey[700],
                            side: BorderSide(
                              color: isDarkMode
                                  ? Colors.white30
                                  : Colors.grey[300]!,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _markAsTaken,
                          icon: const Icon(Icons.check_circle),
                          label: Text(l10n.markAsTaken),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4DD0E1),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Overlay to show in-app notifications
class InAppNotificationOverlay {
  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext context, {
    required String medicationId,
    required String medicationName,
    required String dosageInfo,
  }) {
    // Dismiss any existing notification
    dismiss();

    _currentEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top,
        left: 0,
        right: 0,
        child: InAppNotification(
          medicationId: medicationId,
          medicationName: medicationName,
          dosageInfo: dosageInfo,
          onDismiss: () => dismiss(),
        ),
      ),
    );

    Overlay.of(context).insert(_currentEntry!);
  }

  static void dismiss() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}
