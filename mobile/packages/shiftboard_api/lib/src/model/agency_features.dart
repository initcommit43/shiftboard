//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'agency_features.g.dart';

/// AgencyFeatures
///
/// Properties:
/// * [contactButton] - Workers see a WhatsApp button for the contact person on a shift, for agencies that prefer that over the in-app chat. Off by default.
/// * [checkIn] - Workers check in and out of their shifts in the app. Off by default. Always present in responses; absent in a request, it stays as it is.
/// * [clientPortal] - The staff of the agency's clients log in to see their shifts and who is coming (ADR 0032). Off by default. Always present in responses; absent in a request, it stays as it is.
@BuiltValue()
abstract class AgencyFeatures
    implements Built<AgencyFeatures, AgencyFeaturesBuilder> {
  /// Workers see a WhatsApp button for the contact person on a shift, for agencies that prefer that over the in-app chat. Off by default.
  @BuiltValueField(wireName: r'contactButton')
  bool get contactButton;

  /// Workers check in and out of their shifts in the app. Off by default. Always present in responses; absent in a request, it stays as it is.
  @BuiltValueField(wireName: r'checkIn')
  bool? get checkIn;

  /// The staff of the agency's clients log in to see their shifts and who is coming (ADR 0032). Off by default. Always present in responses; absent in a request, it stays as it is.
  @BuiltValueField(wireName: r'clientPortal')
  bool? get clientPortal;

  AgencyFeatures._();

  factory AgencyFeatures([void updates(AgencyFeaturesBuilder b)]) =
      _$AgencyFeatures;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AgencyFeaturesBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AgencyFeatures> get serializer =>
      _$AgencyFeaturesSerializer();
}

class _$AgencyFeaturesSerializer
    implements PrimitiveSerializer<AgencyFeatures> {
  @override
  final Iterable<Type> types = const [AgencyFeatures, _$AgencyFeatures];

  @override
  final String wireName = r'AgencyFeatures';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AgencyFeatures object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'contactButton';
    yield serializers.serialize(
      object.contactButton,
      specifiedType: const FullType(bool),
    );
    if (object.checkIn != null) {
      yield r'checkIn';
      yield serializers.serialize(
        object.checkIn,
        specifiedType: const FullType(bool),
      );
    }
    if (object.clientPortal != null) {
      yield r'clientPortal';
      yield serializers.serialize(
        object.clientPortal,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AgencyFeatures object, {
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
    required AgencyFeaturesBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'contactButton':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.contactButton = valueDes;
          break;
        case r'checkIn':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.checkIn = valueDes;
          break;
        case r'clientPortal':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.clientPortal = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AgencyFeatures deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AgencyFeaturesBuilder();
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
