// Respectlytics SDK for Flutter
// Copyright (c) 2025 Respectlytics. All rights reserved.
// See LICENSE file for terms.

/// Event data model matching the API payload format.
/// 
/// Note: user_id is not included - Respectlytics v2.0.0 uses
/// session-based analytics only for GDPR/ePrivacy compliance.
class Event {
  final String eventName;
  final String timestamp;
  final String sessionId;
  final String? screen;
  final String platform;
  final String osVersion;
  final String appVersion;
  final String locale;
  final String deviceType;

  Event({
    required this.eventName,
    required this.timestamp,
    required this.sessionId,
    this.screen,
    required this.platform,
    required this.osVersion,
    required this.appVersion,
    required this.locale,
    required this.deviceType,
  });

  /// Convert to JSON map for API submission.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'event_name': eventName,
      'timestamp': timestamp,
      'session_id': sessionId,
      'platform': platform,
      'os_version': osVersion,
      'app_version': appVersion,
      'locale': locale,
      'device_type': deviceType,
    };

    if (screen != null) {
      json['screen'] = screen;
    }

    return json;
  }

  /// Create from JSON map (for queue persistence).
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventName: json['event_name'] as String,
      timestamp: json['timestamp'] as String,
      sessionId: json['session_id'] as String,
      screen: json['screen'] as String?,
      platform: json['platform'] as String,
      osVersion: json['os_version'] as String,
      appVersion: json['app_version'] as String,
      locale: json['locale'] as String,
      deviceType: json['device_type'] as String,
    );
  }
}
