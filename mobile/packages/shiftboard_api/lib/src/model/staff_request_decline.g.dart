// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_request_decline.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StaffRequestDecline extends StaffRequestDecline {
  @override
  final String reason;

  factory _$StaffRequestDecline(
          [void Function(StaffRequestDeclineBuilder)? updates]) =>
      (StaffRequestDeclineBuilder()..update(updates))._build();

  _$StaffRequestDecline._({required this.reason}) : super._();
  @override
  StaffRequestDecline rebuild(
          void Function(StaffRequestDeclineBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StaffRequestDeclineBuilder toBuilder() =>
      StaffRequestDeclineBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StaffRequestDecline && reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StaffRequestDecline')
          ..add('reason', reason))
        .toString();
  }
}

class StaffRequestDeclineBuilder
    implements Builder<StaffRequestDecline, StaffRequestDeclineBuilder> {
  _$StaffRequestDecline? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  StaffRequestDeclineBuilder() {
    StaffRequestDecline._defaults(this);
  }

  StaffRequestDeclineBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StaffRequestDecline other) {
    _$v = other as _$StaffRequestDecline;
  }

  @override
  void update(void Function(StaffRequestDeclineBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StaffRequestDecline build() => _build();

  _$StaffRequestDecline _build() {
    final _$result = _$v ??
        _$StaffRequestDecline._(
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'StaffRequestDecline', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
