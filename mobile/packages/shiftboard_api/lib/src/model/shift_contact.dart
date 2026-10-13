//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'shift_contact.g.dart';

/// The person at the agency to ask about a shift; the dispatcher who created it.
///
/// Properties:
/// * [name]
/// * [phone] - Absent when the contact has no phone number on record.
@BuiltValue()
abstract class ShiftContact
    implements Built<ShiftContact, ShiftContactBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  /// Absent when the contact has no phone number on record.
  @BuiltValueField(wireName: r'phone')
  String? get phone;

  ShiftContact._();

  factory ShiftContact([void updates(ShiftContactBuilder b)]) = _$ShiftContact;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShiftContactBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShiftContact> get serializer => _$ShiftContactSerializer();
}

class _$ShiftContactSerializer implements PrimitiveSerializer<ShiftContact> {
  @override
  final Iterable<Type> types = const [ShiftContact, _$ShiftContact];

  @override
  final String wireName = r'ShiftContact';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShiftContact object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.phone != null) {
      yield r'phone';
      yield serializers.serialize(
        object.phone,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ShiftContact object, {
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
    required ShiftContactBuilder result,
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
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.phone = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ShiftContact deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShiftContactBuilder();
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
