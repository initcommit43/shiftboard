//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'assignment_status.g.dart';

/// `PENDING` after the claim, `CONFIRMED` once the agency approved, `REJECTED` when it declined, `CANCELLED` when the worker dropped out, the agency removed them or the shift was called off, `COMPLETED` after the shift took place, `NO_SHOW` when the worker did not turn up. Pending and confirmed assignments hold a spot.
class AssignmentStatus extends EnumClass {
  @BuiltValueEnumConst(wireName: r'PENDING')
  static const AssignmentStatus PENDING = _$PENDING;
  @BuiltValueEnumConst(wireName: r'CONFIRMED')
  static const AssignmentStatus CONFIRMED = _$CONFIRMED;
  @BuiltValueEnumConst(wireName: r'REJECTED')
  static const AssignmentStatus REJECTED = _$REJECTED;
  @BuiltValueEnumConst(wireName: r'CANCELLED')
  static const AssignmentStatus CANCELLED = _$CANCELLED;
  @BuiltValueEnumConst(wireName: r'COMPLETED')
  static const AssignmentStatus COMPLETED = _$COMPLETED;
  @BuiltValueEnumConst(wireName: r'NO_SHOW')
  static const AssignmentStatus NO_SHOW = _$NO_SHOW;

  static Serializer<AssignmentStatus> get serializer =>
      _$assignmentStatusSerializer;

  const AssignmentStatus._(String name) : super(name);

  static BuiltSet<AssignmentStatus> get values => _$values;
  static AssignmentStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class AssignmentStatusMixin = Object with _$AssignmentStatusMixin;
