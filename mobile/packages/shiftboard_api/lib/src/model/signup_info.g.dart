// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signup_info.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SignupInfo extends SignupInfo {
  @override
  final String agencyName;
  @override
  final BuiltList<Qualification> qualifications;

  factory _$SignupInfo([void Function(SignupInfoBuilder)? updates]) =>
      (SignupInfoBuilder()..update(updates))._build();

  _$SignupInfo._({required this.agencyName, required this.qualifications})
      : super._();
  @override
  SignupInfo rebuild(void Function(SignupInfoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SignupInfoBuilder toBuilder() => SignupInfoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SignupInfo &&
        agencyName == other.agencyName &&
        qualifications == other.qualifications;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, agencyName.hashCode);
    _$hash = $jc(_$hash, qualifications.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SignupInfo')
          ..add('agencyName', agencyName)
          ..add('qualifications', qualifications))
        .toString();
  }
}

class SignupInfoBuilder implements Builder<SignupInfo, SignupInfoBuilder> {
  _$SignupInfo? _$v;

  String? _agencyName;
  String? get agencyName => _$this._agencyName;
  set agencyName(String? agencyName) => _$this._agencyName = agencyName;

  ListBuilder<Qualification>? _qualifications;
  ListBuilder<Qualification> get qualifications =>
      _$this._qualifications ??= ListBuilder<Qualification>();
  set qualifications(ListBuilder<Qualification>? qualifications) =>
      _$this._qualifications = qualifications;

  SignupInfoBuilder() {
    SignupInfo._defaults(this);
  }

  SignupInfoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _agencyName = $v.agencyName;
      _qualifications = $v.qualifications.toBuilder();
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
    _$SignupInfo _$result;
    try {
      _$result = _$v ??
          _$SignupInfo._(
            agencyName: BuiltValueNullFieldError.checkNotNull(
                agencyName, r'SignupInfo', 'agencyName'),
            qualifications: qualifications.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'qualifications';
        qualifications.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SignupInfo', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
