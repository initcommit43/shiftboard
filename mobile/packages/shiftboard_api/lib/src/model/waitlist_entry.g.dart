// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'waitlist_entry.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WaitlistEntry extends WaitlistEntry {
  @override
  final String id;
  @override
  final int position;
  @override
  final AssignedWorker worker;
  @override
  final DateTime joinedAt;

  factory _$WaitlistEntry([void Function(WaitlistEntryBuilder)? updates]) =>
      (WaitlistEntryBuilder()..update(updates))._build();

  _$WaitlistEntry._(
      {required this.id,
      required this.position,
      required this.worker,
      required this.joinedAt})
      : super._();
  @override
  WaitlistEntry rebuild(void Function(WaitlistEntryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WaitlistEntryBuilder toBuilder() => WaitlistEntryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WaitlistEntry &&
        id == other.id &&
        position == other.position &&
        worker == other.worker &&
        joinedAt == other.joinedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, position.hashCode);
    _$hash = $jc(_$hash, worker.hashCode);
    _$hash = $jc(_$hash, joinedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WaitlistEntry')
          ..add('id', id)
          ..add('position', position)
          ..add('worker', worker)
          ..add('joinedAt', joinedAt))
        .toString();
  }
}

class WaitlistEntryBuilder
    implements Builder<WaitlistEntry, WaitlistEntryBuilder> {
  _$WaitlistEntry? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  int? _position;
  int? get position => _$this._position;
  set position(int? position) => _$this._position = position;

  AssignedWorkerBuilder? _worker;
  AssignedWorkerBuilder get worker =>
      _$this._worker ??= AssignedWorkerBuilder();
  set worker(AssignedWorkerBuilder? worker) => _$this._worker = worker;

  DateTime? _joinedAt;
  DateTime? get joinedAt => _$this._joinedAt;
  set joinedAt(DateTime? joinedAt) => _$this._joinedAt = joinedAt;

  WaitlistEntryBuilder() {
    WaitlistEntry._defaults(this);
  }

  WaitlistEntryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _position = $v.position;
      _worker = $v.worker.toBuilder();
      _joinedAt = $v.joinedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WaitlistEntry other) {
    _$v = other as _$WaitlistEntry;
  }

  @override
  void update(void Function(WaitlistEntryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WaitlistEntry build() => _build();

  _$WaitlistEntry _build() {
    _$WaitlistEntry _$result;
    try {
      _$result = _$v ??
          _$WaitlistEntry._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'WaitlistEntry', 'id'),
            position: BuiltValueNullFieldError.checkNotNull(
                position, r'WaitlistEntry', 'position'),
            worker: worker.build(),
            joinedAt: BuiltValueNullFieldError.checkNotNull(
                joinedAt, r'WaitlistEntry', 'joinedAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'worker';
        worker.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'WaitlistEntry', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
