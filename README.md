# Respectlytics Flutter SDK

Official Respectlytics SDK for Flutter. Privacy-first analytics.

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  respectlytics_flutter: ^1.0.0
```

Or run:

```bash
flutter pub add respectlytics_flutter
```

## Quick Start

```dart
import 'package:respectlytics_flutter/respectlytics_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Configure (call once at app launch)
  await Respectlytics.configure(apiKey: 'your-api-key');

  // 2. Enable user tracking (optional)
  await Respectlytics.identify();

  runApp(MyApp());
}

// 3. Track events anywhere in your app
await Respectlytics.track('purchase', screen: 'CheckoutScreen');
```

## API Reference

### `configure(apiKey:)`
Initialize the SDK. Call once in your `main()` before `runApp()`.

### `track(eventName, {screen})`
Track an event with optional screen name. Custom properties are not supported (privacy by design).

### `identify()`
Enable cross-session user tracking. Generates and persists a random user ID.

### `reset()`
Clear the user ID. Call when user logs out.

### `flush()`
Force send queued events. Rarely needed - SDK auto-flushes.

## Privacy

- ✅ No device identifiers collected (no IDFA, GAID, etc.)
- ✅ User IDs are random, not linked to device
- ✅ Uninstall clears all data
- ✅ No custom properties - only screen name allowed

## Event Queue Behavior

Events are queued and sent automatically:
- Every 30 seconds
- When 10 events are queued
- When app goes to background
- When `flush()` is called

**Events are NEVER lost**: They are persisted to SharedPreferences immediately on every `track()` call, surviving force-quit, crashes, and app termination.

## Platform Support

| Platform | Support |
|----------|---------|
| iOS      | ✅      |
| Android  | ✅      |
| macOS    | ✅      |
| Linux    | ✅      |
| Windows  | ✅      |

## Requirements

- Flutter 3.10+
- Dart 3.0+

## License

Proprietary. See [LICENSE](LICENSE) file.
