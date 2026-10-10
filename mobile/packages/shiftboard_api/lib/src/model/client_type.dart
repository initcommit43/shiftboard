//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'client_type.g.dart';

/// The client a login comes from.
class ClientType extends EnumClass {
  @BuiltValueEnumConst(wireName: r'WORKER_APP')
  static const ClientType WORKER_APP = _$WORKER_APP;
  @BuiltValueEnumConst(wireName: r'DASHBOARD')
  static const ClientType DASHBOARD = _$DASHBOARD;

  static Serializer<ClientType> get serializer => _$clientTypeSerializer;

  const ClientType._(String name) : super(name);

  static BuiltSet<ClientType> get values => _$values;
  static ClientType valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ClientTypeMixin = Object with _$ClientTypeMixin;
