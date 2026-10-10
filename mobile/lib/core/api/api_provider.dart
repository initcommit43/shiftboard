import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftboard_api/shiftboard_api.dart';

import '../../features/auth/data/auth_interceptor.dart';
import '../../features/auth/data/session.dart';
import '../../features/auth/data/token_storage.dart';

const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

/// Base URL of the backend, set with `--dart-define=API_BASE_URL=...`.
///
/// Without it the app targets a backend on the development machine. The
/// Android emulator reaches the host through 10.0.2.2, not localhost.
String get apiBaseUrl {
  if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
  return defaultTargetPlatform == TargetPlatform.android
      ? 'http://10.0.2.2:8080/api/v1'
      : ShiftboardApi.basePath;
}

final apiProvider = Provider<ShiftboardApi>(createApi);

/// Builds the client with the token handling of [AuthInterceptor].
///
/// Public so that tests can swap the HTTP adapter and keep the interceptor.
ShiftboardApi createApi(Ref ref) {
  final api = ShiftboardApi(basePathOverride: apiBaseUrl, interceptors: []);
  api.dio.interceptors.add(
    AuthInterceptor(
      dio: api.dio,
      authApi: api.getAuthApi(),
      storage: ref.watch(tokenStorageProvider),
      onSessionExpired: () => ref.read(sessionProvider.notifier).expire(),
    ),
  );
  ref.onDispose(api.dio.close);
  return api;
}
