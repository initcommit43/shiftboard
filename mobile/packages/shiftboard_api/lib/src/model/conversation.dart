//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:shiftboard_api/src/model/conversation_worker.dart';
import 'package:shiftboard_api/src/model/message.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'conversation.g.dart';

/// Conversation
///
/// Properties:
/// * [id]
/// * [worker]
/// * [lastMessage]
/// * [unreadCount] - Messages of the worker nobody at the agency has read yet.
@BuiltValue()
abstract class Conversation
    implements Built<Conversation, ConversationBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'worker')
  ConversationWorker get worker;

  @BuiltValueField(wireName: r'lastMessage')
  Message get lastMessage;

  /// Messages of the worker nobody at the agency has read yet.
  @BuiltValueField(wireName: r'unreadCount')
  int get unreadCount;

  Conversation._();

  factory Conversation([void updates(ConversationBuilder b)]) = _$Conversation;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ConversationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Conversation> get serializer => _$ConversationSerializer();
}

class _$ConversationSerializer implements PrimitiveSerializer<Conversation> {
  @override
  final Iterable<Type> types = const [Conversation, _$Conversation];

  @override
  final String wireName = r'Conversation';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Conversation object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'worker';
    yield serializers.serialize(
      object.worker,
      specifiedType: const FullType(ConversationWorker),
    );
    yield r'lastMessage';
    yield serializers.serialize(
      object.lastMessage,
      specifiedType: const FullType(Message),
    );
    yield r'unreadCount';
    yield serializers.serialize(
      object.unreadCount,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Conversation object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ConversationBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'worker':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ConversationWorker),
          ) as ConversationWorker;
          result.worker.replace(valueDes);
          break;
        case r'lastMessage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Message),
          ) as Message;
          result.lastMessage.replace(valueDes);
          break;
        case r'unreadCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.unreadCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Conversation deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ConversationBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
