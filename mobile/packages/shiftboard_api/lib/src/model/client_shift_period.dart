//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'client_shift_period.g.dart';

/// Shifts that haven't ended (`UPCOMING`, the default) or ended ones (`PAST`).
class ClientShiftPeriod extends EnumClass {
  @BuiltValueEnumConst(wireName: r'UPCOMING')
  static const ClientShiftPeriod UPCOMING = _$UPCOMING;
  @BuiltValueEnumConst(wireName: r'PAST')
  static const ClientShiftPeriod PAST = _$PAST;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const ClientShiftPeriod unknownDefaultOpenApi =
      _$unknownDefaultOpenApi;

  static Serializer<ClientShiftPeriod> get serializer =>
      _$clientShiftPeriodSerializer;

  const ClientShiftPeriod._(String name) : super(name);

  static BuiltSet<ClientShiftPeriod> get values => _$values;
  static ClientShiftPeriod valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ClientShiftPeriodMixin = Object with _$ClientShiftPeriodMixin;
