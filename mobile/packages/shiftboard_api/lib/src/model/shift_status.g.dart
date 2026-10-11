// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ShiftStatus _$DRAFT = const ShiftStatus._('DRAFT');
const ShiftStatus _$PUBLISHED = const ShiftStatus._('PUBLISHED');
const ShiftStatus _$COMPLETED = const ShiftStatus._('COMPLETED');
const ShiftStatus _$CANCELLED = const ShiftStatus._('CANCELLED');

ShiftStatus _$valueOf(String name) {
  switch (name) {
    case 'DRAFT':
      return _$DRAFT;
    case 'PUBLISHED':
      return _$PUBLISHED;
    case 'COMPLETED':
      return _$COMPLETED;
    case 'CANCELLED':
      return _$CANCELLED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ShiftStatus> _$values =
    BuiltSet<ShiftStatus>(const <ShiftStatus>[
  _$DRAFT,
  _$PUBLISHED,
  _$COMPLETED,
  _$CANCELLED,
]);

class _$ShiftStatusMeta {
  const _$ShiftStatusMeta();
  ShiftStatus get DRAFT => _$DRAFT;
  ShiftStatus get PUBLISHED => _$PUBLISHED;
  ShiftStatus get COMPLETED => _$COMPLETED;
  ShiftStatus get CANCELLED => _$CANCELLED;
  ShiftStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<ShiftStatus> get values => _$values;
}

abstract class _$ShiftStatusMixin {
  // ignore: non_constant_identifier_names
  _$ShiftStatusMeta get ShiftStatus => const _$ShiftStatusMeta();
}

Serializer<ShiftStatus> _$shiftStatusSerializer = _$ShiftStatusSerializer();

class _$ShiftStatusSerializer implements PrimitiveSerializer<ShiftStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'DRAFT': 'DRAFT',
    'PUBLISHED': 'PUBLISHED',
    'COMPLETED': 'COMPLETED',
    'CANCELLED': 'CANCELLED',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'DRAFT': 'DRAFT',
    'PUBLISHED': 'PUBLISHED',
    'COMPLETED': 'COMPLETED',
    'CANCELLED': 'CANCELLED',
  };

  @override
  final Iterable<Type> types = const <Type>[ShiftStatus];
  @override
  final String wireName = 'ShiftStatus';

  @override
  Object serialize(Serializers serializers, ShiftStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ShiftStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ShiftStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
