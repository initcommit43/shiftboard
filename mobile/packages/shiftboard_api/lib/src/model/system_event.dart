//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'system_event.g.dart';

/// What a `SYSTEM` message reports, so that clients can word it in their language. `body` carries a German text as a fallback.
class SystemEvent extends EnumClass {
  @BuiltValueEnumConst(wireName: r'CLAIM_CONFIRMED')
  static const SystemEvent CLAIM_CONFIRMED = _$CLAIM_CONFIRMED;
  @BuiltValueEnumConst(wireName: r'CLAIM_REJECTED')
  static const SystemEvent CLAIM_REJECTED = _$CLAIM_REJECTED;
  @BuiltValueEnumConst(wireName: r'CLAIM_CANCELLED_BY_WORKER')
  static const SystemEvent CLAIM_CANCELLED_BY_WORKER =
      _$CLAIM_CANCELLED_BY_WORKER;
  @BuiltValueEnumConst(wireName: r'REMOVED_BY_AGENCY')
  static const SystemEvent REMOVED_BY_AGENCY = _$REMOVED_BY_AGENCY;
  @BuiltValueEnumConst(wireName: r'SHIFT_CANCELLED')
  static const SystemEvent SHIFT_CANCELLED = _$SHIFT_CANCELLED;

  static Serializer<SystemEvent> get serializer => _$systemEventSerializer;

  const SystemEvent._(String name) : super(name);

  static BuiltSet<SystemEvent> get values => _$values;
  static SystemEvent valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class SystemEventMixin = Object with _$SystemEventMixin;
