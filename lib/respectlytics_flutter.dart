/// Official Respectlytics SDK for Flutter (v2.0.0)
/// 
/// Privacy-first analytics with no device identifiers.
/// Session-based analytics for GDPR/ePrivacy compliance.
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
/// await Respectlytics.track('purchase', screen: 'CheckoutScreen');
/// ```
/// 
/// ## Privacy by Design
/// 
/// - ✅ No device identifiers (no IDFA, GAID, etc.)
/// - ✅ Session IDs stored in RAM only (never written to disk)
/// - ✅ New session on every app launch
/// - ✅ Sessions rotate automatically every 2 hours
/// - ✅ No user consent required (GDPR/ePrivacy compliant)
library respectlytics_flutter;

export 'src/respectlytics.dart';
