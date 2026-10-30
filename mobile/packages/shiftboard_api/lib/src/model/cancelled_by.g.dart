// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cancelled_by.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CancelledBy _$WORKER = const CancelledBy._('WORKER');
const CancelledBy _$AGENCY = const CancelledBy._('AGENCY');
const CancelledBy _$unknownDefaultOpenApi =
    const CancelledBy._('unknownDefaultOpenApi');

CancelledBy _$valueOf(String name) {
  switch (name) {
    case 'WORKER':
      return _$WORKER;
    case 'AGENCY':
      return _$AGENCY;
    case 'unknownDefaultOpenApi':
      return _$unknownDefaultOpenApi;
    default:
      return _$unknownDefaultOpenApi;
  }
}

final BuiltSet<CancelledBy> _$values =
    BuiltSet<CancelledBy>(const <CancelledBy>[
  _$WORKER,
  _$AGENCY,
  _$unknownDefaultOpenApi,
]);

class _$CancelledByMeta {
  const _$CancelledByMeta();
  CancelledBy get WORKER => _$WORKER;
  CancelledBy get AGENCY => _$AGENCY;
  CancelledBy get unknownDefaultOpenApi => _$unknownDefaultOpenApi;
  CancelledBy valueOf(String name) => _$valueOf(name);
  BuiltSet<CancelledBy> get values => _$values;
}

abstract class _$CancelledByMixin {
  // ignore: non_constant_identifier_names
  _$CancelledByMeta get CancelledBy => const _$CancelledByMeta();
}

Serializer<CancelledBy> _$cancelledBySerializer = _$CancelledBySerializer();

class _$CancelledBySerializer implements PrimitiveSerializer<CancelledBy> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'WORKER': 'WORKER',
    'AGENCY': 'AGENCY',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'WORKER': 'WORKER',
    'AGENCY': 'AGENCY',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[CancelledBy];
  @override
  final String wireName = 'CancelledBy';

  @override
  Object serialize(Serializers serializers, CancelledBy object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CancelledBy deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CancelledBy.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
