//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'agency_settings.g.dart';

/// AgencySettings
///
/// Properties:
/// * [autoConfirm] - Claims are confirmed right away instead of waiting for the agency. Off by default.
/// * [cancellationDeadlineHours] - How many hours before the start a worker can still drop out in the app. 24 by default; 0 means until the start.
@BuiltValue()
abstract class AgencySettings
    implements Built<AgencySettings, AgencySettingsBuilder> {
  /// Claims are confirmed right away instead of waiting for the agency. Off by default.
  @BuiltValueField(wireName: r'autoConfirm')
  bool get autoConfirm;

  /// How many hours before the start a worker can still drop out in the app. 24 by default; 0 means until the start.
  @BuiltValueField(wireName: r'cancellationDeadlineHours')
  int get cancellationDeadlineHours;

  AgencySettings._();

  factory AgencySettings([void updates(AgencySettingsBuilder b)]) =
      _$AgencySettings;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AgencySettingsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AgencySettings> get serializer =>
      _$AgencySettingsSerializer();
}

class _$AgencySettingsSerializer
    implements PrimitiveSerializer<AgencySettings> {
  @override
  final Iterable<Type> types = const [AgencySettings, _$AgencySettings];

  @override
  final String wireName = r'AgencySettings';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AgencySettings object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'autoConfirm';
    yield serializers.serialize(
      object.autoConfirm,
      specifiedType: const FullType(bool),
    );
    yield r'cancellationDeadlineHours';
    yield serializers.serialize(
      object.cancellationDeadlineHours,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AgencySettings object, {
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
    required AgencySettingsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'autoConfirm':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.autoConfirm = valueDes;
          break;
        case r'cancellationDeadlineHours':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.cancellationDeadlineHours = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AgencySettings deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AgencySettingsBuilder();
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
