// Respectlytics SDK for Flutter
// Copyright (c) 2025 Respectlytics. All rights reserved.
// See LICENSE file for terms.

import 'package:flutter_test/flutter_test.dart';
import 'package:respectlytics_flutter/src/configuration.dart';

void main() {
  group('Configuration', () {
    test('creates configuration with API key', () {
      final config = Configuration(apiKey: 'test-api-key');

      expect(config.apiKey, equals('test-api-key'));
    });

    test('uses default base URL', () {
      final config = Configuration(apiKey: 'test-key');

      expect(config.baseUrl, equals('https://respectlytics.com/api/v1'));
    });

    test('allows custom base URL', () {
      final config = Configuration(
        apiKey: 'test-key',
        baseUrl: 'http://localhost:8080/api/v1',
      );

      expect(config.baseUrl, equals('http://localhost:8080/api/v1'));
    });

    test('generates correct events endpoint', () {
      final config = Configuration(apiKey: 'test-key');

      expect(
        config.eventsEndpoint,
        equals('https://respectlytics.com/api/v1/events/'),
      );
    });

    test('generates correct events endpoint with custom base URL', () {
      final config = Configuration(
        apiKey: 'test-key',
        baseUrl: 'http://localhost:8080/api/v1',
      );

      expect(
        config.eventsEndpoint,
        equals('http://localhost:8080/api/v1/events/'),
      );
    });

    test('handles base URL without trailing slash', () {
      final config = Configuration(
        apiKey: 'test-key',
        baseUrl: 'https://api.example.com/v1',
      );

      expect(
        config.eventsEndpoint,
        equals('https://api.example.com/v1/events/'),
      );
    });

    test('stores API key exactly as provided', () {
      const apiKey = 'pk_test_key';
      final config = Configuration(apiKey: apiKey);

      expect(config.apiKey, equals(apiKey));
    });

    test('allows empty API key (validation happens elsewhere)', () {
      final config = Configuration(apiKey: '');

      expect(config.apiKey, equals(''));
    });
  });
}
