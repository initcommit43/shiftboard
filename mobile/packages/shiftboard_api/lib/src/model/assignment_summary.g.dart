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

  factory _$AssignmentSummary(
          [void Function(AssignmentSummaryBuilder)? updates]) =>
      (AssignmentSummaryBuilder()..update(updates))._build();

  _$AssignmentSummary._(
      {required this.id, required this.status, required this.claimedAt})
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
        claimedAt == other.claimedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, claimedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AssignmentSummary')
          ..add('id', id)
          ..add('status', status)
          ..add('claimedAt', claimedAt))
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

  AssignmentSummaryBuilder() {
    AssignmentSummary._defaults(this);
  }

  AssignmentSummaryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _status = $v.status;
      _claimedAt = $v.claimedAt;
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
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
