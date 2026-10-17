//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'broadcast_request.g.dart';

/// BroadcastRequest
///
/// Properties:
/// * [body]
@BuiltValue()
abstract class BroadcastRequest
    implements Built<BroadcastRequest, BroadcastRequestBuilder> {
  @BuiltValueField(wireName: r'body')
  String get body;

  BroadcastRequest._();

  factory BroadcastRequest([void updates(BroadcastRequestBuilder b)]) =
      _$BroadcastRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BroadcastRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BroadcastRequest> get serializer =>
      _$BroadcastRequestSerializer();
}

class _$BroadcastRequestSerializer
    implements PrimitiveSerializer<BroadcastRequest> {
  @override
  final Iterable<Type> types = const [BroadcastRequest, _$BroadcastRequest];

  @override
  final String wireName = r'BroadcastRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BroadcastRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'body';
    yield serializers.serialize(
      object.body,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BroadcastRequest object, {
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
    required BroadcastRequestBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BroadcastRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BroadcastRequestBuilder();
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
