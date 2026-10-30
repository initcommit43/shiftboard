// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_event.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConversationEvent extends ConversationEvent {
  @override
  final String conversationId;
  @override
  final ConversationChange change;

  factory _$ConversationEvent(
          [void Function(ConversationEventBuilder)? updates]) =>
      (ConversationEventBuilder()..update(updates))._build();

  _$ConversationEvent._({required this.conversationId, required this.change})
      : super._();
  @override
  ConversationEvent rebuild(void Function(ConversationEventBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConversationEventBuilder toBuilder() =>
      ConversationEventBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConversationEvent &&
        conversationId == other.conversationId &&
        change == other.change;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, conversationId.hashCode);
    _$hash = $jc(_$hash, change.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ConversationEvent')
          ..add('conversationId', conversationId)
          ..add('change', change))
        .toString();
  }
}

class ConversationEventBuilder
    implements Builder<ConversationEvent, ConversationEventBuilder> {
  _$ConversationEvent? _$v;

  String? _conversationId;
  String? get conversationId => _$this._conversationId;
  set conversationId(String? conversationId) =>
      _$this._conversationId = conversationId;

  ConversationChange? _change;
  ConversationChange? get change => _$this._change;
  set change(ConversationChange? change) => _$this._change = change;

  ConversationEventBuilder() {
    ConversationEvent._defaults(this);
  }

  ConversationEventBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _conversationId = $v.conversationId;
      _change = $v.change;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ConversationEvent other) {
    _$v = other as _$ConversationEvent;
  }

  @override
  void update(void Function(ConversationEventBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConversationEvent build() => _build();

  _$ConversationEvent _build() {
    final _$result = _$v ??
        _$ConversationEvent._(
          conversationId: BuiltValueNullFieldError.checkNotNull(
              conversationId, r'ConversationEvent', 'conversationId'),
          change: BuiltValueNullFieldError.checkNotNull(
              change, r'ConversationEvent', 'change'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
