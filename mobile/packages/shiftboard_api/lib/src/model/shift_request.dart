//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'shift_request.g.dart';

/// ShiftRequest
///
/// Properties:
/// * [clientId]
/// * [locationId] - A location of the client.
/// * [title]
/// * [description] - What to bring, the meeting point and anything else workers need to know.
/// * [startsAt]
/// * [endsAt] - Must be after `startsAt`.
/// * [endIsEstimate] - The end is approximate; clients show it with \"ca.\".
/// * [hourlyRateCents] - Gross pay per hour in euro cents.
/// * [slots] - How many workers the shift needs.
/// * [qualificationIds] - Qualifications the shift asks for. Workers see them on the shift; a claim is not checked against them. Empty or absent means none.
/// * [publish] - Publish the shift right away instead of saving it as a draft.
@BuiltValue()
abstract class ShiftRequest
    implements Built<ShiftRequest, ShiftRequestBuilder> {
  @BuiltValueField(wireName: r'clientId')
  String get clientId;

  /// A location of the client.
  @BuiltValueField(wireName: r'locationId')
  String get locationId;

  @BuiltValueField(wireName: r'title')
  String get title;

  /// What to bring, the meeting point and anything else workers need to know.
  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'startsAt')
  DateTime get startsAt;

  /// Must be after `startsAt`.
  @BuiltValueField(wireName: r'endsAt')
  DateTime get endsAt;

  /// The end is approximate; clients show it with \"ca.\".
  @BuiltValueField(wireName: r'endIsEstimate')
  bool? get endIsEstimate;

  /// Gross pay per hour in euro cents.
  @BuiltValueField(wireName: r'hourlyRateCents')
  int get hourlyRateCents;

  /// How many workers the shift needs.
  @BuiltValueField(wireName: r'slots')
  int get slots;

  /// Qualifications the shift asks for. Workers see them on the shift; a claim is not checked against them. Empty or absent means none.
  @BuiltValueField(wireName: r'qualificationIds')
  BuiltSet<String>? get qualificationIds;

  /// Publish the shift right away instead of saving it as a draft.
  @BuiltValueField(wireName: r'publish')
  bool? get publish;

  ShiftRequest._();

  factory ShiftRequest([void updates(ShiftRequestBuilder b)]) = _$ShiftRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShiftRequestBuilder b) => b
    ..endIsEstimate = false
    ..publish = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShiftRequest> get serializer => _$ShiftRequestSerializer();
}

class _$ShiftRequestSerializer implements PrimitiveSerializer<ShiftRequest> {
  @override
  final Iterable<Type> types = const [ShiftRequest, _$ShiftRequest];

  @override
  final String wireName = r'ShiftRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShiftRequest object, {
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
    if (object.publish != null) {
      yield r'publish';
      yield serializers.serialize(
        object.publish,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ShiftRequest object, {
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
    required ShiftRequestBuilder result,
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
        case r'publish':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.publish = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ShiftRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShiftRequestBuilder();
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
