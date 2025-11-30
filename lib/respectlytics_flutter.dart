/// Official Respectlytics SDK for Flutter
/// 
/// Privacy-first analytics with no device identifiers.
/// 
/// ## Quick Start
/// 
/// ```dart
/// import 'package:respectlytics_flutter/respectlytics_flutter.dart';
/// 
/// // 1. Configure (call once at app launch)
/// await Respectlytics.configure(apiKey: 'your-api-key');
/// 
/// // 2. Enable user tracking (optional)
/// await Respectlytics.identify();
/// 
/// // 3. Track events
/// await Respectlytics.track('purchase', screen: 'CheckoutScreen');
/// ```
/// 
/// ## Privacy
/// 
/// - ✅ No device identifiers collected (no IDFA, GAID, etc.)
/// - ✅ User IDs are random, not linked to device
/// - ✅ Uninstall clears all data
/// - ✅ No custom properties - only screen name allowed
library respectlytics_flutter;

export 'src/respectlytics.dart';
