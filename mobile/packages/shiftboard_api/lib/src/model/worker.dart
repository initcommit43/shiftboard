//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:shiftboard_api/src/model/qualification.dart';
import 'package:shiftboard_api/src/model/worker_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'worker.g.dart';

/// Worker
///
/// Properties:
/// * [id]
/// * [firstName]
/// * [lastName]
/// * [email]
/// * [phone]
/// * [status]
/// * [qualifications]
/// * [createdAt] - When the worker signed up.
@BuiltValue()
abstract class Worker implements Built<Worker, WorkerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'firstName')
  String get firstName;

  @BuiltValueField(wireName: r'lastName')
  String get lastName;

  @BuiltValueField(wireName: r'email')
  String get email;

  @BuiltValueField(wireName: r'phone')
  String get phone;

  @BuiltValueField(wireName: r'status')
  WorkerStatus get status;
  // enum statusEnum {  PENDING,  ACTIVE,  INACTIVE,  };

  @BuiltValueField(wireName: r'qualifications')
  BuiltList<Qualification> get qualifications;

  /// When the worker signed up.
  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  Worker._();

  factory Worker([void updates(WorkerBuilder b)]) = _$Worker;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WorkerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Worker> get serializer => _$WorkerSerializer();
}

class _$WorkerSerializer implements PrimitiveSerializer<Worker> {
  @override
  final Iterable<Type> types = const [Worker, _$Worker];

  @override
  final String wireName = r'Worker';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Worker object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
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
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
    yield r'phone';
    yield serializers.serialize(
      object.phone,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(WorkerStatus),
    );
    yield r'qualifications';
    yield serializers.serialize(
      object.qualifications,
      specifiedType: const FullType(BuiltList, [FullType(Qualification)]),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Worker object, {
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
    required WorkerBuilder result,
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
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.phone = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(WorkerStatus),
          ) as WorkerStatus;
          result.status = valueDes;
          break;
        case r'qualifications':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Qualification)]),
          ) as BuiltList<Qualification>;
          result.qualifications.replace(valueDes);
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Worker deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WorkerBuilder();
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
