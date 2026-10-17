// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MessageRequest extends MessageRequest {
  @override
  final String body;
  @override
  final String? shiftId;

  factory _$MessageRequest([void Function(MessageRequestBuilder)? updates]) =>
      (MessageRequestBuilder()..update(updates))._build();

  _$MessageRequest._({required this.body, this.shiftId}) : super._();
  @override
  MessageRequest rebuild(void Function(MessageRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MessageRequestBuilder toBuilder() => MessageRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MessageRequest &&
        body == other.body &&
        shiftId == other.shiftId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jc(_$hash, shiftId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MessageRequest')
          ..add('body', body)
          ..add('shiftId', shiftId))
        .toString();
  }
}

class MessageRequestBuilder
    implements Builder<MessageRequest, MessageRequestBuilder> {
  _$MessageRequest? _$v;

  String? _body;
  String? get body => _$this._body;
  set body(String? body) => _$this._body = body;

  String? _shiftId;
  String? get shiftId => _$this._shiftId;
  set shiftId(String? shiftId) => _$this._shiftId = shiftId;

  MessageRequestBuilder() {
    MessageRequest._defaults(this);
  }

  MessageRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _body = $v.body;
      _shiftId = $v.shiftId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MessageRequest other) {
    _$v = other as _$MessageRequest;
  }

  @override
  void update(void Function(MessageRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MessageRequest build() => _build();

  _$MessageRequest _build() {
    final _$result = _$v ??
        _$MessageRequest._(
          body: BuiltValueNullFieldError.checkNotNull(
              body, r'MessageRequest', 'body'),
          shiftId: shiftId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
