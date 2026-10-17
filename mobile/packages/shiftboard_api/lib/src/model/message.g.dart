// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Message extends Message {
  @override
  final String id;
  @override
  final MessageType type;
  @override
  final SystemEvent? event;
  @override
  final String body;
  @override
  final bool fromWorker;
  @override
  final String? senderName;
  @override
  final MessageShift? shift;
  @override
  final DateTime createdAt;
  @override
  final DateTime? readAt;

  factory _$Message([void Function(MessageBuilder)? updates]) =>
      (MessageBuilder()..update(updates))._build();

  _$Message._(
      {required this.id,
      required this.type,
      this.event,
      required this.body,
      required this.fromWorker,
      this.senderName,
      this.shift,
      required this.createdAt,
      this.readAt})
      : super._();
  @override
  Message rebuild(void Function(MessageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MessageBuilder toBuilder() => MessageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Message &&
        id == other.id &&
        type == other.type &&
        event == other.event &&
        body == other.body &&
        fromWorker == other.fromWorker &&
        senderName == other.senderName &&
        shift == other.shift &&
        createdAt == other.createdAt &&
        readAt == other.readAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, event.hashCode);
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jc(_$hash, fromWorker.hashCode);
    _$hash = $jc(_$hash, senderName.hashCode);
    _$hash = $jc(_$hash, shift.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, readAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Message')
          ..add('id', id)
          ..add('type', type)
          ..add('event', event)
          ..add('body', body)
          ..add('fromWorker', fromWorker)
          ..add('senderName', senderName)
          ..add('shift', shift)
          ..add('createdAt', createdAt)
          ..add('readAt', readAt))
        .toString();
  }
}

class MessageBuilder implements Builder<Message, MessageBuilder> {
  _$Message? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  MessageType? _type;
  MessageType? get type => _$this._type;
  set type(MessageType? type) => _$this._type = type;

  SystemEvent? _event;
  SystemEvent? get event => _$this._event;
  set event(SystemEvent? event) => _$this._event = event;

  String? _body;
  String? get body => _$this._body;
  set body(String? body) => _$this._body = body;

  bool? _fromWorker;
  bool? get fromWorker => _$this._fromWorker;
  set fromWorker(bool? fromWorker) => _$this._fromWorker = fromWorker;

  String? _senderName;
  String? get senderName => _$this._senderName;
  set senderName(String? senderName) => _$this._senderName = senderName;

  MessageShiftBuilder? _shift;
  MessageShiftBuilder get shift => _$this._shift ??= MessageShiftBuilder();
  set shift(MessageShiftBuilder? shift) => _$this._shift = shift;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _readAt;
  DateTime? get readAt => _$this._readAt;
  set readAt(DateTime? readAt) => _$this._readAt = readAt;

  MessageBuilder() {
    Message._defaults(this);
  }

  MessageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _type = $v.type;
      _event = $v.event;
      _body = $v.body;
      _fromWorker = $v.fromWorker;
      _senderName = $v.senderName;
      _shift = $v.shift?.toBuilder();
      _createdAt = $v.createdAt;
      _readAt = $v.readAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Message other) {
    _$v = other as _$Message;
  }

  @override
  void update(void Function(MessageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Message build() => _build();

  _$Message _build() {
    _$Message _$result;
    try {
      _$result = _$v ??
          _$Message._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Message', 'id'),
            type:
                BuiltValueNullFieldError.checkNotNull(type, r'Message', 'type'),
            event: event,
            body:
                BuiltValueNullFieldError.checkNotNull(body, r'Message', 'body'),
            fromWorker: BuiltValueNullFieldError.checkNotNull(
                fromWorker, r'Message', 'fromWorker'),
            senderName: senderName,
            shift: _shift?.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'Message', 'createdAt'),
            readAt: readAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'shift';
        _shift?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Message', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
