// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NotificationSettings extends NotificationSettings {
  @override
  final bool newShiftsPaused;

  factory _$NotificationSettings(
          [void Function(NotificationSettingsBuilder)? updates]) =>
      (NotificationSettingsBuilder()..update(updates))._build();

  _$NotificationSettings._({required this.newShiftsPaused}) : super._();
  @override
  NotificationSettings rebuild(
          void Function(NotificationSettingsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NotificationSettingsBuilder toBuilder() =>
      NotificationSettingsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationSettings &&
        newShiftsPaused == other.newShiftsPaused;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, newShiftsPaused.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NotificationSettings')
          ..add('newShiftsPaused', newShiftsPaused))
        .toString();
  }
}

class NotificationSettingsBuilder
    implements Builder<NotificationSettings, NotificationSettingsBuilder> {
  _$NotificationSettings? _$v;

  bool? _newShiftsPaused;
  bool? get newShiftsPaused => _$this._newShiftsPaused;
  set newShiftsPaused(bool? newShiftsPaused) =>
      _$this._newShiftsPaused = newShiftsPaused;

  NotificationSettingsBuilder() {
    NotificationSettings._defaults(this);
  }

  NotificationSettingsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _newShiftsPaused = $v.newShiftsPaused;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationSettings other) {
    _$v = other as _$NotificationSettings;
  }

  @override
  void update(void Function(NotificationSettingsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationSettings build() => _build();

  _$NotificationSettings _build() {
    final _$result = _$v ??
        _$NotificationSettings._(
          newShiftsPaused: BuiltValueNullFieldError.checkNotNull(
              newShiftsPaused, r'NotificationSettings', 'newShiftsPaused'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
