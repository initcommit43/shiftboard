//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:shiftboard_api/src/model/agency_features.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'agency_summary.g.dart';

/// AgencySummary
///
/// Properties:
/// * [id]
/// * [name]
/// * [features] - The optional features the agency has switched on.
@BuiltValue()
abstract class AgencySummary
    implements Built<AgencySummary, AgencySummaryBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  /// The optional features the agency has switched on.
  @BuiltValueField(wireName: r'features')
  AgencyFeatures? get features;

  AgencySummary._();

  factory AgencySummary([void updates(AgencySummaryBuilder b)]) =
      _$AgencySummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AgencySummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AgencySummary> get serializer =>
      _$AgencySummarySerializer();
}

class _$AgencySummarySerializer implements PrimitiveSerializer<AgencySummary> {
  @override
  final Iterable<Type> types = const [AgencySummary, _$AgencySummary];

  @override
  final String wireName = r'AgencySummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AgencySummary object, {
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
    if (object.features != null) {
      yield r'features';
      yield serializers.serialize(
        object.features,
        specifiedType: const FullType(AgencyFeatures),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AgencySummary object, {
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
    required AgencySummaryBuilder result,
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
        case r'features':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(AgencyFeatures),
          ) as AgencyFeatures?;
          if (valueDes == null) continue;
          result.features.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AgencySummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AgencySummaryBuilder();
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
