// Respectlytics SDK for Flutter
// Copyright (c) 2025 Respectlytics. Licensed under the MIT License.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'configuration.dart';
import 'models/event.dart';
import 'network_client.dart';

/// Manages event batching and automatic flushing.
///
/// Event queue is RAM-only by design. No data is written to device storage
/// (no SharedPreferences, no files, no databases) for analytics purposes.
/// If the app is force-quit before the next flush, unsent events are lost.
/// This is a deliberate privacy-first design choice — zero bytes are written
/// to the user's device for analytics purposes.
///
/// The SDK auto-flushes every 30 seconds, on 10 queued events, and when the
/// app enters background, so the loss window is narrow.
class EventQueue with WidgetsBindingObserver {
  static const int _maxQueueSize = 10;
  static const Duration _flushInterval = Duration(seconds: 30);

  final Configuration configuration;
  final List<Event> _events = [];
  final NetworkClient _networkClient;

  Timer? _flushTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isOnline = true;
  bool _isFlushing = false;
  bool _isStopped = false;

  /// Whether the server refused the app key (401). Nothing is queued or sent
  /// from then on: no retry can fix a wrong or revoked key, and every refused
  /// request counts toward the server's block of the device's address. A new
  /// `configure` makes a new queue.
  bool get isStopped => _isStopped;

  EventQueue({required this.configuration, NetworkClient? networkClient})
    : _networkClient =
          networkClient ?? NetworkClient(configuration: configuration) {
    // Observe app lifecycle for background flush
    WidgetsBinding.instance.addObserver(this);

    // Monitor connectivity
    _setupConnectivityMonitor();

    // Start flush timer
    _startFlushTimer();
  }

  /// Add an event to the in-memory queue.
  void add(Event event) {
    if (_isStopped) return;

    _events.add(event);

    // Check if we should flush
    if (_events.length >= _maxQueueSize) {
      flush();
    }
  }

  /// Force send all queued events.
  Future<void> flush() async {
    if (_isStopped || _isFlushing || _events.isEmpty || !_isOnline) {
      return;
    }

    _isFlushing = true;

    // Take a copy of events to send
    final eventsToSend = List<Event>.from(_events);

    // Clear queue (unsent events will be re-added on failure)
    _events.clear();

    var sent = 0;
    try {
      for (final event in eventsToSend) {
        await _networkClient.sendEvent(event);
        sent++;
      }
    } catch (e) {
      if (e is NetworkError && e.type == NetworkErrorType.unauthorized) {
        _stop();
      } else {
        // Re-add only the events not yet sent to the front of the queue, so
        // an event the server already accepted is never sent twice
        _events.insertAll(0, eventsToSend.skip(sent));
        print('[Respectlytics] Failed to send events, will retry later');
      }
    } finally {
      _isFlushing = false;
    }
  }

  /// Stop for the rest of the app's run after a 401, dropping what is queued.
  void _stop() {
    _isStopped = true;
    _events.clear();
    _flushTimer?.cancel();
    print(
      '[Respectlytics] The app key was refused (401). Check it in your app\'s '
      'Settings on respectlytics.com. No events are sent until the app starts '
      'again.',
    );
  }

  void _setupConnectivityMonitor() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      result,
    ) {
      final wasOffline = !_isOnline;
      _isOnline = !result.contains(ConnectivityResult.none);

      // If we just came online, try to flush
      if (wasOffline && _isOnline) {
        flush();
      }
    });
  }

  void _startFlushTimer() {
    _flushTimer = Timer.periodic(_flushInterval, (_) {
      flush();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Flush when app goes to background
      flush();
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _flushTimer?.cancel();
    _connectivitySubscription?.cancel();
    _networkClient.dispose();
  }
}
