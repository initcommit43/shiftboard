// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_worker.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConversationWorker extends ConversationWorker {
  @override
  final String id;
  @override
  final String firstName;
  @override
  final String lastName;

  factory _$ConversationWorker(
          [void Function(ConversationWorkerBuilder)? updates]) =>
      (ConversationWorkerBuilder()..update(updates))._build();

  _$ConversationWorker._(
      {required this.id, required this.firstName, required this.lastName})
      : super._();
  @override
  ConversationWorker rebuild(
          void Function(ConversationWorkerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConversationWorkerBuilder toBuilder() =>
      ConversationWorkerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConversationWorker &&
        id == other.id &&
        firstName == other.firstName &&
        lastName == other.lastName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, firstName.hashCode);
    _$hash = $jc(_$hash, lastName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ConversationWorker')
          ..add('id', id)
          ..add('firstName', firstName)
          ..add('lastName', lastName))
        .toString();
  }
}

class ConversationWorkerBuilder
    implements Builder<ConversationWorker, ConversationWorkerBuilder> {
  _$ConversationWorker? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _firstName;
  String? get firstName => _$this._firstName;
  set firstName(String? firstName) => _$this._firstName = firstName;

  String? _lastName;
  String? get lastName => _$this._lastName;
  set lastName(String? lastName) => _$this._lastName = lastName;

  ConversationWorkerBuilder() {
    ConversationWorker._defaults(this);
  }

  ConversationWorkerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _firstName = $v.firstName;
      _lastName = $v.lastName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ConversationWorker other) {
    _$v = other as _$ConversationWorker;
  }

  @override
  void update(void Function(ConversationWorkerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConversationWorker build() => _build();

  _$ConversationWorker _build() {
    final _$result = _$v ??
        _$ConversationWorker._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'ConversationWorker', 'id'),
          firstName: BuiltValueNullFieldError.checkNotNull(
              firstName, r'ConversationWorker', 'firstName'),
          lastName: BuiltValueNullFieldError.checkNotNull(
              lastName, r'ConversationWorker', 'lastName'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
