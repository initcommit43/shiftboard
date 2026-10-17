//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'shift_period.g.dart';

/// `UPCOMING`: shifts that have not ended yet. `PAST`: shifts that have ended.
class ShiftPeriod extends EnumClass {
  @BuiltValueEnumConst(wireName: r'UPCOMING')
  static const ShiftPeriod UPCOMING = _$UPCOMING;
  @BuiltValueEnumConst(wireName: r'PAST')
  static const ShiftPeriod PAST = _$PAST;

  static Serializer<ShiftPeriod> get serializer => _$shiftPeriodSerializer;

  const ShiftPeriod._(String name) : super(name);

  static BuiltSet<ShiftPeriod> get values => _$values;
  static ShiftPeriod valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ShiftPeriodMixin = Object with _$ShiftPeriodMixin;
