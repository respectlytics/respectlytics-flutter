# Respectlytics Flutter SDK

[![pub package](https://img.shields.io/pub/v/respectlytics_flutter.svg)](https://pub.dev/packages/respectlytics_flutter)
[![License: Proprietary](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)

Official Respectlytics SDK for Flutter. Privacy-first analytics that respects your users.

## Features

- 🔒 **No device identifiers** - No IDFA, GAID, or fingerprinting
- 🎲 **Random user IDs** - Not linked to device or personal data
- 🗑️ **Auto-cleanup** - Uninstall clears all data
- 📱 **Cross-platform** - iOS, Android, macOS, Linux, Windows
- ⚡ **Offline-first** - Events queue and sync when online
- 💾 **Never lose events** - Persisted immediately, survives crashes

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  respectlytics_flutter: ^1.0.1
```

Or run:

```bash
flutter pub add respectlytics_flutter
```

## Quick Start

```dart
import 'package:flutter/material.dart';
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

### \`configure(apiKey:)\`
Initialize the SDK. Call once in your \`main()\` before \`runApp()\`.

### \`track(eventName, {screen})\`
Track an event with optional screen name. Custom properties are not supported (privacy by design).

### \`identify()\`
Enable cross-session user tracking. Generates and persists a random user ID.

### \`reset()\`
Clear the user ID. Call when user logs out.

### \`flush()\`
Force send queued events. Rarely needed - SDK auto-flushes.

## Privacy by Design

| What we DON'T collect | Why |
|----------------------|-----|
| IDFA / GAID | Device advertising IDs can track users across apps |
| Device fingerprints | Can be used to identify users without consent |
| IP addresses | Used only for geolocation lookup, then discarded |
| Custom properties | Prevents accidental PII collection |

| What we DO collect | Purpose |
|-------------------|---------|
| Event name | Analytics |
| Screen name | Navigation analytics |
| Random session ID | Group events in a session |
| Random user ID (opt-in) | Cross-session analytics |
| Platform, OS version | Debugging |
| App version | Debugging |

## Event Queue Behavior

Events are queued and sent automatically:
- Every 30 seconds
- When 10 events are queued
- When app goes to background
- When \`flush()\` is called

**Events are NEVER lost**: They are persisted to SharedPreferences immediately on every \`track()\` call, surviving force-quit, crashes, and app termination.

## Platform Support

| Platform | Supported |
|----------|-----------|
| iOS      | ✅        |
| Android  | ✅        |
| macOS    | ✅        |
| Linux    | ✅        |
| Windows  | ✅        |
| Web      | ❌        |

## Requirements

- Flutter 3.10+
- Dart 3.0+

## Getting Help

- 📖 [Documentation](https://respectlytics.com/docs)
- 🐛 [Issue Tracker](https://github.com/respectlytics/respectlytics-flutter/issues)
- 💬 [Support](https://respectlytics.com/support)

## License

Proprietary. See [LICENSE](LICENSE) file.
