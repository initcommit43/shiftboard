// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'broadcast_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BroadcastResult extends BroadcastResult {
  @override
  final int recipients;

  factory _$BroadcastResult([void Function(BroadcastResultBuilder)? updates]) =>
      (BroadcastResultBuilder()..update(updates))._build();

  _$BroadcastResult._({required this.recipients}) : super._();
  @override
  BroadcastResult rebuild(void Function(BroadcastResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BroadcastResultBuilder toBuilder() => BroadcastResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BroadcastResult && recipients == other.recipients;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, recipients.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BroadcastResult')
          ..add('recipients', recipients))
        .toString();
  }
}

class BroadcastResultBuilder
    implements Builder<BroadcastResult, BroadcastResultBuilder> {
  _$BroadcastResult? _$v;

  int? _recipients;
  int? get recipients => _$this._recipients;
  set recipients(int? recipients) => _$this._recipients = recipients;

  BroadcastResultBuilder() {
    BroadcastResult._defaults(this);
  }

  BroadcastResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _recipients = $v.recipients;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BroadcastResult other) {
    _$v = other as _$BroadcastResult;
  }

  @override
  void update(void Function(BroadcastResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BroadcastResult build() => _build();

  _$BroadcastResult _build() {
    final _$result = _$v ??
        _$BroadcastResult._(
          recipients: BuiltValueNullFieldError.checkNotNull(
              recipients, r'BroadcastResult', 'recipients'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
