// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_shift.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MessageShift extends MessageShift {
  @override
  final String id;
  @override
  final String title;
  @override
  final DateTime startsAt;

  factory _$MessageShift([void Function(MessageShiftBuilder)? updates]) =>
      (MessageShiftBuilder()..update(updates))._build();

  _$MessageShift._(
      {required this.id, required this.title, required this.startsAt})
      : super._();
  @override
  MessageShift rebuild(void Function(MessageShiftBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MessageShiftBuilder toBuilder() => MessageShiftBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MessageShift &&
        id == other.id &&
        title == other.title &&
        startsAt == other.startsAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, startsAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MessageShift')
          ..add('id', id)
          ..add('title', title)
          ..add('startsAt', startsAt))
        .toString();
  }
}

class MessageShiftBuilder
    implements Builder<MessageShift, MessageShiftBuilder> {
  _$MessageShift? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  DateTime? _startsAt;
  DateTime? get startsAt => _$this._startsAt;
  set startsAt(DateTime? startsAt) => _$this._startsAt = startsAt;

  MessageShiftBuilder() {
    MessageShift._defaults(this);
  }

  MessageShiftBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _startsAt = $v.startsAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MessageShift other) {
    _$v = other as _$MessageShift;
  }

  @override
  void update(void Function(MessageShiftBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MessageShift build() => _build();

  _$MessageShift _build() {
    final _$result = _$v ??
        _$MessageShift._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'MessageShift', 'id'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'MessageShift', 'title'),
          startsAt: BuiltValueNullFieldError.checkNotNull(
              startsAt, r'MessageShift', 'startsAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
