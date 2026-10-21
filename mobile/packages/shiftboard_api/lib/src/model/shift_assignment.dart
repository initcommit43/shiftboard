//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:shiftboard_api/src/model/cancelled_by.dart';
import 'package:shiftboard_api/src/model/assignment_status.dart';
import 'package:shiftboard_api/src/model/assigned_worker.dart';
import 'package:shiftboard_api/src/model/worked_hours.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'shift_assignment.g.dart';

/// A claim on a shift as the agency sees it.
///
/// Properties:
/// * [id]
/// * [status]
/// * [worker]
/// * [claimedAt]
/// * [decidedAt] - When the claim was last decided on, cancelled or completed. Absent while pending.
/// * [cancelledBy] - Present when the status is `CANCELLED`.
/// * [reason] - Why the agency removed the worker. Present only for a removal.
/// * [checkedInAt] - When the worker checked in in the app.
/// * [checkedOutAt] - When the worker checked out in the app.
/// * [hours] - The approved hours. Absent until the agency approved them.
@BuiltValue()
abstract class ShiftAssignment
    implements Built<ShiftAssignment, ShiftAssignmentBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'status')
  AssignmentStatus get status;
  // enum statusEnum {  PENDING,  CONFIRMED,  REJECTED,  CANCELLED,  COMPLETED,  NO_SHOW,  };

  @BuiltValueField(wireName: r'worker')
  AssignedWorker get worker;

  @BuiltValueField(wireName: r'claimedAt')
  DateTime get claimedAt;

  /// When the claim was last decided on, cancelled or completed. Absent while pending.
  @BuiltValueField(wireName: r'decidedAt')
  DateTime? get decidedAt;

  /// Present when the status is `CANCELLED`.
  @BuiltValueField(wireName: r'cancelledBy')
  CancelledBy? get cancelledBy;
  // enum cancelledByEnum {  WORKER,  AGENCY,  };

  /// Why the agency removed the worker. Present only for a removal.
  @BuiltValueField(wireName: r'reason')
  String? get reason;

  /// When the worker checked in in the app.
  @BuiltValueField(wireName: r'checkedInAt')
  DateTime? get checkedInAt;

  /// When the worker checked out in the app.
  @BuiltValueField(wireName: r'checkedOutAt')
  DateTime? get checkedOutAt;

  /// The approved hours. Absent until the agency approved them.
  @BuiltValueField(wireName: r'hours')
  WorkedHours? get hours;

  ShiftAssignment._();

  factory ShiftAssignment([void updates(ShiftAssignmentBuilder b)]) =
      _$ShiftAssignment;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShiftAssignmentBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShiftAssignment> get serializer =>
      _$ShiftAssignmentSerializer();
}

class _$ShiftAssignmentSerializer
    implements PrimitiveSerializer<ShiftAssignment> {
  @override
  final Iterable<Type> types = const [ShiftAssignment, _$ShiftAssignment];

  @override
  final String wireName = r'ShiftAssignment';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShiftAssignment object, {
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
    yield r'worker';
    yield serializers.serialize(
      object.worker,
      specifiedType: const FullType(AssignedWorker),
    );
    yield r'claimedAt';
    yield serializers.serialize(
      object.claimedAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.decidedAt != null) {
      yield r'decidedAt';
      yield serializers.serialize(
        object.decidedAt,
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
    if (object.reason != null) {
      yield r'reason';
      yield serializers.serialize(
        object.reason,
        specifiedType: const FullType(String),
      );
    }
    if (object.checkedInAt != null) {
      yield r'checkedInAt';
      yield serializers.serialize(
        object.checkedInAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.checkedOutAt != null) {
      yield r'checkedOutAt';
      yield serializers.serialize(
        object.checkedOutAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.hours != null) {
      yield r'hours';
      yield serializers.serialize(
        object.hours,
        specifiedType: const FullType(WorkedHours),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ShiftAssignment object, {
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
    required ShiftAssignmentBuilder result,
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
        case r'worker':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AssignedWorker),
          ) as AssignedWorker;
          result.worker.replace(valueDes);
          break;
        case r'claimedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.claimedAt = valueDes;
          break;
        case r'decidedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.decidedAt = valueDes;
          break;
        case r'cancelledBy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(CancelledBy),
          ) as CancelledBy?;
          if (valueDes == null) continue;
          result.cancelledBy = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        case r'checkedInAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.checkedInAt = valueDes;
          break;
        case r'checkedOutAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.checkedOutAt = valueDes;
          break;
        case r'hours':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(WorkedHours),
          ) as WorkedHours?;
          if (valueDes == null) continue;
          result.hours.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ShiftAssignment deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShiftAssignmentBuilder();
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
