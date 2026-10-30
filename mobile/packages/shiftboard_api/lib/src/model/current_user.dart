//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:shiftboard_api/src/model/client_summary.dart';
import 'package:shiftboard_api/src/model/worker_profile.dart';
import 'package:shiftboard_api/src/model/agency_summary.dart';
import 'package:shiftboard_api/src/model/role.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'current_user.g.dart';

/// CurrentUser
///
/// Properties:
/// * [id]
/// * [email]
/// * [role]
/// * [agency]
/// * [worker] - Present when the role is `WORKER`.
/// * [client] - Present when the role is `CLIENT`; the client the user belongs to.
@BuiltValue()
abstract class CurrentUser implements Built<CurrentUser, CurrentUserBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'email')
  String get email;

  @BuiltValueField(wireName: r'role')
  Role get role;
  // enum roleEnum {  ADMIN,  DISPATCHER,  WORKER,  CLIENT,  };

  @BuiltValueField(wireName: r'agency')
  AgencySummary get agency;

  /// Present when the role is `WORKER`.
  @BuiltValueField(wireName: r'worker')
  WorkerProfile? get worker;

  /// Present when the role is `CLIENT`; the client the user belongs to.
  @BuiltValueField(wireName: r'client')
  ClientSummary? get client;

  CurrentUser._();

  factory CurrentUser([void updates(CurrentUserBuilder b)]) = _$CurrentUser;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CurrentUserBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CurrentUser> get serializer => _$CurrentUserSerializer();
}

class _$CurrentUserSerializer implements PrimitiveSerializer<CurrentUser> {
  @override
  final Iterable<Type> types = const [CurrentUser, _$CurrentUser];

  @override
  final String wireName = r'CurrentUser';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CurrentUser object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(Role),
    );
    yield r'agency';
    yield serializers.serialize(
      object.agency,
      specifiedType: const FullType(AgencySummary),
    );
    if (object.worker != null) {
      yield r'worker';
      yield serializers.serialize(
        object.worker,
        specifiedType: const FullType(WorkerProfile),
      );
    }
    if (object.client != null) {
      yield r'client';
      yield serializers.serialize(
        object.client,
        specifiedType: const FullType(ClientSummary),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CurrentUser object, {
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
    required CurrentUserBuilder result,
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
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Role),
          ) as Role;
          result.role = valueDes;
          break;
        case r'agency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AgencySummary),
          ) as AgencySummary;
          result.agency.replace(valueDes);
          break;
        case r'worker':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(WorkerProfile),
          ) as WorkerProfile?;
          if (valueDes == null) continue;
          result.worker.replace(valueDes);
          break;
        case r'client':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ClientSummary),
          ) as ClientSummary?;
          if (valueDes == null) continue;
          result.client.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CurrentUser deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CurrentUserBuilder();
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
