// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_change.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ConversationChange _$MESSAGE = const ConversationChange._('MESSAGE');
const ConversationChange _$READ = const ConversationChange._('READ');
const ConversationChange _$unknownDefaultOpenApi =
    const ConversationChange._('unknownDefaultOpenApi');

ConversationChange _$valueOf(String name) {
  switch (name) {
    case 'MESSAGE':
      return _$MESSAGE;
    case 'READ':
      return _$READ;
    case 'unknownDefaultOpenApi':
      return _$unknownDefaultOpenApi;
    default:
      return _$unknownDefaultOpenApi;
  }
}

final BuiltSet<ConversationChange> _$values =
    BuiltSet<ConversationChange>(const <ConversationChange>[
  _$MESSAGE,
  _$READ,
  _$unknownDefaultOpenApi,
]);

class _$ConversationChangeMeta {
  const _$ConversationChangeMeta();
  ConversationChange get MESSAGE => _$MESSAGE;
  ConversationChange get READ => _$READ;
  ConversationChange get unknownDefaultOpenApi => _$unknownDefaultOpenApi;
  ConversationChange valueOf(String name) => _$valueOf(name);
  BuiltSet<ConversationChange> get values => _$values;
}

abstract class _$ConversationChangeMixin {
  // ignore: non_constant_identifier_names
  _$ConversationChangeMeta get ConversationChange =>
      const _$ConversationChangeMeta();
}

Serializer<ConversationChange> _$conversationChangeSerializer =
    _$ConversationChangeSerializer();

class _$ConversationChangeSerializer
    implements PrimitiveSerializer<ConversationChange> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'MESSAGE': 'MESSAGE',
    'READ': 'READ',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'MESSAGE': 'MESSAGE',
    'READ': 'READ',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[ConversationChange];
  @override
  final String wireName = 'ConversationChange';

  @override
  Object serialize(Serializers serializers, ConversationChange object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ConversationChange deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ConversationChange.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
