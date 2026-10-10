//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'problem.g.dart';

/// RFC 9457 problem details.
///
/// Properties:
/// * [type] - URI reference that identifies the problem type.
/// * [title] - Short, human-readable summary of the problem type.
/// * [status] - HTTP status code.
/// * [detail] - Human-readable explanation of this occurrence.
/// * [instance] - URI reference that identifies this occurrence.
/// * [code] - Machine-readable error code. Clients translate it into a localized message.
@BuiltValue()
abstract class Problem implements Built<Problem, ProblemBuilder> {
  /// URI reference that identifies the problem type.
  @BuiltValueField(wireName: r'type')
  String get type;

  /// Short, human-readable summary of the problem type.
  @BuiltValueField(wireName: r'title')
  String get title;

  /// HTTP status code.
  @BuiltValueField(wireName: r'status')
  int get status;

  /// Human-readable explanation of this occurrence.
  @BuiltValueField(wireName: r'detail')
  String? get detail;

  /// URI reference that identifies this occurrence.
  @BuiltValueField(wireName: r'instance')
  String? get instance;

  /// Machine-readable error code. Clients translate it into a localized message.
  @BuiltValueField(wireName: r'code')
  String? get code;

  Problem._();

  factory Problem([void updates(ProblemBuilder b)]) = _$Problem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProblemBuilder b) => b..type = 'about:blank';

  @BuiltValueSerializer(custom: true)
  static Serializer<Problem> get serializer => _$ProblemSerializer();
}

class _$ProblemSerializer implements PrimitiveSerializer<Problem> {
  @override
  final Iterable<Type> types = const [Problem, _$Problem];

  @override
  final String wireName = r'Problem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Problem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(String),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(int),
    );
    if (object.detail != null) {
      yield r'detail';
      yield serializers.serialize(
        object.detail,
        specifiedType: const FullType(String),
      );
    }
    if (object.instance != null) {
      yield r'instance';
      yield serializers.serialize(
        object.instance,
        specifiedType: const FullType(String),
      );
    }
    if (object.code != null) {
      yield r'code';
      yield serializers.serialize(
        object.code,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Problem object, {
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
    required ProblemBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.type = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.status = valueDes;
          break;
        case r'detail':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.detail = valueDes;
          break;
        case r'instance':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.instance = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.code = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Problem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProblemBuilder();
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
