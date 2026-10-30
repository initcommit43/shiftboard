//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'conversation_change.g.dart';

/// `MESSAGE` when a message of any type was added, `READ` when messages in it were marked as read. Clients treat values they don't know like `MESSAGE` and reload.
class ConversationChange extends EnumClass {
  @BuiltValueEnumConst(wireName: r'MESSAGE')
  static const ConversationChange MESSAGE = _$MESSAGE;
  @BuiltValueEnumConst(wireName: r'READ')
  static const ConversationChange READ = _$READ;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const ConversationChange unknownDefaultOpenApi =
      _$unknownDefaultOpenApi;

  static Serializer<ConversationChange> get serializer =>
      _$conversationChangeSerializer;

  const ConversationChange._(String name) : super(name);

  static BuiltSet<ConversationChange> get values => _$values;
  static ConversationChange valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ConversationChangeMixin = Object with _$ConversationChangeMixin;
