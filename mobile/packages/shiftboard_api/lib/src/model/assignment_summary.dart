//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:shiftboard_api/src/model/assignment_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'assignment_summary.g.dart';

/// A worker's claim on a shift.
///
/// Properties:
/// * [id]
/// * [status]
/// * [claimedAt]
@BuiltValue()
abstract class AssignmentSummary
    implements Built<AssignmentSummary, AssignmentSummaryBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'status')
  AssignmentStatus get status;
  // enum statusEnum {  PENDING,  CONFIRMED,  REJECTED,  CANCELLED,  COMPLETED,  NO_SHOW,  };

  @BuiltValueField(wireName: r'claimedAt')
  DateTime get claimedAt;

  AssignmentSummary._();

  factory AssignmentSummary([void updates(AssignmentSummaryBuilder b)]) =
      _$AssignmentSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AssignmentSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AssignmentSummary> get serializer =>
      _$AssignmentSummarySerializer();
}

class _$AssignmentSummarySerializer
    implements PrimitiveSerializer<AssignmentSummary> {
  @override
  final Iterable<Type> types = const [AssignmentSummary, _$AssignmentSummary];

  @override
  final String wireName = r'AssignmentSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AssignmentSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(AssignmentStatus),
    );
    yield r'claimedAt';
    yield serializers.serialize(
      object.claimedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AssignmentSummary object, {
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
    required AssignmentSummaryBuilder result,
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
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AssignmentStatus),
          ) as AssignmentStatus;
          result.status = valueDes;
          break;
        case r'claimedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.claimedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AssignmentSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AssignmentSummaryBuilder();
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
