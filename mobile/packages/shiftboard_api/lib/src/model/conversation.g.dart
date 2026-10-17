// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Conversation extends Conversation {
  @override
  final String id;
  @override
  final ConversationWorker worker;
  @override
  final Message lastMessage;
  @override
  final int unreadCount;

  factory _$Conversation([void Function(ConversationBuilder)? updates]) =>
      (ConversationBuilder()..update(updates))._build();

  _$Conversation._(
      {required this.id,
      required this.worker,
      required this.lastMessage,
      required this.unreadCount})
      : super._();
  @override
  Conversation rebuild(void Function(ConversationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConversationBuilder toBuilder() => ConversationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Conversation &&
        id == other.id &&
        worker == other.worker &&
        lastMessage == other.lastMessage &&
        unreadCount == other.unreadCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, worker.hashCode);
    _$hash = $jc(_$hash, lastMessage.hashCode);
    _$hash = $jc(_$hash, unreadCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Conversation')
          ..add('id', id)
          ..add('worker', worker)
          ..add('lastMessage', lastMessage)
          ..add('unreadCount', unreadCount))
        .toString();
  }
}

class ConversationBuilder
    implements Builder<Conversation, ConversationBuilder> {
  _$Conversation? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  ConversationWorkerBuilder? _worker;
  ConversationWorkerBuilder get worker =>
      _$this._worker ??= ConversationWorkerBuilder();
  set worker(ConversationWorkerBuilder? worker) => _$this._worker = worker;

  MessageBuilder? _lastMessage;
  MessageBuilder get lastMessage => _$this._lastMessage ??= MessageBuilder();
  set lastMessage(MessageBuilder? lastMessage) =>
      _$this._lastMessage = lastMessage;

  int? _unreadCount;
  int? get unreadCount => _$this._unreadCount;
  set unreadCount(int? unreadCount) => _$this._unreadCount = unreadCount;

  ConversationBuilder() {
    Conversation._defaults(this);
  }

  ConversationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _worker = $v.worker.toBuilder();
      _lastMessage = $v.lastMessage.toBuilder();
      _unreadCount = $v.unreadCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Conversation other) {
    _$v = other as _$Conversation;
  }

  @override
  void update(void Function(ConversationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Conversation build() => _build();

  _$Conversation _build() {
    _$Conversation _$result;
    try {
      _$result = _$v ??
          _$Conversation._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'Conversation', 'id'),
            worker: worker.build(),
            lastMessage: lastMessage.build(),
            unreadCount: BuiltValueNullFieldError.checkNotNull(
                unreadCount, r'Conversation', 'unreadCount'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'worker';
        worker.build();
        _$failedField = 'lastMessage';
        lastMessage.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Conversation', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
