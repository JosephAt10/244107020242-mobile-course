# Week 6 — Authentication, Security & FCM

## Objective

Build the Campus Notification App from the Week 6 codelab. The app demonstrates
mock authentication, secure token storage, one-time access-token refresh, a
GoRouter login guard, and Firebase Cloud Messaging notification routing.

## Features

- Mock email/password sign-in and route guard for `/login`, `/`, and
  `/announcement/:id`.
- Access and refresh values stored through `flutter_secure_storage`.
- Dio sends the access token as a Bearer header, refreshes once after a 401,
  retries once, and clears the session if refresh fails.
- FCM permission request, token retrieval and rotation callback, and the
  `campus-announcement` topic.
- Combined notification/data messages; a local notification is shown while
  foregrounded. Taps route through `onMessageOpenedApp` or
  `getInitialMessage` for background and terminated states.
- `routeFromMessage` is a pure function in `lib/routes.dart`; Dio error mapping
  is in `lib/data/api_errors.dart`.

## Tech stack

Flutter, Riverpod, GoRouter, Dio, `flutter_secure_storage`, `firebase_core`,
`firebase_messaging`, and `flutter_local_notifications`.

## Run the app

1. Install Flutter and use an Android emulator image with Google Play services
   or a physical Android device.
2. From this project directory, run:

   ```powershell
   flutter pub get
   flutter run
   ```

3. Demo sign-in accepts any valid email and a password of at least six
   characters. The authentication provider is intentionally mock-only; it does
   not create real accounts or issue verified JWTs.

### Configure Firebase for FCM

The Firebase setup in the codelab must be completed in your Firebase account:

1. Create a Firebase project and register an Android app with application ID
   `com.example.campus_notify` (the current value in
   `android/app/build.gradle.kts`).
2. Download that app's `google-services.json` into `android/app/`. Do not rename
   the file. The Google Services Gradle plugin is declared and is applied when
   this file is present.
3. Rebuild with `flutter run`. For iOS, add the Firebase app's
   `GoogleService-Info.plist`, configure APNs, and enable Push Notifications in
   Xcode.

Until those platform files are present, Firebase initialization is attempted
before `runApp`, then the app keeps the mock-auth flow available with FCM
disabled. Real tokens, console delivery, and notification click behavior cannot
be demonstrated before Firebase is configured.

The codelab has no campus backend. If one is available, run with
`--dart-define=CAMPUS_API_BASE_URL=https://your-campus-api.example`; current and
rotated tokens are posted to `POST /devices` as
`{"fcm_token":"…","platform":"android"}`. Without a configured backend,
the code does not send the token to a made-up service.

## Combined FCM payload

Send a notification and data payload together, as required by the codelab:

```json
{
  "message": {
    "topic": "campus-announcement",
    "notification": {
      "title": "Schedule changed",
      "body": "Mobile class moved to Room A2 at 1:00 PM"
    },
    "data": {
      "route": "/announcement/3",
      "id": "3"
    }
  }
}
```

## Required device test matrix

Use the same payload for each state. Fill in the result after testing on a
Firebase-configured device; source code is not proof of delivery.

| State | Expected result | Test procedure | Result |
|---|---|---|---|
| Foreground | Local banner appears; tap opens `/announcement/3` | Keep app open, send from Firebase Console/backend, tap banner | Not yet tested: Firebase config required |
| Background | System banner appears; tap opens `/announcement/3` | Press Home, send the same payload, tap banner | Not yet tested: Firebase config required |
| Terminated | App opens `/announcement/3` using `getInitialMessage` | Swipe-close app, send the same payload, tap banner | Not yet tested: Firebase config required |

## AI challenge and manual review

The required prompt, preserved first draft, platform differences, manual fixes,
and technical rationale are in [`docs/ai-challenge.md`](docs/ai-challenge.md).

## Tests

Run the codelab's static analysis and unit tests:

```powershell
flutter analyze
flutter test
```

`test/auth_push_test.dart` covers route parsing, the data payload's
announcement ID, mock session/refresh behavior, and user-facing API error
mapping. FCM itself requires real device integration testing.

## Reflection

1. **Why must refresh tokens not live in SharedPreferences?** It is ordinary
   preference storage, not the platform-backed secure storage intended for
   credentials. A stolen refresh token could be used to request new access
   tokens until it expires or is revoked.
2. **What if `onTokenRefresh` is ignored?** Firebase may rotate a token after
   reinstall, data wipe, or security changes. The backend then sends to a stale
   registration, and that installation stops receiving pushes.
3. **When should a topic or device token be used?** Use a topic for a broadcast,
   such as a room change for a class. Use one device token for an individual
   message, such as a private fee reminder; never broadcast personal grades or
   billing details to a topic.
4. **Which AI draft part was fixed and why?** The local notification plugin
   calls used obsolete positional arguments and did not compile with the
   installed package version. The corrected calls use named arguments. The
   background handler also remains isolated from UI navigation. Details are in
   `docs/ai-challenge.md`.

## Screenshots to capture

Save genuine, unaltered captures under `screenshots/`. Never include the full
FCM token or Firebase server credentials. See [`screenshots/README.md`](screenshots/README.md).
