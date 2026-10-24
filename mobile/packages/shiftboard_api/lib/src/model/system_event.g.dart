// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_event.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SystemEvent _$CLAIM_CONFIRMED = const SystemEvent._('CLAIM_CONFIRMED');
const SystemEvent _$CLAIM_REJECTED = const SystemEvent._('CLAIM_REJECTED');
const SystemEvent _$CLAIM_CANCELLED_BY_WORKER =
    const SystemEvent._('CLAIM_CANCELLED_BY_WORKER');
const SystemEvent _$REMOVED_BY_AGENCY =
    const SystemEvent._('REMOVED_BY_AGENCY');
const SystemEvent _$SHIFT_CANCELLED = const SystemEvent._('SHIFT_CANCELLED');
const SystemEvent _$SHIFT_CHANGED = const SystemEvent._('SHIFT_CHANGED');
const SystemEvent _$WAITLIST_MOVED_UP =
    const SystemEvent._('WAITLIST_MOVED_UP');
const SystemEvent _$WAITLIST_MOVED_UP_CONFIRMED =
    const SystemEvent._('WAITLIST_MOVED_UP_CONFIRMED');
const SystemEvent _$WAITLIST_REMOVED_BY_AGENCY =
    const SystemEvent._('WAITLIST_REMOVED_BY_AGENCY');
const SystemEvent _$WAITLIST_SKIPPED = const SystemEvent._('WAITLIST_SKIPPED');
const SystemEvent _$unknownDefaultOpenApi =
    const SystemEvent._('unknownDefaultOpenApi');

SystemEvent _$valueOf(String name) {
  switch (name) {
    case 'CLAIM_CONFIRMED':
      return _$CLAIM_CONFIRMED;
    case 'CLAIM_REJECTED':
      return _$CLAIM_REJECTED;
    case 'CLAIM_CANCELLED_BY_WORKER':
      return _$CLAIM_CANCELLED_BY_WORKER;
    case 'REMOVED_BY_AGENCY':
      return _$REMOVED_BY_AGENCY;
    case 'SHIFT_CANCELLED':
      return _$SHIFT_CANCELLED;
    case 'SHIFT_CHANGED':
      return _$SHIFT_CHANGED;
    case 'WAITLIST_MOVED_UP':
      return _$WAITLIST_MOVED_UP;
    case 'WAITLIST_MOVED_UP_CONFIRMED':
      return _$WAITLIST_MOVED_UP_CONFIRMED;
    case 'WAITLIST_REMOVED_BY_AGENCY':
      return _$WAITLIST_REMOVED_BY_AGENCY;
    case 'WAITLIST_SKIPPED':
      return _$WAITLIST_SKIPPED;
    case 'unknownDefaultOpenApi':
      return _$unknownDefaultOpenApi;
    default:
      return _$unknownDefaultOpenApi;
  }
}

final BuiltSet<SystemEvent> _$values =
    BuiltSet<SystemEvent>(const <SystemEvent>[
  _$CLAIM_CONFIRMED,
  _$CLAIM_REJECTED,
  _$CLAIM_CANCELLED_BY_WORKER,
  _$REMOVED_BY_AGENCY,
  _$SHIFT_CANCELLED,
  _$SHIFT_CHANGED,
  _$WAITLIST_MOVED_UP,
  _$WAITLIST_MOVED_UP_CONFIRMED,
  _$WAITLIST_REMOVED_BY_AGENCY,
  _$WAITLIST_SKIPPED,
  _$unknownDefaultOpenApi,
]);

class _$SystemEventMeta {
  const _$SystemEventMeta();
  SystemEvent get CLAIM_CONFIRMED => _$CLAIM_CONFIRMED;
  SystemEvent get CLAIM_REJECTED => _$CLAIM_REJECTED;
  SystemEvent get CLAIM_CANCELLED_BY_WORKER => _$CLAIM_CANCELLED_BY_WORKER;
  SystemEvent get REMOVED_BY_AGENCY => _$REMOVED_BY_AGENCY;
  SystemEvent get SHIFT_CANCELLED => _$SHIFT_CANCELLED;
  SystemEvent get SHIFT_CHANGED => _$SHIFT_CHANGED;
  SystemEvent get WAITLIST_MOVED_UP => _$WAITLIST_MOVED_UP;
  SystemEvent get WAITLIST_MOVED_UP_CONFIRMED => _$WAITLIST_MOVED_UP_CONFIRMED;
  SystemEvent get WAITLIST_REMOVED_BY_AGENCY => _$WAITLIST_REMOVED_BY_AGENCY;
  SystemEvent get WAITLIST_SKIPPED => _$WAITLIST_SKIPPED;
  SystemEvent get unknownDefaultOpenApi => _$unknownDefaultOpenApi;
  SystemEvent valueOf(String name) => _$valueOf(name);
  BuiltSet<SystemEvent> get values => _$values;
}

abstract class _$SystemEventMixin {
  // ignore: non_constant_identifier_names
  _$SystemEventMeta get SystemEvent => const _$SystemEventMeta();
}

Serializer<SystemEvent> _$systemEventSerializer = _$SystemEventSerializer();

class _$SystemEventSerializer implements PrimitiveSerializer<SystemEvent> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'CLAIM_CONFIRMED': 'CLAIM_CONFIRMED',
    'CLAIM_REJECTED': 'CLAIM_REJECTED',
    'CLAIM_CANCELLED_BY_WORKER': 'CLAIM_CANCELLED_BY_WORKER',
    'REMOVED_BY_AGENCY': 'REMOVED_BY_AGENCY',
    'SHIFT_CANCELLED': 'SHIFT_CANCELLED',
    'SHIFT_CHANGED': 'SHIFT_CHANGED',
    'WAITLIST_MOVED_UP': 'WAITLIST_MOVED_UP',
    'WAITLIST_MOVED_UP_CONFIRMED': 'WAITLIST_MOVED_UP_CONFIRMED',
    'WAITLIST_REMOVED_BY_AGENCY': 'WAITLIST_REMOVED_BY_AGENCY',
    'WAITLIST_SKIPPED': 'WAITLIST_SKIPPED',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'CLAIM_CONFIRMED': 'CLAIM_CONFIRMED',
    'CLAIM_REJECTED': 'CLAIM_REJECTED',
    'CLAIM_CANCELLED_BY_WORKER': 'CLAIM_CANCELLED_BY_WORKER',
    'REMOVED_BY_AGENCY': 'REMOVED_BY_AGENCY',
    'SHIFT_CANCELLED': 'SHIFT_CANCELLED',
    'SHIFT_CHANGED': 'SHIFT_CHANGED',
    'WAITLIST_MOVED_UP': 'WAITLIST_MOVED_UP',
    'WAITLIST_MOVED_UP_CONFIRMED': 'WAITLIST_MOVED_UP_CONFIRMED',
    'WAITLIST_REMOVED_BY_AGENCY': 'WAITLIST_REMOVED_BY_AGENCY',
    'WAITLIST_SKIPPED': 'WAITLIST_SKIPPED',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[SystemEvent];
  @override
  final String wireName = 'SystemEvent';

  @override
  Object serialize(Serializers serializers, SystemEvent object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  SystemEvent deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      SystemEvent.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
