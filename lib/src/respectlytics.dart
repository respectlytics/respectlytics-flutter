// Respectlytics SDK for Flutter
// Copyright (c) 2025 Respectlytics. All rights reserved.
// See LICENSE file for terms.

import 'dart:async';

import 'configuration.dart';
import 'event_queue.dart';
import 'session_manager.dart';
import 'user_manager.dart';
import 'models/event.dart';
import 'device_info.dart';

/// Main entry point for the Respectlytics SDK.
/// 
/// All methods are static for easy access throughout your app.
class Respectlytics {
  static Configuration? _configuration;
  static SessionManager? _sessionManager;
  static UserManager? _userManager;
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
    _userManager = UserManager();
    _deviceInfo = DeviceInfo();
    _eventQueue = EventQueue(configuration: _configuration!);

    await _userManager!.load();
    await _eventQueue!.load();
    await _deviceInfo!.load();

    print('[Respectlytics] ✓ SDK configured');
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
      userId: _userManager!.userId,
      screen: screen,
      platform: _deviceInfo!.platform,
      osVersion: _deviceInfo!.osVersion,
      appVersion: _deviceInfo!.appVersion,
      locale: _deviceInfo!.locale,
      deviceType: _deviceInfo!.deviceType,
    );

    await _eventQueue!.add(event);
  }

  /// Enable cross-session user tracking.
  /// 
  /// Generates and persists a random user ID. All subsequent events
  /// will include this ID until [reset] is called.
  /// 
  /// ```dart
  /// await Respectlytics.identify();
  /// ```
  static Future<void> identify() async {
    if (_configuration == null) {
      print('[Respectlytics] ⚠️ SDK not configured. Call configure(apiKey:) first.');
      return;
    }

    await _userManager!.identify();
    print('[Respectlytics] ✓ User identified');
  }

  /// Clear the user ID.
  /// 
  /// Call this when user logs out. Subsequent events will be anonymous
  /// until [identify] is called again.
  /// 
  /// ```dart
  /// await Respectlytics.reset();
  /// ```
  static Future<void> reset() async {
    if (_configuration == null) {
      print('[Respectlytics] ⚠️ SDK not configured. Call configure(apiKey:) first.');
      return;
    }

    await _userManager!.reset();
    print('[Respectlytics] ✓ User reset');
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
