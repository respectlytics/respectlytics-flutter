# Respectlytics Flutter SDK

Official Respectlytics SDK for Flutter. Privacy-first analytics with automatic session management, offline support, and zero device identifier collection.

[![pub version](https://img.shields.io/pub/v/respectlytics_flutter.svg)](https://pub.dev/packages/respectlytics_flutter)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android%20%7C%20macOS%20%7C%20Linux%20%7C%20Windows-lightgrey.svg)](https://pub.dev/packages/respectlytics_flutter)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## What's New in v2.2.0

- **MIT License** — SDK is now open source under the MIT License for maximum adoption
- **Self-Hosted Support** — New `baseUrl` parameter in `configure()` lets you point at your own Respectlytics server
- **Privacy Wording** — Removed regulatory compliance claims; SDK documentation now describes technical facts only

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  respectlytics_flutter: ^2.2.0
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
await Respectlytics.track('purchase');
```

## API Reference

### `configure(apiKey:, baseUrl:)`
Initialize the SDK. Call once in your `main()` before `runApp()`.

- `apiKey` (required) — Your Respectlytics API key
- `baseUrl` (optional) — Server URL. Defaults to `https://respectlytics.com/api/v1`

### `track(eventName)`
Track an event. Custom properties are not supported (privacy by design).

### `flush()`
Force send queued events. Rarely needed - SDK auto-flushes every 30 seconds.

## Self-Hosted Server

If you're running the [Respectlytics Community Edition](https://github.com/respectlytics/respectlytics), point the SDK at your own server:

```dart
await Respectlytics.configure(
  apiKey: 'your-api-key',
  baseUrl: 'https://your-server.com/api/v1',
);
```

The `baseUrl` must include the `/api/v1` path. If omitted, the SDK defaults to the Respectlytics cloud at `https://respectlytics.com/api/v1`.

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

## 🛡️ Privacy by Design

Respectlytics helps developers **avoid collecting personal data** in the first place. Our motto is **Return of Avoidance (ROA)** — the best way to protect sensitive data is to never collect it.

### What We Store (5 fields only)

| Field | Purpose |
|-------|---------||
| `event_name` | The action being tracked |
| `timestamp` | When it happened |
| `session_id` | Groups events in a session (RAM-only, 2-hour rotation, hashed server-side) |
| `platform` | iOS, Android, macOS, Linux, Windows |
| `country` | Derived server-side from IP address (IP immediately discarded) |

### What We DON'T Collect

| Data | Why Not |
|------|---------|
| IDFA / GAID | Device advertising IDs enable cross-app tracking |
| IP addresses | Processed transiently for country lookup, never stored |
| Device fingerprints | Can be used to identify individuals |
| Custom properties | API rejects extra fields to prevent accidental PII |
| Persistent user IDs | No cross-session tracking by design |

### Privacy Architecture

- **RAM-only sessions**: Session IDs exist only in device memory, never written to disk
- **2-hour rotation**: Sessions automatically expire and regenerate
- **New session on restart**: Each app launch starts a fresh session
- **Server-side hashing**: Session IDs are hashed with daily-rotating salt before storage
- **Strict allowlist**: API rejects any fields not on the 5-field allowlist
- **Open source SDKs**: Full transparency into what data is collected

This architecture is designed to be **transparent** (you know exactly what's collected), **defensible** (minimal data surface), and **clear** (explicit reasoning for each field).

Consult your legal team to determine your specific compliance requirements.

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

## Migration Guide

### From v2.0.x to v2.1.0

**Breaking Change:** The `screen` parameter has been removed from `track()`.

```diff
- await Respectlytics.track('purchase', screen: 'CheckoutScreen');
+ await Respectlytics.track('purchase');
```

If you need screen context, include it in your event name (e.g., `checkout_screen_purchase`).

### From v1.x to v2.x

⚠️ **Breaking Changes:**
- **REMOVED**: `identify()` method - no longer needed
- **REMOVED**: `reset()` method - no longer needed
- **REMOVED**: SharedPreferences storage for user IDs

**What to do:**
1. Remove any calls to `Respectlytics.identify()`
2. Remove any calls to `Respectlytics.reset()`
3. That's it! Session management is now automatic.

## Getting Help

- 📖 [SDK Documentation](https://respectlytics.com/sdk/)
- 🐛 [Issue Tracker](https://github.com/respectlytics/respectlytics-flutter/issues)
- 💬 [Support](mailto:respectlytics@loheden.com)

## License

MIT License. See [LICENSE](LICENSE) file.
