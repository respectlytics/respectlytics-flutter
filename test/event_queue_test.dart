// Respectlytics SDK for Flutter
// Copyright (c) 2025 Respectlytics. Licensed under the MIT License.

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:respectlytics_flutter/src/configuration.dart';
import 'package:respectlytics_flutter/src/event_queue.dart';
import 'package:respectlytics_flutter/src/models/event.dart';
import 'package:respectlytics_flutter/src/network_client.dart';

Event _event(String name, {Map<String, Object> properties = const {}}) => Event(
      eventName: name,
      timestamp: '2026-10-24T10:00:00Z',
      sessionId: 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4',
      platform: 'iOS',
      properties: properties,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<Map<String, dynamic>> requests;
  late int Function(Map<String, dynamic> body) answer;
  late EventQueue queue;

  setUp(() {
    // The event queue listens for connectivity; no plugin runs in unit tests.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(
      const EventChannel('dev.fluttercommunity.plus/connectivity_status'),
      MockStreamHandler.inline(onListen: (arguments, events) {}),
    );

    requests = [];
    answer = (_) => 201;
    final configuration = Configuration(apiKey: 'test-key');
    queue = EventQueue(
      configuration: configuration,
      networkClient: NetworkClient(
        configuration: configuration,
        client: MockClient((request) async {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          requests.add(body);
          return http.Response('{}', answer(body));
        }),
      ),
    );
  });

  tearDown(() => queue.dispose());

  List<String> names() =>
      requests.map((body) => body['event_name'] as String).toList();

  test('a failed flush never sends an accepted event twice', () async {
    queue.add(_event('e1'));
    queue.add(_event('e2'));
    queue.add(_event('e3'));

    answer = (body) => body['event_name'] == 'e2' ? 401 : 201;
    await queue.flush();
    expect(names(), ['e1', 'e2']);

    requests.clear();
    answer = (_) => 201;
    await queue.flush();
    expect(names(), ['e2', 'e3']);
  });

  test('an event refused with 400 is dropped and the rest are sent', () async {
    queue.add(_event('e1'));
    queue.add(_event('e2'));
    queue.add(_event('e3'));

    answer = (body) => body['event_name'] == 'e1' ? 400 : 201;
    await queue.flush();
    expect(names(), ['e1', 'e2', 'e3']);

    requests.clear();
    await queue.flush();
    expect(requests, isEmpty);
  });

  test('a server refusing properties gets the event without them', () async {
    queue.add(_event('paywall_viewed', properties: {'paywall': 'b'}));
    queue.add(_event('e2'));

    answer = (body) => body.containsKey('properties') ? 400 : 201;
    await queue.flush();

    expect(names(), ['paywall_viewed', 'paywall_viewed', 'e2']);
    expect(requests[0]['properties'], {'paywall': 'b'});
    expect(requests[1].containsKey('properties'), isFalse);
    expect(requests[1].keys.toSet(), {
      'event_name',
      'timestamp',
      'session_id',
      'platform',
    });

    requests.clear();
    await queue.flush();
    expect(requests, isEmpty);
  });

  test('an event refused with and without properties is dropped', () async {
    queue.add(_event('bad', properties: {'paywall': 'b'}));
    queue.add(_event('e2'));

    answer = (body) => body['event_name'] == 'bad' ? 400 : 201;
    await queue.flush();
    expect(names(), ['bad', 'bad', 'e2']);

    requests.clear();
    await queue.flush();
    expect(requests, isEmpty);
  });

  test('an event without properties is sent once on a 400', () async {
    queue.add(_event('bad'));

    answer = (_) => 400;
    await queue.flush();
    expect(names(), ['bad']);
  });
}
