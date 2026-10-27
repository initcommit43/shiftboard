//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:shiftboard_api/src/model/shift_status.dart';
import 'package:shiftboard_api/src/model/client_shift_worker.dart';
import 'package:shiftboard_api/src/model/client_shift.dart';
import 'package:built_collection/built_collection.dart';
import 'package:shiftboard_api/src/model/location.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'client_shift_detail.g.dart';

/// ClientShiftDetail
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
/// * [description] - What the agency wrote about the shift; empty when it wrote nothing.
/// * [confirmedWorkers] - Sorted by last and first name.
@BuiltValue()
abstract class ClientShiftDetail
    implements ClientShift, Built<ClientShiftDetail, ClientShiftDetailBuilder> {
  /// What the agency wrote about the shift; empty when it wrote nothing.
  @BuiltValueField(wireName: r'description')
  String get description;

  /// Sorted by last and first name.
  @BuiltValueField(wireName: r'confirmedWorkers')
  BuiltList<ClientShiftWorker> get confirmedWorkers;

  ClientShiftDetail._();

  factory ClientShiftDetail([void updates(ClientShiftDetailBuilder b)]) =
      _$ClientShiftDetail;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ClientShiftDetailBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ClientShiftDetail> get serializer =>
      _$ClientShiftDetailSerializer();
}

class _$ClientShiftDetailSerializer
    implements PrimitiveSerializer<ClientShiftDetail> {
  @override
  final Iterable<Type> types = const [ClientShiftDetail, _$ClientShiftDetail];

  @override
  final String wireName = r'ClientShiftDetail';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ClientShiftDetail object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'confirmedCount';
    yield serializers.serialize(
      object.confirmedCount,
      specifiedType: const FullType(int),
    );
    yield r'slots';
    yield serializers.serialize(
      object.slots,
      specifiedType: const FullType(int),
    );
    yield r'description';
    yield serializers.serialize(
      object.description,
      specifiedType: const FullType(String),
    );
    yield r'startsAt';
    yield serializers.serialize(
      object.startsAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'confirmedWorkers';
    yield serializers.serialize(
      object.confirmedWorkers,
      specifiedType: const FullType(BuiltList, [FullType(ClientShiftWorker)]),
    );
    yield r'location';
    yield serializers.serialize(
      object.location,
      specifiedType: const FullType(Location),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'endIsEstimate';
    yield serializers.serialize(
      object.endIsEstimate,
      specifiedType: const FullType(bool),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'endsAt';
    yield serializers.serialize(
      object.endsAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(ShiftStatus),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ClientShiftDetail object, {
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
    required ClientShiftDetailBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'confirmedCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.confirmedCount = valueDes;
          break;
        case r'slots':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.slots = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.description = valueDes;
          break;
        case r'startsAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.startsAt = valueDes;
          break;
        case r'confirmedWorkers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(ClientShiftWorker)]),
          ) as BuiltList<ClientShiftWorker>;
          result.confirmedWorkers.replace(valueDes);
          break;
        case r'location':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Location),
          ) as Location;
          result.location.replace(valueDes);
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'endIsEstimate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.endIsEstimate = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'endsAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.endsAt = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ShiftStatus),
          ) as ShiftStatus;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ClientShiftDetail deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ClientShiftDetailBuilder();
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
