// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remove_assignment_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RemoveAssignmentRequest extends RemoveAssignmentRequest {
  @override
  final String reason;

  factory _$RemoveAssignmentRequest(
          [void Function(RemoveAssignmentRequestBuilder)? updates]) =>
      (RemoveAssignmentRequestBuilder()..update(updates))._build();

  _$RemoveAssignmentRequest._({required this.reason}) : super._();
  @override
  RemoveAssignmentRequest rebuild(
          void Function(RemoveAssignmentRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RemoveAssignmentRequestBuilder toBuilder() =>
      RemoveAssignmentRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RemoveAssignmentRequest && reason == other.reason;
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
    return (newBuiltValueToStringHelper(r'RemoveAssignmentRequest')
          ..add('reason', reason))
        .toString();
  }
}

class RemoveAssignmentRequestBuilder
    implements
        Builder<RemoveAssignmentRequest, RemoveAssignmentRequestBuilder> {
  _$RemoveAssignmentRequest? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  RemoveAssignmentRequestBuilder() {
    RemoveAssignmentRequest._defaults(this);
  }

  RemoveAssignmentRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RemoveAssignmentRequest other) {
    _$v = other as _$RemoveAssignmentRequest;
  }

  @override
  void update(void Function(RemoveAssignmentRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RemoveAssignmentRequest build() => _build();

  _$RemoveAssignmentRequest _build() {
    final _$result = _$v ??
        _$RemoveAssignmentRequest._(
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'RemoveAssignmentRequest', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
