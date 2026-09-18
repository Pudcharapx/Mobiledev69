import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/rest_timer_service.dart';
import '../theme/app_colors.dart';
import 'glass_container.dart';

/// FloatingGlassRestTimer displays a frosted glass timer overlay
/// that floats above content and allows gym-goers to track rest intervals
/// with haptics, quick time extensions, and play/pause controls.
class FloatingGlassRestTimer extends StatefulWidget {
  final VoidCallback? onDismiss;

  const FloatingGlassRestTimer({super.key, this.onDismiss});

  @override
  State<FloatingGlassRestTimer> createState() => _FloatingGlassRestTimerState();
}

class _FloatingGlassRestTimerState extends State<FloatingGlassRestTimer> {
  bool _isMinimized = false;

  @override
  Widget build(BuildContext context) {
    final timerService = context.watch<RestTimerService>();

    if (!timerService.isVisible) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isMinimized) {
      return _buildMinimizedPill(context, timerService, isDark);
    }

    return _buildExpandedCard(context, timerService, isDark);
  }

  Widget _buildMinimizedPill(
    BuildContext context,
    RestTimerService timer,
    bool isDark,
  ) {
    return Positioned(
      bottom: 80,
      right: 16,
      child: GestureDetector(
        onTap: () => setState(() => _isMinimized = false),
        child: GlassContainer(
          borderRadius: 28,
          blur: 16,
          opacity: isDark ? 0.45 : 0.85,
          borderColor: timer.isFinished
              ? AppColors.heatmapOptimal
              : AppColors.primary.withValues(alpha: 0.6),
          borderWidth: 1.5,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                timer.isFinished
                    ? Icons.check_circle_rounded
                    : Icons.timer_outlined,
                size: 18,
                color: timer.isFinished
                    ? AppColors.heatmapOptimal
                    : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                timer.isFinished ? 'Ready!' : timer.formattedTime,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedCard(
    BuildContext context,
    RestTimerService timer,
    bool isDark,
  ) {
    return Positioned(
      bottom: 80,
      left: 16,
      right: 16,
      child: Material(
        type: MaterialType.transparency,
        child: GlassContainer(
          borderRadius: 24,
          blur: 24,
          opacity: isDark ? 0.5 : 0.9,
          borderColor: timer.isFinished
              ? AppColors.heatmapOptimal
              : AppColors.primary.withValues(alpha: 0.5),
          borderWidth: 1.5,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: (timer.isFinished
                                  ? AppColors.heatmapOptimal
                                  : AppColors.primary)
                              .withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          timer.isFinished
                              ? Icons.done_all_rounded
                              : Icons.timer_rounded,
                          size: 16,
                          color: timer.isFinished
                              ? AppColors.heatmapOptimal
                              : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timer.isFinished
                            ? 'Rest Complete!'
                            : (timer.exerciseName != null
                                ? 'Rest: ${timer.exerciseName}'
                                : 'Rest Interval'),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                        tooltip: 'Minimize',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => setState(() => _isMinimized = true),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        tooltip: 'Dismiss',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          timer.dismiss();
                          widget.onDismiss?.call();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Timer display + Progress bar
              Row(
                children: [
                  Text(
                    timer.formattedTime,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: timer.isFinished
                          ? AppColors.heatmapOptimal
                          : (isDark ? Colors.white : AppColors.textPrimaryLight),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: timer.progress,
                            minHeight: 8,
                            backgroundColor: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.08),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              timer.isFinished
                                  ? AppColors.heatmapOptimal
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timer.isFinished
                              ? 'Time for your next set! 💪'
                              : '${(timer.progress * 100).toInt()}% remaining',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildPillButton(
                        label: '+15s',
                        onTap: () => timer.addSeconds(15),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 6),
                      _buildPillButton(
                        label: '+30s',
                        onTap: () => timer.addSeconds(30),
                        isDark: isDark,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_rounded, size: 20),
                        tooltip: 'Reset',
                        onPressed: () => timer.reset(),
                      ),
                      const SizedBox(width: 4),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: timer.isFinished
                              ? AppColors.heatmapOptimal
                              : AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        icon: Icon(
                          timer.isRunning
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 20,
                        ),
                        tooltip: timer.isRunning ? 'Pause' : 'Resume',
                        onPressed: () {
                          if (timer.isRunning) {
                            timer.pause();
                          } else {
                            timer.resume();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPillButton({
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.1),
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
          ),
        ),
      ),
    );
  }
}
