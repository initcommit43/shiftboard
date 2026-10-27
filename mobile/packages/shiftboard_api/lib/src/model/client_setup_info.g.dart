// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_setup_info.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ClientSetupInfo extends ClientSetupInfo {
  @override
  final String firstName;
  @override
  final String email;
  @override
  final String clientName;
  @override
  final String agencyName;

  factory _$ClientSetupInfo([void Function(ClientSetupInfoBuilder)? updates]) =>
      (ClientSetupInfoBuilder()..update(updates))._build();

  _$ClientSetupInfo._(
      {required this.firstName,
      required this.email,
      required this.clientName,
      required this.agencyName})
      : super._();
  @override
  ClientSetupInfo rebuild(void Function(ClientSetupInfoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ClientSetupInfoBuilder toBuilder() => ClientSetupInfoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClientSetupInfo &&
        firstName == other.firstName &&
        email == other.email &&
        clientName == other.clientName &&
        agencyName == other.agencyName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, firstName.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, clientName.hashCode);
    _$hash = $jc(_$hash, agencyName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ClientSetupInfo')
          ..add('firstName', firstName)
          ..add('email', email)
          ..add('clientName', clientName)
          ..add('agencyName', agencyName))
        .toString();
  }
}

class ClientSetupInfoBuilder
    implements Builder<ClientSetupInfo, ClientSetupInfoBuilder> {
  _$ClientSetupInfo? _$v;

  String? _firstName;
  String? get firstName => _$this._firstName;
  set firstName(String? firstName) => _$this._firstName = firstName;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _clientName;
  String? get clientName => _$this._clientName;
  set clientName(String? clientName) => _$this._clientName = clientName;

  String? _agencyName;
  String? get agencyName => _$this._agencyName;
  set agencyName(String? agencyName) => _$this._agencyName = agencyName;

  ClientSetupInfoBuilder() {
    ClientSetupInfo._defaults(this);
  }

  ClientSetupInfoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _firstName = $v.firstName;
      _email = $v.email;
      _clientName = $v.clientName;
      _agencyName = $v.agencyName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ClientSetupInfo other) {
    _$v = other as _$ClientSetupInfo;
  }

  @override
  void update(void Function(ClientSetupInfoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ClientSetupInfo build() => _build();

  _$ClientSetupInfo _build() {
    final _$result = _$v ??
        _$ClientSetupInfo._(
          firstName: BuiltValueNullFieldError.checkNotNull(
              firstName, r'ClientSetupInfo', 'firstName'),
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'ClientSetupInfo', 'email'),
          clientName: BuiltValueNullFieldError.checkNotNull(
              clientName, r'ClientSetupInfo', 'clientName'),
          agencyName: BuiltValueNullFieldError.checkNotNull(
              agencyName, r'ClientSetupInfo', 'agencyName'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
