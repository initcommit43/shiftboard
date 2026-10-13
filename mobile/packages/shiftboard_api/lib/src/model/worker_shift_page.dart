//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:shiftboard_api/src/model/worker_shift.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'worker_shift_page.g.dart';

/// WorkerShiftPage
///
/// Properties:
/// * [content]
/// * [page]
/// * [size]
/// * [totalElements]
/// * [totalPages]
@BuiltValue()
abstract class WorkerShiftPage
    implements Built<WorkerShiftPage, WorkerShiftPageBuilder> {
  @BuiltValueField(wireName: r'content')
  BuiltList<WorkerShift> get content;

  @BuiltValueField(wireName: r'page')
  int get page;

  @BuiltValueField(wireName: r'size')
  int get size;

  @BuiltValueField(wireName: r'totalElements')
  int get totalElements;

  @BuiltValueField(wireName: r'totalPages')
  int get totalPages;

  WorkerShiftPage._();

  factory WorkerShiftPage([void updates(WorkerShiftPageBuilder b)]) =
      _$WorkerShiftPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WorkerShiftPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WorkerShiftPage> get serializer =>
      _$WorkerShiftPageSerializer();
}

class _$WorkerShiftPageSerializer
    implements PrimitiveSerializer<WorkerShiftPage> {
  @override
  final Iterable<Type> types = const [WorkerShiftPage, _$WorkerShiftPage];

  @override
  final String wireName = r'WorkerShiftPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WorkerShiftPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(BuiltList, [FullType(WorkerShift)]),
    );
    yield r'page';
    yield serializers.serialize(
      object.page,
      specifiedType: const FullType(int),
    );
    yield r'size';
    yield serializers.serialize(
      object.size,
      specifiedType: const FullType(int),
    );
    yield r'totalElements';
    yield serializers.serialize(
      object.totalElements,
      specifiedType: const FullType(int),
    );
    yield r'totalPages';
    yield serializers.serialize(
      object.totalPages,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WorkerShiftPage object, {
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
    required WorkerShiftPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(WorkerShift)]),
          ) as BuiltList<WorkerShift>;
          result.content.replace(valueDes);
          break;
        case r'page':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.page = valueDes;
          break;
        case r'size':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.size = valueDes;
          break;
        case r'totalElements':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalElements = valueDes;
          break;
        case r'totalPages':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalPages = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WorkerShiftPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WorkerShiftPageBuilder();
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
