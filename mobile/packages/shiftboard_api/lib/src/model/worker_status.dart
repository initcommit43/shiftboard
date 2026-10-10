//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'worker_status.g.dart';

/// `PENDING` after signup, `ACTIVE` once the agency approved, `INACTIVE` after a rejection or deactivation.
class WorkerStatus extends EnumClass {
  @BuiltValueEnumConst(wireName: r'PENDING')
  static const WorkerStatus PENDING = _$PENDING;
  @BuiltValueEnumConst(wireName: r'ACTIVE')
  static const WorkerStatus ACTIVE = _$ACTIVE;
  @BuiltValueEnumConst(wireName: r'INACTIVE')
  static const WorkerStatus INACTIVE = _$INACTIVE;

  static Serializer<WorkerStatus> get serializer => _$workerStatusSerializer;

  const WorkerStatus._(String name) : super(name);

  static BuiltSet<WorkerStatus> get values => _$values;
  static WorkerStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class WorkerStatusMixin = Object with _$WorkerStatusMixin;
