// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_setup_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ClientSetupRequest extends ClientSetupRequest {
  @override
  final String password;

  factory _$ClientSetupRequest(
          [void Function(ClientSetupRequestBuilder)? updates]) =>
      (ClientSetupRequestBuilder()..update(updates))._build();

  _$ClientSetupRequest._({required this.password}) : super._();
  @override
  ClientSetupRequest rebuild(
          void Function(ClientSetupRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ClientSetupRequestBuilder toBuilder() =>
      ClientSetupRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClientSetupRequest && password == other.password;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ClientSetupRequest')
          ..add('password', password))
        .toString();
  }
}

class ClientSetupRequestBuilder
    implements Builder<ClientSetupRequest, ClientSetupRequestBuilder> {
  _$ClientSetupRequest? _$v;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  ClientSetupRequestBuilder() {
    ClientSetupRequest._defaults(this);
  }

  ClientSetupRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _password = $v.password;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ClientSetupRequest other) {
    _$v = other as _$ClientSetupRequest;
  }

  @override
  void update(void Function(ClientSetupRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ClientSetupRequest build() => _build();

  _$ClientSetupRequest _build() {
    final _$result = _$v ??
        _$ClientSetupRequest._(
          password: BuiltValueNullFieldError.checkNotNull(
              password, r'ClientSetupRequest', 'password'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
