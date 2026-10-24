// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const Role _$ADMIN = const Role._('ADMIN');
const Role _$DISPATCHER = const Role._('DISPATCHER');
const Role _$WORKER = const Role._('WORKER');
const Role _$unknownDefaultOpenApi = const Role._('unknownDefaultOpenApi');

Role _$valueOf(String name) {
  switch (name) {
    case 'ADMIN':
      return _$ADMIN;
    case 'DISPATCHER':
      return _$DISPATCHER;
    case 'WORKER':
      return _$WORKER;
    case 'unknownDefaultOpenApi':
      return _$unknownDefaultOpenApi;
    default:
      return _$unknownDefaultOpenApi;
  }
}

final BuiltSet<Role> _$values = BuiltSet<Role>(const <Role>[
  _$ADMIN,
  _$DISPATCHER,
  _$WORKER,
  _$unknownDefaultOpenApi,
]);

class _$RoleMeta {
  const _$RoleMeta();
  Role get ADMIN => _$ADMIN;
  Role get DISPATCHER => _$DISPATCHER;
  Role get WORKER => _$WORKER;
  Role get unknownDefaultOpenApi => _$unknownDefaultOpenApi;
  Role valueOf(String name) => _$valueOf(name);
  BuiltSet<Role> get values => _$values;
}

abstract class _$RoleMixin {
  // ignore: non_constant_identifier_names
  _$RoleMeta get Role => const _$RoleMeta();
}

Serializer<Role> _$roleSerializer = _$RoleSerializer();

class _$RoleSerializer implements PrimitiveSerializer<Role> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ADMIN': 'ADMIN',
    'DISPATCHER': 'DISPATCHER',
    'WORKER': 'WORKER',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ADMIN': 'ADMIN',
    'DISPATCHER': 'DISPATCHER',
    'WORKER': 'WORKER',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[Role];
  @override
  final String wireName = 'Role';

  @override
  Object serialize(Serializers serializers, Role object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  Role deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      Role.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
