// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_shift_detail.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ClientShiftDetail extends ClientShiftDetail {
  @override
  final String description;
  @override
  final BuiltList<ClientShiftWorker> confirmedWorkers;
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

  factory _$ClientShiftDetail(
          [void Function(ClientShiftDetailBuilder)? updates]) =>
      (ClientShiftDetailBuilder()..update(updates))._build();

  _$ClientShiftDetail._(
      {required this.description,
      required this.confirmedWorkers,
      required this.id,
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
  ClientShiftDetail rebuild(void Function(ClientShiftDetailBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ClientShiftDetailBuilder toBuilder() =>
      ClientShiftDetailBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClientShiftDetail &&
        description == other.description &&
        confirmedWorkers == other.confirmedWorkers &&
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
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, confirmedWorkers.hashCode);
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
    return (newBuiltValueToStringHelper(r'ClientShiftDetail')
          ..add('description', description)
          ..add('confirmedWorkers', confirmedWorkers)
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

class ClientShiftDetailBuilder
    implements
        Builder<ClientShiftDetail, ClientShiftDetailBuilder>,
        ClientShiftBuilder {
  _$ClientShiftDetail? _$v;

  String? _description;
  String? get description => _$this._description;
  set description(covariant String? description) =>
      _$this._description = description;

  ListBuilder<ClientShiftWorker>? _confirmedWorkers;
  ListBuilder<ClientShiftWorker> get confirmedWorkers =>
      _$this._confirmedWorkers ??= ListBuilder<ClientShiftWorker>();
  set confirmedWorkers(
          covariant ListBuilder<ClientShiftWorker>? confirmedWorkers) =>
      _$this._confirmedWorkers = confirmedWorkers;

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

  ClientShiftDetailBuilder() {
    ClientShiftDetail._defaults(this);
  }

  ClientShiftDetailBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _description = $v.description;
      _confirmedWorkers = $v.confirmedWorkers.toBuilder();
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
  void replace(covariant ClientShiftDetail other) {
    _$v = other as _$ClientShiftDetail;
  }

  @override
  void update(void Function(ClientShiftDetailBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ClientShiftDetail build() => _build();

  _$ClientShiftDetail _build() {
    _$ClientShiftDetail _$result;
    try {
      _$result = _$v ??
          _$ClientShiftDetail._(
            description: BuiltValueNullFieldError.checkNotNull(
                description, r'ClientShiftDetail', 'description'),
            confirmedWorkers: confirmedWorkers.build(),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'ClientShiftDetail', 'id'),
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'ClientShiftDetail', 'title'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'ClientShiftDetail', 'status'),
            location: location.build(),
            startsAt: BuiltValueNullFieldError.checkNotNull(
                startsAt, r'ClientShiftDetail', 'startsAt'),
            endsAt: BuiltValueNullFieldError.checkNotNull(
                endsAt, r'ClientShiftDetail', 'endsAt'),
            endIsEstimate: BuiltValueNullFieldError.checkNotNull(
                endIsEstimate, r'ClientShiftDetail', 'endIsEstimate'),
            slots: BuiltValueNullFieldError.checkNotNull(
                slots, r'ClientShiftDetail', 'slots'),
            confirmedCount: BuiltValueNullFieldError.checkNotNull(
                confirmedCount, r'ClientShiftDetail', 'confirmedCount'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'confirmedWorkers';
        confirmedWorkers.build();

        _$failedField = 'location';
        location.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ClientShiftDetail', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
