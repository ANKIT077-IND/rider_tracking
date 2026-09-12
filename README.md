# rider_tracking
## Screens
- Splash
- Login
- Create Account
- Home / Main tracking
- Trip History
- Trip Details
- Profile
- Settings

## Trip functionality
- Start/end location entry via device geocoder
- Current location as start
- Google Map with start/end markers and rider route
- Start Trip / End Trip
- Current speed, max speed, distance
- Local SQLite storage
- GPS accuracy, speed and position-jump filtering
- Android foreground/background service

## Failure requirements
### No internet during trip
Fulfilled locally: GPS points and trip metrics are written to SQLite. Internet is not required for collection. Address geocoding itself can depend on platform/provider availability, so enter/resolve locations before starting when offline.

### API timeout/server error
Backend is NOT implemented in this MVP, so there is no API call to time out. When backend sync is added, use a persistent sync queue, timeouts, exponential backoff, and keep local records until acknowledgement.

### Duplicate actions
On-device Start prevents a second active trip. A backend idempotency key (`requestId`) is stored per trip. A production API should enforce uniqueness server-side for Start/End requests.

### App killed/device restart
The active trip ID is persisted and Android service is configured for boot auto-start. If Android allows the service to restart, the trip can continue. If the OS/user force-stops the app, no generic Flutter implementation can guarantee tracking. After reboot, permission/OEM/OS restrictions must be tested. iOS force-quit is especially restrictive; native Core Location is required for robust production behavior.

### Offline then reconnect
Collection remains local. Backend sync is intentionally a next phase; no data is discarded because points remain in SQLite.

### Unrealistic GPS
Filtered using accuracy, raw speed and implied speed between accepted points. Rejected points are stored with a reason and do not increase distance/max speed.

### Server/device state mismatch
Backend is not implemented yet. Production design should reconcile server state before Start/End and use idempotent request IDs.

## Google Maps
Enable Maps SDK for Android and Maps SDK for iOS in Google Cloud. Replace `YOUR_GOOGLE_MAPS_API_KEY` in Android `build.gradle` and iOS `AppDelegate.swift`. Restrict production keys.

## Run
```bash
flutter pub get
flutter run
```

## Important
This repository is a source-layer MVP. Use `flutter create .` in the project directory if your Flutter installation requires generated platform wrapper files/Gradle wrapper, then keep the supplied `lib`, Android manifest/build settings, and iOS configuration. For production, add a real authentication/backend service rather than the local demo authentication in `AuthService`.

