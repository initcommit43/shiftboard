// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_assignment.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShiftAssignment extends ShiftAssignment {
  @override
  final String id;
  @override
  final AssignmentStatus status;
  @override
  final AssignedWorker worker;
  @override
  final DateTime claimedAt;
  @override
  final DateTime? decidedAt;
  @override
  final CancelledBy? cancelledBy;
  @override
  final String? reason;

  factory _$ShiftAssignment([void Function(ShiftAssignmentBuilder)? updates]) =>
      (ShiftAssignmentBuilder()..update(updates))._build();

  _$ShiftAssignment._(
      {required this.id,
      required this.status,
      required this.worker,
      required this.claimedAt,
      this.decidedAt,
      this.cancelledBy,
      this.reason})
      : super._();
  @override
  ShiftAssignment rebuild(void Function(ShiftAssignmentBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShiftAssignmentBuilder toBuilder() => ShiftAssignmentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShiftAssignment &&
        id == other.id &&
        status == other.status &&
        worker == other.worker &&
        claimedAt == other.claimedAt &&
        decidedAt == other.decidedAt &&
        cancelledBy == other.cancelledBy &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, worker.hashCode);
    _$hash = $jc(_$hash, claimedAt.hashCode);
    _$hash = $jc(_$hash, decidedAt.hashCode);
    _$hash = $jc(_$hash, cancelledBy.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ShiftAssignment')
          ..add('id', id)
          ..add('status', status)
          ..add('worker', worker)
          ..add('claimedAt', claimedAt)
          ..add('decidedAt', decidedAt)
          ..add('cancelledBy', cancelledBy)
          ..add('reason', reason))
        .toString();
  }
}

class ShiftAssignmentBuilder
    implements Builder<ShiftAssignment, ShiftAssignmentBuilder> {
  _$ShiftAssignment? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  AssignmentStatus? _status;
  AssignmentStatus? get status => _$this._status;
  set status(AssignmentStatus? status) => _$this._status = status;

  AssignedWorkerBuilder? _worker;
  AssignedWorkerBuilder get worker =>
      _$this._worker ??= AssignedWorkerBuilder();
  set worker(AssignedWorkerBuilder? worker) => _$this._worker = worker;

  DateTime? _claimedAt;
  DateTime? get claimedAt => _$this._claimedAt;
  set claimedAt(DateTime? claimedAt) => _$this._claimedAt = claimedAt;

  DateTime? _decidedAt;
  DateTime? get decidedAt => _$this._decidedAt;
  set decidedAt(DateTime? decidedAt) => _$this._decidedAt = decidedAt;

  CancelledBy? _cancelledBy;
  CancelledBy? get cancelledBy => _$this._cancelledBy;
  set cancelledBy(CancelledBy? cancelledBy) =>
      _$this._cancelledBy = cancelledBy;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  ShiftAssignmentBuilder() {
    ShiftAssignment._defaults(this);
  }

  ShiftAssignmentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _status = $v.status;
      _worker = $v.worker.toBuilder();
      _claimedAt = $v.claimedAt;
      _decidedAt = $v.decidedAt;
      _cancelledBy = $v.cancelledBy;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShiftAssignment other) {
    _$v = other as _$ShiftAssignment;
  }

  @override
  void update(void Function(ShiftAssignmentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShiftAssignment build() => _build();

  _$ShiftAssignment _build() {
    _$ShiftAssignment _$result;
    try {
      _$result = _$v ??
          _$ShiftAssignment._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'ShiftAssignment', 'id'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'ShiftAssignment', 'status'),
            worker: worker.build(),
            claimedAt: BuiltValueNullFieldError.checkNotNull(
                claimedAt, r'ShiftAssignment', 'claimedAt'),
            decidedAt: decidedAt,
            cancelledBy: cancelledBy,
            reason: reason,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'worker';
        worker.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ShiftAssignment', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
