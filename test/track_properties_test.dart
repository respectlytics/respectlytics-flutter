// Respectlytics SDK for Flutter
// Copyright (c) 2025 Respectlytics. Licensed under the MIT License.

// Drives the public API (configure, track, flush) and reads the HTTP body the
// SDK actually sends, through package:http's runWithClient.

import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:respectlytics_flutter/respectlytics_flutter.dart';

/// A map that cannot be read, standing in for any broken input.
class _UnreadableMap extends MapBase<String, Object?> {
  @override
  Object? operator [](Object? key) => throw StateError('unreadable');

  @override
  void operator []=(String key, Object? value) {}

  @override
  void clear() {}

  @override
  Iterable<String> get keys => throw StateError('unreadable');

  @override
  bool get isEmpty => false;

  @override
  Object? remove(Object? key) => null;
}

/// What one run of the SDK sent and printed.
class _Run {
  final List<Map<String, dynamic>> bodies = [];
  final List<String> logs = [];
}

/// Configure the SDK, run [body], flush, and return what was sent and logged.
Future<_Run> _send(Future<void> Function() body) async {
  final run = _Run();
  await runZoned(
    () => http.runWithClient(
      () async {
        await Respectlytics.configure(apiKey: 'test-key');
        await body();
        await Respectlytics.flush();
      },
      () => MockClient((request) async {
        expect(
            request.url.toString(), 'https://respectlytics.com/api/v1/events/');
        run.bodies.add(jsonDecode(request.body) as Map<String, dynamic>);
        return http.Response('{}', 201);
      }),
    ),
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) => run.logs.add(line),
    ),
  );
  return run;
}

List<String> _propertyLogs(_Run run) =>
    run.logs.where((line) => line.contains('dropped properties')).toList();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // The event queue listens for connectivity; no plugin runs in unit tests.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(
      const EventChannel('dev.fluttercommunity.plus/connectivity_status'),
      MockStreamHandler.inline(onListen: (arguments, events) {}),
    );
  });

  test('track(name) still compiles as a one-argument function', () {
    final Future<void> Function(String) track = Respectlytics.track;
    expect(track, isNotNull);
  });

  test('an event without properties is sent exactly as before', () async {
    final run = await _send(() => Respectlytics.track('app_opened'));

    expect(run.bodies, hasLength(1));
    final body = run.bodies.single;
    expect(body.keys.toSet(), {
      'event_name',
      'timestamp',
      'session_id',
      'platform',
    });
    expect(body['event_name'], 'app_opened');
    expect(_propertyLogs(run), isEmpty);
  });

  test('an empty map sends no properties key either', () async {
    final run = await _send(() => Respectlytics.track('app_opened', {}));

    expect(run.bodies.single.containsKey('properties'), isFalse);
  });

  test('an A/B variant, a number and a bool are sent as given', () async {
    final run = await _send(
      () => Respectlytics.track('paywall_viewed', {
        'paywall': 'b',
        'price': 7.5,
        'trial': true,
      }),
    );

    expect(run.bodies.single['event_name'], 'paywall_viewed');
    expect(run.bodies.single['properties'], {
      'paywall': 'b',
      'price': 7.5,
      'trial': true,
    });
    expect(_propertyLogs(run), isEmpty);
  });

  test('bad properties are dropped and the event is still sent', () async {
    final run = await _send(
      () => Respectlytics.track('signup', {
        'Email': 'x',
        'email': 'jane@example.com',
        'ratio': double.nan,
        'tags': ['a', 'b'],
        'plan': 'pro',
      }),
    );

    expect(run.bodies, hasLength(1));
    expect(run.bodies.single['event_name'], 'signup');
    expect(run.bodies.single['properties'], {'plan': 'pro'});
    expect(jsonEncode(run.bodies.single), isNot(contains('jane')));
  });

  test('an event whose properties are all bad is sent without them', () async {
    final run = await _send(
      () => Respectlytics.track('signup', {
        'note': 'Free text, with punctuation!',
        'when': DateTime(2026),
      }),
    );

    expect(run.bodies, hasLength(1));
    expect(run.bodies.single.containsKey('properties'), isFalse);
  });

  test('more than 20 properties: the first 20 are sent', () async {
    final run = await _send(
      () => Respectlytics.track('many', {
        for (var i = 1; i <= 30; i++) 'p$i': i,
      }),
    );

    final sent = run.bodies.single['properties'] as Map<String, dynamic>;
    expect(sent.keys.toList(), [for (var i = 1; i <= 20; i++) 'p$i']);
  });

  test('the debug log names drops once per event, never the values', () async {
    final run = await _send(() async {
      await Respectlytics.track('signup', {
        'email': 'jane@example.com',
        'Bad Name': 'secret_value',
        'plan': 'pro',
      });
      await Respectlytics.track('clean', {'plan': 'pro'});
    });

    final lines = _propertyLogs(run);
    expect(lines, hasLength(1));
    expect(lines.single, contains('signup'));
    expect(lines.single, contains('email ('));
    expect(lines.single, contains('Bad Name ('));
    expect(lines.single, isNot(contains('jane')));
    expect(lines.single, isNot(contains('secret_value')));
    expect(lines.single, isNot(contains('plan')));
    expect(run.bodies, hasLength(2));
  });

  test('a map that cannot be read never stops the event', () async {
    final run = await _send(
      () => Respectlytics.track('broken_input', _UnreadableMap()),
    );

    expect(run.bodies, hasLength(1));
    expect(run.bodies.single['event_name'], 'broken_input');
    expect(run.bodies.single.containsKey('properties'), isFalse);
  });

  test('the caller changing its map after track changes nothing sent',
      () async {
    final properties = <String, Object?>{'paywall': 'a'};
    final run = await _send(() async {
      await Respectlytics.track('paywall_viewed', properties);
      properties['paywall'] = 'b';
      properties['extra'] = 'c';
    });

    expect(run.bodies.single['properties'], {'paywall': 'a'});
  });
}
