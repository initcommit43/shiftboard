//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'staff_request_decline.g.dart';

/// StaffRequestDecline
///
/// Properties:
/// * [reason] - Shown to the client.
@BuiltValue()
abstract class StaffRequestDecline
    implements Built<StaffRequestDecline, StaffRequestDeclineBuilder> {
  /// Shown to the client.
  @BuiltValueField(wireName: r'reason')
  String get reason;

  StaffRequestDecline._();

  factory StaffRequestDecline([void updates(StaffRequestDeclineBuilder b)]) =
      _$StaffRequestDecline;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StaffRequestDeclineBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StaffRequestDecline> get serializer =>
      _$StaffRequestDeclineSerializer();
}

class _$StaffRequestDeclineSerializer
    implements PrimitiveSerializer<StaffRequestDecline> {
  @override
  final Iterable<Type> types = const [
    StaffRequestDecline,
    _$StaffRequestDecline
  ];

  @override
  final String wireName = r'StaffRequestDecline';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StaffRequestDecline object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    StaffRequestDecline object, {
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
    required StaffRequestDeclineBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StaffRequestDecline deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StaffRequestDeclineBuilder();
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
