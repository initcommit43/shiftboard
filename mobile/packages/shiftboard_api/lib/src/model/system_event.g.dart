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
  _$unknownDefaultOpenApi,
]);

class _$SystemEventMeta {
  const _$SystemEventMeta();
  SystemEvent get CLAIM_CONFIRMED => _$CLAIM_CONFIRMED;
  SystemEvent get CLAIM_REJECTED => _$CLAIM_REJECTED;
  SystemEvent get CLAIM_CANCELLED_BY_WORKER => _$CLAIM_CANCELLED_BY_WORKER;
  SystemEvent get REMOVED_BY_AGENCY => _$REMOVED_BY_AGENCY;
  SystemEvent get SHIFT_CANCELLED => _$SHIFT_CANCELLED;
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
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'CLAIM_CONFIRMED': 'CLAIM_CONFIRMED',
    'CLAIM_REJECTED': 'CLAIM_REJECTED',
    'CLAIM_CANCELLED_BY_WORKER': 'CLAIM_CANCELLED_BY_WORKER',
    'REMOVED_BY_AGENCY': 'REMOVED_BY_AGENCY',
    'SHIFT_CANCELLED': 'SHIFT_CANCELLED',
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
