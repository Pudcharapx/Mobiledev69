import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/imbalance_calculator.dart';

/// Dark feature card displaying the Imbalance Alert summary per SRS.md sections 8.2 and 9.2.
class ImbalanceAlertCard extends StatefulWidget {
  final List<ImbalanceAlert> activeAlerts;
  final List<ImbalanceAlert> allEvaluatedPairs;
  final VoidCallback? onLogAction;

  const ImbalanceAlertCard({
    super.key,
    required this.activeAlerts,
    required this.allEvaluatedPairs,
    this.onLogAction,
  });

  @override
  State<ImbalanceAlertCard> createState() => _ImbalanceAlertCardState();
}

class _ImbalanceAlertCardState extends State<ImbalanceAlertCard> {
  bool _showAllPairs = false;

  @override
  Widget build(BuildContext context) {
    final hasAlerts = widget.activeAlerts.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkFeatureCardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasAlerts
              ? AppColors.alertWarning.withValues(alpha: 0.6)
              : AppColors.borderDark,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: hasAlerts
                      ? AppColors.alertWarning.withValues(alpha: 0.2)
                      : AppColors.heatmapOptimal.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasAlerts
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_outline_rounded,
                  color: hasAlerts
                      ? AppColors.alertWarning
                      : AppColors.heatmapOptimal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasAlerts ? 'Muscle Imbalance Alert' : 'Muscle Balance: Optimal',
                      style: const TextStyle(
                        color: AppColors.darkFeatureCardText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasAlerts
                          ? '${widget.activeAlerts.length} opposing ${widget.activeAlerts.length == 1 ? "pair exceeds" : "pairs exceed"} 40% volume difference'
                          : 'All opposing pairs are well-balanced this week',
                      style: const TextStyle(
                        color: AppColors.textSecondaryDark,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: hasAlerts
                      ? AppColors.alertWarning.withValues(alpha: 0.25)
                      : AppColors.heatmapOptimal.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  hasAlerts ? '${widget.activeAlerts.length} Alert' : 'Balanced',
                  style: TextStyle(
                    color: hasAlerts
                        ? AppColors.alertWarning
                        : AppColors.heatmapOptimal,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Active Alerts List
          if (hasAlerts) ...[
            ...widget.activeAlerts.map((alert) => _buildAlertItem(alert)),
            const SizedBox(height: 12),
          ] else ...[
            // Optimal state description
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.thumb_up_outlined,
                    color: AppColors.heatmapOptimal,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Great job! Your chest/back, quads/hamstrings, and biceps/triceps are balanced within safe ratios.',
                      style: TextStyle(
                        color: AppColors.darkFeatureCardText,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Expandable Pair Breakdown
          InkWell(
            onTap: () {
              setState(() {
                _showAllPairs = !_showAllPairs;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    _showAllPairs
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondaryDark,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _showAllPairs ? 'Hide Pair Breakdown' : 'View All 3 Opposing Pairs',
                    style: const TextStyle(
                      color: AppColors.textSecondaryDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_showAllPairs) ...[
            const SizedBox(height: 8),
            ...widget.allEvaluatedPairs.map((pair) => _buildPairStatusRow(pair)),
            const SizedBox(height: 8),
          ],

          const SizedBox(height: 12),

          // Prominent Action Button (SRS 9.2: Dark feature card with prominent action button)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onLogAction ?? () => context.push('/workouts/new'),
              icon: Icon(
                hasAlerts ? Icons.fitness_center_rounded : Icons.add_rounded,
                size: 18,
              ),
              label: Text(
                hasAlerts ? 'Add Workout to Balance' : 'Log Another Workout',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasAlerts
                    ? AppColors.alertWarning
                    : AppColors.heatmapOptimal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(ImbalanceAlert alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.alertWarning.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.arrow_right_rounded,
                  color: AppColors.alertWarning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  alert.message,
                  style: const TextStyle(
                    color: AppColors.darkFeatureCardText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.alertWarning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '+${alert.differencePercentageInt}% diff',
                  style: const TextStyle(
                    color: AppColors.alertWarning,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Volume comparison mini bar
          _buildVolumeComparisonBar(alert),
        ],
      ),
    );
  }

  Widget _buildVolumeComparisonBar(ImbalanceAlert alert) {
    final maxVol = alert.overtrainedVolume > 0 ? alert.overtrainedVolume : 1.0;
    final underVolRatio = (alert.undertrainedVolume / maxVol).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${alert.overtrainedLabel}: ${alert.overtrainedVolume.toStringAsFixed(0)} vol',
              style: const TextStyle(
                color: AppColors.textSecondaryDark,
                fontSize: 11,
              ),
            ),
            Text(
              '${alert.undertrainedLabel}: ${alert.undertrainedVolume.toStringAsFixed(0)} vol',
              style: const TextStyle(
                color: AppColors.alertWarning,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 6,
            child: Row(
              children: [
                Expanded(
                  flex: (underVolRatio * 100).round(),
                  child: Container(color: AppColors.alertWarning),
                ),
                Expanded(
                  flex: ((1.0 - underVolRatio) * 100).round(),
                  child: Container(color: Colors.white.withValues(alpha: 0.15)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPairStatusRow(ImbalanceAlert alert) {
    final isImbalanced = alert.hasImbalance;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isImbalanced
                    ? Icons.circle_outlined
                    : Icons.check_circle_rounded,
                size: 14,
                color: isImbalanced
                    ? AppColors.alertWarning
                    : AppColors.heatmapOptimal,
              ),
              const SizedBox(width: 8),
              Text(
                '${alert.labelA} vs ${alert.labelB}',
                style: const TextStyle(
                  color: AppColors.darkFeatureCardText,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Text(
            isImbalanced
                ? '${alert.differencePercentageInt}% diff'
                : 'Balanced (${alert.differencePercentageInt}%)',
            style: TextStyle(
              color: isImbalanced
                  ? AppColors.alertWarning
                  : AppColors.heatmapOptimal,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
