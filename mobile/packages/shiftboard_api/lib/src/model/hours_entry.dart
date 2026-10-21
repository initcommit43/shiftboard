//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:shiftboard_api/src/model/hours_shift.dart';
import 'package:shiftboard_api/src/model/hours_status.dart';
import 'package:shiftboard_api/src/model/assigned_worker.dart';
import 'package:shiftboard_api/src/model/worked_hours.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'hours_entry.g.dart';

/// The hours of one worker on one shift.
///
/// Properties:
/// * [assignmentId]
/// * [status]
/// * [shift]
/// * [worker]
/// * [checkedInAt]
/// * [checkedOutAt]
/// * [hours] - Present when the status is `APPROVED`.
@BuiltValue()
abstract class HoursEntry implements Built<HoursEntry, HoursEntryBuilder> {
  @BuiltValueField(wireName: r'assignmentId')
  String get assignmentId;

  @BuiltValueField(wireName: r'status')
  HoursStatus get status;
  // enum statusEnum {  OPEN,  APPROVED,  };

  @BuiltValueField(wireName: r'shift')
  HoursShift get shift;

  @BuiltValueField(wireName: r'worker')
  AssignedWorker get worker;

  @BuiltValueField(wireName: r'checkedInAt')
  DateTime? get checkedInAt;

  @BuiltValueField(wireName: r'checkedOutAt')
  DateTime? get checkedOutAt;

  /// Present when the status is `APPROVED`.
  @BuiltValueField(wireName: r'hours')
  WorkedHours? get hours;

  HoursEntry._();

  factory HoursEntry([void updates(HoursEntryBuilder b)]) = _$HoursEntry;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HoursEntryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<HoursEntry> get serializer => _$HoursEntrySerializer();
}

class _$HoursEntrySerializer implements PrimitiveSerializer<HoursEntry> {
  @override
  final Iterable<Type> types = const [HoursEntry, _$HoursEntry];

  @override
  final String wireName = r'HoursEntry';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HoursEntry object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'assignmentId';
    yield serializers.serialize(
      object.assignmentId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(HoursStatus),
    );
    yield r'shift';
    yield serializers.serialize(
      object.shift,
      specifiedType: const FullType(HoursShift),
    );
    yield r'worker';
    yield serializers.serialize(
      object.worker,
      specifiedType: const FullType(AssignedWorker),
    );
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
    HoursEntry object, {
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
    required HoursEntryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'assignmentId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.assignmentId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(HoursStatus),
          ) as HoursStatus;
          result.status = valueDes;
          break;
        case r'shift':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(HoursShift),
          ) as HoursShift;
          result.shift.replace(valueDes);
          break;
        case r'worker':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AssignedWorker),
          ) as AssignedWorker;
          result.worker.replace(valueDes);
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
  HoursEntry deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HoursEntryBuilder();
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
