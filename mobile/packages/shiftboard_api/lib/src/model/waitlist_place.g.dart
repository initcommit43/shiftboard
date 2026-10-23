// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'waitlist_place.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WaitlistPlace extends WaitlistPlace {
  @override
  final int position;
  @override
  final DateTime joinedAt;

  factory _$WaitlistPlace([void Function(WaitlistPlaceBuilder)? updates]) =>
      (WaitlistPlaceBuilder()..update(updates))._build();

  _$WaitlistPlace._({required this.position, required this.joinedAt})
      : super._();
  @override
  WaitlistPlace rebuild(void Function(WaitlistPlaceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WaitlistPlaceBuilder toBuilder() => WaitlistPlaceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WaitlistPlace &&
        position == other.position &&
        joinedAt == other.joinedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, position.hashCode);
    _$hash = $jc(_$hash, joinedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WaitlistPlace')
          ..add('position', position)
          ..add('joinedAt', joinedAt))
        .toString();
  }
}

class WaitlistPlaceBuilder
    implements Builder<WaitlistPlace, WaitlistPlaceBuilder> {
  _$WaitlistPlace? _$v;

  int? _position;
  int? get position => _$this._position;
  set position(int? position) => _$this._position = position;

  DateTime? _joinedAt;
  DateTime? get joinedAt => _$this._joinedAt;
  set joinedAt(DateTime? joinedAt) => _$this._joinedAt = joinedAt;

  WaitlistPlaceBuilder() {
    WaitlistPlace._defaults(this);
  }

  WaitlistPlaceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _position = $v.position;
      _joinedAt = $v.joinedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WaitlistPlace other) {
    _$v = other as _$WaitlistPlace;
  }

  @override
  void update(void Function(WaitlistPlaceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WaitlistPlace build() => _build();

  _$WaitlistPlace _build() {
    final _$result = _$v ??
        _$WaitlistPlace._(
          position: BuiltValueNullFieldError.checkNotNull(
              position, r'WaitlistPlace', 'position'),
          joinedAt: BuiltValueNullFieldError.checkNotNull(
              joinedAt, r'WaitlistPlace', 'joinedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
