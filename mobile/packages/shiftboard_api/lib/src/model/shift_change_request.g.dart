// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_change_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShiftChangeRequest extends ShiftChangeRequest {
  @override
  final String clientId;
  @override
  final String locationId;
  @override
  final String title;
  @override
  final String? description;
  @override
  final DateTime startsAt;
  @override
  final DateTime endsAt;
  @override
  final bool? endIsEstimate;
  @override
  final int hourlyRateCents;
  @override
  final int slots;
  @override
  final BuiltSet<String>? qualificationIds;

  factory _$ShiftChangeRequest(
          [void Function(ShiftChangeRequestBuilder)? updates]) =>
      (ShiftChangeRequestBuilder()..update(updates))._build();

  _$ShiftChangeRequest._(
      {required this.clientId,
      required this.locationId,
      required this.title,
      this.description,
      required this.startsAt,
      required this.endsAt,
      this.endIsEstimate,
      required this.hourlyRateCents,
      required this.slots,
      this.qualificationIds})
      : super._();
  @override
  ShiftChangeRequest rebuild(
          void Function(ShiftChangeRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShiftChangeRequestBuilder toBuilder() =>
      ShiftChangeRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShiftChangeRequest &&
        clientId == other.clientId &&
        locationId == other.locationId &&
        title == other.title &&
        description == other.description &&
        startsAt == other.startsAt &&
        endsAt == other.endsAt &&
        endIsEstimate == other.endIsEstimate &&
        hourlyRateCents == other.hourlyRateCents &&
        slots == other.slots &&
        qualificationIds == other.qualificationIds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientId.hashCode);
    _$hash = $jc(_$hash, locationId.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, startsAt.hashCode);
    _$hash = $jc(_$hash, endsAt.hashCode);
    _$hash = $jc(_$hash, endIsEstimate.hashCode);
    _$hash = $jc(_$hash, hourlyRateCents.hashCode);
    _$hash = $jc(_$hash, slots.hashCode);
    _$hash = $jc(_$hash, qualificationIds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ShiftChangeRequest')
          ..add('clientId', clientId)
          ..add('locationId', locationId)
          ..add('title', title)
          ..add('description', description)
          ..add('startsAt', startsAt)
          ..add('endsAt', endsAt)
          ..add('endIsEstimate', endIsEstimate)
          ..add('hourlyRateCents', hourlyRateCents)
          ..add('slots', slots)
          ..add('qualificationIds', qualificationIds))
        .toString();
  }
}

class ShiftChangeRequestBuilder
    implements Builder<ShiftChangeRequest, ShiftChangeRequestBuilder> {
  _$ShiftChangeRequest? _$v;

  String? _clientId;
  String? get clientId => _$this._clientId;
  set clientId(String? clientId) => _$this._clientId = clientId;

  String? _locationId;
  String? get locationId => _$this._locationId;
  set locationId(String? locationId) => _$this._locationId = locationId;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

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

  int? _hourlyRateCents;
  int? get hourlyRateCents => _$this._hourlyRateCents;
  set hourlyRateCents(int? hourlyRateCents) =>
      _$this._hourlyRateCents = hourlyRateCents;

  int? _slots;
  int? get slots => _$this._slots;
  set slots(int? slots) => _$this._slots = slots;

  SetBuilder<String>? _qualificationIds;
  SetBuilder<String> get qualificationIds =>
      _$this._qualificationIds ??= SetBuilder<String>();
  set qualificationIds(SetBuilder<String>? qualificationIds) =>
      _$this._qualificationIds = qualificationIds;

  ShiftChangeRequestBuilder() {
    ShiftChangeRequest._defaults(this);
  }

  ShiftChangeRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientId = $v.clientId;
      _locationId = $v.locationId;
      _title = $v.title;
      _description = $v.description;
      _startsAt = $v.startsAt;
      _endsAt = $v.endsAt;
      _endIsEstimate = $v.endIsEstimate;
      _hourlyRateCents = $v.hourlyRateCents;
      _slots = $v.slots;
      _qualificationIds = $v.qualificationIds?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShiftChangeRequest other) {
    _$v = other as _$ShiftChangeRequest;
  }

  @override
  void update(void Function(ShiftChangeRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShiftChangeRequest build() => _build();

  _$ShiftChangeRequest _build() {
    _$ShiftChangeRequest _$result;
    try {
      _$result = _$v ??
          _$ShiftChangeRequest._(
            clientId: BuiltValueNullFieldError.checkNotNull(
                clientId, r'ShiftChangeRequest', 'clientId'),
            locationId: BuiltValueNullFieldError.checkNotNull(
                locationId, r'ShiftChangeRequest', 'locationId'),
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'ShiftChangeRequest', 'title'),
            description: description,
            startsAt: BuiltValueNullFieldError.checkNotNull(
                startsAt, r'ShiftChangeRequest', 'startsAt'),
            endsAt: BuiltValueNullFieldError.checkNotNull(
                endsAt, r'ShiftChangeRequest', 'endsAt'),
            endIsEstimate: endIsEstimate,
            hourlyRateCents: BuiltValueNullFieldError.checkNotNull(
                hourlyRateCents, r'ShiftChangeRequest', 'hourlyRateCents'),
            slots: BuiltValueNullFieldError.checkNotNull(
                slots, r'ShiftChangeRequest', 'slots'),
            qualificationIds: _qualificationIds?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'qualificationIds';
        _qualificationIds?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ShiftChangeRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
