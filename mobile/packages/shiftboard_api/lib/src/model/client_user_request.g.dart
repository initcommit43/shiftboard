// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_user_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ClientUserRequest extends ClientUserRequest {
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String email;

  factory _$ClientUserRequest(
          [void Function(ClientUserRequestBuilder)? updates]) =>
      (ClientUserRequestBuilder()..update(updates))._build();

  _$ClientUserRequest._(
      {required this.firstName, required this.lastName, required this.email})
      : super._();
  @override
  ClientUserRequest rebuild(void Function(ClientUserRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ClientUserRequestBuilder toBuilder() =>
      ClientUserRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClientUserRequest &&
        firstName == other.firstName &&
        lastName == other.lastName &&
        email == other.email;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, firstName.hashCode);
    _$hash = $jc(_$hash, lastName.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ClientUserRequest')
          ..add('firstName', firstName)
          ..add('lastName', lastName)
          ..add('email', email))
        .toString();
  }
}

class ClientUserRequestBuilder
    implements Builder<ClientUserRequest, ClientUserRequestBuilder> {
  _$ClientUserRequest? _$v;

  String? _firstName;
  String? get firstName => _$this._firstName;
  set firstName(String? firstName) => _$this._firstName = firstName;

  String? _lastName;
  String? get lastName => _$this._lastName;
  set lastName(String? lastName) => _$this._lastName = lastName;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  ClientUserRequestBuilder() {
    ClientUserRequest._defaults(this);
  }

  ClientUserRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _firstName = $v.firstName;
      _lastName = $v.lastName;
      _email = $v.email;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ClientUserRequest other) {
    _$v = other as _$ClientUserRequest;
  }

  @override
  void update(void Function(ClientUserRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ClientUserRequest build() => _build();

  _$ClientUserRequest _build() {
    final _$result = _$v ??
        _$ClientUserRequest._(
          firstName: BuiltValueNullFieldError.checkNotNull(
              firstName, r'ClientUserRequest', 'firstName'),
          lastName: BuiltValueNullFieldError.checkNotNull(
              lastName, r'ClientUserRequest', 'lastName'),
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'ClientUserRequest', 'email'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
