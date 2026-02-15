// Integration test for Respectlytics Flutter SDK v2.2.0
// Run with: RESPECTLYTICS_TEST_API_KEY=your-key dart test/integration_test.dart

import 'dart:convert';
import 'dart:io';

// Read API key from environment variable
final String? testApiKey = Platform.environment['RESPECTLYTICS_TEST_API_KEY'];
const String baseUrl = 'http://127.0.0.1:8080/api/v1';

Future<void> main() async {
  print('🧪 Respectlytics Flutter SDK v2.2.0 Integration Tests\n');

  // Check for API key
  if (testApiKey == null || testApiKey!.isEmpty) {
    print('⚠️  RESPECTLYTICS_TEST_API_KEY environment variable not set');
    print(
      '   Run with: RESPECTLYTICS_TEST_API_KEY=your-key dart test/integration_test.dart',
    );
    exit(1);
  }

  print('✅ API Key: Found (from environment)');
  print('🔗 Server: $baseUrl\n');

  var passed = 0;
  var failed = 0;

  // Test 1: Valid event submission (session-based, no user_id)
  print('Test 1: Valid event submission (session-based)...');
  try {
    final result = await sendEvent({
      'event_name': 'integration_test_event',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'session_id': 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4',
      'platform': 'iOS',
    });
    if (result['statusCode'] == 201) {
      print('  ✅ PASSED: Event created (status 201)');
      passed++;
    } else {
      print('  ❌ FAILED: Expected 201, got ${result['statusCode']}');
      print('     Response: ${result['body']}');
      failed++;
    }
  } catch (e) {
    print('  ❌ FAILED: $e');
    failed++;
  }

  // Test 2: Event from Android platform
  print('\nTest 2: Event from Android platform...');
  try {
    final result = await sendEvent({
      'event_name': 'android_test_event',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'session_id': 'd4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1',
      'platform': 'Android',
    });
    if (result['statusCode'] == 201) {
      print('  ✅ PASSED: Android event created');
      passed++;
    } else {
      print('  ❌ FAILED: Expected 201, got ${result['statusCode']}');
      print('     Response: ${result['body']}');
      failed++;
    }
  } catch (e) {
    print('  ❌ FAILED: $e');
    failed++;
  }

  // Test 3: Event from macOS platform
  print('\nTest 3: Event from macOS platform...');
  try {
    final result = await sendEvent({
      'event_name': 'macos_test_event',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'session_id': 'b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5',
      'platform': 'macOS',
    });
    if (result['statusCode'] == 201) {
      print('  ✅ PASSED: macOS event created');
      passed++;
    } else {
      print('  ❌ FAILED: Expected 201, got ${result['statusCode']}');
      print('     Response: ${result['body']}');
      failed++;
    }
  } catch (e) {
    print('  ❌ FAILED: $e');
    failed++;
  }

  // Test 4: Invalid API key
  print('\nTest 4: Invalid API key (expect 401)...');
  try {
    final result = await sendEvent({
      'event_name': 'should_fail',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'session_id': 'e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2',
      'platform': 'iOS',
    }, apiKey: 'invalid-api-key-12345');
    if (result['statusCode'] == 401) {
      print('  ✅ PASSED: Correctly rejected with 401');
      passed++;
    } else {
      print('  ❌ FAILED: Expected 401, got ${result['statusCode']}');
      failed++;
    }
  } catch (e) {
    print('  ❌ FAILED: $e');
    failed++;
  }

  // Test 5: Missing event_name (expect 400)
  print('\nTest 5: Missing event_name (expect 400)...');
  try {
    final result = await sendEvent({
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'session_id': 'f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3',
      'platform': 'iOS',
    });
    if (result['statusCode'] == 400) {
      print('  ✅ PASSED: Correctly rejected with 400');
      passed++;
    } else {
      print('  ❌ FAILED: Expected 400, got ${result['statusCode']}');
      print('     Response: ${result['body']}');
      failed++;
    }
  } catch (e) {
    print('  ❌ FAILED: $e');
    failed++;
  }

  // Test 6: Empty event_name (expect 400)
  print('\nTest 6: Empty event_name (expect 400)...');
  try {
    final result = await sendEvent({
      'event_name': '',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'session_id': 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4',
      'platform': 'iOS',
    });
    if (result['statusCode'] == 400) {
      print('  ✅ PASSED: Correctly rejected empty event_name');
      passed++;
    } else {
      print('  ❌ FAILED: Expected 400, got ${result['statusCode']}');
      print('     Response: ${result['body']}');
      failed++;
    }
  } catch (e) {
    print('  ❌ FAILED: $e');
    failed++;
  }

  // Test 7: Session ID format validation (32 hex chars)
  print('\nTest 7: Session ID format validation...');
  try {
    final result = await sendEvent({
      'event_name': 'session_format_test',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'session_id': 'abcdef0123456789abcdef0123456789', // Valid 32 hex chars
      'platform': 'iOS',
    });
    if (result['statusCode'] == 201) {
      print('  ✅ PASSED: Valid session ID format accepted');
      passed++;
    } else {
      print('  ❌ FAILED: Expected 201, got ${result['statusCode']}');
      print('     Response: ${result['body']}');
      failed++;
    }
  } catch (e) {
    print('  ❌ FAILED: $e');
    failed++;
  }

  // Summary
  print('\n==================================================');
  print('Results: $passed passed, $failed failed');
  if (failed == 0) {
    print('🎉 All tests passed!');
  } else {
    print('⚠️  Some tests failed');
    exit(1);
  }
}

Future<Map<String, dynamic>> sendEvent(
  Map<String, dynamic> event, {
  String? apiKey,
}) async {
  final client = HttpClient();
  try {
    final jsonBody = jsonEncode(event);
    final bodyBytes = utf8.encode(jsonBody);

    final request = await client.postUrl(Uri.parse('$baseUrl/events/'));
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('X-App-Key', apiKey ?? testApiKey!);
    request.headers.set('Content-Length', bodyBytes.length.toString());
    request.add(bodyBytes);

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    return {'statusCode': response.statusCode, 'body': body};
  } finally {
    client.close();
  }
}
