/// Official Respectlytics SDK for Flutter (v2.2.0)
///
/// Privacy-first analytics with no device identifiers.
/// Session-based analytics - no persistent user tracking.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:respectlytics_flutter/respectlytics_flutter.dart';
///
/// // 1. Configure (call once at app launch)
/// await Respectlytics.configure(apiKey: 'your-api-key');
///
/// // 2. Track events
/// await Respectlytics.track('purchase');
/// ```
///
/// ## Privacy by Design
///
/// - ✅ No device identifiers (no IDFA, GAID, etc.)
/// - ✅ Session IDs stored in RAM only (never written to disk)
/// - ✅ New session on every app launch
/// - ✅ Sessions rotate automatically every 2 hours
/// - ✅ Only 5 fields stored: event_name, timestamp, session_id, platform, country
library respectlytics_flutter;

export 'src/respectlytics.dart';
