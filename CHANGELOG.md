# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.3.8] - 2026-08-19

### Added
- [Android] Added correlation headers to DevRev network requests for end-to-end request tracing.

### Changed
- [Android] Read fresh mask locations on-demand before capture instead of relying only on the per-frame pass, improving mask accuracy during rapid navigations.
- [Android] Session replay now honors a server-computed recording flag, so recording can be enabled or disabled centrally from the backend.
- [iOS] Refined network observability to track the SDK's essential API calls while excluding the SDK's own internal API traffic.
- [iOS] Improved logs traceability.

### Fixed
- [Android] Fixed masking across multiple Flutter engines/channels by tracking the foreground (active) channel and recording on it.
- [Android] Moved session-recording keystore decryption off the main thread to reduce startup jank and avoid ANRs.

## [2.3.7] - 2026-07-29

### Added
- Added an SDK version filter for session replay, allowing replay to be enabled or disabled for specific SDK versions from the dashboard.

### Fixed
- [Android] Fixed masks on the base page being dropped while a dialog or modal bottom sheet was open.
- [Android] Fixed a main-thread deadlock when resolving external masks with Flutter.
- [Android] Fixed a crash in the screenshot capturer caused by a recycled bitmap on cancel.
- [Android] Fixed an issue with mask coordinate clipping.
- [iOS] Fixed a race condition that could affect network event counts during concurrent requests.

## [2.3.6] - 2026-06-24

### Changed
- [iOS] Improved memory usage during offline session replay uploads.
- Enhanced overall performance during screen navigations.

### Fixed
- [Android] Fixed an issue related to rapid navigations.
- [Android] Fixed an ANR related to animated dialog captures.
- [Android] Fixed an issue related to keyboard scrolls on webviews.
- [Android] Fixed an issue related to dispatch window callback mutations.

## [2.3.5] - 2026-06-02

### Added
- Optional prefilled message support the support chat input field.

### Changed
- Improved privacy(masking) stability.
- Improved iOS Flutter lifecycle handling to prevent crashes when Flutter is unavailable during session replays in hybrid Flutter + native approach.

### Fixed
- Fixed session recordings associating events with the wrong DevRev's different workspace.
- [iOS] Fixed crashes from thread-unsafe.

## [2.3.4] - 2026-05-22

### Fixed
- [Android] Fixed the fractional masking delay during navigation.

## [2.3.3] - 2026-05-12

### Fixed
- Fixed an issue where Ktor classes were getting stripped due to proguard rules.
- Fixed an issue related to blank user identifier in identification calls.
- Added a fix for masking stability during scrolls. 
- Fixed an issue related to garbage characters in custom events.
- Fixed an issue with empty crash types in iOS.
- Fixed an issue with push notifications not being delivered in sandbox environments in iOS.

## [2.3.2] - 2026-04-28

### Changed
- [iOS] Reduced memory and CPU usage during paused screen recording.

### Fixed
- [iOS] Fixed crashes and memory leaks during screen recording.
- [Android] Fixed VerifyError crash.

## [2.3.1] - 2026-04-07

### Changed
- Broader stability (recording, sessions, masking, memory).
- [iOS] Screen recording uses less memory and stays idle when paused.

### Fixed
- [Android] Fixed fractional masking delay while rapid screen transitions and fast scrolling.
- [Android] Correct engagement time for sessions still uploading
- Improved rare Android long startup time and configuration issues.

## [2.3.0] - 2026-02-19

### Added
- Feature configuration for screen capture, auto-start recording, plug chat theme, and remote config (fresh vs cached/lazy fetch).

### Changed
- Improved frame capture disabled session replays experience.
- [iOS] Session upload now enforces minimum visit duration before uploading.

### Fixed
- Fixed a few memory leaks and crashes.
- [Android] Fixed device specific distorted session replays.

## [2.2.5] - 2026-02-04

### Added
- [Android] Added Masking support for multiple Flutter method channels.
- [iOS] Added CocoaPods support.

## [2.2.4] - 2026-01-29

### Changed
- Lowered the minimum supported Dart SDK to `3.5.0` across the plugin to match current Flutter stable toolchains.
- Improved session replays stabality and performance.
- Reduced log noise.
- [Android] Removed redundant dependencies for reduced SDK size and enhanced security.

### Fixed
- Fixed session data not found.

## [2.2.3] - 2025-12-18

### Added
- Introduced a capture error API so apps can report runtime errors through the SDK.

### Changed
- Improved rage tap detection to avoid misclassifying double taps as rage taps.
- [Android] Optimized session recording and network request handling to reduce overhead during active sessions.

### Fixed
- [iOS] Corrected timer response rounding to return accurate durations.
- [Android] Fixed incorrect engagement time calculation in crash scenarios.
- [Android] Fixed ANRs occurring during SDK initialization.

## [2.2.2] - 2025-11-26

### Added
- [Android] Support for session capturing on Android 16 devices.
- Support for tracking hybrid platforms and their versions.
- [iOS] Added automatic restoration of sessions lost when the app is killed.

### Changed
- Improved masking behavior on `RecyclerView` scrolls.
- Improved session upload reliability and stability.
- Optimized network bandwidth usage.
- [iOS] Improved crash log parsing and formatting for clearer diagnostics.

### Fixed
- Fixed an issue in the logout flow.

## [2.2.1] - 2025-10-17

### Added
- Added the ability to pause and resume user interaction event tracking, offering more security on the confidential screens.
- Added sendException method to track handled exceptions.
  
### Changed
- Improved performance and modularity by decoupling the screen recording functionality from the main tracking flow.

### Fixed
- [Android] Resolved potential out of memory crashes.
- [iOS] Corrected incorrect or missing device model names on certain iPhone versions.
- [iOS] Fixed visual distortion issues when zooming inside web view.

## [2.2.0] - 2025-09-16
Note: This initial release is aligned with version `2.2.0` of all supported DevRev SDK platforms to maintain consistency across the ecosystem.

### Added
- Identification of users as anonymous, unverified, or verified user.
- In-app support chat for users, including push notification support and the ability to create new conversations.
- Controlling modal behavior when links are opened from within the chat.
- Tracking custom user events and actions with rich event properties.
- Gaining session-level behavior with features like timers and screen tracking.
