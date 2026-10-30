import 'dart:async';

/// One event of a `text/event-stream` response.
class ServerSentEvent {
  const ServerSentEvent({this.event = 'message', required this.data, this.id});

  /// The `event` field, `message` when the server named none.
  final String event;

  /// The `data` lines, joined with line breaks.
  final String data;

  /// The last `id` the stream sent, if any.
  final String? id;

  @override
  String toString() => 'ServerSentEvent($event, $data)';
}

/// Turns the lines of a `text/event-stream` body into events, following the
/// HTML event stream format: `field: value` lines, several `data` lines
/// joined with line breaks, comment lines (`: ping`) ignored, and an event
/// ending at a blank line. A last event without its blank line is dropped.
///
/// Expects the lines without their line breaks, as `LineSplitter` gives them.
class ServerSentEventDecoder
    extends StreamTransformerBase<String, ServerSentEvent> {
  const ServerSentEventDecoder();

  @override
  Stream<ServerSentEvent> bind(Stream<String> lines) {
    final parser = ServerSentEventParser();
    return lines.transform(
      StreamTransformer.fromHandlers(
        handleData: (line, sink) {
          if (parser.addLine(line) case final event?) sink.add(event);
        },
      ),
    );
  }
}

/// The line by line state of [ServerSentEventDecoder].
class ServerSentEventParser {
  String? _event;
  final _data = StringBuffer();
  bool _hasData = false;
  String? _id;
  bool _first = true;

  /// Takes one line and returns the event it completes, if any.
  ServerSentEvent? addLine(String line) {
    if (_first) {
      _first = false;
      // A byte order mark may start the stream.
      if (line.startsWith('﻿')) line = line.substring(1);
    }

    if (line.isEmpty) return _dispatch();
    if (line.startsWith(':')) return null;

    final colon = line.indexOf(':');
    final field = colon < 0 ? line : line.substring(0, colon);
    var value = colon < 0 ? '' : line.substring(colon + 1);
    if (value.startsWith(' ')) value = value.substring(1);

    switch (field) {
      case 'event':
        _event = value;
      case 'data':
        if (_hasData) _data.write('\n');
        _data.write(value);
        _hasData = true;
      case 'id':
        if (!value.contains('\u0000')) _id = value;
      default:
      // `retry` and unknown fields: the app reconnects on its own schedule.
    }
    return null;
  }

  ServerSentEvent? _dispatch() {
    final event = _hasData
        ? ServerSentEvent(
            event: (_event?.isNotEmpty ?? false) ? _event! : 'message',
            data: _data.toString(),
            id: _id,
          )
        : null;
    _event = null;
    _data.clear();
    _hasData = false;
    return event;
  }
}
