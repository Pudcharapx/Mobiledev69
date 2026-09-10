import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_top_nav_bar.dart';
import '../domain/exercise.dart';
import '../domain/workout_log.dart';
import 'workout_view_model.dart';

/// Workout log create/edit form adhering to SRS.md section 5 input requirements:
/// 1. Exercise selection via dropdown/picker (no free typing)
/// 2. Sets and Reps via Stepper (+/-)
/// 3. Weight via numeric keypad, pre-filled with smart defaults from last log
class LogForm extends StatefulWidget {
  final WorkoutLog? initialLog;

  const LogForm({super.key, this.initialLog});

  @override
  State<LogForm> createState() => _LogFormState();
}

class _LogFormState extends State<LogForm> {
  final _formKey = GlobalKey<FormState>();

  Exercise? _selectedExercise;
  late DateTime _selectedDate;
  int _sets = 3;
  int _reps = 10;
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _isSaving = false;

  bool get _isEditMode => widget.initialLog != null;

  @override
  void initState() {
    super.initState();
    final log = widget.initialLog;
    if (log != null) {
      _selectedDate = log.date;
      _sets = log.sets;
      _reps = log.reps;
      if (log.weightKg != null) {
        _weightController.text = log.weightKg.toString();
      }
      if (log.note != null) {
        _noteController.text = log.note!;
      }
    } else {
      _selectedDate = DateTime.now();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedExercise == null) {
      final vm = context.read<WorkoutViewModel>();
      if (widget.initialLog != null) {
        _selectedExercise = vm.getExerciseById(widget.initialLog!.exerciseId);
      } else if (vm.exercises.isNotEmpty) {
        _applyExerciseSelection(vm.exercises.first, isInitial: true);
      }
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// Smart Defaults (SRS 5):
  /// When an exercise is selected in create mode, pre-fill sets, reps, and weight
  /// from the most recent log of that exercise.
  void _applyExerciseSelection(Exercise exercise, {bool isInitial = false}) {
    _selectedExercise = exercise;
    if (!_isEditMode) {
      final vm = context.read<WorkoutViewModel>();
      final lastLog = vm.getLastLogForExercise(exercise.id);
      if (lastLog != null) {
        setState(() {
          _sets = lastLog.sets;
          _reps = lastLog.reps;
          if (lastLog.weightKg != null) {
            _weightController.text = lastLog.weightKg.toString();
          } else {
            _weightController.clear();
          }
        });
      } else if (!isInitial) {
        setState(() {
          _sets = 3;
          _reps = 10;
          _weightController.clear();
        });
      }
    } else {
      setState(() {});
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveLog() async {
    if (_selectedExercise == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an exercise.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final vm = context.read<WorkoutViewModel>();

    final weightText = _weightController.text.trim();
    final weight = weightText.isNotEmpty ? double.tryParse(weightText) : null;
    final noteText = _noteController.text.trim();
    final note = noteText.isNotEmpty ? noteText : null;

    bool success;
    if (_isEditMode) {
      success = await vm.updateLog(
        id: widget.initialLog!.id,
        exerciseId: _selectedExercise!.id,
        date: _selectedDate,
        sets: _sets,
        reps: _reps,
        weightKg: weight,
        note: note,
      );
    } else {
      success = await vm.createLog(
        exerciseId: _selectedExercise!.id,
        date: _selectedDate,
        sets: _sets,
        reps: _reps,
        weightKg: weight,
        note: note,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode
              ? 'Workout log updated successfully.'
              : 'Workout log saved successfully.'),
          backgroundColor: AppColors.heatmapOptimal,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } else {
      final error = vm.errorMessage ?? 'Failed to save workout log.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.heatmapUnderTrained,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final vm = context.watch<WorkoutViewModel>();
    final exercises = vm.exercises;

    return Scaffold(
      appBar: AppTopNavBar(
        title: _isEditMode ? 'Edit Workout Log' : 'New Workout Log',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Exercise Picker Card (SRS 5.1: Dropdown / search, no free text)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Exercise',
                            style: AppTypography.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          if (exercises.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else
                            DropdownButtonFormField<Exercise>(
                              value: _selectedExercise,
                              decoration: const InputDecoration(
                                hintText: 'Select an exercise',
                                prefixIcon: Icon(Icons.fitness_center_rounded),
                              ),
                              items: exercises.map((ex) {
                                return DropdownMenuItem<Exercise>(
                                  value: ex,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        ex.name,
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? AppColors.primaryLight
                                              : AppColors.borderLight,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          ex.primaryMuscle,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDark
                                                ? AppColors.textPrimaryDark
                                                : AppColors.textSecondaryLight,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  _applyExerciseSelection(val);
                                }
                              },
                            ),
                          if (_selectedExercise != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Target muscles: ${_selectedExercise!.primaryMuscle}${_selectedExercise!.secondaryMuscles.isNotEmpty ? " + ${_selectedExercise!.secondaryMuscles.join(', ')}" : ""}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Stepper Card (SRS 5.2: Sets + Reps via Stepper +/-)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sets & Repetitions',
                            style: AppTypography.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          _StepperRow(
                            label: 'Sets',
                            value: _sets,
                            minValue: 1,
                            maxValue: 50,
                            onChanged: (val) => setState(() => _sets = val),
                          ),
                          const Divider(height: 24),
                          _StepperRow(
                            label: 'Reps per Set',
                            value: _reps,
                            minValue: 1,
                            maxValue: 200,
                            onChanged: (val) => setState(() => _reps = val),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Weight Card (SRS 5.3: Numeric keypad + smart default)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Weight (Optional)',
                            style: AppTypography.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Leave empty for bodyweight exercises',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'e.g. 60.0',
                              suffixText: 'kg',
                              prefixIcon: Icon(Icons.scale_rounded),
                            ),
                            validator: (val) {
                              if (val != null && val.trim().isNotEmpty) {
                                final parsed = double.tryParse(val.trim());
                                if (parsed == null || parsed < 0) {
                                  return 'Please enter a valid weight in kg.';
                                }
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Date & Note Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Date & Notes',
                            style: AppTypography.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today_rounded, size: 20),
                                      const SizedBox(width: 12),
                                      Text(
                                        DateFormat('EEEE, MMM d, yyyy')
                                            .format(_selectedDate),
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  const Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _noteController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              hintText: 'Optional notes (e.g. felt easy, form cues)...',
                              prefixIcon: Icon(Icons.notes_rounded),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button (SRS 5.3: 3-tap logging)
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveLog,
                      child: _isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _isEditMode ? 'Update Log' : 'Save Workout Log',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
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

/// Stepper (+/-) row widget per SRS 5.2.
class _StepperRow extends StatelessWidget {
  final String label;
  final int value;
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;

  const _StepperRow({
    required this.label,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Row(
          children: [
            IconButton.filledTonal(
              icon: const Icon(Icons.remove_rounded),
              onPressed: value > minValue ? () => onChanged(value - 1) : null,
            ),
            Container(
              constraints: const BoxConstraints(minWidth: 50),
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: AppTypography.statNumberMedium,
              ),
            ),
            IconButton.filledTonal(
              icon: const Icon(Icons.add_rounded),
              onPressed: value < maxValue ? () => onChanged(value + 1) : null,
            ),
          ],
        ),
      ],
    );
  }
}
