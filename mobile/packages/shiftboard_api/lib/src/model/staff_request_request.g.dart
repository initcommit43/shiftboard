// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_request_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StaffRequestRequest extends StaffRequestRequest {
  @override
  final String locationId;
  @override
  final String role;
  @override
  final DateTime startsAt;
  @override
  final DateTime endsAt;
  @override
  final bool? endIsEstimate;
  @override
  final int workerCount;
  @override
  final String? notes;

  factory _$StaffRequestRequest(
          [void Function(StaffRequestRequestBuilder)? updates]) =>
      (StaffRequestRequestBuilder()..update(updates))._build();

  _$StaffRequestRequest._(
      {required this.locationId,
      required this.role,
      required this.startsAt,
      required this.endsAt,
      this.endIsEstimate,
      required this.workerCount,
      this.notes})
      : super._();
  @override
  StaffRequestRequest rebuild(
          void Function(StaffRequestRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StaffRequestRequestBuilder toBuilder() =>
      StaffRequestRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StaffRequestRequest &&
        locationId == other.locationId &&
        role == other.role &&
        startsAt == other.startsAt &&
        endsAt == other.endsAt &&
        endIsEstimate == other.endIsEstimate &&
        workerCount == other.workerCount &&
        notes == other.notes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, locationId.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, startsAt.hashCode);
    _$hash = $jc(_$hash, endsAt.hashCode);
    _$hash = $jc(_$hash, endIsEstimate.hashCode);
    _$hash = $jc(_$hash, workerCount.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StaffRequestRequest')
          ..add('locationId', locationId)
          ..add('role', role)
          ..add('startsAt', startsAt)
          ..add('endsAt', endsAt)
          ..add('endIsEstimate', endIsEstimate)
          ..add('workerCount', workerCount)
          ..add('notes', notes))
        .toString();
  }
}

class StaffRequestRequestBuilder
    implements Builder<StaffRequestRequest, StaffRequestRequestBuilder> {
  _$StaffRequestRequest? _$v;

  String? _locationId;
  String? get locationId => _$this._locationId;
  set locationId(String? locationId) => _$this._locationId = locationId;

  String? _role;
  String? get role => _$this._role;
  set role(String? role) => _$this._role = role;

  DateTime? _startsAt;
  DateTime? get startsAt => _$this._startsAt;
  set startsAt(DateTime? startsAt) => _$this._startsAt = startsAt;

  DateTime? _endsAt;
  DateTime? get endsAt => _$this._endsAt;
  set endsAt(DateTime? endsAt) => _$this._endsAt = endsAt;

  bool? _endIsEstimate;
  bool? get endIsEstimate => _$this._endIsEstimate;
  set endIsEstimate(bool? endIsEstimate) =>
      _$this._endIsEstimate = endIsEstimate;

  int? _workerCount;
  int? get workerCount => _$this._workerCount;
  set workerCount(int? workerCount) => _$this._workerCount = workerCount;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  StaffRequestRequestBuilder() {
    StaffRequestRequest._defaults(this);
  }

  StaffRequestRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _locationId = $v.locationId;
      _role = $v.role;
      _startsAt = $v.startsAt;
      _endsAt = $v.endsAt;
      _endIsEstimate = $v.endIsEstimate;
      _workerCount = $v.workerCount;
      _notes = $v.notes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StaffRequestRequest other) {
    _$v = other as _$StaffRequestRequest;
  }

  @override
  void update(void Function(StaffRequestRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StaffRequestRequest build() => _build();

  _$StaffRequestRequest _build() {
    final _$result = _$v ??
        _$StaffRequestRequest._(
          locationId: BuiltValueNullFieldError.checkNotNull(
              locationId, r'StaffRequestRequest', 'locationId'),
          role: BuiltValueNullFieldError.checkNotNull(
              role, r'StaffRequestRequest', 'role'),
          startsAt: BuiltValueNullFieldError.checkNotNull(
              startsAt, r'StaffRequestRequest', 'startsAt'),
          endsAt: BuiltValueNullFieldError.checkNotNull(
              endsAt, r'StaffRequestRequest', 'endsAt'),
          endIsEstimate: endIsEstimate,
          workerCount: BuiltValueNullFieldError.checkNotNull(
              workerCount, r'StaffRequestRequest', 'workerCount'),
          notes: notes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
