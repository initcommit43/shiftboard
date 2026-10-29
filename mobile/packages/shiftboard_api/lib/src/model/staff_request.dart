//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:shiftboard_api/src/model/client_summary.dart';
import 'package:shiftboard_api/src/model/location.dart';
import 'package:shiftboard_api/src/model/staff_request_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'staff_request.g.dart';

/// A client's request for staff. Clients and dispatchers get the same shape; it holds nothing about pay.
///
/// Properties:
/// * [id]
/// * [status]
/// * [client]
/// * [location]
/// * [role]
/// * [startsAt]
/// * [endsAt]
/// * [endIsEstimate]
/// * [workerCount]
/// * [notes] - Empty when the client wrote nothing.
/// * [requestedBy] - Full name of the client user who sent the request.
/// * [createdAt]
/// * [decidedAt] - When it was accepted, declined or withdrawn; absent while open.
/// * [declineReason] - Why the agency declined; only when `DECLINED`.
/// * [shiftId] - The shift the request was turned into; only when `ACCEPTED`. Clients get it only once the shift is published, since they never see drafts.
@BuiltValue()
abstract class StaffRequest
    implements Built<StaffRequest, StaffRequestBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'status')
  StaffRequestStatus get status;
  // enum statusEnum {  OPEN,  ACCEPTED,  DECLINED,  WITHDRAWN,  };

  @BuiltValueField(wireName: r'client')
  ClientSummary get client;

  @BuiltValueField(wireName: r'location')
  Location get location;

  @BuiltValueField(wireName: r'role')
  String get role;

  @BuiltValueField(wireName: r'startsAt')
  DateTime get startsAt;

  @BuiltValueField(wireName: r'endsAt')
  DateTime get endsAt;

  @BuiltValueField(wireName: r'endIsEstimate')
  bool get endIsEstimate;

  @BuiltValueField(wireName: r'workerCount')
  int get workerCount;

  /// Empty when the client wrote nothing.
  @BuiltValueField(wireName: r'notes')
  String get notes;

  /// Full name of the client user who sent the request.
  @BuiltValueField(wireName: r'requestedBy')
  String get requestedBy;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  /// When it was accepted, declined or withdrawn; absent while open.
  @BuiltValueField(wireName: r'decidedAt')
  DateTime? get decidedAt;

  /// Why the agency declined; only when `DECLINED`.
  @BuiltValueField(wireName: r'declineReason')
  String? get declineReason;

  /// The shift the request was turned into; only when `ACCEPTED`. Clients get it only once the shift is published, since they never see drafts.
  @BuiltValueField(wireName: r'shiftId')
  String? get shiftId;

  StaffRequest._();

  factory StaffRequest([void updates(StaffRequestBuilder b)]) = _$StaffRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StaffRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StaffRequest> get serializer => _$StaffRequestSerializer();
}

class _$StaffRequestSerializer implements PrimitiveSerializer<StaffRequest> {
  @override
  final Iterable<Type> types = const [StaffRequest, _$StaffRequest];

  @override
  final String wireName = r'StaffRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StaffRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(StaffRequestStatus),
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
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(String),
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
    yield r'workerCount';
    yield serializers.serialize(
      object.workerCount,
      specifiedType: const FullType(int),
    );
    yield r'notes';
    yield serializers.serialize(
      object.notes,
      specifiedType: const FullType(String),
    );
    yield r'requestedBy';
    yield serializers.serialize(
      object.requestedBy,
      specifiedType: const FullType(String),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.decidedAt != null) {
      yield r'decidedAt';
      yield serializers.serialize(
        object.decidedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.declineReason != null) {
      yield r'declineReason';
      yield serializers.serialize(
        object.declineReason,
        specifiedType: const FullType(String),
      );
    }
    if (object.shiftId != null) {
      yield r'shiftId';
      yield serializers.serialize(
        object.shiftId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    StaffRequest object, {
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
    required StaffRequestBuilder result,
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
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(StaffRequestStatus),
          ) as StaffRequestStatus;
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
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.role = valueDes;
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
        case r'workerCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.workerCount = valueDes;
          break;
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.notes = valueDes;
          break;
        case r'requestedBy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.requestedBy = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'decidedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.decidedAt = valueDes;
          break;
        case r'declineReason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.declineReason = valueDes;
          break;
        case r'shiftId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.shiftId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StaffRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StaffRequestBuilder();
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
