import 'dart:io';

import 'package:dio/dio.dart';
import 'package:shiftboard_api/shiftboard_api.dart';

import 'token_storage.dart';

/// Sends the access token with every request that needs one and renews it
/// once when the API answers 401.
///
/// Refresh tokens are single use, so all requests that fail while a refresh is
/// running wait for that one instead of starting their own.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this._dio,
    required this._authApi,
    required this._storage,
    required this._onSessionExpired,
  });

  static const _retriedKey = 'auth_retried';

  final Dio _dio;
  final AuthApi _authApi;
  final TokenStorage _storage;
  final void Function() _onSessionExpired;

  Future<String?>? _refresh;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_needsToken(options)) {
      final tokens = await _storage.read();
      if (tokens != null) _authorize(options, tokens.accessToken);
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final canRefresh =
        err.response?.statusCode == HttpStatus.unauthorized &&
        _needsToken(options) &&
        options.extra[_retriedKey] != true;
    if (!canRefresh) return handler.next(err);

    try {
      final rejected = options.headers[HttpHeaders.authorizationHeader];
      final accessToken = await (_refresh ??= _renew(rejected)
          .whenComplete(() => _refresh = null));
      if (accessToken == null) return handler.next(err);

      _authorize(options, accessToken);
      options.extra[_retriedKey] = true;
      handler.resolve(await _dio.fetch<Object?>(options));
    } on DioException catch (error) {
      handler.next(error);
    }
  }

  /// Returns a usable access token, or null when the session is over.
  ///
  /// Throws when the refresh could not be attempted or answered, for example
  /// without a connection; the session is kept in that case.
  Future<String?> _renew(Object? rejectedHeader) async {
    final tokens = await _storage.read();
    if (tokens == null) return null;
    // Rotated while this request was on its way: the new token is there.
    if (_bearer(tokens.accessToken) != rejectedHeader) {
      return tokens.accessToken;
    }

    try {
      final response = await _authApi.refreshToken(
        refreshTokenRequest: RefreshTokenRequest(
          (b) => b.refreshToken = tokens.refreshToken,
        ),
      );
      final renewed = response.data!;
      await _storage.write((
        accessToken: renewed.accessToken,
        refreshToken: renewed.refreshToken,
      ));
      return renewed.accessToken;
    } on DioException catch (error) {
      if (error.response?.statusCode != HttpStatus.unauthorized) rethrow;
      await _storage.clear();
      _onSessionExpired();
      return null;
    }
  }

  /// The generated client marks the operations that need a token; login,
  /// refresh, logout and signup carry an empty list and are left alone.
  static bool _needsToken(RequestOptions options) {
    final secure = options.extra['secure'];
    return secure is List && secure.isNotEmpty;
  }

  static void _authorize(RequestOptions options, String accessToken) {
    options.headers[HttpHeaders.authorizationHeader] = _bearer(accessToken);
  }

  static String _bearer(String accessToken) => 'Bearer $accessToken';
}
