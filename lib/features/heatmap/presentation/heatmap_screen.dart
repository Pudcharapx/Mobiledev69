import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_top_nav_bar.dart';
import '../../../core/widgets/pill_tab_bar.dart';
import '../../workout/presentation/workout_view_model.dart';
import '../domain/imbalance_calculator.dart';
import '../domain/muscle_volume_calculator.dart';
import 'body_svg_widget.dart';
import 'imbalance_alert_card.dart';
import 'muscle_zone_detail_popup.dart';

/// Heatmap Screen rendering front+back body view and volume statistics per SRS.md section 8.1.
class HeatmapScreen extends StatefulWidget {
  const HeatmapScreen({super.key});

  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutViewModel>().loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final vm = context.watch<WorkoutViewModel>();

    // Calculate weekly volume data using MuscleVolumeCalculator
    final volumeData = MuscleVolumeCalculator.calculateWeeklyVolume(
      logs: vm.logs,
      exercises: vm.exercises,
    );

    // Calculate overall weekly average completion percentage
    final totalPercent = volumeData.values.fold<double>(
          0.0,
          (sum, e) => sum + e.percentage.clamp(0.0, 1.0),
        ) /
        volumeData.length;
    final overallScore = (totalPercent * 100).round();

    final startOfWeek = MuscleVolumeCalculator.getStartOfWeek();
    final endOfWeek = MuscleVolumeCalculator.getEndOfWeek();
    final weekRangeStr =
        '${DateFormat.MMMd().format(startOfWeek)} – ${DateFormat.MMMd().format(endOfWeek)}';

    // Calculate imbalance alerts per SRS 8.2
    final activeAlerts = ImbalanceCalculator.checkImbalances(volumeData: volumeData);
    final allEvaluatedPairs = ImbalanceCalculator.evaluateAllPairs(
      volumes: volumeData.map((k, v) => MapEntry(k, v.volume)),
    );

    return Scaffold(
      appBar: AppTopNavBar(
        title: 'Muscle Heatmap',
        extraActions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => vm.loadInitialData(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => vm.loadInitialData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Pill / Segmented Tab Bar for switching Heatmap / Log List / Settings (SRS 9.2)
                  const PillTabBar(currentRoute: '/'),

                  const SizedBox(height: 16),

                  // Dark feature card for Imbalance Alert summary (SRS 8.2, 9.2, 9.3 at top)
                  ImbalanceAlertCard(
                    activeAlerts: activeAlerts,
                    allEvaluatedPairs: allEvaluatedPairs,
                    onLogAction: () => context.push('/workouts/new'),
                  ),

                  const SizedBox(height: 16),

                  // Week Header & Overall Weekly Balance Card with Circular Progress Ring (SRS 9.2)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Row(
                        children: [
                          // Circular Progress Ring (SRS 9.2: shows number in center for overall balance)
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 74,
                                height: 74,
                                child: CircularProgressIndicator(
                                  value: totalPercent,
                                  strokeWidth: 8,
                                  backgroundColor: isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.colorForCompletion(totalPercent),
                                  ),
                                ),
                              ),
                              Text(
                                '$overallScore%',
                                style: AppTypography.statNumberMedium,
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Weekly Training Balance',
                                  style: AppTypography.headlineMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  weekRangeStr,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Tap any muscle zone on the body map or chip below to view contributing workout logs.',
                                  style: TextStyle(
                                    fontSize: 11.5,
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
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Body Heatmap SVG Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          if (vm.isLoading && vm.logs.isEmpty)
                            const SizedBox(
                              height: 280,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else
                            BodySvgWidget(
                              volumeData: volumeData,
                              onZoneTapped: (muscleGroup) {
                                final data = volumeData[muscleGroup];
                                if (data != null) {
                                  MuscleZoneDetailPopup.show(context, data);
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Quick Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/workouts'),
                          icon: const Icon(Icons.history_rounded),
                          label: const Text('Workout Logs'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.push('/workouts/new'),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Log Workout'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
