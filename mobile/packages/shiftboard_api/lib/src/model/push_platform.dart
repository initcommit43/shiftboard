//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'push_platform.g.dart';

class PushPlatform extends EnumClass {
  @BuiltValueEnumConst(wireName: r'ANDROID')
  static const PushPlatform ANDROID = _$ANDROID;
  @BuiltValueEnumConst(wireName: r'IOS')
  static const PushPlatform IOS = _$IOS;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const PushPlatform unknownDefaultOpenApi = _$unknownDefaultOpenApi;

  static Serializer<PushPlatform> get serializer => _$pushPlatformSerializer;

  const PushPlatform._(String name) : super(name);

  static BuiltSet<PushPlatform> get values => _$values;
  static PushPlatform valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class PushPlatformMixin = Object with _$PushPlatformMixin;
