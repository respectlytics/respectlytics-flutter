# Respectlytics Flutter SDK

[![pub package](https://img.shields.io/pub/v/respectlytics_flutter.svg)](https://pub.dev/packages/respectlytics_flutter)
[![License: Proprietary](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)

Official Respectlytics SDK for Flutter. Privacy-first analytics that respects your users.

## Features

- 🔒 **No device identifiers** - No IDFA, GAID, or fingerprinting
- 🔄 **Automatic session management** - Sessions rotate every 2 hours
- 💾 **RAM-only storage** - Session IDs never written to disk
- 🗑️ **Auto-cleanup** - Uninstall clears all data
- 📱 **Cross-platform** - iOS, Android, macOS, Linux, Windows
- ⚡ **Offline-first** - Events queue and sync when online
- 💾 **Never lose events** - Persisted immediately, survives crashes
- ✅ **Designed for GDPR/ePrivacy compliance** - Potentially consent-free

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  respectlytics_flutter: ^2.0.0
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

  runApp(MyApp());
}

// 2. Track events anywhere in your app
await Respectlytics.track('purchase', screen: 'CheckoutScreen');
```

## API Reference

### `configure(apiKey:)`
Initialize the SDK. Call once in your `main()` before `runApp()`.

### `track(eventName, {screen})`
Track an event with optional screen name. Custom properties are not supported (privacy by design).

### `flush()`
Force send queued events. Rarely needed - SDK auto-flushes every 30 seconds.

## 🔄 Automatic Session Management

Session IDs are managed entirely by the SDK - no configuration needed.

| Scenario | Behavior |
|----------|----------|
| App starts fresh | New session ID generated |
| App killed & restarted | **New session ID** (regardless of time) |
| App in foreground 2+ hours | Session ID rotates automatically |
| App in background 2+ hours | Session ID rotates on next `track()` call |

**Key points:**
- 🔄 New session on every app launch
- ⏱️ Sessions rotate after 2 hours of continuous use
- 💾 Session IDs stored in RAM only (never persisted to disk)
- 🚫 No cross-session tracking - each session is independent

## ��️ Privacy by Design

Your privacy is our priority. Our mobile analytics solution is meticulously designed to provide valuable insights without compromising your data. We achieve this by collecting only session-based data, using anonymized identifiers that are stored only in your device's memory and renewed every two hours or upon app restart. IP addresses are processed transiently for approximate geolocation (country and region) only and are never stored. This privacy-by-design approach ensures that no personal data is retained, making our solution designed to comply with GDPR and the ePrivacy Directive, potentially enabling analytics without user consent in many jurisdictions.

| What we DON'T collect | Why |
|----------------------|-----|
| IDFA / GAID | Device advertising IDs can track users across apps |
| Device fingerprints | Can be used to identify users without consent |
| IP addresses | Processed transiently for geolocation, never stored |
| Custom properties | Prevents accidental PII collection |
| Persistent user IDs | Would require consent under ePrivacy Directive |

| What we DO collect | Purpose |
|-------------------|---------|
| Event name | Analytics |
| Screen name | Navigation analytics |
| Session ID (RAM-only) | Group events within a session |
| Platform, OS version | Debugging |
| App version | Debugging |
| Approximate location | Country/region only (from IP, never stored) |

## Event Queue Behavior

Events are queued and sent automatically:
- Every 30 seconds
- When 10 events are queued
- When app goes to background
- When `flush()` is called

**Events are NEVER lost**: They are persisted to SharedPreferences immediately on every `track()` call, surviving force-quit, crashes, and app termination.

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

## Migration from v1.x

### ⚠️ Breaking Changes

- **REMOVED**: `identify()` method - no longer needed
- **REMOVED**: `reset()` method - no longer needed
- **REMOVED**: SharedPreferences storage for user IDs

### What to do

1. Remove any calls to `Respectlytics.identify()`
2. Remove any calls to `Respectlytics.reset()`
3. That's it! Session management is now automatic.

### Why this change?

Storing identifiers on device (SharedPreferences) requires user consent under ePrivacy Directive Article 5(3). In-memory sessions require no consent, making Respectlytics truly consent-free analytics.

## Getting Help

- 📖 [SDK Documentation](https://respectlytics.com/sdk/)
- 🐛 [Issue Tracker](https://github.com/respectlytics/respectlytics-flutter/issues)
- 💬 [Support](mailto:respectlytics@loheden.com)

## License

Proprietary. See [LICENSE](LICENSE) file.
