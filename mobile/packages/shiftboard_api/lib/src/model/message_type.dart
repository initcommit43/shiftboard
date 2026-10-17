//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'message_type.g.dart';

/// `TEXT` from the worker or the agency, `SYSTEM` written by the platform when a claim or shift changed, `BROADCAST` sent by the agency to all confirmed workers of a shift.
class MessageType extends EnumClass {
  @BuiltValueEnumConst(wireName: r'TEXT')
  static const MessageType TEXT = _$TEXT;
  @BuiltValueEnumConst(wireName: r'SYSTEM')
  static const MessageType SYSTEM = _$SYSTEM;
  @BuiltValueEnumConst(wireName: r'BROADCAST')
  static const MessageType BROADCAST = _$BROADCAST;

  static Serializer<MessageType> get serializer => _$messageTypeSerializer;

  const MessageType._(String name) : super(name);

  static BuiltSet<MessageType> get values => _$values;
  static MessageType valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class MessageTypeMixin = Object with _$MessageTypeMixin;
