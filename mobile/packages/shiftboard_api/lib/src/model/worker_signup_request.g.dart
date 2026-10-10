// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker_signup_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WorkerSignupRequest extends WorkerSignupRequest {
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String email;
  @override
  final String phone;
  @override
  final String password;
  @override
  final BuiltList<String> qualificationIds;

  factory _$WorkerSignupRequest(
          [void Function(WorkerSignupRequestBuilder)? updates]) =>
      (WorkerSignupRequestBuilder()..update(updates))._build();

  _$WorkerSignupRequest._(
      {required this.firstName,
      required this.lastName,
      required this.email,
      required this.phone,
      required this.password,
      required this.qualificationIds})
      : super._();
  @override
  WorkerSignupRequest rebuild(
          void Function(WorkerSignupRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkerSignupRequestBuilder toBuilder() =>
      WorkerSignupRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkerSignupRequest &&
        firstName == other.firstName &&
        lastName == other.lastName &&
        email == other.email &&
        phone == other.phone &&
        password == other.password &&
        qualificationIds == other.qualificationIds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, firstName.hashCode);
    _$hash = $jc(_$hash, lastName.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jc(_$hash, qualificationIds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WorkerSignupRequest')
          ..add('firstName', firstName)
          ..add('lastName', lastName)
          ..add('email', email)
          ..add('phone', phone)
          ..add('password', password)
          ..add('qualificationIds', qualificationIds))
        .toString();
  }
}

class WorkerSignupRequestBuilder
    implements Builder<WorkerSignupRequest, WorkerSignupRequestBuilder> {
  _$WorkerSignupRequest? _$v;

  String? _firstName;
  String? get firstName => _$this._firstName;
  set firstName(String? firstName) => _$this._firstName = firstName;

  String? _lastName;
  String? get lastName => _$this._lastName;
  set lastName(String? lastName) => _$this._lastName = lastName;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  ListBuilder<String>? _qualificationIds;
  ListBuilder<String> get qualificationIds =>
      _$this._qualificationIds ??= ListBuilder<String>();
  set qualificationIds(ListBuilder<String>? qualificationIds) =>
      _$this._qualificationIds = qualificationIds;

  WorkerSignupRequestBuilder() {
    WorkerSignupRequest._defaults(this);
  }

  WorkerSignupRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _firstName = $v.firstName;
      _lastName = $v.lastName;
      _email = $v.email;
      _phone = $v.phone;
      _password = $v.password;
      _qualificationIds = $v.qualificationIds.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkerSignupRequest other) {
    _$v = other as _$WorkerSignupRequest;
  }

  @override
  void update(void Function(WorkerSignupRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkerSignupRequest build() => _build();

  _$WorkerSignupRequest _build() {
    _$WorkerSignupRequest _$result;
    try {
      _$result = _$v ??
          _$WorkerSignupRequest._(
            firstName: BuiltValueNullFieldError.checkNotNull(
                firstName, r'WorkerSignupRequest', 'firstName'),
            lastName: BuiltValueNullFieldError.checkNotNull(
                lastName, r'WorkerSignupRequest', 'lastName'),
            email: BuiltValueNullFieldError.checkNotNull(
                email, r'WorkerSignupRequest', 'email'),
            phone: BuiltValueNullFieldError.checkNotNull(
                phone, r'WorkerSignupRequest', 'phone'),
            password: BuiltValueNullFieldError.checkNotNull(
                password, r'WorkerSignupRequest', 'password'),
            qualificationIds: qualificationIds.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'qualificationIds';
        qualificationIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'WorkerSignupRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
