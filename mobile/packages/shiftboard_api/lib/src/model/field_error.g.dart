// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'field_error.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FieldError extends FieldError {
  @override
  final String field;
  @override
  final String code;

  factory _$FieldError([void Function(FieldErrorBuilder)? updates]) =>
      (FieldErrorBuilder()..update(updates))._build();

  _$FieldError._({required this.field, required this.code}) : super._();
  @override
  FieldError rebuild(void Function(FieldErrorBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FieldErrorBuilder toBuilder() => FieldErrorBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FieldError && field == other.field && code == other.code;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, field.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FieldError')
          ..add('field', field)
          ..add('code', code))
        .toString();
  }
}

class FieldErrorBuilder implements Builder<FieldError, FieldErrorBuilder> {
  _$FieldError? _$v;

  String? _field;
  String? get field => _$this._field;
  set field(String? field) => _$this._field = field;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  FieldErrorBuilder() {
    FieldError._defaults(this);
  }

  FieldErrorBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _field = $v.field;
      _code = $v.code;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FieldError other) {
    _$v = other as _$FieldError;
  }

  @override
  void update(void Function(FieldErrorBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FieldError build() => _build();

  _$FieldError _build() {
    final _$result = _$v ??
        _$FieldError._(
          field: BuiltValueNullFieldError.checkNotNull(
              field, r'FieldError', 'field'),
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'FieldError', 'code'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
