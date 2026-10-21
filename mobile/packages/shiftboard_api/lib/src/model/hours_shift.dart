//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:shiftboard_api/src/model/client_summary.dart';
import 'package:shiftboard_api/src/model/location.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'hours_shift.g.dart';

/// The shift of an hours entry.
///
/// Properties:
/// * [id]
/// * [title]
/// * [startsAt]
/// * [endsAt]
/// * [hourlyRateCents]
/// * [client]
/// * [location]
@BuiltValue()
abstract class HoursShift implements Built<HoursShift, HoursShiftBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'startsAt')
  DateTime get startsAt;

  @BuiltValueField(wireName: r'endsAt')
  DateTime get endsAt;

  @BuiltValueField(wireName: r'hourlyRateCents')
  int get hourlyRateCents;

  @BuiltValueField(wireName: r'client')
  ClientSummary get client;

  @BuiltValueField(wireName: r'location')
  Location get location;

  HoursShift._();

  factory HoursShift([void updates(HoursShiftBuilder b)]) = _$HoursShift;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HoursShiftBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<HoursShift> get serializer => _$HoursShiftSerializer();
}

class _$HoursShiftSerializer implements PrimitiveSerializer<HoursShift> {
  @override
  final Iterable<Type> types = const [HoursShift, _$HoursShift];

  @override
  final String wireName = r'HoursShift';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HoursShift object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'startsAt';
    yield serializers.serialize(
      object.startsAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'endsAt';
    yield serializers.serialize(
      object.endsAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'hourlyRateCents';
    yield serializers.serialize(
      object.hourlyRateCents,
      specifiedType: const FullType(int),
    );
    yield r'client';
    yield serializers.serialize(
      object.client,
      specifiedType: const FullType(ClientSummary),
    );
    yield r'location';
    yield serializers.serialize(
      object.location,
      specifiedType: const FullType(Location),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    HoursShift object, {
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
    required HoursShiftBuilder result,
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
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'startsAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.startsAt = valueDes;
          break;
        case r'endsAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.endsAt = valueDes;
          break;
        case r'hourlyRateCents':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.hourlyRateCents = valueDes;
          break;
        case r'client':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ClientSummary),
          ) as ClientSummary;
          result.client.replace(valueDes);
          break;
        case r'location':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Location),
          ) as Location;
          result.location.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  HoursShift deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HoursShiftBuilder();
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
