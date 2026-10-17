//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'message_request.g.dart';

/// MessageRequest
///
/// Properties:
/// * [body]
/// * [shiftId] - The shift the message is about.
@BuiltValue()
abstract class MessageRequest
    implements Built<MessageRequest, MessageRequestBuilder> {
  @BuiltValueField(wireName: r'body')
  String get body;

  /// The shift the message is about.
  @BuiltValueField(wireName: r'shiftId')
  String? get shiftId;

  MessageRequest._();

  factory MessageRequest([void updates(MessageRequestBuilder b)]) =
      _$MessageRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MessageRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MessageRequest> get serializer =>
      _$MessageRequestSerializer();
}

class _$MessageRequestSerializer
    implements PrimitiveSerializer<MessageRequest> {
  @override
  final Iterable<Type> types = const [MessageRequest, _$MessageRequest];

  @override
  final String wireName = r'MessageRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MessageRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'body';
    yield serializers.serialize(
      object.body,
      specifiedType: const FullType(String),
    );
    if (object.shiftId != null) {
      yield r'shiftId';
      yield serializers.serialize(
        object.shiftId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MessageRequest object, {
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
    required MessageRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'body':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.body = valueDes;
          break;
        case r'shiftId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.shiftId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MessageRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MessageRequestBuilder();
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
