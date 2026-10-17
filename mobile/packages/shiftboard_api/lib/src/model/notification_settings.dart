//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notification_settings.g.dart';

/// NotificationSettings
///
/// Properties:
/// * [newShiftsPaused] - No push for new shifts while true.
@BuiltValue()
abstract class NotificationSettings
    implements Built<NotificationSettings, NotificationSettingsBuilder> {
  /// No push for new shifts while true.
  @BuiltValueField(wireName: r'newShiftsPaused')
  bool get newShiftsPaused;

  NotificationSettings._();

  factory NotificationSettings([void updates(NotificationSettingsBuilder b)]) =
      _$NotificationSettings;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationSettingsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationSettings> get serializer =>
      _$NotificationSettingsSerializer();
}

class _$NotificationSettingsSerializer
    implements PrimitiveSerializer<NotificationSettings> {
  @override
  final Iterable<Type> types = const [
    NotificationSettings,
    _$NotificationSettings
  ];

  @override
  final String wireName = r'NotificationSettings';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationSettings object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'newShiftsPaused';
    yield serializers.serialize(
      object.newShiftsPaused,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    NotificationSettings object, {
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
    required NotificationSettingsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'newShiftsPaused':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.newShiftsPaused = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NotificationSettings deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationSettingsBuilder();
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
