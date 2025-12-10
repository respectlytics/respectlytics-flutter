// Respectlytics SDK for Flutter
// Copyright (c) 2025 Respectlytics. All rights reserved.
// See LICENSE file for terms.

import 'package:uuid/uuid.dart';

/// Manages session ID generation and automatic rotation.
/// 
/// Sessions are stored in RAM only (never persisted to disk) and:
/// - Regenerate on every app restart
/// - Rotate automatically after 2 hours of continuous use
/// 
/// This ensures compliance with GDPR and ePrivacy Directive without
/// requiring user consent.
class SessionManager {
  /// Session timeout: 2 hours (7200 seconds)
  static const Duration _sessionTimeout = Duration(hours: 2);
  static const _uuid = Uuid();

  String _sessionId;
  DateTime _sessionStart;

  SessionManager()
      : _sessionId = _generateSessionId(),
        _sessionStart = DateTime.now();

  /// Get the current session ID, rotating if 2 hours have elapsed.
  String getSessionId() {
    final now = DateTime.now();

    // Check if session expired (2 hours of use)
    if (now.difference(_sessionStart) > _sessionTimeout) {
      _sessionId = _generateSessionId();
      _sessionStart = now;
    }

    return _sessionId;
  }

  /// Generate a new session ID (32 lowercase hex chars).
  static String _generateSessionId() {
    return _uuid.v4().replaceAll('-', '').toLowerCase();
  }
}
