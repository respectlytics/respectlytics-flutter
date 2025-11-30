# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
