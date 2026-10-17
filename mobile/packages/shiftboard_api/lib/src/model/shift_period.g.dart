// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_period.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ShiftPeriod _$UPCOMING = const ShiftPeriod._('UPCOMING');
const ShiftPeriod _$PAST = const ShiftPeriod._('PAST');

ShiftPeriod _$valueOf(String name) {
  switch (name) {
    case 'UPCOMING':
      return _$UPCOMING;
    case 'PAST':
      return _$PAST;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ShiftPeriod> _$values =
    BuiltSet<ShiftPeriod>(const <ShiftPeriod>[
  _$UPCOMING,
  _$PAST,
]);

class _$ShiftPeriodMeta {
  const _$ShiftPeriodMeta();
  ShiftPeriod get UPCOMING => _$UPCOMING;
  ShiftPeriod get PAST => _$PAST;
  ShiftPeriod valueOf(String name) => _$valueOf(name);
  BuiltSet<ShiftPeriod> get values => _$values;
}

abstract class _$ShiftPeriodMixin {
  // ignore: non_constant_identifier_names
  _$ShiftPeriodMeta get ShiftPeriod => const _$ShiftPeriodMeta();
}

Serializer<ShiftPeriod> _$shiftPeriodSerializer = _$ShiftPeriodSerializer();

class _$ShiftPeriodSerializer implements PrimitiveSerializer<ShiftPeriod> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'UPCOMING': 'UPCOMING',
    'PAST': 'PAST',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'UPCOMING': 'UPCOMING',
    'PAST': 'PAST',
  };

  @override
  final Iterable<Type> types = const <Type>[ShiftPeriod];
  @override
  final String wireName = 'ShiftPeriod';

  @override
  Object serialize(Serializers serializers, ShiftPeriod object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ShiftPeriod deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ShiftPeriod.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
