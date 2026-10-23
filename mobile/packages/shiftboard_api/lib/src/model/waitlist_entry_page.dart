//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:shiftboard_api/src/model/waitlist_entry.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'waitlist_entry_page.g.dart';

/// WaitlistEntryPage
///
/// Properties:
/// * [content]
/// * [page]
/// * [size]
/// * [totalElements]
/// * [totalPages]
@BuiltValue()
abstract class WaitlistEntryPage
    implements Built<WaitlistEntryPage, WaitlistEntryPageBuilder> {
  @BuiltValueField(wireName: r'content')
  BuiltList<WaitlistEntry> get content;

  @BuiltValueField(wireName: r'page')
  int get page;

  @BuiltValueField(wireName: r'size')
  int get size;

  @BuiltValueField(wireName: r'totalElements')
  int get totalElements;

  @BuiltValueField(wireName: r'totalPages')
  int get totalPages;

  WaitlistEntryPage._();

  factory WaitlistEntryPage([void updates(WaitlistEntryPageBuilder b)]) =
      _$WaitlistEntryPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WaitlistEntryPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WaitlistEntryPage> get serializer =>
      _$WaitlistEntryPageSerializer();
}

class _$WaitlistEntryPageSerializer
    implements PrimitiveSerializer<WaitlistEntryPage> {
  @override
  final Iterable<Type> types = const [WaitlistEntryPage, _$WaitlistEntryPage];

  @override
  final String wireName = r'WaitlistEntryPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WaitlistEntryPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(BuiltList, [FullType(WaitlistEntry)]),
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
    WaitlistEntryPage object, {
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
    required WaitlistEntryPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(WaitlistEntry)]),
          ) as BuiltList<WaitlistEntry>;
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
  WaitlistEntryPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WaitlistEntryPageBuilder();
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
