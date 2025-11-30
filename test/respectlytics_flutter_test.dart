import 'package:flutter_test/flutter_test.dart';
import 'package:respectlytics_flutter/respectlytics_flutter.dart';

void main() {
  group('Respectlytics SDK', () {
    test('track rejects empty event name', () async {
      // SDK not configured, should warn but not throw
      await Respectlytics.track('');
      // This test verifies the method doesn't crash
    });

    test('track rejects event name over 100 chars', () async {
      final longName = 'a' * 101;
      await Respectlytics.track(longName);
      // This test verifies the method doesn't crash
    });
  });
}
