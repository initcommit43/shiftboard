//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'hours_status.g.dart';

/// `OPEN` until the agency approved the hours, then `APPROVED`.
class HoursStatus extends EnumClass {
  @BuiltValueEnumConst(wireName: r'OPEN')
  static const HoursStatus OPEN = _$OPEN;
  @BuiltValueEnumConst(wireName: r'APPROVED')
  static const HoursStatus APPROVED = _$APPROVED;

  static Serializer<HoursStatus> get serializer => _$hoursStatusSerializer;

  const HoursStatus._(String name) : super(name);

  static BuiltSet<HoursStatus> get values => _$values;
  static HoursStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class HoursStatusMixin = Object with _$HoursStatusMixin;
