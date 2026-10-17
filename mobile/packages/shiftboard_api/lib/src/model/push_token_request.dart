//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:shiftboard_api/src/model/push_platform.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'push_token_request.g.dart';

/// PushTokenRequest
///
/// Properties:
/// * [token] - The Firebase Cloud Messaging registration token of the device.
/// * [platform]
@BuiltValue()
abstract class PushTokenRequest
    implements Built<PushTokenRequest, PushTokenRequestBuilder> {
  /// The Firebase Cloud Messaging registration token of the device.
  @BuiltValueField(wireName: r'token')
  String get token;

  @BuiltValueField(wireName: r'platform')
  PushPlatform get platform;
  // enum platformEnum {  ANDROID,  IOS,  };

  PushTokenRequest._();

  factory PushTokenRequest([void updates(PushTokenRequestBuilder b)]) =
      _$PushTokenRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PushTokenRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PushTokenRequest> get serializer =>
      _$PushTokenRequestSerializer();
}

class _$PushTokenRequestSerializer
    implements PrimitiveSerializer<PushTokenRequest> {
  @override
  final Iterable<Type> types = const [PushTokenRequest, _$PushTokenRequest];

  @override
  final String wireName = r'PushTokenRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PushTokenRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'token';
    yield serializers.serialize(
      object.token,
      specifiedType: const FullType(String),
    );
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(PushPlatform),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PushTokenRequest object, {
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
    required PushTokenRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.token = valueDes;
          break;
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PushPlatform),
          ) as PushPlatform;
          result.platform = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PushTokenRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PushTokenRequestBuilder();
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
