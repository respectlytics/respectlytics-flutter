// Respectlytics SDK for Flutter
// Copyright (c) 2025 Respectlytics. All rights reserved.
// See LICENSE file for terms.

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Manages user ID generation and persistence.
/// 
/// User IDs are stored in SharedPreferences and persist across app launches.
/// They are cleared on app uninstall (platform behavior).
class UserManager {
  static const String _storageKey = 'com.respectlytics.userId';
  static const _uuid = Uuid();

  String? _userId;

  /// Current user ID (null if not identified).
  String? get userId => _userId;

  /// Load existing user ID from storage.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString(_storageKey);
  }

  /// Generate and persist a new user ID.
  Future<void> identify() async {
    if (_userId != null) {
      // Already identified
      return;
    }

    _userId = _generateUserId();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, _userId!);
  }

  /// Clear the user ID.
  Future<void> reset() async {
    _userId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  /// Generate a new user ID (32 lowercase hex chars).
  String _generateUserId() {
    return _uuid.v4().replaceAll('-', '').toLowerCase();
  }
}
