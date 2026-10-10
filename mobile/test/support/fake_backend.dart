import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftboard/app.dart';
import 'package:shiftboard/core/api/api_provider.dart';
import 'package:shiftboard/core/widgets/app_text_field.dart';

typedef Handler = FutureOr<ResponseBody> Function(RequestOptions options);

/// Stands in for the backend at the HTTP adapter, so the generated client and
/// the auth interceptor run as in the app.
class FakeBackend implements HttpClientAdapter {
  final _handlers = <String, Handler>{};

  /// Every request that was sent, oldest first.
  final requests = <RequestOptions>[];

  /// Answers `method path` (for example `GET /me`) from [handler].
  void on(String route, Handler handler) => _handlers[route] = handler;

  List<RequestOptions> sent(String route) => [
    for (final request in requests)
      if ('${request.method} ${request.path}' == route) request,
  ];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final route = '${options.method} ${options.path}';
    final handler = _handlers[route];
    if (handler == null) throw StateError('No fake answer for $route');
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody json(Object? body, [int status = 200]) {
  return ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

ResponseBody noContent() => ResponseBody.fromString('', 204);

ResponseBody problem(
  int status,
  String code, {
  Map<String, String> fieldErrors = const {},
}) {
  return ResponseBody.fromString(
    jsonEncode({
      'type': 'about:blank',
      'title': code,
      'status': status,
      'code': code,
      if (fieldErrors.isNotEmpty)
        'errors': [
          for (final MapEntry(key: field, value: code) in fieldErrors.entries)
            {'field': field, 'code': code},
        ],
    }),
    status,
    headers: {
      Headers.contentTypeHeader: ['application/problem+json'],
    },
  );
}

Never offline(RequestOptions options) {
  throw DioException.connectionError(
    requestOptions: options,
    reason: 'connection refused',
  );
}

Map<String, Object?> tokenPair([String suffix = '1']) => {
  'accessToken': 'access-$suffix',
  'refreshToken': 'refresh-$suffix',
  'expiresIn': 900,
};

/// The fictional worker Lena Hofer of the agency Donau Personal.
Map<String, Object?> currentUser(String workerStatus) => {
  'id': '0199c0de-0000-7000-8000-000000000001',
  'email': 'lena.hofer@example.com',
  'role': 'WORKER',
  'agency': {
    'id': '0199c0de-0000-7000-8000-0000000000a1',
    'name': 'Donau Personal',
  },
  'worker': {
    'id': '0199c0de-0000-7000-8000-0000000000b1',
    'firstName': 'Lena',
    'lastName': 'Hofer',
    'status': workerStatus,
  },
};

/// Replaces the secure storage with a map and returns it. Pass [suffix] to
/// start with a stored session, as after an earlier login.
Map<String, String> fakeTokenStorage({String? suffix}) {
  final values = <String, String>{
    if (suffix != null) ...{
      'access_token': 'access-$suffix',
      'refresh_token': 'refresh-$suffix',
    },
  };
  FlutterSecureStorage.setMockInitialValues(values);
  return values;
}

/// A provider override that sends all API requests to [backend].
Override apiSentTo(FakeBackend backend) => apiProvider.overrideWith(
  (ref) => createApi(ref)..dio.httpClientAdapter = backend,
);

/// Starts the app. [link] is the link that launched it, if any. With
/// [settle] false the first frame stays up, for example to see a spinner.
Future<void> pumpApp(
  WidgetTester tester,
  FakeBackend backend, {
  Locale locale = const Locale('de', 'DE'),
  String? link,
  bool settle = true,
}) async {
  tester.platformDispatcher.localesTestValue = [locale];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  if (link != null) {
    tester.platformDispatcher.defaultRouteNameTestValue = link;
    addTearDown(tester.platformDispatcher.clearDefaultRouteNameTestValue);
  }

  await tester.pumpWidget(
    ProviderScope(
      overrides: [apiSentTo(backend)],
      child: const ShiftboardApp(),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

/// The text field below the visible [label].
Finder field(String label) => find.widgetWithText(AppTextField, label);

/// Scrolls [finder] into view first, as a worker would on a small screen.
Future<void> scrollToAndTap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}
