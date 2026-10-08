# AI Challenge — PushService review

## Prompt from the codelab

> Flutter Campus Notification App. Stack: firebase_messaging,
> flutter_local_notifications, flutter_secure_storage, go_router, Riverpod.
> Generate a PushService with:
> - requestPermission + getToken + onTokenRefresh (send to POST /devices)
> - onMessage (show a local notification manually)
> - onMessageOpenedApp + getInitialMessage (navigate to data.route)
> - subscribe/unsubscribe topic campus-announcement
> - top-level background handler with @pragma('vm:entry-point')
> Mark which parts DIFFER for Android 13+ vs iOS, and which parts must never
> touch BuildContext.

## Initial AI output

The initial draft reviewed for this assignment is preserved verbatim in
[`initial-ai-push-service.txt`](initial-ai-push-service.txt). It is the
PushService draft that was first pasted into the project discussion.

## Manual validation and fixes

- Updated `flutter_local_notifications` calls to use the named arguments
  required by the installed package version (`show(id:, title:, body:,
  notificationDetails:)` and `initialize(settings:)`). The old positional calls
  did not compile.
- Kept the background handler top-level and annotated it with
  `@pragma('vm:entry-point')`. It only initializes Firebase; it does not use
  `BuildContext`, Riverpod, the router, or UI state.
- Kept `onTokenRefresh` connected to the same callback as the initial token.
  When `CAMPUS_API_BASE_URL` is supplied, that callback posts
  `fcm_token` and `platform` to `POST /devices`; this repository has no real
  campus backend, so no endpoint is invented or called by default.
- Kept combined `notification` and `data.route` handling. Foreground messages
  are shown manually, while background taps use `onMessageOpenedApp` and
  terminated-state taps use `getInitialMessage`.
- Kept topic subscribe/unsubscribe for `campus-announcement` and made route
  parsing a pure function in `lib/routes.dart`.
- Firebase now initializes before `runApp`, as required by the setup section.
  If the platform config is absent, the mock-auth exercise remains usable and
  FCM is marked unavailable. Real FCM still requires the Firebase console
  registration and Android config described in the README.

## Platform differences

- Android 13 and later require runtime notification permission. Android also
  creates the `announcement` notification channel before foreground display.
- iOS requests alert, badge, and sound authorization and requires the APNs key
  and Push Notifications capability in Xcode for actual delivery.
- The background handler runs in a separate isolate on either platform. It
  must not use `BuildContext`, Riverpod state, or router navigation. Navigation
  happens after a notification is tapped and the app is active.

## Decision and rationale

The draft’s event flow is appropriate for the codelab, but its original
positional local-notification calls do not match the installed package API, so
they had to be changed for the project to compile. Token values are never
printed or shown in full. The displayed debug token is truncated. Notification
delivery and deep-link behavior must still be demonstrated on a configured
Firebase project in foreground, background, and terminated states; source
code alone does not prove those device behaviors.
