// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hours_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const HoursStatus _$OPEN = const HoursStatus._('OPEN');
const HoursStatus _$APPROVED = const HoursStatus._('APPROVED');

HoursStatus _$valueOf(String name) {
  switch (name) {
    case 'OPEN':
      return _$OPEN;
    case 'APPROVED':
      return _$APPROVED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<HoursStatus> _$values =
    BuiltSet<HoursStatus>(const <HoursStatus>[
  _$OPEN,
  _$APPROVED,
]);

class _$HoursStatusMeta {
  const _$HoursStatusMeta();
  HoursStatus get OPEN => _$OPEN;
  HoursStatus get APPROVED => _$APPROVED;
  HoursStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<HoursStatus> get values => _$values;
}

abstract class _$HoursStatusMixin {
  // ignore: non_constant_identifier_names
  _$HoursStatusMeta get HoursStatus => const _$HoursStatusMeta();
}

Serializer<HoursStatus> _$hoursStatusSerializer = _$HoursStatusSerializer();

class _$HoursStatusSerializer implements PrimitiveSerializer<HoursStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'OPEN': 'OPEN',
    'APPROVED': 'APPROVED',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'OPEN': 'OPEN',
    'APPROVED': 'APPROVED',
  };

  @override
  final Iterable<Type> types = const <Type>[HoursStatus];
  @override
  final String wireName = 'HoursStatus';

  @override
  Object serialize(Serializers serializers, HoursStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  HoursStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      HoursStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
