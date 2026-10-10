import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftboard/features/auth/data/auth_interceptor.dart';
import 'package:shiftboard/features/auth/data/token_storage.dart';
import 'package:shiftboard_api/shiftboard_api.dart';

import '../../support/fake_backend.dart';

void main() {
  late FakeBackend backend;
  late Map<String, String> stored;
  late AuthApi authApi;
  late int expirations;

  /// Accepts only the access token with [suffix], like a backend on which
  /// the earlier ones have expired.
  void acceptAccessToken(String suffix) {
    backend.on(
      'GET /me',
      (request) => request.headers['Authorization'] == 'Bearer access-$suffix'
          ? json(currentUser('ACTIVE'))
          : problem(401, 'unauthenticated'),
    );
  }

  setUp(() {
    backend = FakeBackend();
    stored = fakeTokenStorage(suffix: '1');
    expirations = 0;

    final api = ShiftboardApi(interceptors: [])
      ..dio.httpClientAdapter = backend;
    authApi = api.getAuthApi();
    api.dio.interceptors.add(
      AuthInterceptor(
        dio: api.dio,
        authApi: authApi,
        storage: TokenStorage(const FlutterSecureStorage()),
        onSessionExpired: () => expirations++,
      ),
    );
  });

  test('sends the access token with requests that need it', () async {
    acceptAccessToken('1');

    final response = await authApi.getCurrentUser();

    expect(response.data!.email, 'lena.hofer@example.com');
    expect(backend.requests, hasLength(1));
  });

  test(
    'sends no token to the auth endpoints and never refreshes for them',
    () async {
      backend.on(
        'POST /auth/login',
        (_) => problem(401, 'invalid_credentials'),
      );

      await expectLater(
        authApi.login(
          loginRequest: LoginRequest(
            (b) => b
              ..email = 'lena.hofer@example.com'
              ..password = 'not-her-password'
              ..client = ClientType.WORKER_APP,
          ),
        ),
        throwsA(isA<DioException>()),
      );

      expect(backend.requests.single.headers, isNot(contains('Authorization')));
      expect(stored, containsPair('refresh_token', 'refresh-1'));
      expect(expirations, 0);
    },
  );

  test('refreshes once after a 401 and repeats the request', () async {
    acceptAccessToken('2');
    backend.on('POST /auth/refresh', (_) => json(tokenPair('2')));

    final response = await authApi.getCurrentUser();

    expect(response.data!.email, 'lena.hofer@example.com');
    expect(backend.sent('GET /me'), hasLength(2));
    expect(backend.sent('POST /auth/refresh').single.data, {
      'refreshToken': 'refresh-1',
    });
    expect(stored, {'access_token': 'access-2', 'refresh_token': 'refresh-2'});
    expect(expirations, 0);
  });

  test('requests failing at the same time share one refresh', () async {
    final refreshed = Completer<void>();
    acceptAccessToken('2');
    backend.on('POST /auth/refresh', (_) async {
      await refreshed.future;
      return json(tokenPair('2'));
    });

    final responses = Future.wait([
      for (var i = 0; i < 3; i++) authApi.getCurrentUser(),
    ]);
    // All three have been rejected and wait for the refresh.
    await pumpEventQueue();
    expect(backend.sent('GET /me'), hasLength(3));
    refreshed.complete();

    expect(await responses, hasLength(3));
    expect(backend.sent('POST /auth/refresh'), hasLength(1));
    expect(backend.sent('GET /me'), hasLength(6));
  });

  test('a request rejected after the rotation uses the new token', () async {
    final secondRejection = Completer<void>();
    var rejections = 0;
    backend.on('GET /me', (request) async {
      if (request.headers['Authorization'] == 'Bearer access-2') {
        return json(currentUser('ACTIVE'));
      }
      if (++rejections == 2) await secondRejection.future;
      return problem(401, 'unauthenticated');
    });
    backend.on('POST /auth/refresh', (_) => json(tokenPair('2')));

    final first = authApi.getCurrentUser();
    final second = authApi.getCurrentUser();
    await first;
    // The second 401 arrives only now, after the tokens were rotated.
    secondRejection.complete();
    await second;

    expect(backend.sent('POST /auth/refresh'), hasLength(1));
  });

  test('ends the session when the refresh token is rejected', () async {
    acceptAccessToken('2');
    backend.on(
      'POST /auth/refresh',
      (_) => problem(401, 'invalid_refresh_token'),
    );

    await expectLater(
      authApi.getCurrentUser(),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'status',
          401,
        ),
      ),
    );

    expect(stored, isEmpty);
    expect(expirations, 1);
    expect(backend.sent('GET /me'), hasLength(1));
  });

  test('keeps the session when the refresh cannot reach the API', () async {
    acceptAccessToken('2');
    backend.on('POST /auth/refresh', offline);

    await expectLater(
      authApi.getCurrentUser(),
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'type',
          DioExceptionType.connectionError,
        ),
      ),
    );

    expect(stored, {'access_token': 'access-1', 'refresh_token': 'refresh-1'});
    expect(expirations, 0);
  });

  test('does not refresh again when the repeated request fails', () async {
    backend.on('GET /me', (_) => problem(401, 'unauthenticated'));
    backend.on('POST /auth/refresh', (_) => json(tokenPair('2')));

    await expectLater(authApi.getCurrentUser(), throwsA(isA<DioException>()));

    expect(backend.sent('POST /auth/refresh'), hasLength(1));
    expect(backend.sent('GET /me'), hasLength(2));
  });
}
