import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_container.dart';
import '../domain/workout_routine.dart';
import 'log_form.dart';
import 'workout_view_model.dart';

/// Modal bottom sheet presenting workout routine templates (Push, Pull, Leg, Upper)
/// with 1-Tap routine logging and exercise customization.
class RoutineTemplatesSheet extends StatefulWidget {
  final void Function(WorkoutRoutine routine)? onRoutineLogged;

  const RoutineTemplatesSheet({super.key, this.onRoutineLogged});

  static Future<void> show(
    BuildContext context, {
    void Function(WorkoutRoutine routine)? onRoutineLogged,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RoutineTemplatesSheet(
        onRoutineLogged: onRoutineLogged,
      ),
    );
  }

  @override
  State<RoutineTemplatesSheet> createState() => _RoutineTemplatesSheetState();
}

class _RoutineTemplatesSheetState extends State<RoutineTemplatesSheet> {
  int _selectedRoutineIndex = 0;
  bool _isLoggingRoutine = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const routines = WorkoutRoutine.standardPresets;
    final activeRoutine = routines[_selectedRoutineIndex];

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: GlassContainer(
            borderRadius: 0,
            blur: 24,
            opacity: isDark ? 0.75 : 0.95,
            borderColor: isDark
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.1),
            borderWidth: 1.5,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: ListView(
              controller: scrollController,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white30 : Colors.black26,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Workout Routines',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Routine selector chips
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: routines.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final routine = routines[index];
                      final isSelected = index == _selectedRoutineIndex;
                      final accentColor = Color(routine.accentColorValue);

                      return ChoiceChip(
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedRoutineIndex = index);
                          }
                        },
                        avatar: Text(routine.emoji, style: const TextStyle(fontSize: 14)),
                        label: Text(
                          routine.name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : AppColors.textPrimaryLight),
                          ),
                        ),
                        selectedColor: accentColor,
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.04),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? accentColor
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.black.withValues(alpha: 0.08)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Active Routine Overview Card
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 20,
                  borderColor: Color(activeRoutine.accentColorValue).withValues(alpha: 0.4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            activeRoutine.emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activeRoutine.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '${activeRoutine.exercises.length} Exercises · ${activeRoutine.totalSets} Total Sets',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Color(activeRoutine.accentColorValue)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              activeRoutine.category,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(activeRoutine.accentColorValue),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        activeRoutine.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Exercise List Header
                const Text(
                  'Planned Exercises',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),

                // Exercise items
                ...activeRoutine.exercises.map((item) {
                  final vm = context.watch<WorkoutViewModel>();
                  final lastLog = vm.getLastLogForExercise(item.exerciseId);
                  final displayWeight = lastLog?.weightKg ?? item.suggestedWeightKg;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Color(activeRoutine.accentColorValue)
                                .withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.fitness_center_rounded,
                              size: 18,
                              color: Color(activeRoutine.accentColorValue),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.exerciseName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${item.targetSets} sets × ${item.targetReps} reps'
                                '${displayWeight != null ? ' @ ${displayWeight}kg' : ''}'
                                ' (${item.primaryMuscle})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            final exercise = vm.getExerciseById(item.exerciseId);
                            if (exercise != null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => LogForm(
                                    initialExercise: exercise,
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text('Log', style: TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),

                // 1-Tap Log Full Routine Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(activeRoutine.accentColorValue),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: _isLoggingRoutine
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.bolt_rounded, size: 22),
                    label: Text(
                      _isLoggingRoutine
                          ? 'Logging Routine...'
                          : '1-Tap Log All ${activeRoutine.name} Exercises',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onPressed: _isLoggingRoutine
                        ? null
                        : () => _logEntireRoutine(activeRoutine),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _logEntireRoutine(WorkoutRoutine routine) async {
    setState(() => _isLoggingRoutine = true);
    final vm = context.read<WorkoutViewModel>();
    final today = DateTime.now();

    int successCount = 0;
    for (final item in routine.exercises) {
      final lastLog = vm.getLastLogForExercise(item.exerciseId);
      final weight = lastLog?.weightKg ?? item.suggestedWeightKg;

      final success = await vm.createLog(
        exerciseId: item.exerciseId,
        date: today,
        sets: item.targetSets,
        reps: item.targetReps,
        weightKg: weight,
        note: 'Completed from ${routine.name}',
      );
      if (success) successCount++;
    }

    if (!mounted) return;
    setState(() => _isLoggingRoutine = false);

    Navigator.pop(context);
    widget.onRoutineLogged?.call(routine);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🔥 Logged $successCount exercises from ${routine.name} successfully!',
        ),
        backgroundColor: AppColors.heatmapOptimal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
