import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_container.dart';
import '../domain/one_rep_max_calculator.dart';

/// Modal dialog celebrating a new Personal Record (PR) breakthrough
/// styled with luxury gold/amber frosted glass and celebratory metrics.
class PrCelebrationDialog extends StatefulWidget {
  final String exerciseName;
  final PersonalRecordResult prResult;
  final VoidCallback? onStartRestTimer;

  const PrCelebrationDialog({
    super.key,
    required this.exerciseName,
    required this.prResult,
    this.onStartRestTimer,
  });

  static Future<void> show(
    BuildContext context, {
    required String exerciseName,
    required PersonalRecordResult prResult,
    VoidCallback? onStartRestTimer,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => PrCelebrationDialog(
        exerciseName: exerciseName,
        prResult: prResult,
        onStartRestTimer: onStartRestTimer,
      ),
    );
  }

  @override
  State<PrCelebrationDialog> createState() => _PrCelebrationDialogState();
}

class _PrCelebrationDialogState extends State<PrCelebrationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final res = widget.prResult;

    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Material(
            type: MaterialType.transparency,
            child: GlassContainer(
              borderRadius: 28,
              blur: 24,
              opacity: isDark ? 0.6 : 0.95,
              borderColor: const Color(0xFFFFD700).withValues(alpha: 0.8),
              borderWidth: 2.0,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Trophy Glow
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFFFD700).withValues(alpha: 0.4),
                          const Color(0xFFFF8C00).withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        '🏆',
                        style: TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Celebration Headline
                  const Text(
                    'NEW PERSONAL RECORD!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.exerciseName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Lifted Weight',
                          value: '${res.newWeight} kg',
                          diff: res.previousMaxWeight != null && res.weightDiff > 0
                              ? '+${res.weightDiff.toStringAsFixed(1)} kg'
                              : (res.isFirstLog ? 'Initial PR' : null),
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Estimated 1RM',
                          value: '${res.new1RM} kg',
                          diff: res.previous1RM != null && res.oneRmDiff > 0
                              ? '+${res.oneRmDiff.toStringAsFixed(1)} kg'
                              : null,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      if (widget.onStartRestTimer != null) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(
                                color: AppColors.primary.withValues(alpha: 0.5),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.timer_outlined, size: 18),
                            label: const Text(
                              'Rest Timer',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              widget.onStartRestTimer?.call();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: Colors.black,
                            elevation: 4,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Keep Crushing It 💪',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
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

  Widget _buildMetricCard({
    required String title,
    required String value,
    String? diff,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (diff != null) ...[
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.heatmapOptimal.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                diff,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.heatmapOptimal,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
