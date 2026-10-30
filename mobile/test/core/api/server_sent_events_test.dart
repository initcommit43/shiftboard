import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shiftboard/core/api/server_sent_events.dart';

/// Decodes [body] as the app does with a response: lines, then events.
Future<List<ServerSentEvent>> decode(List<String> chunks) {
  return Stream.fromIterable(chunks)
      .transform(const LineSplitter())
      .transform(const ServerSentEventDecoder())
      .toList();
}

void main() {
  test('reads named events with their data', () async {
    final events = await decode([
      'event: conversation\n',
      'data: {"conversationId":"c1","change":"MESSAGE"}\n',
      '\n',
    ]);

    expect(events, hasLength(1));
    expect(events.single.event, 'conversation');
    expect(events.single.data, '{"conversationId":"c1","change":"MESSAGE"}');
  });

  test('joins several data lines with line breaks', () async {
    final events = await decode(['data: first\ndata:second\ndata\n\n']);

    expect(events.single.data, 'first\nsecond\n');
    expect(events.single.event, 'message');
  });

  test('skips comments such as the heartbeat', () async {
    final events = await decode([
      ': ping\n\n',
      'event: conversation\n: ping\ndata: x\n\n',
    ]);

    expect(events.map((e) => (e.event, e.data)), [('conversation', 'x')]);
  });

  test('ends an event only at a blank line, across chunks', () async {
    final events = await decode([
      'event: conv',
      'ersation\ndata: a',
      '\r\n\r',
      '\nevent: conversation\ndata: b\n\n',
    ]);

    expect(events.map((e) => e.data), ['a', 'b']);
  });

  test('drops events without data and a last event without blank line', () {
    expect(
      decode(['event: conversation\n\n', 'data: cut off\n']),
      completion(isEmpty),
    );
  });

  test('forgets the event name after each event and keeps the id', () async {
    final events = await decode([
      'id: 7\nevent: conversation\ndata: a\n\n',
      'data: b\n\n',
    ]);

    expect(events.map((e) => (e.event, e.id)), [
      ('conversation', '7'),
      ('message', '7'),
    ]);
  });

  test('ignores a byte order mark and unknown fields', () async {
    final events = await decode([
      '﻿retry: 1000\nfoo: bar\nevent: conversation\ndata:x\n\n',
    ]);

    expect(events.single.event, 'conversation');
    expect(events.single.data, 'x');
  });
}
