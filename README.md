# Respectlytics Flutter SDK

Official Respectlytics SDK for Flutter. Privacy-first analytics with automatic session management, zero device storage, and no device identifier collection.

[![pub version](https://img.shields.io/pub/v/respectlytics_flutter.svg)](https://pub.dev/packages/respectlytics_flutter)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android%20%7C%20macOS%20%7C%20Linux%20%7C%20Windows-lightgrey.svg)](https://pub.dev/packages/respectlytics_flutter)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## What's New in v3.1.0

- **Event properties**: `track(eventName, properties)` can send properties, such as the variant of an A/B test. See [Properties and A/B tests](#properties-and-ab-tests).
- Existing `track(eventName)` calls work as before and send the same request.

## What's New in v3.0.0

- **RAM-Only Event Queue** — Events are no longer persisted to SharedPreferences. The entire SDK now writes zero bytes to the device for analytics
- **Zero Device Storage** — Session IDs AND event queue are held exclusively in RAM
- **Removed `shared_preferences` dependency** — One fewer dependency to audit

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  respectlytics_flutter: ^3.1.0
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

### `track(eventName, [properties])`
Track an event.

- `eventName` (required): The action being tracked, at most 100 characters
- `properties` (optional): A `Map<String, Object?>` of names to a `String`, a number or a `bool`. See [Properties and A/B tests](#properties-and-ab-tests).

### `flush()`
Force send queued events. Rarely needed - SDK auto-flushes every 30 seconds.

## Properties and A/B tests

An event can carry properties.
On a paid plan, the server keeps a property once you declare it in your app's Settings on respectlytics.com.
A property is one of two kinds:

- **A list of values**, such as the variants of an A/B test.
  A value is kept only when it matches one you declared exactly (case matters).
  For a list of `true` and `false` you can send a `bool`.
- **A number**, which is kept only as the band it falls in (such as "5 to 10").

```dart
// The variant of an A/B test
await Respectlytics.track('paywall_viewed', {'paywall': 'b'});

// A number, kept as its band
await Respectlytics.track('plan_chosen', {'price': 7.5});
```

What is dropped:

- **Anything you have not declared**, and every property on the free plan.
  The server drops it and still keeps the event.
- **Text that does not fit the shape of a declared value**, such as an email address, a URL or anything over 40 characters.
  The SDK drops it on the device, so it never leaves the device.
  A name must be lowercase letters, digits and `_`, start with a letter, and be at most 40 characters.
  A text value must be 1 to 40 letters, digits, spaces, `_`, `.` or `-`, starting with a letter or digit.
  A number must be finite, and any other type of value is dropped.
  A short value that fits the shape, such as "John Smith", is sent, and the server drops it unless you declared it.
- **More than 20 properties** on one event.
  The first 20 that pass are sent.

A dropped property never stops the event: it is sent with the properties that passed.
In debug builds the SDK prints which names it dropped and why, never their values.

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
- 🧠 Session IDs stored in RAM only (never persisted to disk)
- 🚫 No cross-session tracking - each session is independent

## 🛡️ Privacy by Design

Respectlytics helps developers **avoid collecting personal data** in the first place. Our motto is **Return of Avoidance (ROA)** — the best way to protect sensitive data is to never collect it.

### What We Store (5 fields, plus declared properties on paid plans)

| Field | Purpose |
|-------|---------|
| `event_name` | The action being tracked |
| `timestamp` | When it happened |
| `session_id` | Groups events in a session (RAM-only, 2-hour rotation, hashed server-side) |
| `platform` | iOS, Android, macOS, Linux, Windows |
| `country` | Derived server-side from IP address (IP immediately discarded) |
| `properties` | Paid plans only: the properties you declared, each a value from your list or a number's band |

### What We DON'T Collect

| Data | Why Not |
|------|---------|
| IDFA / GAID | Device advertising IDs enable cross-app tracking |
| IP addresses | Processed transiently for country lookup, never stored |
| Device fingerprints | Can be used to identify individuals |
| Undeclared properties and free text | Only properties you declared are kept, with a value from your list or a number's band |
| Persistent user IDs | No cross-session tracking by design |

### Privacy Architecture

- **RAM-only sessions**: Session IDs exist only in device memory, never written to disk
- **RAM-only event queue**: Events are held in memory until flushed to the server — zero device storage
- **2-hour rotation**: Sessions automatically expire and regenerate
- **New session on restart**: Each app launch starts a fresh session
- **Server-side hashing**: Session IDs are hashed with daily-rotating salt before storage
- **Strict allowlist**: API rejects any field not on its allowlist, and keeps a property only when you declared it
- **Open source SDKs**: Full transparency into what data is collected

This architecture is designed to be **transparent** (you know exactly what's collected), **defensible** (minimal data surface), and **clear** (explicit reasoning for each field).

Consult your legal team to determine your specific compliance requirements.

## Event Queue Behavior

Events are queued in memory and sent automatically:
- Every 30 seconds
- When 10 events are queued
- When app goes to background
- When `flush()` is called
- When the device comes back online

**Unsent events are lost on force-quit** — this is a deliberate privacy trade-off. The SDK writes zero bytes to the device for analytics purposes. The ~1-3% event loss from force-quits has no meaningful impact on session-based aggregate analytics.

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

### From v3.0.0 to v3.1.0

Update your dependency to `respectlytics_flutter: ^3.1.0`.

**No code changes required.** `track(eventName)` works as before and sends the same request. To send properties, see [Properties and A/B tests](#properties-and-ab-tests).

### From v2.x to v3.0.0

**Breaking Change:** Event queue no longer persists to SharedPreferences.

Update your dependency version:

```yaml
# Before
respectlytics_flutter: ^2.2.0

# After
respectlytics_flutter: ^3.0.0
```

**No code changes required.** The public API (`configure`, `track`, `flush`) is unchanged. Events previously stored in SharedPreferences under the old key will be ignored (they remain inert but are never read).

**What changed:**
- Events are now held in an in-memory list (RAM-only)
- Unsent events are lost on force-quit — this is by design
- `shared_preferences` is no longer a dependency

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
