//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'worked_hours.g.dart';

/// Approved hours of one worker on one shift.
///
/// Properties:
/// * [startedAt]
/// * [endedAt]
/// * [breakMinutes]
/// * [workedMinutes] - End minus start minus break, in whole minutes. Not rounded.
/// * [grossCents] - Worked minutes times the shift's hourly rate, in euro cents, rounded half up.
/// * [approvedAt] - When the hours were last saved.
@BuiltValue()
abstract class WorkedHours implements Built<WorkedHours, WorkedHoursBuilder> {
  @BuiltValueField(wireName: r'startedAt')
  DateTime get startedAt;

  @BuiltValueField(wireName: r'endedAt')
  DateTime get endedAt;

  @BuiltValueField(wireName: r'breakMinutes')
  int get breakMinutes;

  /// End minus start minus break, in whole minutes. Not rounded.
  @BuiltValueField(wireName: r'workedMinutes')
  int get workedMinutes;

  /// Worked minutes times the shift's hourly rate, in euro cents, rounded half up.
  @BuiltValueField(wireName: r'grossCents')
  int get grossCents;

  /// When the hours were last saved.
  @BuiltValueField(wireName: r'approvedAt')
  DateTime get approvedAt;

  WorkedHours._();

  factory WorkedHours([void updates(WorkedHoursBuilder b)]) = _$WorkedHours;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WorkedHoursBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WorkedHours> get serializer => _$WorkedHoursSerializer();
}

class _$WorkedHoursSerializer implements PrimitiveSerializer<WorkedHours> {
  @override
  final Iterable<Type> types = const [WorkedHours, _$WorkedHours];

  @override
  final String wireName = r'WorkedHours';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WorkedHours object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'startedAt';
    yield serializers.serialize(
      object.startedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'endedAt';
    yield serializers.serialize(
      object.endedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'breakMinutes';
    yield serializers.serialize(
      object.breakMinutes,
      specifiedType: const FullType(int),
    );
    yield r'workedMinutes';
    yield serializers.serialize(
      object.workedMinutes,
      specifiedType: const FullType(int),
    );
    yield r'grossCents';
    yield serializers.serialize(
      object.grossCents,
      specifiedType: const FullType(int),
    );
    yield r'approvedAt';
    yield serializers.serialize(
      object.approvedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WorkedHours object, {
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
    required WorkedHoursBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'startedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.startedAt = valueDes;
          break;
        case r'endedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.endedAt = valueDes;
          break;
        case r'breakMinutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.breakMinutes = valueDes;
          break;
        case r'workedMinutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.workedMinutes = valueDes;
          break;
        case r'grossCents':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.grossCents = valueDes;
          break;
        case r'approvedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.approvedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WorkedHours deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WorkedHoursBuilder();
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
