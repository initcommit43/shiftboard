// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_shift_period.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ClientShiftPeriod _$UPCOMING = const ClientShiftPeriod._('UPCOMING');
const ClientShiftPeriod _$PAST = const ClientShiftPeriod._('PAST');
const ClientShiftPeriod _$unknownDefaultOpenApi =
    const ClientShiftPeriod._('unknownDefaultOpenApi');

ClientShiftPeriod _$valueOf(String name) {
  switch (name) {
    case 'UPCOMING':
      return _$UPCOMING;
    case 'PAST':
      return _$PAST;
    case 'unknownDefaultOpenApi':
      return _$unknownDefaultOpenApi;
    default:
      return _$unknownDefaultOpenApi;
  }
}

final BuiltSet<ClientShiftPeriod> _$values =
    BuiltSet<ClientShiftPeriod>(const <ClientShiftPeriod>[
  _$UPCOMING,
  _$PAST,
  _$unknownDefaultOpenApi,
]);

class _$ClientShiftPeriodMeta {
  const _$ClientShiftPeriodMeta();
  ClientShiftPeriod get UPCOMING => _$UPCOMING;
  ClientShiftPeriod get PAST => _$PAST;
  ClientShiftPeriod get unknownDefaultOpenApi => _$unknownDefaultOpenApi;
  ClientShiftPeriod valueOf(String name) => _$valueOf(name);
  BuiltSet<ClientShiftPeriod> get values => _$values;
}

abstract class _$ClientShiftPeriodMixin {
  // ignore: non_constant_identifier_names
  _$ClientShiftPeriodMeta get ClientShiftPeriod =>
      const _$ClientShiftPeriodMeta();
}

Serializer<ClientShiftPeriod> _$clientShiftPeriodSerializer =
    _$ClientShiftPeriodSerializer();

class _$ClientShiftPeriodSerializer
    implements PrimitiveSerializer<ClientShiftPeriod> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'UPCOMING': 'UPCOMING',
    'PAST': 'PAST',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'UPCOMING': 'UPCOMING',
    'PAST': 'PAST',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[ClientShiftPeriod];
  @override
  final String wireName = 'ClientShiftPeriod';

  @override
  Object serialize(Serializers serializers, ClientShiftPeriod object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ClientShiftPeriod deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ClientShiftPeriod.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
