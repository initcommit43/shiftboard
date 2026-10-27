// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_user.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ClientUser extends ClientUser {
  @override
  final String id;
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String email;
  @override
  final ClientUserStatus status;

  factory _$ClientUser([void Function(ClientUserBuilder)? updates]) =>
      (ClientUserBuilder()..update(updates))._build();

  _$ClientUser._(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.status})
      : super._();
  @override
  ClientUser rebuild(void Function(ClientUserBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ClientUserBuilder toBuilder() => ClientUserBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClientUser &&
        id == other.id &&
        firstName == other.firstName &&
        lastName == other.lastName &&
        email == other.email &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, firstName.hashCode);
    _$hash = $jc(_$hash, lastName.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ClientUser')
          ..add('id', id)
          ..add('firstName', firstName)
          ..add('lastName', lastName)
          ..add('email', email)
          ..add('status', status))
        .toString();
  }
}

class ClientUserBuilder implements Builder<ClientUser, ClientUserBuilder> {
  _$ClientUser? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _firstName;
  String? get firstName => _$this._firstName;
  set firstName(String? firstName) => _$this._firstName = firstName;

  String? _lastName;
  String? get lastName => _$this._lastName;
  set lastName(String? lastName) => _$this._lastName = lastName;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  ClientUserStatus? _status;
  ClientUserStatus? get status => _$this._status;
  set status(ClientUserStatus? status) => _$this._status = status;

  ClientUserBuilder() {
    ClientUser._defaults(this);
  }

  ClientUserBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _firstName = $v.firstName;
      _lastName = $v.lastName;
      _email = $v.email;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ClientUser other) {
    _$v = other as _$ClientUser;
  }

  @override
  void update(void Function(ClientUserBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ClientUser build() => _build();

  _$ClientUser _build() {
    final _$result = _$v ??
        _$ClientUser._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'ClientUser', 'id'),
          firstName: BuiltValueNullFieldError.checkNotNull(
              firstName, r'ClientUser', 'firstName'),
          lastName: BuiltValueNullFieldError.checkNotNull(
              lastName, r'ClientUser', 'lastName'),
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'ClientUser', 'email'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'ClientUser', 'status'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
