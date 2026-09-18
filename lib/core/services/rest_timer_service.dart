import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// RestTimerService manages rest intervals between workout sets.
/// Provides countdown state, audio/haptic feedback upon completion,
/// and methods to adjust, pause, or resume the timer.
class RestTimerService extends ChangeNotifier {
  Timer? _timer;
  int _totalSeconds = 60;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isFinished = false;
  bool _isVisible = false;
  String? _exerciseName;

  int get totalSeconds => _totalSeconds;
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  bool get isFinished => _isFinished;
  bool get isVisible => _isVisible;
  String? get exerciseName => _exerciseName;

  /// Progress from 1.0 (start) down to 0.0 (finished).
  double get progress {
    if (_totalSeconds <= 0) return 0.0;
    return (_remainingSeconds / _totalSeconds).clamp(0.0, 1.0);
  }

  /// Formatted time string, e.g. "01:30" or "00:45".
  String get formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Start a new rest timer countdown.
  void startTimer(int seconds, {String? exerciseName}) {
    _timer?.cancel();
    _totalSeconds = seconds > 0 ? seconds : 60;
    _remainingSeconds = _totalSeconds;
    _isRunning = true;
    _isFinished = false;
    _isVisible = true;
    _exerciseName = exerciseName;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 1) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _remainingSeconds = 0;
        _isRunning = false;
        _isFinished = true;
        _timer?.cancel();
        _timer = null;
        _triggerCompletionAlert();
        notifyListeners();
      }
    });
  }

  /// Pause countdown.
  void pause() {
    if (_isRunning) {
      _timer?.cancel();
      _timer = null;
      _isRunning = false;
      notifyListeners();
    }
  }

  /// Resume countdown if paused and remaining time > 0.
  void resume() {
    if (!_isRunning && _remainingSeconds > 0) {
      _isRunning = true;
      _isFinished = false;
      notifyListeners();

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 1) {
          _remainingSeconds--;
          notifyListeners();
        } else {
          _remainingSeconds = 0;
          _isRunning = false;
          _isFinished = true;
          _timer?.cancel();
          _timer = null;
          _triggerCompletionAlert();
          notifyListeners();
        }
      });
    }
  }

  /// Add or subtract seconds (e.g. +15s or +30s).
  void addSeconds(int seconds) {
    _remainingSeconds = (_remainingSeconds + seconds).clamp(0, 3600);
    if (_remainingSeconds > _totalSeconds) {
      _totalSeconds = _remainingSeconds;
    }
    if (_remainingSeconds > 0 && _isFinished) {
      _isFinished = false;
      resume();
    }
    notifyListeners();
  }

  /// Reset timer to the initial total seconds.
  void reset() {
    startTimer(_totalSeconds, exerciseName: _exerciseName);
  }

  /// Dismiss / hide the floating timer overlay.
  void dismiss() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _isFinished = false;
    _isVisible = false;
    notifyListeners();
  }

  /// Audio and Haptic feedback on timer completion.
  void _triggerCompletionAlert() {
    try {
      HapticFeedback.heavyImpact();
      SystemSound.play(SystemSoundType.alert);
    } catch (_) {
      // Ignored in test environment
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
