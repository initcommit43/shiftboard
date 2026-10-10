// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_type.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ClientType _$WORKER_APP = const ClientType._('WORKER_APP');
const ClientType _$DASHBOARD = const ClientType._('DASHBOARD');

ClientType _$valueOf(String name) {
  switch (name) {
    case 'WORKER_APP':
      return _$WORKER_APP;
    case 'DASHBOARD':
      return _$DASHBOARD;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ClientType> _$values = BuiltSet<ClientType>(const <ClientType>[
  _$WORKER_APP,
  _$DASHBOARD,
]);

class _$ClientTypeMeta {
  const _$ClientTypeMeta();
  ClientType get WORKER_APP => _$WORKER_APP;
  ClientType get DASHBOARD => _$DASHBOARD;
  ClientType valueOf(String name) => _$valueOf(name);
  BuiltSet<ClientType> get values => _$values;
}

abstract class _$ClientTypeMixin {
  // ignore: non_constant_identifier_names
  _$ClientTypeMeta get ClientType => const _$ClientTypeMeta();
}

Serializer<ClientType> _$clientTypeSerializer = _$ClientTypeSerializer();

class _$ClientTypeSerializer implements PrimitiveSerializer<ClientType> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'WORKER_APP': 'WORKER_APP',
    'DASHBOARD': 'DASHBOARD',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'WORKER_APP': 'WORKER_APP',
    'DASHBOARD': 'DASHBOARD',
  };

  @override
  final Iterable<Type> types = const <Type>[ClientType];
  @override
  final String wireName = 'ClientType';

  @override
  Object serialize(Serializers serializers, ClientType object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ClientType deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ClientType.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
