// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hours_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$HoursRequest extends HoursRequest {
  @override
  final DateTime startedAt;
  @override
  final DateTime endedAt;
  @override
  final int breakMinutes;

  factory _$HoursRequest([void Function(HoursRequestBuilder)? updates]) =>
      (HoursRequestBuilder()..update(updates))._build();

  _$HoursRequest._(
      {required this.startedAt,
      required this.endedAt,
      required this.breakMinutes})
      : super._();
  @override
  HoursRequest rebuild(void Function(HoursRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  HoursRequestBuilder toBuilder() => HoursRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HoursRequest &&
        startedAt == other.startedAt &&
        endedAt == other.endedAt &&
        breakMinutes == other.breakMinutes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, endedAt.hashCode);
    _$hash = $jc(_$hash, breakMinutes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'HoursRequest')
          ..add('startedAt', startedAt)
          ..add('endedAt', endedAt)
          ..add('breakMinutes', breakMinutes))
        .toString();
  }
}

class HoursRequestBuilder
    implements Builder<HoursRequest, HoursRequestBuilder> {
  _$HoursRequest? _$v;

  DateTime? _startedAt;
  DateTime? get startedAt => _$this._startedAt;
  set startedAt(DateTime? startedAt) => _$this._startedAt = startedAt;

  DateTime? _endedAt;
  DateTime? get endedAt => _$this._endedAt;
  set endedAt(DateTime? endedAt) => _$this._endedAt = endedAt;

  int? _breakMinutes;
  int? get breakMinutes => _$this._breakMinutes;
  set breakMinutes(int? breakMinutes) => _$this._breakMinutes = breakMinutes;

  HoursRequestBuilder() {
    HoursRequest._defaults(this);
  }

  HoursRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _startedAt = $v.startedAt;
      _endedAt = $v.endedAt;
      _breakMinutes = $v.breakMinutes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HoursRequest other) {
    _$v = other as _$HoursRequest;
  }

  @override
  void update(void Function(HoursRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  HoursRequest build() => _build();

  _$HoursRequest _build() {
    final _$result = _$v ??
        _$HoursRequest._(
          startedAt: BuiltValueNullFieldError.checkNotNull(
              startedAt, r'HoursRequest', 'startedAt'),
          endedAt: BuiltValueNullFieldError.checkNotNull(
              endedAt, r'HoursRequest', 'endedAt'),
          breakMinutes: BuiltValueNullFieldError.checkNotNull(
              breakMinutes, r'HoursRequest', 'breakMinutes'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
