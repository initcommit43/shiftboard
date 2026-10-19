// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_template.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShiftTemplate extends ShiftTemplate {
  @override
  final String id;
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
  final bool endIsEstimate;
  @override
  final int hourlyRateCents;
  @override
  final int slots;
  @override
  final BuiltSet<String> qualificationIds;
  @override
  final DateTime createdAt;

  factory _$ShiftTemplate([void Function(ShiftTemplateBuilder)? updates]) =>
      (ShiftTemplateBuilder()..update(updates))._build();

  _$ShiftTemplate._(
      {required this.id,
      required this.name,
      required this.clientId,
      required this.locationId,
      required this.title,
      this.description,
      required this.startTime,
      required this.durationMinutes,
      required this.endIsEstimate,
      required this.hourlyRateCents,
      required this.slots,
      required this.qualificationIds,
      required this.createdAt})
      : super._();
  @override
  ShiftTemplate rebuild(void Function(ShiftTemplateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShiftTemplateBuilder toBuilder() => ShiftTemplateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShiftTemplate &&
        id == other.id &&
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
        qualificationIds == other.qualificationIds &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
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
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ShiftTemplate')
          ..add('id', id)
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
          ..add('qualificationIds', qualificationIds)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class ShiftTemplateBuilder
    implements Builder<ShiftTemplate, ShiftTemplateBuilder> {
  _$ShiftTemplate? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

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

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  ShiftTemplateBuilder() {
    ShiftTemplate._defaults(this);
  }

  ShiftTemplateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
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
      _qualificationIds = $v.qualificationIds.toBuilder();
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShiftTemplate other) {
    _$v = other as _$ShiftTemplate;
  }

  @override
  void update(void Function(ShiftTemplateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShiftTemplate build() => _build();

  _$ShiftTemplate _build() {
    _$ShiftTemplate _$result;
    try {
      _$result = _$v ??
          _$ShiftTemplate._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'ShiftTemplate', 'id'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'ShiftTemplate', 'name'),
            clientId: BuiltValueNullFieldError.checkNotNull(
                clientId, r'ShiftTemplate', 'clientId'),
            locationId: BuiltValueNullFieldError.checkNotNull(
                locationId, r'ShiftTemplate', 'locationId'),
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'ShiftTemplate', 'title'),
            description: description,
            startTime: BuiltValueNullFieldError.checkNotNull(
                startTime, r'ShiftTemplate', 'startTime'),
            durationMinutes: BuiltValueNullFieldError.checkNotNull(
                durationMinutes, r'ShiftTemplate', 'durationMinutes'),
            endIsEstimate: BuiltValueNullFieldError.checkNotNull(
                endIsEstimate, r'ShiftTemplate', 'endIsEstimate'),
            hourlyRateCents: BuiltValueNullFieldError.checkNotNull(
                hourlyRateCents, r'ShiftTemplate', 'hourlyRateCents'),
            slots: BuiltValueNullFieldError.checkNotNull(
                slots, r'ShiftTemplate', 'slots'),
            qualificationIds: qualificationIds.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'ShiftTemplate', 'createdAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'qualificationIds';
        qualificationIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ShiftTemplate', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
