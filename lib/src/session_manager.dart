// Respectlytics SDK for Flutter
// Copyright (c) 2025 Respectlytics. All rights reserved.
// See LICENSE file for terms.

import 'package:uuid/uuid.dart';

/// Manages session ID generation and rotation.
/// 
/// Sessions rotate after 30 minutes of inactivity.
class SessionManager {
  static const Duration _sessionTimeout = Duration(minutes: 30);
  static const _uuid = Uuid();

  String? _sessionId;
  DateTime? _lastEventTime;

  /// Get the current session ID, rotating if necessary.
  String getSessionId() {
    final now = DateTime.now();

    // Check if session expired (30 min inactivity)
    if (_lastEventTime != null && 
        now.difference(_lastEventTime!) > _sessionTimeout) {
      _sessionId = null;
    }

    // Generate new session if needed
    _sessionId ??= _generateSessionId();
    _lastEventTime = now;

    return _sessionId!;
  }

  /// Generate a new session ID (32 lowercase hex chars).
  String _generateSessionId() {
    return _uuid.v4().replaceAll('-', '').toLowerCase();
  }
}
