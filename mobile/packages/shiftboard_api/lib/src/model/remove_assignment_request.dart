//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'remove_assignment_request.g.dart';

/// RemoveAssignmentRequest
///
/// Properties:
/// * [reason]
@BuiltValue()
abstract class RemoveAssignmentRequest
    implements Built<RemoveAssignmentRequest, RemoveAssignmentRequestBuilder> {
  @BuiltValueField(wireName: r'reason')
  String get reason;

  RemoveAssignmentRequest._();

  factory RemoveAssignmentRequest(
          [void updates(RemoveAssignmentRequestBuilder b)]) =
      _$RemoveAssignmentRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RemoveAssignmentRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RemoveAssignmentRequest> get serializer =>
      _$RemoveAssignmentRequestSerializer();
}

class _$RemoveAssignmentRequestSerializer
    implements PrimitiveSerializer<RemoveAssignmentRequest> {
  @override
  final Iterable<Type> types = const [
    RemoveAssignmentRequest,
    _$RemoveAssignmentRequest
  ];

  @override
  final String wireName = r'RemoveAssignmentRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RemoveAssignmentRequest object, {
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
    RemoveAssignmentRequest object, {
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
    required RemoveAssignmentRequestBuilder result,
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
  RemoveAssignmentRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RemoveAssignmentRequestBuilder();
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
