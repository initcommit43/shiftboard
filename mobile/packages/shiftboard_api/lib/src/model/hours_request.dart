//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'hours_request.g.dart';

/// The hours a worker worked, as the agency approves them.
///
/// Properties:
/// * [startedAt]
/// * [endedAt] - After `startedAt`, at most 24 hours later.
/// * [breakMinutes] - Unpaid break. Shorter than the time between start and end.
@BuiltValue()
abstract class HoursRequest
    implements Built<HoursRequest, HoursRequestBuilder> {
  @BuiltValueField(wireName: r'startedAt')
  DateTime get startedAt;

  /// After `startedAt`, at most 24 hours later.
  @BuiltValueField(wireName: r'endedAt')
  DateTime get endedAt;

  /// Unpaid break. Shorter than the time between start and end.
  @BuiltValueField(wireName: r'breakMinutes')
  int get breakMinutes;

  HoursRequest._();

  factory HoursRequest([void updates(HoursRequestBuilder b)]) = _$HoursRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HoursRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<HoursRequest> get serializer => _$HoursRequestSerializer();
}

class _$HoursRequestSerializer implements PrimitiveSerializer<HoursRequest> {
  @override
  final Iterable<Type> types = const [HoursRequest, _$HoursRequest];

  @override
  final String wireName = r'HoursRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HoursRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'startedAt';
    yield serializers.serialize(
      object.startedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'endedAt';
    yield serializers.serialize(
      object.endedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'breakMinutes';
    yield serializers.serialize(
      object.breakMinutes,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    HoursRequest object, {
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
    required HoursRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'startedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.startedAt = valueDes;
          break;
        case r'endedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.endedAt = valueDes;
          break;
        case r'breakMinutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.breakMinutes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  HoursRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HoursRequestBuilder();
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
