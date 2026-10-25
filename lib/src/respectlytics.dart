// Respectlytics SDK for Flutter
// Copyright (c) 2025 Respectlytics. Licensed under the MIT License.

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'configuration.dart';
import 'event_queue.dart';
import 'properties.dart';
import 'session_manager.dart';
import 'models/event.dart';

/// Main entry point for the Respectlytics SDK.
///
/// All methods are static for easy access throughout your app.
///
/// ## Public API (v3.1.0)
///
/// - `configure(apiKey:, baseUrl:)` - Initialize SDK (call once at app launch)
/// - `track(eventName, [properties])` - Track an event, optionally with
///   properties
/// - `flush()` - Force send queued events
///
/// ## Session Management
///
/// Sessions are managed automatically:
/// - New session ID generated on every app launch
/// - Sessions rotate automatically after 2 hours of use
/// - Session IDs are stored in RAM only (never persisted to disk)
class Respectlytics {
  static Configuration? _configuration;
  static SessionManager? _sessionManager;
  static EventQueue? _eventQueue;
  static String _platform = 'unknown';

  // Private constructor to prevent instantiation
  Respectlytics._();

  /// Initialize the SDK with your API key.
  ///
  /// Call this once at app launch, typically in your main() function
  /// before runApp().
  ///
  /// ```dart
  /// // Cloud (default)
  /// await Respectlytics.configure(apiKey: 'your-api-key');
  ///
  /// // Self-hosted server
  /// await Respectlytics.configure(
  ///   apiKey: 'your-api-key',
  ///   baseUrl: 'https://your-server.com/api/v1',
  /// );
  /// ```
  static Future<void> configure({
    required String apiKey,
    String? baseUrl,
  }) async {
    if (apiKey.isEmpty) {
      print('[Respectlytics] ⚠️ API key cannot be empty');
      return;
    }

    _configuration = Configuration(
      apiKey: apiKey,
      baseUrl: baseUrl ?? 'https://respectlytics.com/api/v1',
    );
    _sessionManager = SessionManager();
    _eventQueue = EventQueue(configuration: _configuration!);
    _platform = _detectPlatform();

    print('[Respectlytics] ✓ SDK configured (v3.1.2)');
  }

  /// Detect the current platform.
  static String _detectPlatform() {
    if (Platform.isIOS) return 'iOS';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isWindows) return 'Windows';
    return 'unknown';
  }

  /// Track an event.
  ///
  /// The server stores 5 fields for every event: event_name, timestamp,
  /// session_id, platform, and country (derived server-side from IP).
  ///
  /// [properties] are optional. On a paid plan the server keeps a property
  /// once it is declared in the app's Settings on respectlytics.com: a list of
  /// values, or a number, which is kept only as its band (such as "5 to 10").
  /// Everything else is dropped. The SDK drops on the device anything the
  /// server could never keep, so text such as an email address, a URL or
  /// anything longer than 40 characters never leaves the device:
  ///
  /// - a name that is not lowercase letters, digits and `_`, starting with a
  ///   letter, at most 40 characters
  /// - a text value that is not 1 to 40 letters, digits, spaces, `_`, `.` or
  ///   `-`, starting with a letter or digit
  /// - a number that is NaN or infinite
  /// - any value that is not a String, a number or a bool
  /// - every property after the first 20 that pass
  ///
  /// A short value that fits these rules (such as "John Smith") is sent, and
  /// the server drops it unless it was declared.
  ///
  /// A dropped property never stops the event: it is sent with what passed.
  /// In debug builds the SDK prints which names were dropped and why, never
  /// their values.
  ///
  /// ```dart
  /// await Respectlytics.track('purchase');
  /// await Respectlytics.track('paywall_viewed', {'paywall': 'b'});
  /// await Respectlytics.track('plan_chosen', {'price': 7.5});
  /// ```
  static Future<void> track(
    String eventName, [
    Map<String, Object?>? properties,
  ]) async {
    if (_configuration == null) {
      print(
        '[Respectlytics] ⚠️ SDK not configured. Call configure(apiKey:) first.',
      );
      return;
    }

    // The server refused the app key: nothing is sent until configure again
    if (_eventQueue!.isStopped) {
      return;
    }

    if (eventName.isEmpty) {
      print('[Respectlytics] ⚠️ Event name cannot be empty');
      return;
    }

    if (eventName.length > 100) {
      print('[Respectlytics] ⚠️ Event name too long (max 100 characters)');
      return;
    }

    final filtered = _filterProperties(eventName, properties);

    final event = Event(
      eventName: eventName,
      timestamp: DateTime.now().toUtc().toIso8601String(),
      sessionId: _sessionManager!.getSessionId(),
      platform: _platform,
      properties: filtered.kept,
    );

    _eventQueue!.add(event);
  }

  /// Filter [properties] for [eventName], saying in debug builds what was
  /// dropped. Never throws: if the map cannot be read at all, the event is
  /// sent without properties.
  static FilteredProperties _filterProperties(
    String eventName,
    Map<String, Object?>? properties,
  ) {
    try {
      final filtered = PropertyFilter.filter(properties);
      if (kDebugMode) {
        final message = PropertyFilter.describeDropped(eventName, filtered);
        if (message != null) print(message);
      }
      return filtered;
    } catch (_) {
      if (kDebugMode) {
        print(
          '[Respectlytics] ⚠️ "$eventName": properties could not be read, '
          'event sent without them',
        );
      }
      return FilteredProperties.none;
    }
  }

  /// Force send queued events.
  ///
  /// Rarely needed - the SDK automatically flushes every 30 seconds
  /// or when 10 events are queued.
  ///
  /// ```dart
  /// await Respectlytics.flush();
  /// ```
  static Future<void> flush() async {
    if (_configuration == null) {
      print(
        '[Respectlytics] ⚠️ SDK not configured. Call configure(apiKey:) first.',
      );
      return;
    }

    await _eventQueue!.flush();
  }
}
