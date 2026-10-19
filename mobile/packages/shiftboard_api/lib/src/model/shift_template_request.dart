//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'shift_template_request.g.dart';

/// ShiftTemplateRequest
///
/// Properties:
/// * [name] - Unique within the agency, ignoring case.
/// * [clientId]
/// * [locationId] - A location of the client.
/// * [title]
/// * [description]
/// * [startTime] - Local time of day the shift starts, `hh:mm`. Clients turn it into a point in time on the date the dispatcher picks.
/// * [durationMinutes] - How long the shift runs. A shift that runs past midnight ends on the next day.
/// * [endIsEstimate]
/// * [hourlyRateCents] - Gross pay per hour in euro cents.
/// * [slots]
/// * [qualificationIds] - Empty or absent means none.
@BuiltValue()
abstract class ShiftTemplateRequest
    implements Built<ShiftTemplateRequest, ShiftTemplateRequestBuilder> {
  /// Unique within the agency, ignoring case.
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'clientId')
  String get clientId;

  /// A location of the client.
  @BuiltValueField(wireName: r'locationId')
  String get locationId;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'description')
  String? get description;

  /// Local time of day the shift starts, `hh:mm`. Clients turn it into a point in time on the date the dispatcher picks.
  @BuiltValueField(wireName: r'startTime')
  String get startTime;

  /// How long the shift runs. A shift that runs past midnight ends on the next day.
  @BuiltValueField(wireName: r'durationMinutes')
  int get durationMinutes;

  @BuiltValueField(wireName: r'endIsEstimate')
  bool? get endIsEstimate;

  /// Gross pay per hour in euro cents.
  @BuiltValueField(wireName: r'hourlyRateCents')
  int get hourlyRateCents;

  @BuiltValueField(wireName: r'slots')
  int get slots;

  /// Empty or absent means none.
  @BuiltValueField(wireName: r'qualificationIds')
  BuiltSet<String>? get qualificationIds;

  ShiftTemplateRequest._();

  factory ShiftTemplateRequest([void updates(ShiftTemplateRequestBuilder b)]) =
      _$ShiftTemplateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShiftTemplateRequestBuilder b) =>
      b..endIsEstimate = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShiftTemplateRequest> get serializer =>
      _$ShiftTemplateRequestSerializer();
}

class _$ShiftTemplateRequestSerializer
    implements PrimitiveSerializer<ShiftTemplateRequest> {
  @override
  final Iterable<Type> types = const [
    ShiftTemplateRequest,
    _$ShiftTemplateRequest
  ];

  @override
  final String wireName = r'ShiftTemplateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShiftTemplateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
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
    yield r'startTime';
    yield serializers.serialize(
      object.startTime,
      specifiedType: const FullType(String),
    );
    yield r'durationMinutes';
    yield serializers.serialize(
      object.durationMinutes,
      specifiedType: const FullType(int),
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
    ShiftTemplateRequest object, {
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
    required ShiftTemplateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
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
        case r'startTime':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.startTime = valueDes;
          break;
        case r'durationMinutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.durationMinutes = valueDes;
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
  ShiftTemplateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShiftTemplateRequestBuilder();
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
