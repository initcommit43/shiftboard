//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'staff_request_request.g.dart';

/// StaffRequestRequest
///
/// Properties:
/// * [locationId] - A location of the client.
/// * [role] - What the people will do; becomes the shift's title.
/// * [startsAt] - Must not have passed.
/// * [endsAt] - Must be after `startsAt`.
/// * [endIsEstimate] - The end is approximate (\"ca.\").
/// * [workerCount] - How many people the client needs.
/// * [notes] - Anything else the agency should know.
@BuiltValue()
abstract class StaffRequestRequest
    implements Built<StaffRequestRequest, StaffRequestRequestBuilder> {
  /// A location of the client.
  @BuiltValueField(wireName: r'locationId')
  String get locationId;

  /// What the people will do; becomes the shift's title.
  @BuiltValueField(wireName: r'role')
  String get role;

  /// Must not have passed.
  @BuiltValueField(wireName: r'startsAt')
  DateTime get startsAt;

  /// Must be after `startsAt`.
  @BuiltValueField(wireName: r'endsAt')
  DateTime get endsAt;

  /// The end is approximate (\"ca.\").
  @BuiltValueField(wireName: r'endIsEstimate')
  bool? get endIsEstimate;

  /// How many people the client needs.
  @BuiltValueField(wireName: r'workerCount')
  int get workerCount;

  /// Anything else the agency should know.
  @BuiltValueField(wireName: r'notes')
  String? get notes;

  StaffRequestRequest._();

  factory StaffRequestRequest([void updates(StaffRequestRequestBuilder b)]) =
      _$StaffRequestRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StaffRequestRequestBuilder b) =>
      b..endIsEstimate = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<StaffRequestRequest> get serializer =>
      _$StaffRequestRequestSerializer();
}

class _$StaffRequestRequestSerializer
    implements PrimitiveSerializer<StaffRequestRequest> {
  @override
  final Iterable<Type> types = const [
    StaffRequestRequest,
    _$StaffRequestRequest
  ];

  @override
  final String wireName = r'StaffRequestRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StaffRequestRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'locationId';
    yield serializers.serialize(
      object.locationId,
      specifiedType: const FullType(String),
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
    if (object.endIsEstimate != null) {
      yield r'endIsEstimate';
      yield serializers.serialize(
        object.endIsEstimate,
        specifiedType: const FullType(bool),
      );
    }
    yield r'workerCount';
    yield serializers.serialize(
      object.workerCount,
      specifiedType: const FullType(int),
    );
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    StaffRequestRequest object, {
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
    required StaffRequestRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'locationId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.locationId = valueDes;
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
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
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
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.notes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StaffRequestRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StaffRequestRequestBuilder();
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
