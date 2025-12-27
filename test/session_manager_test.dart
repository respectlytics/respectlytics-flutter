// Respectlytics SDK for Flutter
// Copyright (c) 2025 Respectlytics. All rights reserved.
// See LICENSE file for terms.

import 'package:flutter_test/flutter_test.dart';
import 'package:respectlytics_flutter/src/session_manager.dart';

void main() {
  group('SessionManager', () {
    test('generates session ID on creation', () {
      final manager = SessionManager();
      final sessionId = manager.getSessionId();

      expect(sessionId, isNotNull);
      expect(sessionId, isNotEmpty);
    });

    test('session ID is 32 lowercase hex characters', () {
      final manager = SessionManager();
      final sessionId = manager.getSessionId();

      expect(sessionId.length, equals(32));
      expect(RegExp(r'^[0-9a-f]{32}$').hasMatch(sessionId), isTrue);
    });

    test('returns same session ID on subsequent calls', () {
      final manager = SessionManager();

      final firstCall = manager.getSessionId();
      final secondCall = manager.getSessionId();
      final thirdCall = manager.getSessionId();

      expect(secondCall, equals(firstCall));
      expect(thirdCall, equals(firstCall));
    });

    test('different SessionManager instances have different session IDs', () {
      final manager1 = SessionManager();
      final manager2 = SessionManager();

      final sessionId1 = manager1.getSessionId();
      final sessionId2 = manager2.getSessionId();

      expect(sessionId1, isNot(equals(sessionId2)));
    });

    test('session ID contains no uppercase letters', () {
      final manager = SessionManager();
      final sessionId = manager.getSessionId();

      expect(sessionId, equals(sessionId.toLowerCase()));
    });

    test('session ID contains no hyphens (UUID v4 stripped)', () {
      final manager = SessionManager();
      final sessionId = manager.getSessionId();

      expect(sessionId.contains('-'), isFalse);
    });

    test('session ID is valid hex string', () {
      final manager = SessionManager();
      final sessionId = manager.getSessionId();

      // All characters should be valid hex digits
      for (var char in sessionId.split('')) {
        expect('0123456789abcdef'.contains(char), isTrue);
      }
    });

    test('multiple managers generate unique IDs', () {
      final ids = <String>{};

      for (var i = 0; i < 10; i++) {
        final manager = SessionManager();
        ids.add(manager.getSessionId());
      }

      // All 10 should be unique
      expect(ids.length, equals(10));
    });

    test('session ID format matches API requirements', () {
      final manager = SessionManager();
      final sessionId = manager.getSessionId();

      // API requires: 32 lowercase hex characters
      expect(sessionId.length, equals(32));
      expect(RegExp(r'^[0-9a-f]+$').hasMatch(sessionId), isTrue);
    });
  });
}
