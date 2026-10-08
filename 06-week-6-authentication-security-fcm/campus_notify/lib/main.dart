import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'data/api_client.dart';
import 'data/auth_repository.dart';
import 'messaging/push_service.dart';
import 'pages/announcement_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';
import 'routes.dart';

late final ProviderContainer appContainer;
late final GoRouter appRouter;
late final _RouterRefresh routerRefresh;
final ValueNotifier<String?> tokenPreview = ValueNotifier(null);
final ValueNotifier<bool?> messagingReady = ValueNotifier(null);
final ValueNotifier<String?> messagingIssue = ValueNotifier(null);
final PushService pushService = PushService();
bool firebaseInitialized = false;

Future<void> startPushService() async {
  if (!firebaseInitialized) {
    messagingReady.value = false;
    return;
  }
  final baseUrl = const String.fromEnvironment('CAMPUS_API_BASE_URL');
  final api = ApiClient(
    store: appContainer.read(tokenStoreProvider),
    auth: appContainer.read(authRepositoryProvider),
    baseUrl: baseUrl,
    onSessionExpired: () => appContainer.read(authStateProvider.notifier).logout(),
  );
  final ready = await pushService.initialize(
    onToken: (token) async {
      tokenPreview.value = token.length > 12 ? '${token.substring(0, 12)}…' : '••••••••';
      if (baseUrl.isEmpty) return; // Documented endpoint mode: no fake server call.
      try {
        await api.dio.post<dynamic>('/devices', data: {
          'fcm_token': token,
          'platform': defaultTargetPlatform.name.toLowerCase(),
        });
      } on DioException {
        // Keep FCM listener alive; UI never displays or logs a full token.
      }
    },
    onRoute: (route) => appRouter.go(route),
  );
  messagingReady.value = ready;
  messagingIssue.value = pushService.lastError;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseReady = false;
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    firebaseReady = true;
  } on FirebaseException catch (error) {
    // The mock-auth exercise can run before the Firebase console setup is done.
    final details = error.message ?? 'no details';
    messagingIssue.value = 'Firebase initialization failed (${error.code}): $details';
  } on PlatformException catch (error) {
    // Android Firebase resources are generated after adding google-services.json.
    final details = error.message ?? 'no details';
    messagingIssue.value = 'Firebase initialization failed (${error.code}): $details';
  }
  firebaseInitialized = firebaseReady;
  runApp(_BootstrapApp(firebaseReady: firebaseReady));
}

class _RouterRefresh extends ChangeNotifier {}

class _BootstrapApp extends StatefulWidget {
  const _BootstrapApp({required this.firebaseReady});

  final bool firebaseReady;

  @override
  State<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<_BootstrapApp> {
  bool _ready = false;
  String? _startupError;

  @override
  void initState() {
    super.initState();
    unawaited(_initializeApp());
  }

  Future<void> _initializeApp() async {
    setState(() => _startupError = null);
    final container = ProviderContainer();
    try {
      final loggedIn = await container
          .read(authStateProvider.future)
          .timeout(const Duration(seconds: 20));
      final refresh = _RouterRefresh();
      container.listen(authStateProvider, (_, __) => refresh.notifyListeners());
      final router = GoRouter(
        initialLocation: loggedIn ? AppRoutes.home : AppRoutes.login,
        refreshListenable: refresh,
        redirect: (context, state) {
          final authenticated = container.read(authStateProvider).value ?? false;
          final goingToLogin = state.matchedLocation == AppRoutes.login;
          if (!authenticated && !goingToLogin) return AppRoutes.login;
          if (authenticated && goingToLogin) return AppRoutes.home;
          return null;
        },
        routes: [
          GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginPage()),
          GoRoute(path: AppRoutes.home, builder: (_, __) => const HomePage()),
          GoRoute(
            path: AppRoutes.announcementPattern,
            builder: (_, state) => AnnouncementPage(id: state.pathParameters['id'] ?? ''),
          ),
        ],
      );

      if (!mounted) {
        router.dispose();
        refresh.dispose();
        container.dispose();
        return;
      }

      appContainer = container;
      routerRefresh = refresh;
      appRouter = router;
      setState(() {
        _ready = true;
      });
    } catch (error) {
      container.dispose();
      if (!mounted) return;
      setState(() => _startupError = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) {
      return UncontrolledProviderScope(
        container: appContainer,
        child: CampusNotifyApp(firebaseReady: widget.firebaseReady),
      );
    }

    return MaterialApp(
      title: 'Campus Notify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2457D6)),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: _startupError == null
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text('Starting Campus Notify…'),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text(
                        'Campus Notify could not start',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(_startupError!, textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      FilledButton(onPressed: _initializeApp, child: const Text('Try again')),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class CampusNotifyApp extends StatefulWidget {
  const CampusNotifyApp({required this.firebaseReady, super.key});
  final bool firebaseReady;

  @override
  State<CampusNotifyApp> createState() => _CampusNotifyAppState();
}

class _CampusNotifyAppState extends State<CampusNotifyApp> {
  @override
  void initState() {
    super.initState();
    if (!widget.firebaseReady) {
      messagingReady.value = false;
    }
  }

  @override
  void dispose() {
    unawaited(pushService.dispose());
    appRouter.dispose();
    routerRefresh.dispose();
    appContainer.dispose();
    tokenPreview.dispose();
    messagingReady.dispose();
    messagingIssue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Campus Notify',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2457D6)),
          useMaterial3: true, scaffoldBackgroundColor: const Color(0xFFF5F7FB)),
        routerConfig: appRouter,
      );
}
