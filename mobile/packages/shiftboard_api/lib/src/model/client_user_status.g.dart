// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_user_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ClientUserStatus _$INVITED = const ClientUserStatus._('INVITED');
const ClientUserStatus _$ACTIVE = const ClientUserStatus._('ACTIVE');
const ClientUserStatus _$DEACTIVATED = const ClientUserStatus._('DEACTIVATED');
const ClientUserStatus _$unknownDefaultOpenApi =
    const ClientUserStatus._('unknownDefaultOpenApi');

ClientUserStatus _$valueOf(String name) {
  switch (name) {
    case 'INVITED':
      return _$INVITED;
    case 'ACTIVE':
      return _$ACTIVE;
    case 'DEACTIVATED':
      return _$DEACTIVATED;
    case 'unknownDefaultOpenApi':
      return _$unknownDefaultOpenApi;
    default:
      return _$unknownDefaultOpenApi;
  }
}

final BuiltSet<ClientUserStatus> _$values =
    BuiltSet<ClientUserStatus>(const <ClientUserStatus>[
  _$INVITED,
  _$ACTIVE,
  _$DEACTIVATED,
  _$unknownDefaultOpenApi,
]);

class _$ClientUserStatusMeta {
  const _$ClientUserStatusMeta();
  ClientUserStatus get INVITED => _$INVITED;
  ClientUserStatus get ACTIVE => _$ACTIVE;
  ClientUserStatus get DEACTIVATED => _$DEACTIVATED;
  ClientUserStatus get unknownDefaultOpenApi => _$unknownDefaultOpenApi;
  ClientUserStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<ClientUserStatus> get values => _$values;
}

abstract class _$ClientUserStatusMixin {
  // ignore: non_constant_identifier_names
  _$ClientUserStatusMeta get ClientUserStatus => const _$ClientUserStatusMeta();
}

Serializer<ClientUserStatus> _$clientUserStatusSerializer =
    _$ClientUserStatusSerializer();

class _$ClientUserStatusSerializer
    implements PrimitiveSerializer<ClientUserStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'INVITED': 'INVITED',
    'ACTIVE': 'ACTIVE',
    'DEACTIVATED': 'DEACTIVATED',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'INVITED': 'INVITED',
    'ACTIVE': 'ACTIVE',
    'DEACTIVATED': 'DEACTIVATED',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[ClientUserStatus];
  @override
  final String wireName = 'ClientUserStatus';

  @override
  Object serialize(Serializers serializers, ClientUserStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ClientUserStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ClientUserStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
