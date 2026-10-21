// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worked_hours.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WorkedHours extends WorkedHours {
  @override
  final DateTime startedAt;
  @override
  final DateTime endedAt;
  @override
  final int breakMinutes;
  @override
  final int workedMinutes;
  @override
  final int grossCents;
  @override
  final DateTime approvedAt;

  factory _$WorkedHours([void Function(WorkedHoursBuilder)? updates]) =>
      (WorkedHoursBuilder()..update(updates))._build();

  _$WorkedHours._(
      {required this.startedAt,
      required this.endedAt,
      required this.breakMinutes,
      required this.workedMinutes,
      required this.grossCents,
      required this.approvedAt})
      : super._();
  @override
  WorkedHours rebuild(void Function(WorkedHoursBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkedHoursBuilder toBuilder() => WorkedHoursBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkedHours &&
        startedAt == other.startedAt &&
        endedAt == other.endedAt &&
        breakMinutes == other.breakMinutes &&
        workedMinutes == other.workedMinutes &&
        grossCents == other.grossCents &&
        approvedAt == other.approvedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, endedAt.hashCode);
    _$hash = $jc(_$hash, breakMinutes.hashCode);
    _$hash = $jc(_$hash, workedMinutes.hashCode);
    _$hash = $jc(_$hash, grossCents.hashCode);
    _$hash = $jc(_$hash, approvedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WorkedHours')
          ..add('startedAt', startedAt)
          ..add('endedAt', endedAt)
          ..add('breakMinutes', breakMinutes)
          ..add('workedMinutes', workedMinutes)
          ..add('grossCents', grossCents)
          ..add('approvedAt', approvedAt))
        .toString();
  }
}

class WorkedHoursBuilder implements Builder<WorkedHours, WorkedHoursBuilder> {
  _$WorkedHours? _$v;

  DateTime? _startedAt;
  DateTime? get startedAt => _$this._startedAt;
  set startedAt(DateTime? startedAt) => _$this._startedAt = startedAt;

  DateTime? _endedAt;
  DateTime? get endedAt => _$this._endedAt;
  set endedAt(DateTime? endedAt) => _$this._endedAt = endedAt;

  int? _breakMinutes;
  int? get breakMinutes => _$this._breakMinutes;
  set breakMinutes(int? breakMinutes) => _$this._breakMinutes = breakMinutes;

  int? _workedMinutes;
  int? get workedMinutes => _$this._workedMinutes;
  set workedMinutes(int? workedMinutes) =>
      _$this._workedMinutes = workedMinutes;

  int? _grossCents;
  int? get grossCents => _$this._grossCents;
  set grossCents(int? grossCents) => _$this._grossCents = grossCents;

  DateTime? _approvedAt;
  DateTime? get approvedAt => _$this._approvedAt;
  set approvedAt(DateTime? approvedAt) => _$this._approvedAt = approvedAt;

  WorkedHoursBuilder() {
    WorkedHours._defaults(this);
  }

  WorkedHoursBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _startedAt = $v.startedAt;
      _endedAt = $v.endedAt;
      _breakMinutes = $v.breakMinutes;
      _workedMinutes = $v.workedMinutes;
      _grossCents = $v.grossCents;
      _approvedAt = $v.approvedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkedHours other) {
    _$v = other as _$WorkedHours;
  }

  @override
  void update(void Function(WorkedHoursBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkedHours build() => _build();

  _$WorkedHours _build() {
    final _$result = _$v ??
        _$WorkedHours._(
          startedAt: BuiltValueNullFieldError.checkNotNull(
              startedAt, r'WorkedHours', 'startedAt'),
          endedAt: BuiltValueNullFieldError.checkNotNull(
              endedAt, r'WorkedHours', 'endedAt'),
          breakMinutes: BuiltValueNullFieldError.checkNotNull(
              breakMinutes, r'WorkedHours', 'breakMinutes'),
          workedMinutes: BuiltValueNullFieldError.checkNotNull(
              workedMinutes, r'WorkedHours', 'workedMinutes'),
          grossCents: BuiltValueNullFieldError.checkNotNull(
              grossCents, r'WorkedHours', 'grossCents'),
          approvedAt: BuiltValueNullFieldError.checkNotNull(
              approvedAt, r'WorkedHours', 'approvedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
