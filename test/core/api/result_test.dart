import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/api/result.dart';

void main() {
  group('Result Pattern Tests', () {
    test('Success returns correct data and state', () {
      const result = Success<String>('hello');
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, 'hello');
      expect(result.errorOrNull, isNull);

      final val = result.when(
        success: (d) => 'got $d',
        failure: (m, _) => 'err $m',
      );
      expect(val, 'got hello');
    });

    test('Failure returns correct error and state', () {
      const result = Failure<String>('failed request', statusCode: 404);
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.dataOrNull, isNull);
      expect(result.errorOrNull, 'failed request');
      expect(result.statusCode, 404);

      final val = result.when(
        success: (d) => 'got $d',
        failure: (m, _) => 'err $m',
      );
      expect(val, 'err failed request');
    });
  });
}
