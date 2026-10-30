//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'shift_status.g.dart';

/// `DRAFT` until the agency publishes it, `PUBLISHED` while workers can see it, `COMPLETED` after it took place, `CANCELLED` when the agency called it off. Whether a published shift is full follows from `takenSlots` and `slots`.
class ShiftStatus extends EnumClass {
  @BuiltValueEnumConst(wireName: r'DRAFT')
  static const ShiftStatus DRAFT = _$DRAFT;
  @BuiltValueEnumConst(wireName: r'PUBLISHED')
  static const ShiftStatus PUBLISHED = _$PUBLISHED;
  @BuiltValueEnumConst(wireName: r'COMPLETED')
  static const ShiftStatus COMPLETED = _$COMPLETED;
  @BuiltValueEnumConst(wireName: r'CANCELLED')
  static const ShiftStatus CANCELLED = _$CANCELLED;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const ShiftStatus unknownDefaultOpenApi = _$unknownDefaultOpenApi;

  static Serializer<ShiftStatus> get serializer => _$shiftStatusSerializer;

  const ShiftStatus._(String name) : super(name);

  static BuiltSet<ShiftStatus> get values => _$values;
  static ShiftStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ShiftStatusMixin = Object with _$ShiftStatusMixin;
