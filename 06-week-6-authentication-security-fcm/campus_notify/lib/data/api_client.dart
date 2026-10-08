import 'package:dio/dio.dart';

import 'auth_repository.dart';
import 'token_store.dart';

class ApiClient {
  ApiClient({required TokenStore store, required AuthRepository auth, String? baseUrl,
    Future<void> Function()? onSessionExpired})
      : _store = store,
        _auth = auth,
        _onSessionExpired = onSessionExpired,
        dio = Dio(BaseOptions(
          baseUrl: (baseUrl == null || baseUrl.isEmpty)
              ? 'https://example-campus-api.test'
              : baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        )) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final access = await _store.readAccess();
        if (access != null) options.headers['Authorization'] = 'Bearer $access';
        handler.next(options);
      },
      onError: (error, handler) async {
        final request = error.requestOptions;
        if (error.response?.statusCode != 401 || request.extra['retried'] == true) {
          handler.next(error);
          return;
        }
        final refresh = await _store.readRefresh();
        if (refresh == null || refresh.isEmpty) {
          await _store.clear();
          await _onSessionExpired?.call();
          handler.next(error);
          return;
        }
        try {
          final renewed = await _auth.refresh(refresh);
          await _store.save(access: renewed, refresh: refresh);
          final retry = request.copyWith(
            headers: {...request.headers, 'Authorization': 'Bearer $renewed'},
            extra: {...request.extra, 'retried': true},
          );
          handler.resolve(await dio.fetch<dynamic>(retry));
        } catch (_) {
          await _store.clear();
          await _onSessionExpired?.call();
          handler.next(error);
        }
      },
    ));
  }

  final TokenStore _store;
  final AuthRepository _auth;
  final Future<void> Function()? _onSessionExpired;
  final Dio dio;
}
