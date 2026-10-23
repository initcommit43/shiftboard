//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:shiftboard_api/src/model/shift_status.dart';
import 'package:shiftboard_api/src/model/client_summary.dart';
import 'package:shiftboard_api/src/model/shift_contact.dart';
import 'package:shiftboard_api/src/model/waitlist_place.dart';
import 'package:built_collection/built_collection.dart';
import 'package:shiftboard_api/src/model/location.dart';
import 'package:shiftboard_api/src/model/qualification.dart';
import 'package:shiftboard_api/src/model/assignment_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'worker_shift.g.dart';

/// A shift as a worker sees it.
///
/// Properties:
/// * [id]
/// * [title]
/// * [description] - What to bring, the meeting point and anything else workers need to know.
/// * [status] - Never `DRAFT`.
/// * [client]
/// * [location]
/// * [startsAt]
/// * [endsAt]
/// * [endIsEstimate] - The end is approximate; clients show it with \"ca.\".
/// * [hourlyRateCents] - Gross pay per hour in euro cents.
/// * [slots] - How many workers the shift needs.
/// * [takenSlots] - How many of the slots are claimed. The shift is full when it equals `slots`.
/// * [qualifications] - Qualifications the shift asks for. Information only; a claim is not checked against them.
/// * [contact]
/// * [assignment] - The worker's own claim on this shift. Absent when they have not claimed it, and while they are on the waitlist.
/// * [waitlistEnabled] - The agency uses the waitlist. Clients offer joining when this is true, the shift is full and published, it has not started, and the worker has neither an `assignment` nor a `waitlist` place. Absent means false.
/// * [waitlist] - The worker's place on the shift's waitlist. Absent when they are not waiting.
@BuiltValue()
abstract class WorkerShift implements Built<WorkerShift, WorkerShiftBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'title')
  String get title;

  /// What to bring, the meeting point and anything else workers need to know.
  @BuiltValueField(wireName: r'description')
  String? get description;

  /// Never `DRAFT`.
  @BuiltValueField(wireName: r'status')
  ShiftStatus get status;
  // enum statusEnum {  DRAFT,  PUBLISHED,  COMPLETED,  CANCELLED,  };

  @BuiltValueField(wireName: r'client')
  ClientSummary get client;

  @BuiltValueField(wireName: r'location')
  Location get location;

  @BuiltValueField(wireName: r'startsAt')
  DateTime get startsAt;

  @BuiltValueField(wireName: r'endsAt')
  DateTime get endsAt;

  /// The end is approximate; clients show it with \"ca.\".
  @BuiltValueField(wireName: r'endIsEstimate')
  bool get endIsEstimate;

  /// Gross pay per hour in euro cents.
  @BuiltValueField(wireName: r'hourlyRateCents')
  int get hourlyRateCents;

  /// How many workers the shift needs.
  @BuiltValueField(wireName: r'slots')
  int get slots;

  /// How many of the slots are claimed. The shift is full when it equals `slots`.
  @BuiltValueField(wireName: r'takenSlots')
  int get takenSlots;

  /// Qualifications the shift asks for. Information only; a claim is not checked against them.
  @BuiltValueField(wireName: r'qualifications')
  BuiltList<Qualification> get qualifications;

  @BuiltValueField(wireName: r'contact')
  ShiftContact get contact;

  /// The worker's own claim on this shift. Absent when they have not claimed it, and while they are on the waitlist.
  @BuiltValueField(wireName: r'assignment')
  AssignmentSummary? get assignment;

  /// The agency uses the waitlist. Clients offer joining when this is true, the shift is full and published, it has not started, and the worker has neither an `assignment` nor a `waitlist` place. Absent means false.
  @BuiltValueField(wireName: r'waitlistEnabled')
  bool? get waitlistEnabled;

  /// The worker's place on the shift's waitlist. Absent when they are not waiting.
  @BuiltValueField(wireName: r'waitlist')
  WaitlistPlace? get waitlist;

  WorkerShift._();

  factory WorkerShift([void updates(WorkerShiftBuilder b)]) = _$WorkerShift;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WorkerShiftBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WorkerShift> get serializer => _$WorkerShiftSerializer();
}

class _$WorkerShiftSerializer implements PrimitiveSerializer<WorkerShift> {
  @override
  final Iterable<Type> types = const [WorkerShift, _$WorkerShift];

  @override
  final String wireName = r'WorkerShift';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WorkerShift object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      );
    }
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(ShiftStatus),
    );
    yield r'client';
    yield serializers.serialize(
      object.client,
      specifiedType: const FullType(ClientSummary),
    );
    yield r'location';
    yield serializers.serialize(
      object.location,
      specifiedType: const FullType(Location),
    );
    yield r'startsAt';
    yield serializers.serialize(
      object.startsAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'endsAt';
    yield serializers.serialize(
      object.endsAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'endIsEstimate';
    yield serializers.serialize(
      object.endIsEstimate,
      specifiedType: const FullType(bool),
    );
    yield r'hourlyRateCents';
    yield serializers.serialize(
      object.hourlyRateCents,
      specifiedType: const FullType(int),
    );
    yield r'slots';
    yield serializers.serialize(
      object.slots,
      specifiedType: const FullType(int),
    );
    yield r'takenSlots';
    yield serializers.serialize(
      object.takenSlots,
      specifiedType: const FullType(int),
    );
    yield r'qualifications';
    yield serializers.serialize(
      object.qualifications,
      specifiedType: const FullType(BuiltList, [FullType(Qualification)]),
    );
    yield r'contact';
    yield serializers.serialize(
      object.contact,
      specifiedType: const FullType(ShiftContact),
    );
    if (object.assignment != null) {
      yield r'assignment';
      yield serializers.serialize(
        object.assignment,
        specifiedType: const FullType(AssignmentSummary),
      );
    }
    if (object.waitlistEnabled != null) {
      yield r'waitlistEnabled';
      yield serializers.serialize(
        object.waitlistEnabled,
        specifiedType: const FullType(bool),
      );
    }
    if (object.waitlist != null) {
      yield r'waitlist';
      yield serializers.serialize(
        object.waitlist,
        specifiedType: const FullType(WaitlistPlace),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    WorkerShift object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WorkerShiftBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ShiftStatus),
          ) as ShiftStatus;
          result.status = valueDes;
          break;
        case r'client':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ClientSummary),
          ) as ClientSummary;
          result.client.replace(valueDes);
          break;
        case r'location':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Location),
          ) as Location;
          result.location.replace(valueDes);
          break;
        case r'startsAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.startsAt = valueDes;
          break;
        case r'endsAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.endsAt = valueDes;
          break;
        case r'endIsEstimate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.endIsEstimate = valueDes;
          break;
        case r'hourlyRateCents':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.hourlyRateCents = valueDes;
          break;
        case r'slots':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.slots = valueDes;
          break;
        case r'takenSlots':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.takenSlots = valueDes;
          break;
        case r'qualifications':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Qualification)]),
          ) as BuiltList<Qualification>;
          result.qualifications.replace(valueDes);
          break;
        case r'contact':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ShiftContact),
          ) as ShiftContact;
          result.contact.replace(valueDes);
          break;
        case r'assignment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(AssignmentSummary),
          ) as AssignmentSummary?;
          if (valueDes == null) continue;
          result.assignment.replace(valueDes);
          break;
        case r'waitlistEnabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.waitlistEnabled = valueDes;
          break;
        case r'waitlist':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(WaitlistPlace),
          ) as WaitlistPlace?;
          if (valueDes == null) continue;
          result.waitlist.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WorkerShift deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WorkerShiftBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
