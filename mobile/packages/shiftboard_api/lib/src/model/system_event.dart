//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'system_event.g.dart';

/// What a `SYSTEM` message reports, so that clients can word it in their language. `body` carries a German text as a fallback. `SHIFT_CHANGED` means the agency changed the shift, and its `body` says what changed. The `WAITLIST_*` events report the waitlist: moved up into a claim that waits for the agency (`WAITLIST_MOVED_UP`) or into a confirmed spot (`WAITLIST_MOVED_UP_CONFIRMED`), taken off by the agency (`WAITLIST_REMOVED_BY_AGENCY`), or taken off because the worker is booked at the same time by now (`WAITLIST_SKIPPED`).  New values may be added. Clients show the `body` of an event they do not know.
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
  @BuiltValueEnumConst(wireName: r'SHIFT_CHANGED')
  static const SystemEvent SHIFT_CHANGED = _$SHIFT_CHANGED;
  @BuiltValueEnumConst(wireName: r'WAITLIST_MOVED_UP')
  static const SystemEvent WAITLIST_MOVED_UP = _$WAITLIST_MOVED_UP;
  @BuiltValueEnumConst(wireName: r'WAITLIST_MOVED_UP_CONFIRMED')
  static const SystemEvent WAITLIST_MOVED_UP_CONFIRMED =
      _$WAITLIST_MOVED_UP_CONFIRMED;
  @BuiltValueEnumConst(wireName: r'WAITLIST_REMOVED_BY_AGENCY')
  static const SystemEvent WAITLIST_REMOVED_BY_AGENCY =
      _$WAITLIST_REMOVED_BY_AGENCY;
  @BuiltValueEnumConst(wireName: r'WAITLIST_SKIPPED')
  static const SystemEvent WAITLIST_SKIPPED = _$WAITLIST_SKIPPED;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const SystemEvent unknownDefaultOpenApi = _$unknownDefaultOpenApi;

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
