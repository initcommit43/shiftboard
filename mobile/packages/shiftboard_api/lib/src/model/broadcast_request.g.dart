// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'broadcast_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BroadcastRequest extends BroadcastRequest {
  @override
  final String body;

  factory _$BroadcastRequest(
          [void Function(BroadcastRequestBuilder)? updates]) =>
      (BroadcastRequestBuilder()..update(updates))._build();

  _$BroadcastRequest._({required this.body}) : super._();
  @override
  BroadcastRequest rebuild(void Function(BroadcastRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BroadcastRequestBuilder toBuilder() =>
      BroadcastRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BroadcastRequest && body == other.body;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BroadcastRequest')..add('body', body))
        .toString();
  }
}

class BroadcastRequestBuilder
    implements Builder<BroadcastRequest, BroadcastRequestBuilder> {
  _$BroadcastRequest? _$v;

  String? _body;
  String? get body => _$this._body;
  set body(String? body) => _$this._body = body;

  BroadcastRequestBuilder() {
    BroadcastRequest._defaults(this);
  }

  BroadcastRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _body = $v.body;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BroadcastRequest other) {
    _$v = other as _$BroadcastRequest;
  }

  @override
  void update(void Function(BroadcastRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BroadcastRequest build() => _build();

  _$BroadcastRequest _build() {
    final _$result = _$v ??
        _$BroadcastRequest._(
          body: BuiltValueNullFieldError.checkNotNull(
              body, r'BroadcastRequest', 'body'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
