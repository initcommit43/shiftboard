// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StaffRequest extends StaffRequest {
  @override
  final String id;
  @override
  final StaffRequestStatus status;
  @override
  final ClientSummary client;
  @override
  final Location location;
  @override
  final String role;
  @override
  final DateTime startsAt;
  @override
  final DateTime endsAt;
  @override
  final bool endIsEstimate;
  @override
  final int workerCount;
  @override
  final String notes;
  @override
  final String requestedBy;
  @override
  final DateTime createdAt;
  @override
  final DateTime? decidedAt;
  @override
  final String? declineReason;
  @override
  final String? shiftId;

  factory _$StaffRequest([void Function(StaffRequestBuilder)? updates]) =>
      (StaffRequestBuilder()..update(updates))._build();

  _$StaffRequest._(
      {required this.id,
      required this.status,
      required this.client,
      required this.location,
      required this.role,
      required this.startsAt,
      required this.endsAt,
      required this.endIsEstimate,
      required this.workerCount,
      required this.notes,
      required this.requestedBy,
      required this.createdAt,
      this.decidedAt,
      this.declineReason,
      this.shiftId})
      : super._();
  @override
  StaffRequest rebuild(void Function(StaffRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StaffRequestBuilder toBuilder() => StaffRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StaffRequest &&
        id == other.id &&
        status == other.status &&
        client == other.client &&
        location == other.location &&
        role == other.role &&
        startsAt == other.startsAt &&
        endsAt == other.endsAt &&
        endIsEstimate == other.endIsEstimate &&
        workerCount == other.workerCount &&
        notes == other.notes &&
        requestedBy == other.requestedBy &&
        createdAt == other.createdAt &&
        decidedAt == other.decidedAt &&
        declineReason == other.declineReason &&
        shiftId == other.shiftId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, client.hashCode);
    _$hash = $jc(_$hash, location.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, startsAt.hashCode);
    _$hash = $jc(_$hash, endsAt.hashCode);
    _$hash = $jc(_$hash, endIsEstimate.hashCode);
    _$hash = $jc(_$hash, workerCount.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, requestedBy.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, decidedAt.hashCode);
    _$hash = $jc(_$hash, declineReason.hashCode);
    _$hash = $jc(_$hash, shiftId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StaffRequest')
          ..add('id', id)
          ..add('status', status)
          ..add('client', client)
          ..add('location', location)
          ..add('role', role)
          ..add('startsAt', startsAt)
          ..add('endsAt', endsAt)
          ..add('endIsEstimate', endIsEstimate)
          ..add('workerCount', workerCount)
          ..add('notes', notes)
          ..add('requestedBy', requestedBy)
          ..add('createdAt', createdAt)
          ..add('decidedAt', decidedAt)
          ..add('declineReason', declineReason)
          ..add('shiftId', shiftId))
        .toString();
  }
}

class StaffRequestBuilder
    implements Builder<StaffRequest, StaffRequestBuilder> {
  _$StaffRequest? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  StaffRequestStatus? _status;
  StaffRequestStatus? get status => _$this._status;
  set status(StaffRequestStatus? status) => _$this._status = status;

  ClientSummaryBuilder? _client;
  ClientSummaryBuilder get client => _$this._client ??= ClientSummaryBuilder();
  set client(ClientSummaryBuilder? client) => _$this._client = client;

  LocationBuilder? _location;
  LocationBuilder get location => _$this._location ??= LocationBuilder();
  set location(LocationBuilder? location) => _$this._location = location;

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

  String? _requestedBy;
  String? get requestedBy => _$this._requestedBy;
  set requestedBy(String? requestedBy) => _$this._requestedBy = requestedBy;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _decidedAt;
  DateTime? get decidedAt => _$this._decidedAt;
  set decidedAt(DateTime? decidedAt) => _$this._decidedAt = decidedAt;

  String? _declineReason;
  String? get declineReason => _$this._declineReason;
  set declineReason(String? declineReason) =>
      _$this._declineReason = declineReason;

  String? _shiftId;
  String? get shiftId => _$this._shiftId;
  set shiftId(String? shiftId) => _$this._shiftId = shiftId;

  StaffRequestBuilder() {
    StaffRequest._defaults(this);
  }

  StaffRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _status = $v.status;
      _client = $v.client.toBuilder();
      _location = $v.location.toBuilder();
      _role = $v.role;
      _startsAt = $v.startsAt;
      _endsAt = $v.endsAt;
      _endIsEstimate = $v.endIsEstimate;
      _workerCount = $v.workerCount;
      _notes = $v.notes;
      _requestedBy = $v.requestedBy;
      _createdAt = $v.createdAt;
      _decidedAt = $v.decidedAt;
      _declineReason = $v.declineReason;
      _shiftId = $v.shiftId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StaffRequest other) {
    _$v = other as _$StaffRequest;
  }

  @override
  void update(void Function(StaffRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StaffRequest build() => _build();

  _$StaffRequest _build() {
    _$StaffRequest _$result;
    try {
      _$result = _$v ??
          _$StaffRequest._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'StaffRequest', 'id'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'StaffRequest', 'status'),
            client: client.build(),
            location: location.build(),
            role: BuiltValueNullFieldError.checkNotNull(
                role, r'StaffRequest', 'role'),
            startsAt: BuiltValueNullFieldError.checkNotNull(
                startsAt, r'StaffRequest', 'startsAt'),
            endsAt: BuiltValueNullFieldError.checkNotNull(
                endsAt, r'StaffRequest', 'endsAt'),
            endIsEstimate: BuiltValueNullFieldError.checkNotNull(
                endIsEstimate, r'StaffRequest', 'endIsEstimate'),
            workerCount: BuiltValueNullFieldError.checkNotNull(
                workerCount, r'StaffRequest', 'workerCount'),
            notes: BuiltValueNullFieldError.checkNotNull(
                notes, r'StaffRequest', 'notes'),
            requestedBy: BuiltValueNullFieldError.checkNotNull(
                requestedBy, r'StaffRequest', 'requestedBy'),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'StaffRequest', 'createdAt'),
            decidedAt: decidedAt,
            declineReason: declineReason,
            shiftId: shiftId,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'client';
        client.build();
        _$failedField = 'location';
        location.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'StaffRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
