//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:shiftboard_api/src/model/system_event.dart';
import 'package:shiftboard_api/src/model/message_shift.dart';
import 'package:shiftboard_api/src/model/message_type.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'message.g.dart';

/// Message
///
/// Properties:
/// * [id]
/// * [type]
/// * [event] - Present for `SYSTEM` messages; says what the message reports.
/// * [body]
/// * [fromWorker] - Written by the worker; otherwise by the agency or the platform.
/// * [senderName] - The dispatcher who wrote a `TEXT` or `BROADCAST` message. Absent for the worker's own and for `SYSTEM` messages.
/// * [shift]
/// * [createdAt]
/// * [readAt] - When the other side read it. Absent while unread.
@BuiltValue()
abstract class Message implements Built<Message, MessageBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'type')
  MessageType get type;
  // enum typeEnum {  TEXT,  SYSTEM,  BROADCAST,  };

  /// Present for `SYSTEM` messages; says what the message reports.
  @BuiltValueField(wireName: r'event')
  SystemEvent? get event;
  // enum eventEnum {  CLAIM_CONFIRMED,  CLAIM_REJECTED,  CLAIM_CANCELLED_BY_WORKER,  REMOVED_BY_AGENCY,  SHIFT_CANCELLED,  SHIFT_CHANGED,  WAITLIST_MOVED_UP,  WAITLIST_MOVED_UP_CONFIRMED,  WAITLIST_REMOVED_BY_AGENCY,  WAITLIST_SKIPPED,  };

  @BuiltValueField(wireName: r'body')
  String get body;

  /// Written by the worker; otherwise by the agency or the platform.
  @BuiltValueField(wireName: r'fromWorker')
  bool get fromWorker;

  /// The dispatcher who wrote a `TEXT` or `BROADCAST` message. Absent for the worker's own and for `SYSTEM` messages.
  @BuiltValueField(wireName: r'senderName')
  String? get senderName;

  @BuiltValueField(wireName: r'shift')
  MessageShift? get shift;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  /// When the other side read it. Absent while unread.
  @BuiltValueField(wireName: r'readAt')
  DateTime? get readAt;

  Message._();

  factory Message([void updates(MessageBuilder b)]) = _$Message;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MessageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Message> get serializer => _$MessageSerializer();
}

class _$MessageSerializer implements PrimitiveSerializer<Message> {
  @override
  final Iterable<Type> types = const [Message, _$Message];

  @override
  final String wireName = r'Message';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Message object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(MessageType),
    );
    if (object.event != null) {
      yield r'event';
      yield serializers.serialize(
        object.event,
        specifiedType: const FullType(SystemEvent),
      );
    }
    yield r'body';
    yield serializers.serialize(
      object.body,
      specifiedType: const FullType(String),
    );
    yield r'fromWorker';
    yield serializers.serialize(
      object.fromWorker,
      specifiedType: const FullType(bool),
    );
    if (object.senderName != null) {
      yield r'senderName';
      yield serializers.serialize(
        object.senderName,
        specifiedType: const FullType(String),
      );
    }
    if (object.shift != null) {
      yield r'shift';
      yield serializers.serialize(
        object.shift,
        specifiedType: const FullType(MessageShift),
      );
    }
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.readAt != null) {
      yield r'readAt';
      yield serializers.serialize(
        object.readAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Message object, {
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
    required MessageBuilder result,
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
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MessageType),
          ) as MessageType;
          result.type = valueDes;
          break;
        case r'event':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(SystemEvent),
          ) as SystemEvent?;
          if (valueDes == null) continue;
          result.event = valueDes;
          break;
        case r'body':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.body = valueDes;
          break;
        case r'fromWorker':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.fromWorker = valueDes;
          break;
        case r'senderName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.senderName = valueDes;
          break;
        case r'shift':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(MessageShift),
          ) as MessageShift?;
          if (valueDes == null) continue;
          result.shift.replace(valueDes);
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'readAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.readAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Message deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MessageBuilder();
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
