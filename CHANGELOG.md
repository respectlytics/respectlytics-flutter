# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-12-10

### ⚠️ Breaking Changes

- **REMOVED**: `identify()` method (GDPR/ePrivacy compliance)
- **REMOVED**: `reset()` method (no longer needed)
- **REMOVED**: SharedPreferences storage for user IDs

### Changed

- Session IDs now generated in RAM only (never persisted to disk)
- New session ID generated on every app launch
- Sessions rotate automatically every 2 hours (changed from 30-minute inactivity)

### Why This Change?

Storing identifiers on device (SharedPreferences) requires user consent under ePrivacy Directive Article 5(3). In-memory sessions require no consent, making Respectlytics truly consent-free analytics.

### Migration

Remove any calls to `identify()` and `reset()`. Session management is now automatic.

## [1.0.1] - 2025-11-30

### Changed
- Standardized privacy documentation across all Respectlytics SDKs
- Clarified IP address handling: "Used only for geolocation lookup, then discarded"
- Updated README with consistent "Privacy by Design" section format

## [1.0.0] - 2025-11-30

### Added
- Initial release of Respectlytics Flutter SDK
- `configure(apiKey:)` - Initialize SDK with your API key
- `track(eventName, screen:)` - Track events with optional screen name
- `identify()` - Enable cross-session user tracking with auto-generated user ID
- `reset()` - Clear user ID for logout scenarios
- `flush()` - Force send queued events (rarely needed)
- Automatic session management with 30-minute timeout rotation
- Offline event queue with automatic retry when connectivity returns
- Background flush when app enters paused state
- Event persistence to SharedPreferences (survives force-quit/crash)
- Automatic metadata collection: platform, os_version, app_version, locale, device_type
- 3-retry exponential backoff for network failures

### Privacy Features
- User IDs are randomly generated UUIDs, never linked to device identifiers
- No IDFA, GAID, or any device identifiers collected
- User ID cleared on app uninstall
- No custom properties - only screen name allowed (by design)

### Dependencies
- `shared_preferences: ^2.5.3`
- `http: ^1.6.0`
- `uuid: ^4.5.2`
- `connectivity_plus: ^7.0.0`
- `package_info_plus: ^9.0.0`

### Platforms
- iOS 12.0+
- Android API 21+ (Lollipop)
- Flutter 3.10.0+
- Dart 3.0.0+
