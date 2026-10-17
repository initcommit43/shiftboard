// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_token_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PushTokenRequest extends PushTokenRequest {
  @override
  final String token;
  @override
  final PushPlatform platform;

  factory _$PushTokenRequest(
          [void Function(PushTokenRequestBuilder)? updates]) =>
      (PushTokenRequestBuilder()..update(updates))._build();

  _$PushTokenRequest._({required this.token, required this.platform})
      : super._();
  @override
  PushTokenRequest rebuild(void Function(PushTokenRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PushTokenRequestBuilder toBuilder() =>
      PushTokenRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PushTokenRequest &&
        token == other.token &&
        platform == other.platform;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, token.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PushTokenRequest')
          ..add('token', token)
          ..add('platform', platform))
        .toString();
  }
}

class PushTokenRequestBuilder
    implements Builder<PushTokenRequest, PushTokenRequestBuilder> {
  _$PushTokenRequest? _$v;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  PushPlatform? _platform;
  PushPlatform? get platform => _$this._platform;
  set platform(PushPlatform? platform) => _$this._platform = platform;

  PushTokenRequestBuilder() {
    PushTokenRequest._defaults(this);
  }

  PushTokenRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _token = $v.token;
      _platform = $v.platform;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PushTokenRequest other) {
    _$v = other as _$PushTokenRequest;
  }

  @override
  void update(void Function(PushTokenRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PushTokenRequest build() => _build();

  _$PushTokenRequest _build() {
    final _$result = _$v ??
        _$PushTokenRequest._(
          token: BuiltValueNullFieldError.checkNotNull(
              token, r'PushTokenRequest', 'token'),
          platform: BuiltValueNullFieldError.checkNotNull(
              platform, r'PushTokenRequest', 'platform'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
