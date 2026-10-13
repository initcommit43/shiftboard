// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AssignmentStatus _$PENDING = const AssignmentStatus._('PENDING');
const AssignmentStatus _$CONFIRMED = const AssignmentStatus._('CONFIRMED');
const AssignmentStatus _$REJECTED = const AssignmentStatus._('REJECTED');
const AssignmentStatus _$CANCELLED = const AssignmentStatus._('CANCELLED');
const AssignmentStatus _$COMPLETED = const AssignmentStatus._('COMPLETED');
const AssignmentStatus _$NO_SHOW = const AssignmentStatus._('NO_SHOW');

AssignmentStatus _$valueOf(String name) {
  switch (name) {
    case 'PENDING':
      return _$PENDING;
    case 'CONFIRMED':
      return _$CONFIRMED;
    case 'REJECTED':
      return _$REJECTED;
    case 'CANCELLED':
      return _$CANCELLED;
    case 'COMPLETED':
      return _$COMPLETED;
    case 'NO_SHOW':
      return _$NO_SHOW;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AssignmentStatus> _$values =
    BuiltSet<AssignmentStatus>(const <AssignmentStatus>[
  _$PENDING,
  _$CONFIRMED,
  _$REJECTED,
  _$CANCELLED,
  _$COMPLETED,
  _$NO_SHOW,
]);

class _$AssignmentStatusMeta {
  const _$AssignmentStatusMeta();
  AssignmentStatus get PENDING => _$PENDING;
  AssignmentStatus get CONFIRMED => _$CONFIRMED;
  AssignmentStatus get REJECTED => _$REJECTED;
  AssignmentStatus get CANCELLED => _$CANCELLED;
  AssignmentStatus get COMPLETED => _$COMPLETED;
  AssignmentStatus get NO_SHOW => _$NO_SHOW;
  AssignmentStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<AssignmentStatus> get values => _$values;
}

abstract class _$AssignmentStatusMixin {
  // ignore: non_constant_identifier_names
  _$AssignmentStatusMeta get AssignmentStatus => const _$AssignmentStatusMeta();
}

Serializer<AssignmentStatus> _$assignmentStatusSerializer =
    _$AssignmentStatusSerializer();

class _$AssignmentStatusSerializer
    implements PrimitiveSerializer<AssignmentStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'PENDING': 'PENDING',
    'CONFIRMED': 'CONFIRMED',
    'REJECTED': 'REJECTED',
    'CANCELLED': 'CANCELLED',
    'COMPLETED': 'COMPLETED',
    'NO_SHOW': 'NO_SHOW',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'PENDING': 'PENDING',
    'CONFIRMED': 'CONFIRMED',
    'REJECTED': 'REJECTED',
    'CANCELLED': 'CANCELLED',
    'COMPLETED': 'COMPLETED',
    'NO_SHOW': 'NO_SHOW',
  };

  @override
  final Iterable<Type> types = const <Type>[AssignmentStatus];
  @override
  final String wireName = 'AssignmentStatus';

  @override
  Object serialize(Serializers serializers, AssignmentStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AssignmentStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AssignmentStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
