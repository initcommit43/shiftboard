// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hours_shift.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$HoursShift extends HoursShift {
  @override
  final String id;
  @override
  final String title;
  @override
  final DateTime startsAt;
  @override
  final DateTime endsAt;
  @override
  final int hourlyRateCents;
  @override
  final ClientSummary client;
  @override
  final Location location;

  factory _$HoursShift([void Function(HoursShiftBuilder)? updates]) =>
      (HoursShiftBuilder()..update(updates))._build();

  _$HoursShift._(
      {required this.id,
      required this.title,
      required this.startsAt,
      required this.endsAt,
      required this.hourlyRateCents,
      required this.client,
      required this.location})
      : super._();
  @override
  HoursShift rebuild(void Function(HoursShiftBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  HoursShiftBuilder toBuilder() => HoursShiftBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HoursShift &&
        id == other.id &&
        title == other.title &&
        startsAt == other.startsAt &&
        endsAt == other.endsAt &&
        hourlyRateCents == other.hourlyRateCents &&
        client == other.client &&
        location == other.location;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, startsAt.hashCode);
    _$hash = $jc(_$hash, endsAt.hashCode);
    _$hash = $jc(_$hash, hourlyRateCents.hashCode);
    _$hash = $jc(_$hash, client.hashCode);
    _$hash = $jc(_$hash, location.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'HoursShift')
          ..add('id', id)
          ..add('title', title)
          ..add('startsAt', startsAt)
          ..add('endsAt', endsAt)
          ..add('hourlyRateCents', hourlyRateCents)
          ..add('client', client)
          ..add('location', location))
        .toString();
  }
}

class HoursShiftBuilder implements Builder<HoursShift, HoursShiftBuilder> {
  _$HoursShift? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  DateTime? _startsAt;
  DateTime? get startsAt => _$this._startsAt;
  set startsAt(DateTime? startsAt) => _$this._startsAt = startsAt;

  DateTime? _endsAt;
  DateTime? get endsAt => _$this._endsAt;
  set endsAt(DateTime? endsAt) => _$this._endsAt = endsAt;

  int? _hourlyRateCents;
  int? get hourlyRateCents => _$this._hourlyRateCents;
  set hourlyRateCents(int? hourlyRateCents) =>
      _$this._hourlyRateCents = hourlyRateCents;

  ClientSummaryBuilder? _client;
  ClientSummaryBuilder get client => _$this._client ??= ClientSummaryBuilder();
  set client(ClientSummaryBuilder? client) => _$this._client = client;

  LocationBuilder? _location;
  LocationBuilder get location => _$this._location ??= LocationBuilder();
  set location(LocationBuilder? location) => _$this._location = location;

  HoursShiftBuilder() {
    HoursShift._defaults(this);
  }

  HoursShiftBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _startsAt = $v.startsAt;
      _endsAt = $v.endsAt;
      _hourlyRateCents = $v.hourlyRateCents;
      _client = $v.client.toBuilder();
      _location = $v.location.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HoursShift other) {
    _$v = other as _$HoursShift;
  }

  @override
  void update(void Function(HoursShiftBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  HoursShift build() => _build();

  _$HoursShift _build() {
    _$HoursShift _$result;
    try {
      _$result = _$v ??
          _$HoursShift._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'HoursShift', 'id'),
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'HoursShift', 'title'),
            startsAt: BuiltValueNullFieldError.checkNotNull(
                startsAt, r'HoursShift', 'startsAt'),
            endsAt: BuiltValueNullFieldError.checkNotNull(
                endsAt, r'HoursShift', 'endsAt'),
            hourlyRateCents: BuiltValueNullFieldError.checkNotNull(
                hourlyRateCents, r'HoursShift', 'hourlyRateCents'),
            client: client.build(),
            location: location.build(),
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
            r'HoursShift', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
