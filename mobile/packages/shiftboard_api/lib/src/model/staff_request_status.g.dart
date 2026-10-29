// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_request_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const StaffRequestStatus _$OPEN = const StaffRequestStatus._('OPEN');
const StaffRequestStatus _$ACCEPTED = const StaffRequestStatus._('ACCEPTED');
const StaffRequestStatus _$DECLINED = const StaffRequestStatus._('DECLINED');
const StaffRequestStatus _$WITHDRAWN = const StaffRequestStatus._('WITHDRAWN');
const StaffRequestStatus _$unknownDefaultOpenApi =
    const StaffRequestStatus._('unknownDefaultOpenApi');

StaffRequestStatus _$valueOf(String name) {
  switch (name) {
    case 'OPEN':
      return _$OPEN;
    case 'ACCEPTED':
      return _$ACCEPTED;
    case 'DECLINED':
      return _$DECLINED;
    case 'WITHDRAWN':
      return _$WITHDRAWN;
    case 'unknownDefaultOpenApi':
      return _$unknownDefaultOpenApi;
    default:
      return _$unknownDefaultOpenApi;
  }
}

final BuiltSet<StaffRequestStatus> _$values =
    BuiltSet<StaffRequestStatus>(const <StaffRequestStatus>[
  _$OPEN,
  _$ACCEPTED,
  _$DECLINED,
  _$WITHDRAWN,
  _$unknownDefaultOpenApi,
]);

class _$StaffRequestStatusMeta {
  const _$StaffRequestStatusMeta();
  StaffRequestStatus get OPEN => _$OPEN;
  StaffRequestStatus get ACCEPTED => _$ACCEPTED;
  StaffRequestStatus get DECLINED => _$DECLINED;
  StaffRequestStatus get WITHDRAWN => _$WITHDRAWN;
  StaffRequestStatus get unknownDefaultOpenApi => _$unknownDefaultOpenApi;
  StaffRequestStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<StaffRequestStatus> get values => _$values;
}

abstract class _$StaffRequestStatusMixin {
  // ignore: non_constant_identifier_names
  _$StaffRequestStatusMeta get StaffRequestStatus =>
      const _$StaffRequestStatusMeta();
}

Serializer<StaffRequestStatus> _$staffRequestStatusSerializer =
    _$StaffRequestStatusSerializer();

class _$StaffRequestStatusSerializer
    implements PrimitiveSerializer<StaffRequestStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'OPEN': 'OPEN',
    'ACCEPTED': 'ACCEPTED',
    'DECLINED': 'DECLINED',
    'WITHDRAWN': 'WITHDRAWN',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'OPEN': 'OPEN',
    'ACCEPTED': 'ACCEPTED',
    'DECLINED': 'DECLINED',
    'WITHDRAWN': 'WITHDRAWN',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[StaffRequestStatus];
  @override
  final String wireName = 'StaffRequestStatus';

  @override
  Object serialize(Serializers serializers, StaffRequestStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  StaffRequestStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      StaffRequestStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
