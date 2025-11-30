// Respectlytics SDK for Flutter
// Copyright (c) 2025 Respectlytics. All rights reserved.
// See LICENSE file for terms.

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Collects device metadata for events.
/// 
/// Privacy-first: Only collects platform, OS version, app version,
/// locale, and device type. NO device identifiers.
class DeviceInfo {
  String _platform = 'unknown';
  String _osVersion = 'unknown';
  String _appVersion = 'unknown';
  String _locale = 'unknown';
  String _deviceType = 'unknown';

  String get platform => _platform;
  String get osVersion => _osVersion;
  String get appVersion => _appVersion;
  String get locale => _locale;
  String get deviceType => _deviceType;

  /// Load device information.
  Future<void> load() async {
    // Platform
    if (Platform.isIOS) {
      _platform = 'iOS';
    } else if (Platform.isAndroid) {
      _platform = 'Android';
    } else if (Platform.isMacOS) {
      _platform = 'macOS';
    } else if (Platform.isLinux) {
      _platform = 'Linux';
    } else if (Platform.isWindows) {
      _platform = 'Windows';
    }

    // OS Version
    _osVersion = Platform.operatingSystemVersion;

    // App Version
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion = packageInfo.version;
    } catch (e) {
      _appVersion = 'unknown';
    }

    // Locale
    _locale = Platform.localeName;

    // Device Type (simple heuristic based on platform)
    _deviceType = _detectDeviceType();
  }

  String _detectDeviceType() {
    if (Platform.isIOS || Platform.isAndroid) {
      // On mobile, we use a simple heuristic
      // In a real implementation, you might use device_info_plus
      // but we keep it minimal for privacy
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        // iOS - assume phone for now (tablets would need device_info_plus)
        return 'phone';
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        return 'phone';
      }
    } else if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      return 'desktop';
    }
    return 'unknown';
  }
}
