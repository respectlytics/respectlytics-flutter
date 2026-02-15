// Respectlytics SDK for Flutter
// Copyright (c) 2025 Respectlytics. Licensed under the MIT License.

/// Event data model matching the API payload format.
///
/// v2.1.0: Only 4 fields are sent (strict API allowlist):
/// - event_name (required)
/// - timestamp
/// - session_id
/// - platform
///
/// Country is derived server-side from IP (which is immediately discarded).
class Event {
  final String eventName;
  final String timestamp;
  final String sessionId;
  final String platform;

  Event({
    required this.eventName,
    required this.timestamp,
    required this.sessionId,
    required this.platform,
  });

  /// Convert to JSON map for API submission.
  Map<String, dynamic> toJson() {
    return {
      'event_name': eventName,
      'timestamp': timestamp,
      'session_id': sessionId,
      'platform': platform,
    };
  }

  /// Create from JSON map (for queue persistence).
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventName: json['event_name'] as String,
      timestamp: json['timestamp'] as String,
      sessionId: json['session_id'] as String,
      platform: json['platform'] as String,
    );
  }
}
