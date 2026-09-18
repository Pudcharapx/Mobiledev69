import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/services/rest_timer_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RestTimerService Tests', () {
    late RestTimerService service;

    setUp(() {
      service = RestTimerService();
    });

    tearDown(() {
      service.dispose();
    });

    test('Initial state is idle and invisible', () {
      expect(service.isRunning, isFalse);
      expect(service.isFinished, isFalse);
      expect(service.isVisible, isFalse);
      expect(service.remainingSeconds, 0);
      expect(service.progress, 0.0);
    });

    test('startTimer initializes countdown properly', () {
      service.startTimer(90, exerciseName: 'Bench Press');

      expect(service.totalSeconds, 90);
      expect(service.remainingSeconds, 90);
      expect(service.isRunning, isTrue);
      expect(service.isFinished, isFalse);
      expect(service.isVisible, isTrue);
      expect(service.exerciseName, 'Bench Press');
      expect(service.formattedTime, '01:30');
      expect(service.progress, 1.0);
    });

    test('pause and resume control running state', () {
      service.startTimer(60);
      expect(service.isRunning, isTrue);

      service.pause();
      expect(service.isRunning, isFalse);

      service.resume();
      expect(service.isRunning, isTrue);
    });

    test('addSeconds increases remaining time', () {
      service.startTimer(60);
      service.addSeconds(15);

      expect(service.remainingSeconds, 75);
      expect(service.totalSeconds, 75);
      expect(service.formattedTime, '01:15');
    });

    test('reset restarts timer with original duration', () {
      service.startTimer(120, exerciseName: 'Squat');
      service.pause();
      service.reset();

      expect(service.totalSeconds, 120);
      expect(service.remainingSeconds, 120);
      expect(service.isRunning, isTrue);
      expect(service.exerciseName, 'Squat');
    });

    test('dismiss cancels timer and hides overlay', () {
      service.startTimer(60);
      service.dismiss();

      expect(service.isVisible, isFalse);
      expect(service.isRunning, isFalse);
      expect(service.isFinished, isFalse);
    });
  });
}
