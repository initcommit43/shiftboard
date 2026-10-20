//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'shift_change_request.g.dart';

/// Every field of a shift, as when creating one; the status does not change.
///
/// Properties:
/// * [clientId]
/// * [locationId] - A location of the client.
/// * [title]
/// * [description] - Absent or empty removes the description.
/// * [startsAt]
/// * [endsAt] - Must be after `startsAt`.
/// * [endIsEstimate]
/// * [hourlyRateCents] - Gross pay per hour in euro cents.
/// * [slots] - Not below the spots taken.
/// * [qualificationIds] - Empty or absent means none.
@BuiltValue()
abstract class ShiftChangeRequest
    implements Built<ShiftChangeRequest, ShiftChangeRequestBuilder> {
  @BuiltValueField(wireName: r'clientId')
  String get clientId;

  /// A location of the client.
  @BuiltValueField(wireName: r'locationId')
  String get locationId;

  @BuiltValueField(wireName: r'title')
  String get title;

  /// Absent or empty removes the description.
  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'startsAt')
  DateTime get startsAt;

  /// Must be after `startsAt`.
  @BuiltValueField(wireName: r'endsAt')
  DateTime get endsAt;

  @BuiltValueField(wireName: r'endIsEstimate')
  bool? get endIsEstimate;

  /// Gross pay per hour in euro cents.
  @BuiltValueField(wireName: r'hourlyRateCents')
  int get hourlyRateCents;

  /// Not below the spots taken.
  @BuiltValueField(wireName: r'slots')
  int get slots;

  /// Empty or absent means none.
  @BuiltValueField(wireName: r'qualificationIds')
  BuiltSet<String>? get qualificationIds;

  ShiftChangeRequest._();

  factory ShiftChangeRequest([void updates(ShiftChangeRequestBuilder b)]) =
      _$ShiftChangeRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShiftChangeRequestBuilder b) =>
      b..endIsEstimate = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShiftChangeRequest> get serializer =>
      _$ShiftChangeRequestSerializer();
}

class _$ShiftChangeRequestSerializer
    implements PrimitiveSerializer<ShiftChangeRequest> {
  @override
  final Iterable<Type> types = const [ShiftChangeRequest, _$ShiftChangeRequest];

  @override
  final String wireName = r'ShiftChangeRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShiftChangeRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'clientId';
    yield serializers.serialize(
      object.clientId,
      specifiedType: const FullType(String),
    );
    yield r'locationId';
    yield serializers.serialize(
      object.locationId,
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
    if (object.endIsEstimate != null) {
      yield r'endIsEstimate';
      yield serializers.serialize(
        object.endIsEstimate,
        specifiedType: const FullType(bool),
      );
    }
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
    if (object.qualificationIds != null) {
      yield r'qualificationIds';
      yield serializers.serialize(
        object.qualificationIds,
        specifiedType: const FullType(BuiltSet, [FullType(String)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ShiftChangeRequest object, {
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
    required ShiftChangeRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'clientId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientId = valueDes;
          break;
        case r'locationId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.locationId = valueDes;
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
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
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
        case r'qualificationIds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltSet, [FullType(String)]),
          ) as BuiltSet<String>?;
          if (valueDes == null) continue;
          result.qualificationIds.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ShiftChangeRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShiftChangeRequestBuilder();
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
