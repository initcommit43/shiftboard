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
  /// The agency has no shifts, the worker no claims and no messages until a
  /// test adds some.
  FakeBackend() {
    on('GET /worker/shifts', (_) => json(page([])));
    on('GET /worker/my-shifts', (_) => json(page([])));
    on('GET /worker/conversation', (_) => json({'unreadCount': 0}));
    on('GET /worker/conversation/messages', (_) => json(page([])));
    on('GET /worker/conversation/events', (_) => eventStream());
  }

  final _handlers = <String, Handler>{};

  final _eventStreams = <StreamController<Uint8List>>[];

  /// How many conversation event streams are open right now.
  int get openEventStreams => _eventStreams.length;

  /// An open `text/event-stream` answer that [sendEvent] writes to until the
  /// app closes it.
  ResponseBody eventStream() {
    late final StreamController<Uint8List> controller;
    controller = StreamController<Uint8List>(
      onCancel: () => _eventStreams.remove(controller),
    );
    _eventStreams.add(controller);
    return ResponseBody(
      controller.stream,
      200,
      headers: {
        Headers.contentTypeHeader: ['text/event-stream'],
      },
    );
  }

  /// Writes [raw] to every open event stream, as the server would.
  void sendEvent(String raw) {
    for (final controller in [..._eventStreams]) {
      controller.add(utf8.encode(raw));
    }
  }

  /// Ends every open event stream, as when the server goes away.
  void dropEventStreams() {
    for (final controller in [..._eventStreams]) {
      _eventStreams.remove(controller);
      controller.close().ignore();
    }
  }

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

/// The fictional worker Lena Hofer of the agency Donau Personal. With
/// [contactButton] the agency shows the WhatsApp contact, with [checkIn] its
/// workers check in and out in the app.
Map<String, Object?> currentUser(
  String workerStatus, {
  bool contactButton = false,
  bool checkIn = false,
}) => {
  'id': '0199c0de-0000-7000-8000-000000000001',
  'email': 'lena.hofer@example.com',
  'role': 'WORKER',
  'agency': {
    'id': '0199c0de-0000-7000-8000-0000000000a1',
    'name': 'Donau Personal',
    'features': {'contactButton': contactButton, 'checkIn': checkIn},
  },
  'worker': {
    'id': '0199c0de-0000-7000-8000-0000000000b1',
    'firstName': 'Lena',
    'lastName': 'Hofer',
    'status': workerStatus,
  },
};

/// A published shift of Donau Personal, as the worker API returns it.
///
/// [start] and [end] are local times, so that tests read the times the app
/// shows. [checkInFrom] is only set where the agency uses check-in.
/// [waitlistEnabled] is set where the agency uses the waitlist, and
/// [waitlistPosition] puts the worker on it at that place.
Map<String, Object?> workerShift({
  String id = '0199c0de-0000-7000-8000-0000000000c1',
  String title = 'Lagerunterstützung',
  DateTime? start,
  DateTime? end,
  bool endIsEstimate = false,
  int hourlyRateCents = 1450,
  int slots = 5,
  int takenSlots = 2,
  String? description,
  List<String> qualifications = const [],
  String? contactPhone = '+43 660 5550100',
  String? assignmentStatus,
  DateTime? cancellableUntil,
  String? cancelledBy,
  DateTime? checkInFrom,
  DateTime? checkedInAt,
  DateTime? checkedOutAt,
  bool? hoursApproved,
  String status = 'PUBLISHED',
  bool? waitlistEnabled,
  int? waitlistPosition,
}) => {
  'id': id,
  'title': title,
  'description': ?description,
  'status': status,
  'client': {
    'id': '0199c0de-0000-7000-8000-0000000000d1',
    'name': 'Nordlicht Logistik',
  },
  'location': {
    'id': '0199c0de-0000-7000-8000-0000000000e1',
    'name': 'Zentrallager Linz',
    'address': 'Industriezeile 40, 4020 Linz',
  },
  'startsAt': (start ?? DateTime(2026, 10, 17, 18)).toUtc().toIso8601String(),
  'endsAt': (end ?? DateTime(2026, 10, 17, 23, 30)).toUtc().toIso8601String(),
  'endIsEstimate': endIsEstimate,
  'hourlyRateCents': hourlyRateCents,
  'slots': slots,
  'takenSlots': takenSlots,
  'qualifications': [
    for (final (index, name) in qualifications.indexed)
      {'id': '0199c0de-0000-7000-8000-0000000000f$index', 'name': name},
  ],
  'contact': {'name': 'Anna Berger', 'phone': ?contactPhone},
  if (assignmentStatus != null)
    'assignment': {
      'id': '0199c0de-0000-7000-8000-000000000101',
      'status': assignmentStatus,
      'claimedAt': '2026-10-14T08:00:00Z',
      'cancellableUntil': ?cancellableUntil?.toUtc().toIso8601String(),
      'cancelledBy': ?cancelledBy,
      'checkInFrom': ?checkInFrom?.toUtc().toIso8601String(),
      'checkedInAt': ?checkedInAt?.toUtc().toIso8601String(),
      'checkedOutAt': ?checkedOutAt?.toUtc().toIso8601String(),
      'hoursApproved': ?hoursApproved,
    },
  'waitlistEnabled': ?waitlistEnabled,
  if (waitlistPosition != null)
    'waitlist': {
      'position': waitlistPosition,
      'joinedAt': '2026-10-14T09:00:00Z',
    },
};

Map<String, Object?> page(List<Map<String, Object?>> content) => {
  'content': content,
  'page': 0,
  'size': 100,
  'totalElements': content.length,
  'totalPages': 1,
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
/// [overrides] replace further providers, such as the URL opener.
Future<void> pumpApp(
  WidgetTester tester,
  FakeBackend backend, {
  Locale locale = const Locale('de', 'DE'),
  String? link,
  bool settle = true,
  List<Override> overrides = const [],
}) async {
  tester.platformDispatcher.localesTestValue = [locale];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  if (link != null) {
    tester.platformDispatcher.defaultRouteNameTestValue = link;
    addTearDown(tester.platformDispatcher.clearDefaultRouteNameTestValue);
  }

  await tester.pumpWidget(
    ProviderScope(
      overrides: [apiSentTo(backend), ...overrides],
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
