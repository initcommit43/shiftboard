// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MessagePage extends MessagePage {
  @override
  final BuiltList<Message> content;
  @override
  final int page;
  @override
  final int size;
  @override
  final int totalElements;
  @override
  final int totalPages;

  factory _$MessagePage([void Function(MessagePageBuilder)? updates]) =>
      (MessagePageBuilder()..update(updates))._build();

  _$MessagePage._(
      {required this.content,
      required this.page,
      required this.size,
      required this.totalElements,
      required this.totalPages})
      : super._();
  @override
  MessagePage rebuild(void Function(MessagePageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MessagePageBuilder toBuilder() => MessagePageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MessagePage &&
        content == other.content &&
        page == other.page &&
        size == other.size &&
        totalElements == other.totalElements &&
        totalPages == other.totalPages;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, page.hashCode);
    _$hash = $jc(_$hash, size.hashCode);
    _$hash = $jc(_$hash, totalElements.hashCode);
    _$hash = $jc(_$hash, totalPages.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MessagePage')
          ..add('content', content)
          ..add('page', page)
          ..add('size', size)
          ..add('totalElements', totalElements)
          ..add('totalPages', totalPages))
        .toString();
  }
}

class MessagePageBuilder implements Builder<MessagePage, MessagePageBuilder> {
  _$MessagePage? _$v;

  ListBuilder<Message>? _content;
  ListBuilder<Message> get content =>
      _$this._content ??= ListBuilder<Message>();
  set content(ListBuilder<Message>? content) => _$this._content = content;

  int? _page;
  int? get page => _$this._page;
  set page(int? page) => _$this._page = page;

  int? _size;
  int? get size => _$this._size;
  set size(int? size) => _$this._size = size;

  int? _totalElements;
  int? get totalElements => _$this._totalElements;
  set totalElements(int? totalElements) =>
      _$this._totalElements = totalElements;

  int? _totalPages;
  int? get totalPages => _$this._totalPages;
  set totalPages(int? totalPages) => _$this._totalPages = totalPages;

  MessagePageBuilder() {
    MessagePage._defaults(this);
  }

  MessagePageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _content = $v.content.toBuilder();
      _page = $v.page;
      _size = $v.size;
      _totalElements = $v.totalElements;
      _totalPages = $v.totalPages;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MessagePage other) {
    _$v = other as _$MessagePage;
  }

  @override
  void update(void Function(MessagePageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MessagePage build() => _build();

  _$MessagePage _build() {
    _$MessagePage _$result;
    try {
      _$result = _$v ??
          _$MessagePage._(
            content: content.build(),
            page: BuiltValueNullFieldError.checkNotNull(
                page, r'MessagePage', 'page'),
            size: BuiltValueNullFieldError.checkNotNull(
                size, r'MessagePage', 'size'),
            totalElements: BuiltValueNullFieldError.checkNotNull(
                totalElements, r'MessagePage', 'totalElements'),
            totalPages: BuiltValueNullFieldError.checkNotNull(
                totalPages, r'MessagePage', 'totalPages'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'content';
        content.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MessagePage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
