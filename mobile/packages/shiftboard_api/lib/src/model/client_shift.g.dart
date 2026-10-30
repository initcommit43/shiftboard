// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_shift.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

abstract class ClientShiftBuilder {
  void replace(ClientShift other);
  void update(void Function(ClientShiftBuilder) updates);
  String? get id;
  set id(String? id);

  String? get title;
  set title(String? title);

  ShiftStatus? get status;
  set status(ShiftStatus? status);

  LocationBuilder get location;
  set location(LocationBuilder? location);

  DateTime? get startsAt;
  set startsAt(DateTime? startsAt);

  DateTime? get endsAt;
  set endsAt(DateTime? endsAt);

  bool? get endIsEstimate;
  set endIsEstimate(bool? endIsEstimate);

  int? get slots;
  set slots(int? slots);

  int? get confirmedCount;
  set confirmedCount(int? confirmedCount);
}

class _$$ClientShift extends $ClientShift {
  @override
  final String id;
  @override
  final String title;
  @override
  final ShiftStatus status;
  @override
  final Location location;
  @override
  final DateTime startsAt;
  @override
  final DateTime endsAt;
  @override
  final bool endIsEstimate;
  @override
  final int slots;
  @override
  final int confirmedCount;

  factory _$$ClientShift([void Function($ClientShiftBuilder)? updates]) =>
      ($ClientShiftBuilder()..update(updates))._build();

  _$$ClientShift._(
      {required this.id,
      required this.title,
      required this.status,
      required this.location,
      required this.startsAt,
      required this.endsAt,
      required this.endIsEstimate,
      required this.slots,
      required this.confirmedCount})
      : super._();
  @override
  $ClientShift rebuild(void Function($ClientShiftBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  $ClientShiftBuilder toBuilder() => $ClientShiftBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is $ClientShift &&
        id == other.id &&
        title == other.title &&
        status == other.status &&
        location == other.location &&
        startsAt == other.startsAt &&
        endsAt == other.endsAt &&
        endIsEstimate == other.endIsEstimate &&
        slots == other.slots &&
        confirmedCount == other.confirmedCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, location.hashCode);
    _$hash = $jc(_$hash, startsAt.hashCode);
    _$hash = $jc(_$hash, endsAt.hashCode);
    _$hash = $jc(_$hash, endIsEstimate.hashCode);
    _$hash = $jc(_$hash, slots.hashCode);
    _$hash = $jc(_$hash, confirmedCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'$ClientShift')
          ..add('id', id)
          ..add('title', title)
          ..add('status', status)
          ..add('location', location)
          ..add('startsAt', startsAt)
          ..add('endsAt', endsAt)
          ..add('endIsEstimate', endIsEstimate)
          ..add('slots', slots)
          ..add('confirmedCount', confirmedCount))
        .toString();
  }
}

class $ClientShiftBuilder
    implements Builder<$ClientShift, $ClientShiftBuilder>, ClientShiftBuilder {
  _$$ClientShift? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(covariant String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(covariant String? title) => _$this._title = title;

  ShiftStatus? _status;
  ShiftStatus? get status => _$this._status;
  set status(covariant ShiftStatus? status) => _$this._status = status;

  LocationBuilder? _location;
  LocationBuilder get location => _$this._location ??= LocationBuilder();
  set location(covariant LocationBuilder? location) =>
      _$this._location = location;

  DateTime? _startsAt;
  DateTime? get startsAt => _$this._startsAt;
  set startsAt(covariant DateTime? startsAt) => _$this._startsAt = startsAt;

  DateTime? _endsAt;
  DateTime? get endsAt => _$this._endsAt;
  set endsAt(covariant DateTime? endsAt) => _$this._endsAt = endsAt;

  bool? _endIsEstimate;
  bool? get endIsEstimate => _$this._endIsEstimate;
  set endIsEstimate(covariant bool? endIsEstimate) =>
      _$this._endIsEstimate = endIsEstimate;

  int? _slots;
  int? get slots => _$this._slots;
  set slots(covariant int? slots) => _$this._slots = slots;

  int? _confirmedCount;
  int? get confirmedCount => _$this._confirmedCount;
  set confirmedCount(covariant int? confirmedCount) =>
      _$this._confirmedCount = confirmedCount;

  $ClientShiftBuilder() {
    $ClientShift._defaults(this);
  }

  $ClientShiftBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _status = $v.status;
      _location = $v.location.toBuilder();
      _startsAt = $v.startsAt;
      _endsAt = $v.endsAt;
      _endIsEstimate = $v.endIsEstimate;
      _slots = $v.slots;
      _confirmedCount = $v.confirmedCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant $ClientShift other) {
    _$v = other as _$$ClientShift;
  }

  @override
  void update(void Function($ClientShiftBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  $ClientShift build() => _build();

  _$$ClientShift _build() {
    _$$ClientShift _$result;
    try {
      _$result = _$v ??
          _$$ClientShift._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'$ClientShift', 'id'),
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'$ClientShift', 'title'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'$ClientShift', 'status'),
            location: location.build(),
            startsAt: BuiltValueNullFieldError.checkNotNull(
                startsAt, r'$ClientShift', 'startsAt'),
            endsAt: BuiltValueNullFieldError.checkNotNull(
                endsAt, r'$ClientShift', 'endsAt'),
            endIsEstimate: BuiltValueNullFieldError.checkNotNull(
                endIsEstimate, r'$ClientShift', 'endIsEstimate'),
            slots: BuiltValueNullFieldError.checkNotNull(
                slots, r'$ClientShift', 'slots'),
            confirmedCount: BuiltValueNullFieldError.checkNotNull(
                confirmedCount, r'$ClientShift', 'confirmedCount'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'location';
        location.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'$ClientShift', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
