//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:shiftboard_api/src/model/shift_status.dart';
import 'package:shiftboard_api/src/model/client_summary.dart';
import 'package:built_collection/built_collection.dart';
import 'package:shiftboard_api/src/model/location.dart';
import 'package:shiftboard_api/src/model/qualification.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'shift.g.dart';

/// Shift
///
/// Properties:
/// * [id]
/// * [title]
/// * [description]
/// * [status]
/// * [client]
/// * [location]
/// * [startsAt]
/// * [endsAt]
/// * [endIsEstimate]
/// * [hourlyRateCents] - Gross pay per hour in euro cents.
/// * [slots] - How many workers the shift needs.
/// * [takenSlots] - How many of the slots are claimed.
/// * [qualifications] - Qualifications a worker needs to claim the shift.
/// * [createdAt]
@BuiltValue()
abstract class Shift implements Built<Shift, ShiftBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'status')
  ShiftStatus get status;
  // enum statusEnum {  DRAFT,  PUBLISHED,  COMPLETED,  CANCELLED,  };

  @BuiltValueField(wireName: r'client')
  ClientSummary get client;

  @BuiltValueField(wireName: r'location')
  Location get location;

  @BuiltValueField(wireName: r'startsAt')
  DateTime get startsAt;

  @BuiltValueField(wireName: r'endsAt')
  DateTime get endsAt;

  @BuiltValueField(wireName: r'endIsEstimate')
  bool get endIsEstimate;

  /// Gross pay per hour in euro cents.
  @BuiltValueField(wireName: r'hourlyRateCents')
  int get hourlyRateCents;

  /// How many workers the shift needs.
  @BuiltValueField(wireName: r'slots')
  int get slots;

  /// How many of the slots are claimed.
  @BuiltValueField(wireName: r'takenSlots')
  int get takenSlots;

  /// Qualifications a worker needs to claim the shift.
  @BuiltValueField(wireName: r'qualifications')
  BuiltList<Qualification> get qualifications;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  Shift._();

  factory Shift([void updates(ShiftBuilder b)]) = _$Shift;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShiftBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Shift> get serializer => _$ShiftSerializer();
}

class _$ShiftSerializer implements PrimitiveSerializer<Shift> {
  @override
  final Iterable<Type> types = const [Shift, _$Shift];

  @override
  final String wireName = r'Shift';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Shift object, {
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
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      );
    }
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(ShiftStatus),
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
    yield r'endIsEstimate';
    yield serializers.serialize(
      object.endIsEstimate,
      specifiedType: const FullType(bool),
    );
    yield r'hourlyRateCents';
    yield serializers.serialize(
      object.hourlyRateCents,
      specifiedType: const FullType(int),
    );
    yield r'slots';
    yield serializers.serialize(
      object.slots,
      specifiedType: const FullType(int),
    );
    yield r'takenSlots';
    yield serializers.serialize(
      object.takenSlots,
      specifiedType: const FullType(int),
    );
    yield r'qualifications';
    yield serializers.serialize(
      object.qualifications,
      specifiedType: const FullType(BuiltList, [FullType(Qualification)]),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Shift object, {
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
    required ShiftBuilder result,
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
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ShiftStatus),
          ) as ShiftStatus;
          result.status = valueDes;
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
        case r'endIsEstimate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.endIsEstimate = valueDes;
          break;
        case r'hourlyRateCents':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.hourlyRateCents = valueDes;
          break;
        case r'slots':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.slots = valueDes;
          break;
        case r'takenSlots':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.takenSlots = valueDes;
          break;
        case r'qualifications':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Qualification)]),
          ) as BuiltList<Qualification>;
          result.qualifications.replace(valueDes);
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Shift deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShiftBuilder();
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
