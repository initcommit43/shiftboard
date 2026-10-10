// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signup_info.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SignupInfo extends SignupInfo {
  @override
  final String agencyName;

  factory _$SignupInfo([void Function(SignupInfoBuilder)? updates]) =>
      (SignupInfoBuilder()..update(updates))._build();

  _$SignupInfo._({required this.agencyName}) : super._();
  @override
  SignupInfo rebuild(void Function(SignupInfoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SignupInfoBuilder toBuilder() => SignupInfoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SignupInfo && agencyName == other.agencyName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, agencyName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SignupInfo')
          ..add('agencyName', agencyName))
        .toString();
  }
}

class SignupInfoBuilder implements Builder<SignupInfo, SignupInfoBuilder> {
  _$SignupInfo? _$v;

  String? _agencyName;
  String? get agencyName => _$this._agencyName;
  set agencyName(String? agencyName) => _$this._agencyName = agencyName;

  SignupInfoBuilder() {
    SignupInfo._defaults(this);
  }

  SignupInfoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _agencyName = $v.agencyName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SignupInfo other) {
    _$v = other as _$SignupInfo;
  }

  @override
  void update(void Function(SignupInfoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SignupInfo build() => _build();

  _$SignupInfo _build() {
    final _$result = _$v ??
        _$SignupInfo._(
          agencyName: BuiltValueNullFieldError.checkNotNull(
              agencyName, r'SignupInfo', 'agencyName'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
