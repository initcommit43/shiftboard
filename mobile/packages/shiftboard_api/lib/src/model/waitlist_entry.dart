//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:shiftboard_api/src/model/assigned_worker.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'waitlist_entry.g.dart';

/// A worker waiting for a spot on a shift, as the agency sees them.
///
/// Properties:
/// * [id]
/// * [position] - The place in line; 1 moves up next.
/// * [worker]
/// * [joinedAt]
@BuiltValue()
abstract class WaitlistEntry
    implements Built<WaitlistEntry, WaitlistEntryBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  /// The place in line; 1 moves up next.
  @BuiltValueField(wireName: r'position')
  int get position;

  @BuiltValueField(wireName: r'worker')
  AssignedWorker get worker;

  @BuiltValueField(wireName: r'joinedAt')
  DateTime get joinedAt;

  WaitlistEntry._();

  factory WaitlistEntry([void updates(WaitlistEntryBuilder b)]) =
      _$WaitlistEntry;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WaitlistEntryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WaitlistEntry> get serializer =>
      _$WaitlistEntrySerializer();
}

class _$WaitlistEntrySerializer implements PrimitiveSerializer<WaitlistEntry> {
  @override
  final Iterable<Type> types = const [WaitlistEntry, _$WaitlistEntry];

  @override
  final String wireName = r'WaitlistEntry';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WaitlistEntry object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'position';
    yield serializers.serialize(
      object.position,
      specifiedType: const FullType(int),
    );
    yield r'worker';
    yield serializers.serialize(
      object.worker,
      specifiedType: const FullType(AssignedWorker),
    );
    yield r'joinedAt';
    yield serializers.serialize(
      object.joinedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WaitlistEntry object, {
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
    required WaitlistEntryBuilder result,
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
        case r'position':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.position = valueDes;
          break;
        case r'worker':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AssignedWorker),
          ) as AssignedWorker;
          result.worker.replace(valueDes);
          break;
        case r'joinedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.joinedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WaitlistEntry deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WaitlistEntryBuilder();
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
