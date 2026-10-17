//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'broadcast_result.g.dart';

/// BroadcastResult
///
/// Properties:
/// * [recipients] - How many confirmed workers got the message.
@BuiltValue()
abstract class BroadcastResult
    implements Built<BroadcastResult, BroadcastResultBuilder> {
  /// How many confirmed workers got the message.
  @BuiltValueField(wireName: r'recipients')
  int get recipients;

  BroadcastResult._();

  factory BroadcastResult([void updates(BroadcastResultBuilder b)]) =
      _$BroadcastResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BroadcastResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BroadcastResult> get serializer =>
      _$BroadcastResultSerializer();
}

class _$BroadcastResultSerializer
    implements PrimitiveSerializer<BroadcastResult> {
  @override
  final Iterable<Type> types = const [BroadcastResult, _$BroadcastResult];

  @override
  final String wireName = r'BroadcastResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BroadcastResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'recipients';
    yield serializers.serialize(
      object.recipients,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BroadcastResult object, {
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
    required BroadcastResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'recipients':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.recipients = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BroadcastResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BroadcastResultBuilder();
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
