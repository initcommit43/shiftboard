// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const WorkerStatus _$PENDING = const WorkerStatus._('PENDING');
const WorkerStatus _$ACTIVE = const WorkerStatus._('ACTIVE');
const WorkerStatus _$INACTIVE = const WorkerStatus._('INACTIVE');
const WorkerStatus _$unknownDefaultOpenApi =
    const WorkerStatus._('unknownDefaultOpenApi');

WorkerStatus _$valueOf(String name) {
  switch (name) {
    case 'PENDING':
      return _$PENDING;
    case 'ACTIVE':
      return _$ACTIVE;
    case 'INACTIVE':
      return _$INACTIVE;
    case 'unknownDefaultOpenApi':
      return _$unknownDefaultOpenApi;
    default:
      return _$unknownDefaultOpenApi;
  }
}

final BuiltSet<WorkerStatus> _$values =
    BuiltSet<WorkerStatus>(const <WorkerStatus>[
  _$PENDING,
  _$ACTIVE,
  _$INACTIVE,
  _$unknownDefaultOpenApi,
]);

class _$WorkerStatusMeta {
  const _$WorkerStatusMeta();
  WorkerStatus get PENDING => _$PENDING;
  WorkerStatus get ACTIVE => _$ACTIVE;
  WorkerStatus get INACTIVE => _$INACTIVE;
  WorkerStatus get unknownDefaultOpenApi => _$unknownDefaultOpenApi;
  WorkerStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<WorkerStatus> get values => _$values;
}

abstract class _$WorkerStatusMixin {
  // ignore: non_constant_identifier_names
  _$WorkerStatusMeta get WorkerStatus => const _$WorkerStatusMeta();
}

Serializer<WorkerStatus> _$workerStatusSerializer = _$WorkerStatusSerializer();

class _$WorkerStatusSerializer implements PrimitiveSerializer<WorkerStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'PENDING': 'PENDING',
    'ACTIVE': 'ACTIVE',
    'INACTIVE': 'INACTIVE',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'PENDING': 'PENDING',
    'ACTIVE': 'ACTIVE',
    'INACTIVE': 'INACTIVE',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[WorkerStatus];
  @override
  final String wireName = 'WorkerStatus';

  @override
  Object serialize(Serializers serializers, WorkerStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  WorkerStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      WorkerStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
