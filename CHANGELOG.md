# Changelog

All notable changes to this project will be documented in this file.

## [3.0.0] - 2026-02-27

### ⚠️ Breaking Changes
- **REMOVED**: SharedPreferences persistence for event queue
- **REMOVED**: `shared_preferences` dependency
- **CHANGED**: `EventQueue.add()` is now synchronous (no longer returns Future)

### Changed
- Event queue is now RAM-only — zero bytes written to device for analytics
- Unsent events are lost on force-quit (deliberate privacy trade-off)
- `EventQueue.load()` method removed (no persistence to load from)
- Updated all documentation to reflect RAM-only architecture

### Why?
The v2.x event queue persisted events to SharedPreferences, contradicting Respectlytics' privacy promise of "zero device storage for analytics." v3.0.0 removes all disk persistence to align code with documentation. The ~1-3% event loss from force-quits has no meaningful impact on session-based aggregate analytics.

### Migration
Update your dependency version in `pubspec.yaml`:
```yaml
respectlytics_flutter: ^3.0.0
```
**No code changes required.** The public API (`configure`, `track`, `flush`) is unchanged.

---

## [2.2.0] - 2026-02-15

### Added
- `baseUrl` parameter in `configure()` for self-hosted Respectlytics server support
- Self-Hosted Server section in README with configuration example
- "What's New in v2.2.0" section in README

### Changed
- **License changed from Proprietary to MIT** for broader adoption and self-hosted use
- Corrected "4 fields" to "5 fields stored" (server stores country derived from IP)
- Replaced GDPR/ePrivacy compliance claim in SessionManager with technical description
- Updated copyright headers to reference MIT License
- Fixed example app to use current v2.x API (removed identify/reset/screen references)
- Updated integration test to reflect current SDK behavior

---

## [2.1.0] - 2025-12-26

### ⚠️ Breaking Changes
- **REMOVED**: `screen` parameter from `track()` method
- **REMOVED**: `os_version`, `app_version`, `locale`, `device_type` from event payload
- **REMOVED**: `device_info.dart` and `package_info_plus` dependency

### Changed
- Event payload now contains only 4 fields: `event_name`, `timestamp`, `session_id`, `platform`
- Simplified SDK by removing DeviceInfo class
- Updated privacy documentation to emphasize Return of Avoidance (ROA) approach

### Migration
Remove the `screen` parameter from any `track()` calls:

```dart
// Before (v2.0.x)
await Respectlytics.track('purchase', screen: 'CheckoutScreen');

// After (v2.1.0)
await Respectlytics.track('purchase');
```

If you need screen context, include it in the event name: `checkout_screen_purchase`

---

## [2.0.1] - 2025-12-13

### Changed
- Updated privacy documentation

## [2.0.0] - 2025-12-10

### ⚠️ Breaking Changes
- **REMOVED**: `identify()` method
- **REMOVED**: `reset()` method
- Sessions now use RAM-only storage (2-hour rotation)

### Changed
- Session IDs now generated in RAM only (never persisted to disk)
- New session ID generated on every app launch
- Sessions rotate automatically every 2 hours of continuous use

### Migration
Remove any calls to `identify()` and `reset()`. Session management is now automatic.

## [1.0.0] - 2025-11-30

### Added
- Initial release
- `configure(apiKey:)` - Initialize SDK
- `track(eventName, screen:)` - Track events
- `identify()` - Enable cross-session tracking
- `reset()` - Clear user ID
- `flush()` - Force send queued events
- Automatic session management
- Offline event queue with retry
- Background flush on app pause
