// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hours_entry.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$HoursEntry extends HoursEntry {
  @override
  final String assignmentId;
  @override
  final HoursStatus status;
  @override
  final HoursShift shift;
  @override
  final AssignedWorker worker;
  @override
  final DateTime? checkedInAt;
  @override
  final DateTime? checkedOutAt;
  @override
  final WorkedHours? hours;

  factory _$HoursEntry([void Function(HoursEntryBuilder)? updates]) =>
      (HoursEntryBuilder()..update(updates))._build();

  _$HoursEntry._(
      {required this.assignmentId,
      required this.status,
      required this.shift,
      required this.worker,
      this.checkedInAt,
      this.checkedOutAt,
      this.hours})
      : super._();
  @override
  HoursEntry rebuild(void Function(HoursEntryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  HoursEntryBuilder toBuilder() => HoursEntryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HoursEntry &&
        assignmentId == other.assignmentId &&
        status == other.status &&
        shift == other.shift &&
        worker == other.worker &&
        checkedInAt == other.checkedInAt &&
        checkedOutAt == other.checkedOutAt &&
        hours == other.hours;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, assignmentId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, shift.hashCode);
    _$hash = $jc(_$hash, worker.hashCode);
    _$hash = $jc(_$hash, checkedInAt.hashCode);
    _$hash = $jc(_$hash, checkedOutAt.hashCode);
    _$hash = $jc(_$hash, hours.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'HoursEntry')
          ..add('assignmentId', assignmentId)
          ..add('status', status)
          ..add('shift', shift)
          ..add('worker', worker)
          ..add('checkedInAt', checkedInAt)
          ..add('checkedOutAt', checkedOutAt)
          ..add('hours', hours))
        .toString();
  }
}

class HoursEntryBuilder implements Builder<HoursEntry, HoursEntryBuilder> {
  _$HoursEntry? _$v;

  String? _assignmentId;
  String? get assignmentId => _$this._assignmentId;
  set assignmentId(String? assignmentId) => _$this._assignmentId = assignmentId;

  HoursStatus? _status;
  HoursStatus? get status => _$this._status;
  set status(HoursStatus? status) => _$this._status = status;

  HoursShiftBuilder? _shift;
  HoursShiftBuilder get shift => _$this._shift ??= HoursShiftBuilder();
  set shift(HoursShiftBuilder? shift) => _$this._shift = shift;

  AssignedWorkerBuilder? _worker;
  AssignedWorkerBuilder get worker =>
      _$this._worker ??= AssignedWorkerBuilder();
  set worker(AssignedWorkerBuilder? worker) => _$this._worker = worker;

  DateTime? _checkedInAt;
  DateTime? get checkedInAt => _$this._checkedInAt;
  set checkedInAt(DateTime? checkedInAt) => _$this._checkedInAt = checkedInAt;

  DateTime? _checkedOutAt;
  DateTime? get checkedOutAt => _$this._checkedOutAt;
  set checkedOutAt(DateTime? checkedOutAt) =>
      _$this._checkedOutAt = checkedOutAt;

  WorkedHoursBuilder? _hours;
  WorkedHoursBuilder get hours => _$this._hours ??= WorkedHoursBuilder();
  set hours(WorkedHoursBuilder? hours) => _$this._hours = hours;

  HoursEntryBuilder() {
    HoursEntry._defaults(this);
  }

  HoursEntryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _assignmentId = $v.assignmentId;
      _status = $v.status;
      _shift = $v.shift.toBuilder();
      _worker = $v.worker.toBuilder();
      _checkedInAt = $v.checkedInAt;
      _checkedOutAt = $v.checkedOutAt;
      _hours = $v.hours?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HoursEntry other) {
    _$v = other as _$HoursEntry;
  }

  @override
  void update(void Function(HoursEntryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  HoursEntry build() => _build();

  _$HoursEntry _build() {
    _$HoursEntry _$result;
    try {
      _$result = _$v ??
          _$HoursEntry._(
            assignmentId: BuiltValueNullFieldError.checkNotNull(
                assignmentId, r'HoursEntry', 'assignmentId'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'HoursEntry', 'status'),
            shift: shift.build(),
            worker: worker.build(),
            checkedInAt: checkedInAt,
            checkedOutAt: checkedOutAt,
            hours: _hours?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'shift';
        shift.build();
        _$failedField = 'worker';
        worker.build();

        _$failedField = 'hours';
        _hours?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'HoursEntry', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
