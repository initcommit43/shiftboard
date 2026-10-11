// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Shift extends Shift {
  @override
  final String id;
  @override
  final String title;
  @override
  final String? description;
  @override
  final ShiftStatus status;
  @override
  final ClientSummary client;
  @override
  final Location location;
  @override
  final DateTime startsAt;
  @override
  final DateTime endsAt;
  @override
  final bool endIsEstimate;
  @override
  final int hourlyRateCents;
  @override
  final int slots;
  @override
  final int takenSlots;
  @override
  final BuiltList<Qualification> qualifications;
  @override
  final DateTime createdAt;

  factory _$Shift([void Function(ShiftBuilder)? updates]) =>
      (ShiftBuilder()..update(updates))._build();

  _$Shift._(
      {required this.id,
      required this.title,
      this.description,
      required this.status,
      required this.client,
      required this.location,
      required this.startsAt,
      required this.endsAt,
      required this.endIsEstimate,
      required this.hourlyRateCents,
      required this.slots,
      required this.takenSlots,
      required this.qualifications,
      required this.createdAt})
      : super._();
  @override
  Shift rebuild(void Function(ShiftBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShiftBuilder toBuilder() => ShiftBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Shift &&
        id == other.id &&
        title == other.title &&
        description == other.description &&
        status == other.status &&
        client == other.client &&
        location == other.location &&
        startsAt == other.startsAt &&
        endsAt == other.endsAt &&
        endIsEstimate == other.endIsEstimate &&
        hourlyRateCents == other.hourlyRateCents &&
        slots == other.slots &&
        takenSlots == other.takenSlots &&
        qualifications == other.qualifications &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, client.hashCode);
    _$hash = $jc(_$hash, location.hashCode);
    _$hash = $jc(_$hash, startsAt.hashCode);
    _$hash = $jc(_$hash, endsAt.hashCode);
    _$hash = $jc(_$hash, endIsEstimate.hashCode);
    _$hash = $jc(_$hash, hourlyRateCents.hashCode);
    _$hash = $jc(_$hash, slots.hashCode);
    _$hash = $jc(_$hash, takenSlots.hashCode);
    _$hash = $jc(_$hash, qualifications.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Shift')
          ..add('id', id)
          ..add('title', title)
          ..add('description', description)
          ..add('status', status)
          ..add('client', client)
          ..add('location', location)
          ..add('startsAt', startsAt)
          ..add('endsAt', endsAt)
          ..add('endIsEstimate', endIsEstimate)
          ..add('hourlyRateCents', hourlyRateCents)
          ..add('slots', slots)
          ..add('takenSlots', takenSlots)
          ..add('qualifications', qualifications)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class ShiftBuilder implements Builder<Shift, ShiftBuilder> {
  _$Shift? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  ShiftStatus? _status;
  ShiftStatus? get status => _$this._status;
  set status(ShiftStatus? status) => _$this._status = status;

  ClientSummaryBuilder? _client;
  ClientSummaryBuilder get client => _$this._client ??= ClientSummaryBuilder();
  set client(ClientSummaryBuilder? client) => _$this._client = client;

  LocationBuilder? _location;
  LocationBuilder get location => _$this._location ??= LocationBuilder();
  set location(LocationBuilder? location) => _$this._location = location;

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

  int? _takenSlots;
  int? get takenSlots => _$this._takenSlots;
  set takenSlots(int? takenSlots) => _$this._takenSlots = takenSlots;

  ListBuilder<Qualification>? _qualifications;
  ListBuilder<Qualification> get qualifications =>
      _$this._qualifications ??= ListBuilder<Qualification>();
  set qualifications(ListBuilder<Qualification>? qualifications) =>
      _$this._qualifications = qualifications;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  ShiftBuilder() {
    Shift._defaults(this);
  }

  ShiftBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _description = $v.description;
      _status = $v.status;
      _client = $v.client.toBuilder();
      _location = $v.location.toBuilder();
      _startsAt = $v.startsAt;
      _endsAt = $v.endsAt;
      _endIsEstimate = $v.endIsEstimate;
      _hourlyRateCents = $v.hourlyRateCents;
      _slots = $v.slots;
      _takenSlots = $v.takenSlots;
      _qualifications = $v.qualifications.toBuilder();
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Shift other) {
    _$v = other as _$Shift;
  }

  @override
  void update(void Function(ShiftBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Shift build() => _build();

  _$Shift _build() {
    _$Shift _$result;
    try {
      _$result = _$v ??
          _$Shift._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Shift', 'id'),
            title:
                BuiltValueNullFieldError.checkNotNull(title, r'Shift', 'title'),
            description: description,
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'Shift', 'status'),
            client: client.build(),
            location: location.build(),
            startsAt: BuiltValueNullFieldError.checkNotNull(
                startsAt, r'Shift', 'startsAt'),
            endsAt: BuiltValueNullFieldError.checkNotNull(
                endsAt, r'Shift', 'endsAt'),
            endIsEstimate: BuiltValueNullFieldError.checkNotNull(
                endIsEstimate, r'Shift', 'endIsEstimate'),
            hourlyRateCents: BuiltValueNullFieldError.checkNotNull(
                hourlyRateCents, r'Shift', 'hourlyRateCents'),
            slots:
                BuiltValueNullFieldError.checkNotNull(slots, r'Shift', 'slots'),
            takenSlots: BuiltValueNullFieldError.checkNotNull(
                takenSlots, r'Shift', 'takenSlots'),
            qualifications: qualifications.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'Shift', 'createdAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'client';
        client.build();
        _$failedField = 'location';
        location.build();

        _$failedField = 'qualifications';
        qualifications.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'Shift', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
