// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agency_settings.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AgencySettings extends AgencySettings {
  @override
  final bool autoConfirm;
  @override
  final int cancellationDeadlineHours;
  @override
  final bool? waitlist;

  factory _$AgencySettings([void Function(AgencySettingsBuilder)? updates]) =>
      (AgencySettingsBuilder()..update(updates))._build();

  _$AgencySettings._(
      {required this.autoConfirm,
      required this.cancellationDeadlineHours,
      this.waitlist})
      : super._();
  @override
  AgencySettings rebuild(void Function(AgencySettingsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AgencySettingsBuilder toBuilder() => AgencySettingsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AgencySettings &&
        autoConfirm == other.autoConfirm &&
        cancellationDeadlineHours == other.cancellationDeadlineHours &&
        waitlist == other.waitlist;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, autoConfirm.hashCode);
    _$hash = $jc(_$hash, cancellationDeadlineHours.hashCode);
    _$hash = $jc(_$hash, waitlist.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AgencySettings')
          ..add('autoConfirm', autoConfirm)
          ..add('cancellationDeadlineHours', cancellationDeadlineHours)
          ..add('waitlist', waitlist))
        .toString();
  }
}

class AgencySettingsBuilder
    implements Builder<AgencySettings, AgencySettingsBuilder> {
  _$AgencySettings? _$v;

  bool? _autoConfirm;
  bool? get autoConfirm => _$this._autoConfirm;
  set autoConfirm(bool? autoConfirm) => _$this._autoConfirm = autoConfirm;

  int? _cancellationDeadlineHours;
  int? get cancellationDeadlineHours => _$this._cancellationDeadlineHours;
  set cancellationDeadlineHours(int? cancellationDeadlineHours) =>
      _$this._cancellationDeadlineHours = cancellationDeadlineHours;

  bool? _waitlist;
  bool? get waitlist => _$this._waitlist;
  set waitlist(bool? waitlist) => _$this._waitlist = waitlist;

  AgencySettingsBuilder() {
    AgencySettings._defaults(this);
  }

  AgencySettingsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _autoConfirm = $v.autoConfirm;
      _cancellationDeadlineHours = $v.cancellationDeadlineHours;
      _waitlist = $v.waitlist;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AgencySettings other) {
    _$v = other as _$AgencySettings;
  }

  @override
  void update(void Function(AgencySettingsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AgencySettings build() => _build();

  _$AgencySettings _build() {
    final _$result = _$v ??
        _$AgencySettings._(
          autoConfirm: BuiltValueNullFieldError.checkNotNull(
              autoConfirm, r'AgencySettings', 'autoConfirm'),
          cancellationDeadlineHours: BuiltValueNullFieldError.checkNotNull(
              cancellationDeadlineHours,
              r'AgencySettings',
              'cancellationDeadlineHours'),
          waitlist: waitlist,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
