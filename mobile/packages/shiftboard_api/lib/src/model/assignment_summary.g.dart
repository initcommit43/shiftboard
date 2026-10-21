// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment_summary.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AssignmentSummary extends AssignmentSummary {
  @override
  final String id;
  @override
  final AssignmentStatus status;
  @override
  final DateTime claimedAt;
  @override
  final DateTime? cancellableUntil;
  @override
  final CancelledBy? cancelledBy;
  @override
  final DateTime? checkInFrom;
  @override
  final DateTime? checkedInAt;
  @override
  final DateTime? checkedOutAt;
  @override
  final bool? hoursApproved;

  factory _$AssignmentSummary(
          [void Function(AssignmentSummaryBuilder)? updates]) =>
      (AssignmentSummaryBuilder()..update(updates))._build();

  _$AssignmentSummary._(
      {required this.id,
      required this.status,
      required this.claimedAt,
      this.cancellableUntil,
      this.cancelledBy,
      this.checkInFrom,
      this.checkedInAt,
      this.checkedOutAt,
      this.hoursApproved})
      : super._();
  @override
  AssignmentSummary rebuild(void Function(AssignmentSummaryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AssignmentSummaryBuilder toBuilder() =>
      AssignmentSummaryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AssignmentSummary &&
        id == other.id &&
        status == other.status &&
        claimedAt == other.claimedAt &&
        cancellableUntil == other.cancellableUntil &&
        cancelledBy == other.cancelledBy &&
        checkInFrom == other.checkInFrom &&
        checkedInAt == other.checkedInAt &&
        checkedOutAt == other.checkedOutAt &&
        hoursApproved == other.hoursApproved;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, claimedAt.hashCode);
    _$hash = $jc(_$hash, cancellableUntil.hashCode);
    _$hash = $jc(_$hash, cancelledBy.hashCode);
    _$hash = $jc(_$hash, checkInFrom.hashCode);
    _$hash = $jc(_$hash, checkedInAt.hashCode);
    _$hash = $jc(_$hash, checkedOutAt.hashCode);
    _$hash = $jc(_$hash, hoursApproved.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AssignmentSummary')
          ..add('id', id)
          ..add('status', status)
          ..add('claimedAt', claimedAt)
          ..add('cancellableUntil', cancellableUntil)
          ..add('cancelledBy', cancelledBy)
          ..add('checkInFrom', checkInFrom)
          ..add('checkedInAt', checkedInAt)
          ..add('checkedOutAt', checkedOutAt)
          ..add('hoursApproved', hoursApproved))
        .toString();
  }
}

class AssignmentSummaryBuilder
    implements Builder<AssignmentSummary, AssignmentSummaryBuilder> {
  _$AssignmentSummary? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  AssignmentStatus? _status;
  AssignmentStatus? get status => _$this._status;
  set status(AssignmentStatus? status) => _$this._status = status;

  DateTime? _claimedAt;
  DateTime? get claimedAt => _$this._claimedAt;
  set claimedAt(DateTime? claimedAt) => _$this._claimedAt = claimedAt;

  DateTime? _cancellableUntil;
  DateTime? get cancellableUntil => _$this._cancellableUntil;
  set cancellableUntil(DateTime? cancellableUntil) =>
      _$this._cancellableUntil = cancellableUntil;

  CancelledBy? _cancelledBy;
  CancelledBy? get cancelledBy => _$this._cancelledBy;
  set cancelledBy(CancelledBy? cancelledBy) =>
      _$this._cancelledBy = cancelledBy;

  DateTime? _checkInFrom;
  DateTime? get checkInFrom => _$this._checkInFrom;
  set checkInFrom(DateTime? checkInFrom) => _$this._checkInFrom = checkInFrom;

  DateTime? _checkedInAt;
  DateTime? get checkedInAt => _$this._checkedInAt;
  set checkedInAt(DateTime? checkedInAt) => _$this._checkedInAt = checkedInAt;

  DateTime? _checkedOutAt;
  DateTime? get checkedOutAt => _$this._checkedOutAt;
  set checkedOutAt(DateTime? checkedOutAt) =>
      _$this._checkedOutAt = checkedOutAt;

  bool? _hoursApproved;
  bool? get hoursApproved => _$this._hoursApproved;
  set hoursApproved(bool? hoursApproved) =>
      _$this._hoursApproved = hoursApproved;

  AssignmentSummaryBuilder() {
    AssignmentSummary._defaults(this);
  }

  AssignmentSummaryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _status = $v.status;
      _claimedAt = $v.claimedAt;
      _cancellableUntil = $v.cancellableUntil;
      _cancelledBy = $v.cancelledBy;
      _checkInFrom = $v.checkInFrom;
      _checkedInAt = $v.checkedInAt;
      _checkedOutAt = $v.checkedOutAt;
      _hoursApproved = $v.hoursApproved;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AssignmentSummary other) {
    _$v = other as _$AssignmentSummary;
  }

  @override
  void update(void Function(AssignmentSummaryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AssignmentSummary build() => _build();

  _$AssignmentSummary _build() {
    final _$result = _$v ??
        _$AssignmentSummary._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'AssignmentSummary', 'id'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'AssignmentSummary', 'status'),
          claimedAt: BuiltValueNullFieldError.checkNotNull(
              claimedAt, r'AssignmentSummary', 'claimedAt'),
          cancellableUntil: cancellableUntil,
          cancelledBy: cancelledBy,
          checkInFrom: checkInFrom,
          checkedInAt: checkedInAt,
          checkedOutAt: checkedOutAt,
          hoursApproved: hoursApproved,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
