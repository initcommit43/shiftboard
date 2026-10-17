// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unread_count.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UnreadCount extends UnreadCount {
  @override
  final int unreadCount;

  factory _$UnreadCount([void Function(UnreadCountBuilder)? updates]) =>
      (UnreadCountBuilder()..update(updates))._build();

  _$UnreadCount._({required this.unreadCount}) : super._();
  @override
  UnreadCount rebuild(void Function(UnreadCountBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UnreadCountBuilder toBuilder() => UnreadCountBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UnreadCount && unreadCount == other.unreadCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, unreadCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UnreadCount')
          ..add('unreadCount', unreadCount))
        .toString();
  }
}

class UnreadCountBuilder implements Builder<UnreadCount, UnreadCountBuilder> {
  _$UnreadCount? _$v;

  int? _unreadCount;
  int? get unreadCount => _$this._unreadCount;
  set unreadCount(int? unreadCount) => _$this._unreadCount = unreadCount;

  UnreadCountBuilder() {
    UnreadCount._defaults(this);
  }

  UnreadCountBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _unreadCount = $v.unreadCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UnreadCount other) {
    _$v = other as _$UnreadCount;
  }

  @override
  void update(void Function(UnreadCountBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UnreadCount build() => _build();

  _$UnreadCount _build() {
    final _$result = _$v ??
        _$UnreadCount._(
          unreadCount: BuiltValueNullFieldError.checkNotNull(
              unreadCount, r'UnreadCount', 'unreadCount'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
