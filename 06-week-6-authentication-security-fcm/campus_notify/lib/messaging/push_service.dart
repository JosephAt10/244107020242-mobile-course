import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../routes.dart';

final FlutterLocalNotificationsPlugin _local =
    FlutterLocalNotificationsPlugin();

String? pendingDeepLink;

const _announcementChannel = AndroidNotificationChannel(
  'announcement',
  'Campus Announcements',
  description: 'Campus announcement alerts',
  importance: Importance.high,
);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background isolate: no BuildContext, Riverpod, router, or UI access here.
  await Firebase.initializeApp();
}

class PushService {
  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  bool _initialized = false;
  String? lastError;

  Future<bool> initialize({
    required Future<void> Function(String token) onToken,
    required void Function(String route) onRoute,
  }) async {
    if (_initialized) return true;
    lastError = null;

    try {
      await _initLocalNotifications(onRoute);

      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      final authorized =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;

      if (!authorized) {
        lastError =
            'Notification permission is ${settings.authorizationStatus.name}. Enable it in Android Settings.';
        return false;
      }

      final token = await messaging.getToken();
      if (token != null) {
        await onToken(token);
      } else {
        lastError =
            'Firebase returned no FCM token. Check Google Play services and the emulator network.';
      }

      _tokenSubscription = messaging.onTokenRefresh.listen((freshToken) async {
        // Forward rotated tokens to the configured backend. Never log tokens.
        await onToken(freshToken);
      });

      await messaging.subscribeToTopic('campus-announcement');

      _foregroundSubscription =
          FirebaseMessaging.onMessage.listen((message) async {
        final route = routeFromMessage(message.data);

        await _local.show(
          id: message.hashCode,
          title: message.notification?.title ?? 'Campus announcement',
          body: message.notification?.body ?? 'Open to view the latest update.',
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'announcement',
              'Campus Announcements',
              channelDescription: 'Campus announcement alerts',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: route,
        );
      });

      _openedSubscription =
          FirebaseMessaging.onMessageOpenedApp.listen((message) {
        onRoute(routeFromMessage(message.data));
      });

      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        onRoute(routeFromMessage(initialMessage.data));
      }

      _initialized = true;
      return true;
    } on FirebaseException catch (error) {
      // Without Firebase platform configuration, mock auth and app routing
      // remain usable, but push notifications are unavailable.
      lastError = 'Firebase Messaging error (${error.code}): ${error.message ?? 'no details'}';
      return false;
    } on PlatformException catch (error) {
      // Native Firebase resources are not configured yet.
      lastError = 'Firebase Messaging error (${error.code}): ${error.message ?? 'no details'}';
      return false;
    }
  }

  Future<void> _initLocalNotifications(
    void Function(String route) onRoute,
  ) async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _local.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final route = response.payload;
        if (route != null && route.isNotEmpty) {
          pendingDeepLink = route;
          onRoute(route);
        }
      },
    );

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_announcementChannel);
  }

  Future<void> subscribe() async {
    await FirebaseMessaging.instance
        .subscribeToTopic('campus-announcement');
  }

  Future<void> unsubscribe() async {
    await FirebaseMessaging.instance
        .unsubscribeFromTopic('campus-announcement');
  }

  bool get isInitialized => _initialized;

  Future<void> dispose() async {
    await _tokenSubscription?.cancel();
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();
  }
}
