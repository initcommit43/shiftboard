//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'client_shift_worker.g.dart';

/// A confirmed worker, by name only.
///
/// Properties:
/// * [firstName]
/// * [lastName]
@BuiltValue()
abstract class ClientShiftWorker
    implements Built<ClientShiftWorker, ClientShiftWorkerBuilder> {
  @BuiltValueField(wireName: r'firstName')
  String get firstName;

  @BuiltValueField(wireName: r'lastName')
  String get lastName;

  ClientShiftWorker._();

  factory ClientShiftWorker([void updates(ClientShiftWorkerBuilder b)]) =
      _$ClientShiftWorker;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ClientShiftWorkerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ClientShiftWorker> get serializer =>
      _$ClientShiftWorkerSerializer();
}

class _$ClientShiftWorkerSerializer
    implements PrimitiveSerializer<ClientShiftWorker> {
  @override
  final Iterable<Type> types = const [ClientShiftWorker, _$ClientShiftWorker];

  @override
  final String wireName = r'ClientShiftWorker';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ClientShiftWorker object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'firstName';
    yield serializers.serialize(
      object.firstName,
      specifiedType: const FullType(String),
    );
    yield r'lastName';
    yield serializers.serialize(
      object.lastName,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ClientShiftWorker object, {
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
    required ClientShiftWorkerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'firstName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.firstName = valueDes;
          break;
        case r'lastName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.lastName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ClientShiftWorker deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ClientShiftWorkerBuilder();
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
