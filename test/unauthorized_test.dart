// Respectlytics SDK for Flutter
// Copyright (c) 2025 Respectlytics. Licensed under the MIT License.

// A refused app key (401) through the public API: one request, then nothing
// until configure is called again.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:respectlytics_flutter/respectlytics_flutter.dart';

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

  test('a 401 stops sending until configure is called again', () async {
    final requests = <String>[];
    final logs = <String>[];

    await runZoned(
      () => http.runWithClient(
        () async {
          await Respectlytics.configure(apiKey: 'revoked-key');
          await Respectlytics.track('e1');
          await Respectlytics.track('e2', {'paywall': 'b'});
          await Respectlytics.flush();
          expect(requests, ['revoked-key e1']);

          // Later tracks and flushes send nothing
          await Respectlytics.track('e3');
          await Respectlytics.flush();
          await Respectlytics.flush();
          expect(requests, ['revoked-key e1']);

          // A new configure starts again
          await Respectlytics.configure(apiKey: 'good-key');
          await Respectlytics.track('e4');
          await Respectlytics.flush();
          expect(requests, ['revoked-key e1', 'good-key e4']);
        },
        () => MockClient((request) async {
          final key = request.headers['X-App-Key'];
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          requests.add('$key ${body['event_name']}');
          return http.Response('{}', key == 'good-key' ? 201 : 401);
        }),
      ),
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) => logs.add(line),
      ),
    );

    expect(logs.where((line) => line.contains('(401)')), hasLength(1));
  });
}
