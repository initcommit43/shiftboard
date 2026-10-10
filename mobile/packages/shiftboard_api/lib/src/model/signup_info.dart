//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:shiftboard_api/src/model/qualification.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'signup_info.g.dart';

/// SignupInfo
///
/// Properties:
/// * [agencyName]
/// * [qualifications] - The qualifications a worker of this agency can have.
@BuiltValue()
abstract class SignupInfo implements Built<SignupInfo, SignupInfoBuilder> {
  @BuiltValueField(wireName: r'agencyName')
  String get agencyName;

  /// The qualifications a worker of this agency can have.
  @BuiltValueField(wireName: r'qualifications')
  BuiltList<Qualification> get qualifications;

  SignupInfo._();

  factory SignupInfo([void updates(SignupInfoBuilder b)]) = _$SignupInfo;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SignupInfoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SignupInfo> get serializer => _$SignupInfoSerializer();
}

class _$SignupInfoSerializer implements PrimitiveSerializer<SignupInfo> {
  @override
  final Iterable<Type> types = const [SignupInfo, _$SignupInfo];

  @override
  final String wireName = r'SignupInfo';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SignupInfo object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'agencyName';
    yield serializers.serialize(
      object.agencyName,
      specifiedType: const FullType(String),
    );
    yield r'qualifications';
    yield serializers.serialize(
      object.qualifications,
      specifiedType: const FullType(BuiltList, [FullType(Qualification)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SignupInfo object, {
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
    required SignupInfoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'agencyName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.agencyName = valueDes;
          break;
        case r'qualifications':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Qualification)]),
          ) as BuiltList<Qualification>;
          result.qualifications.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SignupInfo deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SignupInfoBuilder();
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
