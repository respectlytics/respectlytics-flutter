// Respectlytics SDK for Flutter
// Copyright (c) 2025 Respectlytics. Licensed under the MIT License.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'configuration.dart';
import 'models/event.dart';
import 'network_client.dart';

/// Manages event queue, persistence, and automatic flushing.
///
/// CRITICAL: Events are IMMEDIATELY persisted on every add() call.
/// This ensures events survive force-quit, crashes, and app termination.
class EventQueue with WidgetsBindingObserver {
  static const int _maxQueueSize = 10;
  static const Duration _flushInterval = Duration(seconds: 30);
  static const String _persistenceKey = 'com.respectlytics.eventQueue';

  final Configuration configuration;
  final List<Event> _events = [];
  final NetworkClient _networkClient;

  Timer? _flushTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isOnline = true;
  bool _isFlushing = false;

  EventQueue({required this.configuration, NetworkClient? networkClient})
      : _networkClient = networkClient ?? NetworkClient(configuration: configuration) {
    // Observe app lifecycle for background flush
    WidgetsBinding.instance.addObserver(this);

    // Monitor connectivity
    _setupConnectivityMonitor();

    // Start flush timer
    _startFlushTimer();
  }

  /// Load persisted queue on SDK init.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_persistenceKey);

    if (jsonString != null) {
      try {
        final jsonList = jsonDecode(jsonString) as List;
        _events.addAll(jsonList.map((e) => Event.fromJson(e as Map<String, dynamic>)));
      } catch (e) {
        // If corrupted, start fresh
        print('[Respectlytics] Warning: Could not load persisted queue');
      }
    }
  }

  /// Add event to queue with IMMEDIATE persistence.
  ///
  /// Events are persisted BEFORE any network operations to ensure
  /// they survive force-quit, crashes, and app termination.
  Future<void> add(Event event) async {
    _events.add(event);

    // CRITICAL: Persist immediately before any async operations
    await _persistQueue();

    // Check if we should flush
    if (_events.length >= _maxQueueSize) {
      await flush();
    }
  }

  /// Force send all queued events.
  Future<void> flush() async {
    if (_isFlushing || _events.isEmpty || !_isOnline) {
      return;
    }

    _isFlushing = true;

    // Take a copy of events to send
    final eventsToSend = List<Event>.from(_events);

    // Clear queue and persist (events will be re-added on failure)
    _events.clear();
    await _persistQueue();

    try {
      await _networkClient.sendEvents(eventsToSend);
    } catch (e) {
      // Re-add failed events to front of queue
      _events.insertAll(0, eventsToSend);
      await _persistQueue();
      print('[Respectlytics] Failed to send events, will retry later');
    } finally {
      _isFlushing = false;
    }
  }

  /// Persist queue to SharedPreferences.
  Future<void> _persistQueue() async {
    final prefs = await SharedPreferences.getInstance();
    if (_events.isEmpty) {
      await prefs.remove(_persistenceKey);
    } else {
      final jsonString = jsonEncode(_events.map((e) => e.toJson()).toList());
      await prefs.setString(_persistenceKey, jsonString);
    }
  }

  void _setupConnectivityMonitor() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
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
