//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:shiftboard_api/src/model/cancelled_by.dart';
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
/// * [cancellableUntil] - Until when the worker can drop out in the app. Present while the assignment is pending or confirmed; may already be in the past.
/// * [cancelledBy] - Present when the status is `CANCELLED`.
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

  /// Until when the worker can drop out in the app. Present while the assignment is pending or confirmed; may already be in the past.
  @BuiltValueField(wireName: r'cancellableUntil')
  DateTime? get cancellableUntil;

  /// Present when the status is `CANCELLED`.
  @BuiltValueField(wireName: r'cancelledBy')
  CancelledBy? get cancelledBy;
  // enum cancelledByEnum {  WORKER,  AGENCY,  };

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
    if (object.cancellableUntil != null) {
      yield r'cancellableUntil';
      yield serializers.serialize(
        object.cancellableUntil,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.cancelledBy != null) {
      yield r'cancelledBy';
      yield serializers.serialize(
        object.cancelledBy,
        specifiedType: const FullType(CancelledBy),
      );
    }
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
        case r'cancellableUntil':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.cancellableUntil = valueDes;
          break;
        case r'cancelledBy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(CancelledBy),
          ) as CancelledBy?;
          if (valueDes == null) continue;
          result.cancelledBy = valueDes;
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
