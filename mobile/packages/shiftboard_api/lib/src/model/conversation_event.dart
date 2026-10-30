//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:shiftboard_api/src/model/conversation_change.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'conversation_event.g.dart';

/// The `data` of a `conversation` event on the event streams. Tells which conversation changed; the client reloads it.
///
/// Properties:
/// * [conversationId]
/// * [change]
@BuiltValue()
abstract class ConversationEvent
    implements Built<ConversationEvent, ConversationEventBuilder> {
  @BuiltValueField(wireName: r'conversationId')
  String get conversationId;

  @BuiltValueField(wireName: r'change')
  ConversationChange get change;
  // enum changeEnum {  MESSAGE,  READ,  };

  ConversationEvent._();

  factory ConversationEvent([void updates(ConversationEventBuilder b)]) =
      _$ConversationEvent;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ConversationEventBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ConversationEvent> get serializer =>
      _$ConversationEventSerializer();
}

class _$ConversationEventSerializer
    implements PrimitiveSerializer<ConversationEvent> {
  @override
  final Iterable<Type> types = const [ConversationEvent, _$ConversationEvent];

  @override
  final String wireName = r'ConversationEvent';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ConversationEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'conversationId';
    yield serializers.serialize(
      object.conversationId,
      specifiedType: const FullType(String),
    );
    yield r'change';
    yield serializers.serialize(
      object.change,
      specifiedType: const FullType(ConversationChange),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ConversationEvent object, {
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
    required ConversationEventBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'conversationId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.conversationId = valueDes;
          break;
        case r'change':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ConversationChange),
          ) as ConversationChange;
          result.change = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ConversationEvent deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ConversationEventBuilder();
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
