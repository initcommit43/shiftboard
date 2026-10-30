//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:shiftboard_api/src/model/client_user.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'client_user_invitation.g.dart';

/// A client user with a fresh setup code. The code is shown only here; the backend keeps a hash of it.
///
/// Properties:
/// * [user]
/// * [setupCode]
/// * [expiresAt]
@BuiltValue()
abstract class ClientUserInvitation
    implements Built<ClientUserInvitation, ClientUserInvitationBuilder> {
  @BuiltValueField(wireName: r'user')
  ClientUser get user;

  @BuiltValueField(wireName: r'setupCode')
  String get setupCode;

  @BuiltValueField(wireName: r'expiresAt')
  DateTime get expiresAt;

  ClientUserInvitation._();

  factory ClientUserInvitation([void updates(ClientUserInvitationBuilder b)]) =
      _$ClientUserInvitation;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ClientUserInvitationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ClientUserInvitation> get serializer =>
      _$ClientUserInvitationSerializer();
}

class _$ClientUserInvitationSerializer
    implements PrimitiveSerializer<ClientUserInvitation> {
  @override
  final Iterable<Type> types = const [
    ClientUserInvitation,
    _$ClientUserInvitation
  ];

  @override
  final String wireName = r'ClientUserInvitation';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ClientUserInvitation object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'user';
    yield serializers.serialize(
      object.user,
      specifiedType: const FullType(ClientUser),
    );
    yield r'setupCode';
    yield serializers.serialize(
      object.setupCode,
      specifiedType: const FullType(String),
    );
    yield r'expiresAt';
    yield serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ClientUserInvitation object, {
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
    required ClientUserInvitationBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'user':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ClientUser),
          ) as ClientUser;
          result.user.replace(valueDes);
          break;
        case r'setupCode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.setupCode = valueDes;
          break;
        case r'expiresAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ClientUserInvitation deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ClientUserInvitationBuilder();
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
