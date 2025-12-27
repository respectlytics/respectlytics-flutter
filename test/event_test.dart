// Respectlytics SDK for Flutter
// Copyright (c) 2025 Respectlytics. All rights reserved.
// See LICENSE file for terms.

import 'package:flutter_test/flutter_test.dart';
import 'package:respectlytics_flutter/src/models/event.dart';

void main() {
  group('Event', () {
    test('creates event with all required fields', () {
      final event = Event(
        eventName: 'test_event',
        timestamp: '2025-12-27T10:00:00Z',
        sessionId: 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4',
        platform: 'iOS',
      );

      expect(event.eventName, equals('test_event'));
      expect(event.timestamp, equals('2025-12-27T10:00:00Z'));
      expect(event.sessionId, equals('a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4'));
      expect(event.platform, equals('iOS'));
    });

    test('converts to JSON with only 4 allowed fields', () {
      final event = Event(
        eventName: 'json_test',
        timestamp: '2025-12-27T12:30:00Z',
        sessionId: 'b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5',
        platform: 'Android',
      );

      final json = event.toJson();

      expect(json.length, equals(4));
      expect(json['event_name'], equals('json_test'));
      expect(json['timestamp'], equals('2025-12-27T12:30:00Z'));
      expect(json['session_id'], equals('b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5'));
      expect(json['platform'], equals('Android'));
    });

    test('toJson does not include extra fields', () {
      final event = Event(
        eventName: 'strict_test',
        timestamp: '2025-12-27T15:00:00Z',
        sessionId: 'c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6',
        platform: 'iOS',
      );

      final json = event.toJson();

      // Only these 4 fields should exist
      expect(json.containsKey('event_name'), isTrue);
      expect(json.containsKey('timestamp'), isTrue);
      expect(json.containsKey('session_id'), isTrue);
      expect(json.containsKey('platform'), isTrue);

      // These fields should NOT exist (removed in v2.1.0)
      expect(json.containsKey('screen'), isFalse);
      expect(json.containsKey('user_id'), isFalse);
      expect(json.containsKey('app_version'), isFalse);
      expect(json.containsKey('os_version'), isFalse);
      expect(json.containsKey('device_type'), isFalse);
      expect(json.containsKey('locale'), isFalse);
    });

    test('creates event from JSON', () {
      final json = {
        'event_name': 'from_json_test',
        'timestamp': '2025-12-27T18:00:00Z',
        'session_id': 'd4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1',
        'platform': 'Android',
      };

      final event = Event.fromJson(json);

      expect(event.eventName, equals('from_json_test'));
      expect(event.timestamp, equals('2025-12-27T18:00:00Z'));
      expect(event.sessionId, equals('d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1'));
      expect(event.platform, equals('Android'));
    });

    test('round-trip JSON serialization', () {
      final original = Event(
        eventName: 'roundtrip_test',
        timestamp: '2025-12-27T20:00:00Z',
        sessionId: 'e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2',
        platform: 'iOS',
      );

      final json = original.toJson();
      final restored = Event.fromJson(json);

      expect(restored.eventName, equals(original.eventName));
      expect(restored.timestamp, equals(original.timestamp));
      expect(restored.sessionId, equals(original.sessionId));
      expect(restored.platform, equals(original.platform));
    });

    test('handles special characters in event name', () {
      final event = Event(
        eventName: 'button_click_with_äöü',
        timestamp: '2025-12-27T21:00:00Z',
        sessionId: 'f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3',
        platform: 'iOS',
      );

      final json = event.toJson();
      final restored = Event.fromJson(json);

      expect(restored.eventName, equals('button_click_with_äöü'));
    });

    test('supports both iOS and Android platforms', () {
      final iosEvent = Event(
        eventName: 'platform_test',
        timestamp: '2025-12-27T22:00:00Z',
        sessionId: 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4',
        platform: 'iOS',
      );

      final androidEvent = Event(
        eventName: 'platform_test',
        timestamp: '2025-12-27T22:00:00Z',
        sessionId: 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4',
        platform: 'Android',
      );

      expect(iosEvent.toJson()['platform'], equals('iOS'));
      expect(androidEvent.toJson()['platform'], equals('Android'));
    });
  });
}
