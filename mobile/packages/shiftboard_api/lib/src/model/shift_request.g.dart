// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShiftRequest extends ShiftRequest {
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
  @override
  final bool? publish;

  factory _$ShiftRequest([void Function(ShiftRequestBuilder)? updates]) =>
      (ShiftRequestBuilder()..update(updates))._build();

  _$ShiftRequest._(
      {required this.clientId,
      required this.locationId,
      required this.title,
      this.description,
      required this.startsAt,
      required this.endsAt,
      this.endIsEstimate,
      required this.hourlyRateCents,
      required this.slots,
      this.qualificationIds,
      this.publish})
      : super._();
  @override
  ShiftRequest rebuild(void Function(ShiftRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShiftRequestBuilder toBuilder() => ShiftRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShiftRequest &&
        clientId == other.clientId &&
        locationId == other.locationId &&
        title == other.title &&
        description == other.description &&
        startsAt == other.startsAt &&
        endsAt == other.endsAt &&
        endIsEstimate == other.endIsEstimate &&
        hourlyRateCents == other.hourlyRateCents &&
        slots == other.slots &&
        qualificationIds == other.qualificationIds &&
        publish == other.publish;
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
    _$hash = $jc(_$hash, publish.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ShiftRequest')
          ..add('clientId', clientId)
          ..add('locationId', locationId)
          ..add('title', title)
          ..add('description', description)
          ..add('startsAt', startsAt)
          ..add('endsAt', endsAt)
          ..add('endIsEstimate', endIsEstimate)
          ..add('hourlyRateCents', hourlyRateCents)
          ..add('slots', slots)
          ..add('qualificationIds', qualificationIds)
          ..add('publish', publish))
        .toString();
  }
}

class ShiftRequestBuilder
    implements Builder<ShiftRequest, ShiftRequestBuilder> {
  _$ShiftRequest? _$v;

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

  bool? _publish;
  bool? get publish => _$this._publish;
  set publish(bool? publish) => _$this._publish = publish;

  ShiftRequestBuilder() {
    ShiftRequest._defaults(this);
  }

  ShiftRequestBuilder get _$this {
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
      _publish = $v.publish;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShiftRequest other) {
    _$v = other as _$ShiftRequest;
  }

  @override
  void update(void Function(ShiftRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShiftRequest build() => _build();

  _$ShiftRequest _build() {
    _$ShiftRequest _$result;
    try {
      _$result = _$v ??
          _$ShiftRequest._(
            clientId: BuiltValueNullFieldError.checkNotNull(
                clientId, r'ShiftRequest', 'clientId'),
            locationId: BuiltValueNullFieldError.checkNotNull(
                locationId, r'ShiftRequest', 'locationId'),
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'ShiftRequest', 'title'),
            description: description,
            startsAt: BuiltValueNullFieldError.checkNotNull(
                startsAt, r'ShiftRequest', 'startsAt'),
            endsAt: BuiltValueNullFieldError.checkNotNull(
                endsAt, r'ShiftRequest', 'endsAt'),
            endIsEstimate: endIsEstimate,
            hourlyRateCents: BuiltValueNullFieldError.checkNotNull(
                hourlyRateCents, r'ShiftRequest', 'hourlyRateCents'),
            slots: BuiltValueNullFieldError.checkNotNull(
                slots, r'ShiftRequest', 'slots'),
            qualificationIds: _qualificationIds?.build(),
            publish: publish,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'qualificationIds';
        _qualificationIds?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ShiftRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
