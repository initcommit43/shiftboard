// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_platform.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PushPlatform _$ANDROID = const PushPlatform._('ANDROID');
const PushPlatform _$IOS = const PushPlatform._('IOS');

PushPlatform _$valueOf(String name) {
  switch (name) {
    case 'ANDROID':
      return _$ANDROID;
    case 'IOS':
      return _$IOS;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PushPlatform> _$values =
    BuiltSet<PushPlatform>(const <PushPlatform>[
  _$ANDROID,
  _$IOS,
]);

class _$PushPlatformMeta {
  const _$PushPlatformMeta();
  PushPlatform get ANDROID => _$ANDROID;
  PushPlatform get IOS => _$IOS;
  PushPlatform valueOf(String name) => _$valueOf(name);
  BuiltSet<PushPlatform> get values => _$values;
}

abstract class _$PushPlatformMixin {
  // ignore: non_constant_identifier_names
  _$PushPlatformMeta get PushPlatform => const _$PushPlatformMeta();
}

Serializer<PushPlatform> _$pushPlatformSerializer = _$PushPlatformSerializer();

class _$PushPlatformSerializer implements PrimitiveSerializer<PushPlatform> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ANDROID': 'ANDROID',
    'IOS': 'IOS',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ANDROID': 'ANDROID',
    'IOS': 'IOS',
  };

  @override
  final Iterable<Type> types = const <Type>[PushPlatform];
  @override
  final String wireName = 'PushPlatform';

  @override
  Object serialize(Serializers serializers, PushPlatform object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PushPlatform deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PushPlatform.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
