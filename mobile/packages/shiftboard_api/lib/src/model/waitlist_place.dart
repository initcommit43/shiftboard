//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'waitlist_place.g.dart';

/// Where a worker stands on the waitlist of a shift.
///
/// Properties:
/// * [position] - The place in line; 1 moves up next.
/// * [joinedAt]
@BuiltValue()
abstract class WaitlistPlace
    implements Built<WaitlistPlace, WaitlistPlaceBuilder> {
  /// The place in line; 1 moves up next.
  @BuiltValueField(wireName: r'position')
  int get position;

  @BuiltValueField(wireName: r'joinedAt')
  DateTime get joinedAt;

  WaitlistPlace._();

  factory WaitlistPlace([void updates(WaitlistPlaceBuilder b)]) =
      _$WaitlistPlace;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WaitlistPlaceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WaitlistPlace> get serializer =>
      _$WaitlistPlaceSerializer();
}

class _$WaitlistPlaceSerializer implements PrimitiveSerializer<WaitlistPlace> {
  @override
  final Iterable<Type> types = const [WaitlistPlace, _$WaitlistPlace];

  @override
  final String wireName = r'WaitlistPlace';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WaitlistPlace object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'position';
    yield serializers.serialize(
      object.position,
      specifiedType: const FullType(int),
    );
    yield r'joinedAt';
    yield serializers.serialize(
      object.joinedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WaitlistPlace object, {
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
    required WaitlistPlaceBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'position':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.position = valueDes;
          break;
        case r'joinedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.joinedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WaitlistPlace deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WaitlistPlaceBuilder();
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
