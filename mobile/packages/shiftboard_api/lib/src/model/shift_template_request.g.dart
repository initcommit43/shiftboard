// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_template_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShiftTemplateRequest extends ShiftTemplateRequest {
  @override
  final String name;
  @override
  final String clientId;
  @override
  final String locationId;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String startTime;
  @override
  final int durationMinutes;
  @override
  final bool? endIsEstimate;
  @override
  final int hourlyRateCents;
  @override
  final int slots;
  @override
  final BuiltSet<String>? qualificationIds;

  factory _$ShiftTemplateRequest(
          [void Function(ShiftTemplateRequestBuilder)? updates]) =>
      (ShiftTemplateRequestBuilder()..update(updates))._build();

  _$ShiftTemplateRequest._(
      {required this.name,
      required this.clientId,
      required this.locationId,
      required this.title,
      this.description,
      required this.startTime,
      required this.durationMinutes,
      this.endIsEstimate,
      required this.hourlyRateCents,
      required this.slots,
      this.qualificationIds})
      : super._();
  @override
  ShiftTemplateRequest rebuild(
          void Function(ShiftTemplateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShiftTemplateRequestBuilder toBuilder() =>
      ShiftTemplateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShiftTemplateRequest &&
        name == other.name &&
        clientId == other.clientId &&
        locationId == other.locationId &&
        title == other.title &&
        description == other.description &&
        startTime == other.startTime &&
        durationMinutes == other.durationMinutes &&
        endIsEstimate == other.endIsEstimate &&
        hourlyRateCents == other.hourlyRateCents &&
        slots == other.slots &&
        qualificationIds == other.qualificationIds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, clientId.hashCode);
    _$hash = $jc(_$hash, locationId.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, startTime.hashCode);
    _$hash = $jc(_$hash, durationMinutes.hashCode);
    _$hash = $jc(_$hash, endIsEstimate.hashCode);
    _$hash = $jc(_$hash, hourlyRateCents.hashCode);
    _$hash = $jc(_$hash, slots.hashCode);
    _$hash = $jc(_$hash, qualificationIds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ShiftTemplateRequest')
          ..add('name', name)
          ..add('clientId', clientId)
          ..add('locationId', locationId)
          ..add('title', title)
          ..add('description', description)
          ..add('startTime', startTime)
          ..add('durationMinutes', durationMinutes)
          ..add('endIsEstimate', endIsEstimate)
          ..add('hourlyRateCents', hourlyRateCents)
          ..add('slots', slots)
          ..add('qualificationIds', qualificationIds))
        .toString();
  }
}

class ShiftTemplateRequestBuilder
    implements Builder<ShiftTemplateRequest, ShiftTemplateRequestBuilder> {
  _$ShiftTemplateRequest? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

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

  String? _startTime;
  String? get startTime => _$this._startTime;
  set startTime(String? startTime) => _$this._startTime = startTime;

  int? _durationMinutes;
  int? get durationMinutes => _$this._durationMinutes;
  set durationMinutes(int? durationMinutes) =>
      _$this._durationMinutes = durationMinutes;

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

  ShiftTemplateRequestBuilder() {
    ShiftTemplateRequest._defaults(this);
  }

  ShiftTemplateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _clientId = $v.clientId;
      _locationId = $v.locationId;
      _title = $v.title;
      _description = $v.description;
      _startTime = $v.startTime;
      _durationMinutes = $v.durationMinutes;
      _endIsEstimate = $v.endIsEstimate;
      _hourlyRateCents = $v.hourlyRateCents;
      _slots = $v.slots;
      _qualificationIds = $v.qualificationIds?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShiftTemplateRequest other) {
    _$v = other as _$ShiftTemplateRequest;
  }

  @override
  void update(void Function(ShiftTemplateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShiftTemplateRequest build() => _build();

  _$ShiftTemplateRequest _build() {
    _$ShiftTemplateRequest _$result;
    try {
      _$result = _$v ??
          _$ShiftTemplateRequest._(
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'ShiftTemplateRequest', 'name'),
            clientId: BuiltValueNullFieldError.checkNotNull(
                clientId, r'ShiftTemplateRequest', 'clientId'),
            locationId: BuiltValueNullFieldError.checkNotNull(
                locationId, r'ShiftTemplateRequest', 'locationId'),
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'ShiftTemplateRequest', 'title'),
            description: description,
            startTime: BuiltValueNullFieldError.checkNotNull(
                startTime, r'ShiftTemplateRequest', 'startTime'),
            durationMinutes: BuiltValueNullFieldError.checkNotNull(
                durationMinutes, r'ShiftTemplateRequest', 'durationMinutes'),
            endIsEstimate: endIsEstimate,
            hourlyRateCents: BuiltValueNullFieldError.checkNotNull(
                hourlyRateCents, r'ShiftTemplateRequest', 'hourlyRateCents'),
            slots: BuiltValueNullFieldError.checkNotNull(
                slots, r'ShiftTemplateRequest', 'slots'),
            qualificationIds: _qualificationIds?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'qualificationIds';
        _qualificationIds?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ShiftTemplateRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
