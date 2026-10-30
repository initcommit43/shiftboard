//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'role.g.dart';

/// `CLIENT` is a user at one of the agency's clients (ADR 0032).
class Role extends EnumClass {
  @BuiltValueEnumConst(wireName: r'ADMIN')
  static const Role ADMIN = _$ADMIN;
  @BuiltValueEnumConst(wireName: r'DISPATCHER')
  static const Role DISPATCHER = _$DISPATCHER;
  @BuiltValueEnumConst(wireName: r'WORKER')
  static const Role WORKER = _$WORKER;
  @BuiltValueEnumConst(wireName: r'CLIENT')
  static const Role CLIENT = _$CLIENT;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const Role unknownDefaultOpenApi = _$unknownDefaultOpenApi;

  static Serializer<Role> get serializer => _$roleSerializer;

  const Role._(String name) : super(name);

  static BuiltSet<Role> get values => _$values;
  static Role valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class RoleMixin = Object with _$RoleMixin;
