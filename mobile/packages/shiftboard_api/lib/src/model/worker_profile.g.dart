// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker_profile.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WorkerProfile extends WorkerProfile {
  @override
  final String id;
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final WorkerStatus status;

  factory _$WorkerProfile([void Function(WorkerProfileBuilder)? updates]) =>
      (WorkerProfileBuilder()..update(updates))._build();

  _$WorkerProfile._(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.status})
      : super._();
  @override
  WorkerProfile rebuild(void Function(WorkerProfileBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkerProfileBuilder toBuilder() => WorkerProfileBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkerProfile &&
        id == other.id &&
        firstName == other.firstName &&
        lastName == other.lastName &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, firstName.hashCode);
    _$hash = $jc(_$hash, lastName.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WorkerProfile')
          ..add('id', id)
          ..add('firstName', firstName)
          ..add('lastName', lastName)
          ..add('status', status))
        .toString();
  }
}

class WorkerProfileBuilder
    implements Builder<WorkerProfile, WorkerProfileBuilder> {
  _$WorkerProfile? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _firstName;
  String? get firstName => _$this._firstName;
  set firstName(String? firstName) => _$this._firstName = firstName;

  String? _lastName;
  String? get lastName => _$this._lastName;
  set lastName(String? lastName) => _$this._lastName = lastName;

  WorkerStatus? _status;
  WorkerStatus? get status => _$this._status;
  set status(WorkerStatus? status) => _$this._status = status;

  WorkerProfileBuilder() {
    WorkerProfile._defaults(this);
  }

  WorkerProfileBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _firstName = $v.firstName;
      _lastName = $v.lastName;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkerProfile other) {
    _$v = other as _$WorkerProfile;
  }

  @override
  void update(void Function(WorkerProfileBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkerProfile build() => _build();

  _$WorkerProfile _build() {
    final _$result = _$v ??
        _$WorkerProfile._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'WorkerProfile', 'id'),
          firstName: BuiltValueNullFieldError.checkNotNull(
              firstName, r'WorkerProfile', 'firstName'),
          lastName: BuiltValueNullFieldError.checkNotNull(
              lastName, r'WorkerProfile', 'lastName'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'WorkerProfile', 'status'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
