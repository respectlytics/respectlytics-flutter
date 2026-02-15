// Respectlytics SDK for Flutter
// Copyright (c) 2025 Respectlytics. Licensed under the MIT License.

import 'dart:async';
import 'dart:io';

import 'configuration.dart';
import 'event_queue.dart';
import 'session_manager.dart';
import 'models/event.dart';

/// Main entry point for the Respectlytics SDK.
///
/// All methods are static for easy access throughout your app.
///
/// ## Public API (v2.2.0)
///
/// - `configure(apiKey:, baseUrl:)` - Initialize SDK (call once at app launch)
/// - `track(eventName)` - Track an event
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

    await _eventQueue!.load();

    print('[Respectlytics] ✓ SDK configured (v2.2.0)');
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
  /// Custom properties are NOT supported - this is by design for privacy.
  /// The server stores only 5 fields: event_name, timestamp, session_id,
  /// platform, and country (derived server-side from IP).
  ///
  /// ```dart
  /// await Respectlytics.track('purchase');
  /// await Respectlytics.track('button_tap');
  /// ```
  static Future<void> track(String eventName) async {
    if (_configuration == null) {
      print('[Respectlytics] ⚠️ SDK not configured. Call configure(apiKey:) first.');
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

    final event = Event(
      eventName: eventName,
      timestamp: DateTime.now().toUtc().toIso8601String(),
      sessionId: _sessionManager!.getSessionId(),
      platform: _platform,
    );

    await _eventQueue!.add(event);
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
      print('[Respectlytics] ⚠️ SDK not configured. Call configure(apiKey:) first.');
      return;
    }

    await _eventQueue!.flush();
  }
}
