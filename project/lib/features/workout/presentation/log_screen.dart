import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_top_nav_bar.dart';
import '../../../core/widgets/pill_tab_bar.dart';
import '../domain/workout_log.dart';
import 'log_form.dart';
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
      body: RefreshIndicator(
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
                    itemCount: vm.logs.length + 2, // 0: PillTabBar, 1: Summary Card, rest: logs
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
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        '${vm.logs.length}',
                                        style: AppTypography.statNumberLarge,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Logged Exercises',
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
                                  Container(
                                    height: 40,
                                    width: 1,
                                    color: isDark
                                        ? AppColors.borderDark
                                        : AppColors.borderLight,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        '$totalSets',
                                        style: AppTypography.statNumberLarge,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Total Sets',
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
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      final log = vm.logs[index - 2];
                      final exercise = vm.getExerciseById(log.exerciseId);

                      // Check if date header should be shown (grouped by day)
                      final showDateHeader = (index - 2) == 0 ||
                          !_isSameDay(log.date, vm.logs[index - 3].date);

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
                          Card(
                            child: Padding(
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
                                        Text(
                                          exercise?.name ?? 'Exercise #${log.exerciseId}',
                                          style: AppTypography.titleMedium,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              '${log.sets} sets × ${log.reps} reps',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: isDark
                                                    ? AppColors.textPrimaryDark
                                                    : AppColors.textPrimaryLight,
                                              ),
                                            ),
                                            if (log.weightKg != null) ...[
                                              const Text(' • '),
                                              Text(
                                                '${log.weightKg} kg',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.accent,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        if (log.note != null &&
                                            log.note!.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            log.note!,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontStyle: FontStyle.italic,
                                              color: isDark
                                                  ? AppColors.textSecondaryDark
                                                  : AppColors.textSecondaryLight,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  // Action Buttons (Edit / Delete)
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
                          ),
                        ],
                      );
                    },
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
          ],
        ),
      ),
    );
  }
}
