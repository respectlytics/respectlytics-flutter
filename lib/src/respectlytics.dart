// Respectlytics SDK for Flutter
// Copyright (c) 2025 Respectlytics. All rights reserved.
// See LICENSE file for terms.

import 'dart:async';

import 'configuration.dart';
import 'event_queue.dart';
import 'session_manager.dart';
import 'models/event.dart';
import 'device_info.dart';

/// Main entry point for the Respectlytics SDK.
/// 
/// All methods are static for easy access throughout your app.
/// 
/// ## Public API (v2.0.0)
/// 
/// - `configure(apiKey:)` - Initialize SDK (call once at app launch)
/// - `track(eventName, screen:)` - Track an event
/// - `flush()` - Force send queued events
/// 
/// ## Session Management
/// 
/// Sessions are managed automatically:
/// - New session ID generated on every app launch
/// - Sessions rotate automatically after 2 hours of use
/// - Session IDs are stored in RAM only (never persisted to disk)
/// 
/// This design ensures GDPR and ePrivacy Directive compliance without
/// requiring user consent.
class Respectlytics {
  static Configuration? _configuration;
  static SessionManager? _sessionManager;
  static EventQueue? _eventQueue;
  static DeviceInfo? _deviceInfo;

  // Private constructor to prevent instantiation
  Respectlytics._();

  /// Initialize the SDK with your API key.
  /// 
  /// Call this once at app launch, typically in your main() function
  /// before runApp().
  /// 
  /// ```dart
  /// await Respectlytics.configure(apiKey: 'your-api-key');
  /// ```
  static Future<void> configure({required String apiKey}) async {
    if (apiKey.isEmpty) {
      print('[Respectlytics] ⚠️ API key cannot be empty');
      return;
    }

    _configuration = Configuration(apiKey: apiKey);
    _sessionManager = SessionManager();
    _deviceInfo = DeviceInfo();
    _eventQueue = EventQueue(configuration: _configuration!);

    await _eventQueue!.load();
    await _deviceInfo!.load();

    print('[Respectlytics] ✓ SDK configured (v2.0.0)');
  }

  /// Track an event with optional screen name.
  /// 
  /// Custom properties are NOT supported - this is by design for privacy.
  /// 
  /// ```dart
  /// await Respectlytics.track('purchase', screen: 'CheckoutScreen');
  /// await Respectlytics.track('button_tap');
  /// ```
  static Future<void> track(String eventName, {String? screen}) async {
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
      screen: screen,
      platform: _deviceInfo!.platform,
      osVersion: _deviceInfo!.osVersion,
      appVersion: _deviceInfo!.appVersion,
      locale: _deviceInfo!.locale,
      deviceType: _deviceInfo!.deviceType,
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
