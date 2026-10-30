//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:shiftboard_api/src/model/shift_status.dart';
import 'package:shiftboard_api/src/model/location.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'client_shift.g.dart';

/// A shift as the client sees it: no hourly rate, no requests or waitlist (ADR 0032).
///
/// Properties:
/// * [id]
/// * [title]
/// * [status] - Never `DRAFT`.
/// * [location]
/// * [startsAt]
/// * [endsAt]
/// * [endIsEstimate]
/// * [slots]
/// * [confirmedCount] - Workers confirmed for the shift; pending requests don't count.
@BuiltValue(instantiable: false)
abstract class ClientShift {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'title')
  String get title;

  /// Never `DRAFT`.
  @BuiltValueField(wireName: r'status')
  ShiftStatus get status;
  // enum statusEnum {  DRAFT,  PUBLISHED,  COMPLETED,  CANCELLED,  };

  @BuiltValueField(wireName: r'location')
  Location get location;

  @BuiltValueField(wireName: r'startsAt')
  DateTime get startsAt;

  @BuiltValueField(wireName: r'endsAt')
  DateTime get endsAt;

  @BuiltValueField(wireName: r'endIsEstimate')
  bool get endIsEstimate;

  @BuiltValueField(wireName: r'slots')
  int get slots;

  /// Workers confirmed for the shift; pending requests don't count.
  @BuiltValueField(wireName: r'confirmedCount')
  int get confirmedCount;

  @BuiltValueSerializer(custom: true)
  static Serializer<ClientShift> get serializer => _$ClientShiftSerializer();
}

class _$ClientShiftSerializer implements PrimitiveSerializer<ClientShift> {
  @override
  final Iterable<Type> types = const [ClientShift];

  @override
  final String wireName = r'ClientShift';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ClientShift object, {
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
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(ShiftStatus),
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
    yield r'slots';
    yield serializers.serialize(
      object.slots,
      specifiedType: const FullType(int),
    );
    yield r'confirmedCount';
    yield serializers.serialize(
      object.confirmedCount,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ClientShift object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  @override
  ClientShift deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.deserialize(serialized,
        specifiedType: FullType($ClientShift)) as $ClientShift;
  }
}

/// a concrete implementation of [ClientShift], since [ClientShift] is not instantiable
@BuiltValue(instantiable: true)
abstract class $ClientShift
    implements ClientShift, Built<$ClientShift, $ClientShiftBuilder> {
  $ClientShift._();

  factory $ClientShift([void Function($ClientShiftBuilder)? updates]) =
      _$$ClientShift;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults($ClientShiftBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<$ClientShift> get serializer => _$$ClientShiftSerializer();
}

class _$$ClientShiftSerializer implements PrimitiveSerializer<$ClientShift> {
  @override
  final Iterable<Type> types = const [$ClientShift, _$$ClientShift];

  @override
  final String wireName = r'$ClientShift';

  @override
  Object serialize(
    Serializers serializers,
    $ClientShift object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.serialize(object, specifiedType: FullType(ClientShift))!;
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ClientShiftBuilder result,
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
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ShiftStatus),
          ) as ShiftStatus;
          result.status = valueDes;
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
        case r'slots':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.slots = valueDes;
          break;
        case r'confirmedCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.confirmedCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  $ClientShift deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = $ClientShiftBuilder();
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
