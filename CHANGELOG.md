# Changelog

All notable changes to this project will be documented in this file.

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
