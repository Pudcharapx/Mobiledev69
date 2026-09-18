import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/services/rest_timer_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ambient_mesh_background.dart';
import '../../../core/widgets/app_top_nav_bar.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/pill_tab_bar.dart';
import '../domain/one_rep_max_calculator.dart';
import '../domain/workout_log.dart';
import 'log_form.dart';
import 'routine_templates_sheet.dart';
import 'workout_view_model.dart';

/// LogScreen displaying list of all workout logs (sorted by date) with CRUD actions
/// per SRS.md sections 7.3, 7.4, 7.5, and 9.2.
class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutViewModel>().loadInitialData();
    });
  }

  Future<void> _confirmDelete(WorkoutLog log) async {
    final vm = context.read<WorkoutViewModel>();
    final exercise = vm.getExerciseById(log.exerciseId);
    final exerciseName = exercise?.name ?? 'Exercise';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout Log'),
        content: Text(
          'Are you sure you want to delete this log for $exerciseName on ${DateFormat.yMMMd().format(log.date)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.heatmapUnderTrained,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await vm.deleteLog(log.id);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout log deleted.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        final error = vm.errorMessage ?? 'Failed to delete workout log.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.heatmapUnderTrained,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _openEditForm(WorkoutLog log) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LogForm(initialLog: log),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final vm = context.watch<WorkoutViewModel>();

    final totalSets = vm.logs.fold<int>(0, (sum, l) => sum + l.sets);

    return Scaffold(
      appBar: AppTopNavBar(
        title: 'Workout Logs',
        extraActions: [
          IconButton(
            icon: const Icon(Icons.timer_outlined),
            tooltip: 'Rest Timer',
            onPressed: () {
              final timer = context.read<RestTimerService>();
              if (!timer.isVisible) {
                timer.startTimer(60);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => vm.loadInitialData(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/workouts/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log Workout', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: isDark ? Colors.white : AppColors.primary,
        foregroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      ),
      body: AmbientMeshBackground(
        child: RefreshIndicator(
          onRefresh: () => vm.loadInitialData(),
          child: vm.isLoading && vm.logs.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : vm.logs.isEmpty
                  ? Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: PillTabBar(currentRoute: '/workouts'),
                        ),
                        Expanded(
                          child: _EmptyLogsState(
                            onAddPressed: () => context.push('/workouts/new'),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      itemCount: vm.logs.length + 3, // 0: PillTabBar, 1: Summary Card, 2: Routine Card, rest: logs
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: PillTabBar(currentRoute: '/workouts'),
                          );
                        }

                        if (index == 1) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: GlassCard(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          '${vm.logs.length}',
                                          style: AppTypography.statNumberLarge,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Logged Exercises',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: isDark
                                                ? AppColors.textSecondaryDark
                                                : AppColors.textSecondaryLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 40,
                                    width: 1,
                                    color: isDark
                                        ? AppColors.borderDark
                                        : AppColors.borderLight,
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          '$totalSets',
                                          style: AppTypography.statNumberLarge,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Total Sets',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
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
                          );
                        }

                        if (index == 2) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GlassCard(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.bolt_rounded,
                                      size: 20,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Workout Routines',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          'Push, Pull, Legs & Upper presets',
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
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: () => RoutineTemplatesSheet.show(context),
                                    child: const Text(
                                      'Explore',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                      final log = vm.logs[index - 3];
                      final exercise = vm.getExerciseById(log.exerciseId);

                      // Check if date header should be shown (grouped by day)
                      final showDateHeader = (index - 3) == 0 ||
                          !_isSameDay(log.date, vm.logs[index - 4].date);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showDateHeader) ...[
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 4,
                                top: 16,
                                bottom: 8,
                              ),
                              child: Text(
                                DateFormat('EEEE, MMMM d, yyyy').format(log.date),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                          ],
                          GlassCard(
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Exercise Icon / Muscle Badge
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.primaryLight
                                        : AppColors.borderLight,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.fitness_center_rounded,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Exercise Info & Volume
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              exercise?.name ??
                                                  'Exercise #${log.exerciseId}',
                                              style: AppTypography.titleMedium,
                                            ),
                                          ),
                                          if (vm.isPRLog(log)) ...[
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFD700)
                                                    .withValues(alpha: 0.15),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: const Color(0xFFFFD700)
                                                      .withValues(alpha: 0.6),
                                                  width: 0.8,
                                                ),
                                              ),
                                              child: const Text(
                                                '🏆 PR',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFFFFD700),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: (exercise?.primaryMuscle != null
                                                      ? AppColors.accent
                                                      : AppColors.heatmapDefault)
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              (exercise?.primaryMuscle ?? 'General')
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: exercise?.primaryMuscle != null
                                                    ? AppColors.accent
                                                    : (isDark
                                                        ? AppColors.textSecondaryDark
                                                        : AppColors.textSecondaryLight),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '${log.sets} sets \u00d7 ${log.reps} reps',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isDark
                                                  ? AppColors.textSecondaryDark
                                                  : AppColors.textSecondaryLight,
                                            ),
                                          ),
                                          if (log.weightKg != null) ...[
                                            Text(
                                              ' @ ${log.weightKg}kg',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: isDark
                                                    ? AppColors.textPrimaryDark
                                                    : AppColors.textPrimaryLight,
                                              ),
                                            ),
                                            Text(
                                              '(1RM ~${OneRepMaxCalculator.calculate1RM(log.weightKg!, log.reps)}kg)',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isDark
                                                    ? AppColors.textSecondaryDark
                                                    : AppColors.textSecondaryLight,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      if (log.note != null && log.note!.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          log.note!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            color: isDark
                                                ? AppColors.textSecondaryDark
                                                : AppColors.textSecondaryLight,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                // Calculated Volume Badge per SRS 8.1
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '+${(log.sets * log.reps * (log.weightKg ?? 1.0)).round()} vol',
                                    style: const TextStyle(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 4),

                                // More Menu (Edit / Delete) per SRS 7.4 & 7.5
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert_rounded),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _openEditForm(log);
                                    } else if (value == 'delete') {
                                      _confirmDelete(log);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit_outlined, size: 18),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete_outline,
                                              size: 18, color: Colors.redAccent),
                                          SizedBox(width: 8),
                                          Text('Delete',
                                              style: TextStyle(color: Colors.redAccent)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _EmptyLogsState extends StatelessWidget {
  final VoidCallback onAddPressed;

  const _EmptyLogsState({required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.borderLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                size: 40,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No workouts logged yet',
              style: AppTypography.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Start tracking your sets and reps to generate your weekly muscle heatmap.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Log First Workout'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => RoutineTemplatesSheet.show(context),
              icon: const Icon(Icons.bolt_rounded),
              label: const Text('Explore Preset Routines (Push/Pull/Legs)'),
            ),
          ],
        ),
      ),
    );
  }
}
