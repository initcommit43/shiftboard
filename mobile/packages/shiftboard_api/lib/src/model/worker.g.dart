// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Worker extends Worker {
  @override
  final String id;
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final Date dateOfBirth;
  @override
  final String email;
  @override
  final String phone;
  @override
  final WorkerStatus status;
  @override
  final BuiltList<Qualification> qualifications;
  @override
  final DateTime createdAt;

  factory _$Worker([void Function(WorkerBuilder)? updates]) =>
      (WorkerBuilder()..update(updates))._build();

  _$Worker._(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.dateOfBirth,
      required this.email,
      required this.phone,
      required this.status,
      required this.qualifications,
      required this.createdAt})
      : super._();
  @override
  Worker rebuild(void Function(WorkerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkerBuilder toBuilder() => WorkerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Worker &&
        id == other.id &&
        firstName == other.firstName &&
        lastName == other.lastName &&
        dateOfBirth == other.dateOfBirth &&
        email == other.email &&
        phone == other.phone &&
        status == other.status &&
        qualifications == other.qualifications &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, firstName.hashCode);
    _$hash = $jc(_$hash, lastName.hashCode);
    _$hash = $jc(_$hash, dateOfBirth.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, qualifications.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Worker')
          ..add('id', id)
          ..add('firstName', firstName)
          ..add('lastName', lastName)
          ..add('dateOfBirth', dateOfBirth)
          ..add('email', email)
          ..add('phone', phone)
          ..add('status', status)
          ..add('qualifications', qualifications)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class WorkerBuilder implements Builder<Worker, WorkerBuilder> {
  _$Worker? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _firstName;
  String? get firstName => _$this._firstName;
  set firstName(String? firstName) => _$this._firstName = firstName;

  String? _lastName;
  String? get lastName => _$this._lastName;
  set lastName(String? lastName) => _$this._lastName = lastName;

  Date? _dateOfBirth;
  Date? get dateOfBirth => _$this._dateOfBirth;
  set dateOfBirth(Date? dateOfBirth) => _$this._dateOfBirth = dateOfBirth;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  WorkerStatus? _status;
  WorkerStatus? get status => _$this._status;
  set status(WorkerStatus? status) => _$this._status = status;

  ListBuilder<Qualification>? _qualifications;
  ListBuilder<Qualification> get qualifications =>
      _$this._qualifications ??= ListBuilder<Qualification>();
  set qualifications(ListBuilder<Qualification>? qualifications) =>
      _$this._qualifications = qualifications;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  WorkerBuilder() {
    Worker._defaults(this);
  }

  WorkerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _firstName = $v.firstName;
      _lastName = $v.lastName;
      _dateOfBirth = $v.dateOfBirth;
      _email = $v.email;
      _phone = $v.phone;
      _status = $v.status;
      _qualifications = $v.qualifications.toBuilder();
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Worker other) {
    _$v = other as _$Worker;
  }

  @override
  void update(void Function(WorkerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Worker build() => _build();

  _$Worker _build() {
    _$Worker _$result;
    try {
      _$result = _$v ??
          _$Worker._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Worker', 'id'),
            firstName: BuiltValueNullFieldError.checkNotNull(
                firstName, r'Worker', 'firstName'),
            lastName: BuiltValueNullFieldError.checkNotNull(
                lastName, r'Worker', 'lastName'),
            dateOfBirth: BuiltValueNullFieldError.checkNotNull(
                dateOfBirth, r'Worker', 'dateOfBirth'),
            email: BuiltValueNullFieldError.checkNotNull(
                email, r'Worker', 'email'),
            phone: BuiltValueNullFieldError.checkNotNull(
                phone, r'Worker', 'phone'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'Worker', 'status'),
            qualifications: qualifications.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'Worker', 'createdAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'qualifications';
        qualifications.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Worker', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
