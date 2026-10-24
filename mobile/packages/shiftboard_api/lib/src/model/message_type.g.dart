// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_type.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MessageType _$TEXT = const MessageType._('TEXT');
const MessageType _$SYSTEM = const MessageType._('SYSTEM');
const MessageType _$BROADCAST = const MessageType._('BROADCAST');
const MessageType _$unknownDefaultOpenApi =
    const MessageType._('unknownDefaultOpenApi');

MessageType _$valueOf(String name) {
  switch (name) {
    case 'TEXT':
      return _$TEXT;
    case 'SYSTEM':
      return _$SYSTEM;
    case 'BROADCAST':
      return _$BROADCAST;
    case 'unknownDefaultOpenApi':
      return _$unknownDefaultOpenApi;
    default:
      return _$unknownDefaultOpenApi;
  }
}

final BuiltSet<MessageType> _$values =
    BuiltSet<MessageType>(const <MessageType>[
  _$TEXT,
  _$SYSTEM,
  _$BROADCAST,
  _$unknownDefaultOpenApi,
]);

class _$MessageTypeMeta {
  const _$MessageTypeMeta();
  MessageType get TEXT => _$TEXT;
  MessageType get SYSTEM => _$SYSTEM;
  MessageType get BROADCAST => _$BROADCAST;
  MessageType get unknownDefaultOpenApi => _$unknownDefaultOpenApi;
  MessageType valueOf(String name) => _$valueOf(name);
  BuiltSet<MessageType> get values => _$values;
}

abstract class _$MessageTypeMixin {
  // ignore: non_constant_identifier_names
  _$MessageTypeMeta get MessageType => const _$MessageTypeMeta();
}

Serializer<MessageType> _$messageTypeSerializer = _$MessageTypeSerializer();

class _$MessageTypeSerializer implements PrimitiveSerializer<MessageType> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'TEXT': 'TEXT',
    'SYSTEM': 'SYSTEM',
    'BROADCAST': 'BROADCAST',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'TEXT': 'TEXT',
    'SYSTEM': 'SYSTEM',
    'BROADCAST': 'BROADCAST',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[MessageType];
  @override
  final String wireName = 'MessageType';

  @override
  Object serialize(Serializers serializers, MessageType object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MessageType deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MessageType.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
