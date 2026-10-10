import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftboard/app.dart';
import 'package:shiftboard/core/api/api_provider.dart';
import 'package:shiftboard/core/theme/tokens.dart';
import 'package:shiftboard_api/shiftboard_api.dart';

/// Answers every request from [handler] instead of the network.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(String body, int status) {
  return ResponseBody.fromString(
    body,
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

Future<ResponseBody> _pingOk(RequestOptions options) async {
  return _json('{"status":"ok","version":"0.1.0"}', 200);
}

Future<void> _pumpApp(
  WidgetTester tester,
  _FakeAdapter adapter, {
  Locale deviceLocale = const Locale('de', 'DE'),
}) {
  tester.platformDispatcher.localesTestValue = [deviceLocale];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);

  final api = ShiftboardApi()..dio.httpClientAdapter = adapter;

  return tester.pumpWidget(
    ProviderScope(
      overrides: [apiProvider.overrideWithValue(api)],
      child: const ShiftboardApp(),
    ),
  );
}

void main() {
  testWidgets('shows a progress indicator while the ping is running', (
    tester,
  ) async {
    final response = Completer<ResponseBody>();
    await _pumpApp(tester, _FakeAdapter((_) => response.future));
    await tester.pump();

    expect(find.text(AppBrand.name), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Verbindung wird geprüft …'), findsOneWidget);
    expect(find.text('Erneut versuchen'), findsNothing);

    response.complete(_pingOk(RequestOptions()));
    await tester.pumpAndSettle();
  });

  testWidgets('shows the API version once the backend answered', (
    tester,
  ) async {
    late RequestOptions request;
    await _pumpApp(
      tester,
      _FakeAdapter((options) {
        request = options;
        return _pingOk(options);
      }),
    );
    await tester.pumpAndSettle();

    expect(request.path, '/ping');
    expect(find.text('Verbunden'), findsOneWidget);
    expect(find.text('API-Version 0.1.0'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Erneut versuchen'), findsNothing);
  });

  testWidgets('shows an error with retry when the backend is unreachable', (
    tester,
  ) async {
    final adapter = _FakeAdapter(
      (options) async => throw DioException.connectionError(
        requestOptions: options,
        reason: 'connection refused',
      ),
    );
    await _pumpApp(tester, adapter);
    await tester.pumpAndSettle();

    expect(find.text('Keine Verbindung'), findsOneWidget);
    expect(find.text('Erneut versuchen'), findsOneWidget);
    expect(find.text('Verbunden'), findsNothing);

    adapter.handler = _pingOk;
    await tester.tap(find.text('Erneut versuchen'));
    await tester.pumpAndSettle();

    expect(find.text('API-Version 0.1.0'), findsOneWidget);
    expect(find.text('Keine Verbindung'), findsNothing);
  });

  testWidgets('treats an error response as unreachable', (tester) async {
    await _pumpApp(
      tester,
      _FakeAdapter(
        (_) async => _json(
          '{"type":"about:blank","title":"Service Unavailable","status":503}',
          503,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Keine Verbindung'), findsOneWidget);
    expect(find.text('Erneut versuchen'), findsOneWidget);
  });

  testWidgets('follows the device language for supported locales', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      _FakeAdapter(_pingOk),
      deviceLocale: const Locale('en', 'US'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Connected'), findsOneWidget);
    expect(find.text('API version 0.1.0'), findsOneWidget);
  });

  testWidgets('falls back to German for unsupported locales', (tester) async {
    await _pumpApp(
      tester,
      _FakeAdapter(_pingOk),
      deviceLocale: const Locale('fr', 'FR'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Verbunden'), findsOneWidget);
  });
}
