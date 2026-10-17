// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assigned_worker.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AssignedWorker extends AssignedWorker {
  @override
  final String id;
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String phone;

  factory _$AssignedWorker([void Function(AssignedWorkerBuilder)? updates]) =>
      (AssignedWorkerBuilder()..update(updates))._build();

  _$AssignedWorker._(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.phone})
      : super._();
  @override
  AssignedWorker rebuild(void Function(AssignedWorkerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AssignedWorkerBuilder toBuilder() => AssignedWorkerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AssignedWorker &&
        id == other.id &&
        firstName == other.firstName &&
        lastName == other.lastName &&
        phone == other.phone;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, firstName.hashCode);
    _$hash = $jc(_$hash, lastName.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AssignedWorker')
          ..add('id', id)
          ..add('firstName', firstName)
          ..add('lastName', lastName)
          ..add('phone', phone))
        .toString();
  }
}

class AssignedWorkerBuilder
    implements Builder<AssignedWorker, AssignedWorkerBuilder> {
  _$AssignedWorker? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _firstName;
  String? get firstName => _$this._firstName;
  set firstName(String? firstName) => _$this._firstName = firstName;

  String? _lastName;
  String? get lastName => _$this._lastName;
  set lastName(String? lastName) => _$this._lastName = lastName;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  AssignedWorkerBuilder() {
    AssignedWorker._defaults(this);
  }

  AssignedWorkerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _firstName = $v.firstName;
      _lastName = $v.lastName;
      _phone = $v.phone;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AssignedWorker other) {
    _$v = other as _$AssignedWorker;
  }

  @override
  void update(void Function(AssignedWorkerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AssignedWorker build() => _build();

  _$AssignedWorker _build() {
    final _$result = _$v ??
        _$AssignedWorker._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'AssignedWorker', 'id'),
          firstName: BuiltValueNullFieldError.checkNotNull(
              firstName, r'AssignedWorker', 'firstName'),
          lastName: BuiltValueNullFieldError.checkNotNull(
              lastName, r'AssignedWorker', 'lastName'),
          phone: BuiltValueNullFieldError.checkNotNull(
              phone, r'AssignedWorker', 'phone'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
