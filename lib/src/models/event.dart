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
/// v3.1.0: plus `properties`, only when the event carries any. They are
/// already filtered on the device (see `PropertyFilter`), and the server keeps
/// only those the app declared in its Settings on respectlytics.com.
///
/// Country is derived server-side from IP (which is immediately discarded).
class Event {
  final String eventName;
  final String timestamp;
  final String sessionId;
  final String platform;

  /// The event's properties, already filtered. Empty when it has none.
  final Map<String, Object> properties;

  Event({
    required this.eventName,
    required this.timestamp,
    required this.sessionId,
    required this.platform,
    Map<String, Object> properties = const {},
  }) : properties = Map.unmodifiable(properties);

  /// Convert to JSON map for API submission.
  ///
  /// `properties` is included only when the event has any, so an event
  /// without properties is sent exactly as before v3.1.0.
  Map<String, dynamic> toJson() {
    return {
      'event_name': eventName,
      'timestamp': timestamp,
      'session_id': sessionId,
      'platform': platform,
      if (properties.isNotEmpty) 'properties': properties,
    };
  }

  /// Create from JSON map.
  factory Event.fromJson(Map<String, dynamic> json) {
    final properties = json['properties'] as Map<String, dynamic>?;
    return Event(
      eventName: json['event_name'] as String,
      timestamp: json['timestamp'] as String,
      sessionId: json['session_id'] as String,
      platform: json['platform'] as String,
      properties: properties == null
          ? const {}
          : {
              for (final entry in properties.entries)
                if (entry.value != null) entry.key: entry.value as Object,
            },
    );
  }
}
