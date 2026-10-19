//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'shift_template.g.dart';

/// A shift without a date. Client, location and qualifications are ids; one that no longer exists is left out of the form a template fills in.
///
/// Properties:
/// * [id]
/// * [name]
/// * [clientId]
/// * [locationId]
/// * [title]
/// * [description]
/// * [startTime] - Local time of day, `hh:mm`.
/// * [durationMinutes]
/// * [endIsEstimate]
/// * [hourlyRateCents] - Gross pay per hour in euro cents.
/// * [slots]
/// * [qualificationIds]
/// * [createdAt]
@BuiltValue()
abstract class ShiftTemplate
    implements Built<ShiftTemplate, ShiftTemplateBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'clientId')
  String get clientId;

  @BuiltValueField(wireName: r'locationId')
  String get locationId;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'description')
  String? get description;

  /// Local time of day, `hh:mm`.
  @BuiltValueField(wireName: r'startTime')
  String get startTime;

  @BuiltValueField(wireName: r'durationMinutes')
  int get durationMinutes;

  @BuiltValueField(wireName: r'endIsEstimate')
  bool get endIsEstimate;

  /// Gross pay per hour in euro cents.
  @BuiltValueField(wireName: r'hourlyRateCents')
  int get hourlyRateCents;

  @BuiltValueField(wireName: r'slots')
  int get slots;

  @BuiltValueField(wireName: r'qualificationIds')
  BuiltSet<String> get qualificationIds;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  ShiftTemplate._();

  factory ShiftTemplate([void updates(ShiftTemplateBuilder b)]) =
      _$ShiftTemplate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShiftTemplateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShiftTemplate> get serializer =>
      _$ShiftTemplateSerializer();
}

class _$ShiftTemplateSerializer implements PrimitiveSerializer<ShiftTemplate> {
  @override
  final Iterable<Type> types = const [ShiftTemplate, _$ShiftTemplate];

  @override
  final String wireName = r'ShiftTemplate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShiftTemplate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
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
    yield r'qualificationIds';
    yield serializers.serialize(
      object.qualificationIds,
      specifiedType: const FullType(BuiltSet, [FullType(String)]),
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
    ShiftTemplate object, {
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
    required ShiftTemplateBuilder result,
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
        case r'qualificationIds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltSet, [FullType(String)]),
          ) as BuiltSet<String>;
          result.qualificationIds.replace(valueDes);
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
  ShiftTemplate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShiftTemplateBuilder();
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
