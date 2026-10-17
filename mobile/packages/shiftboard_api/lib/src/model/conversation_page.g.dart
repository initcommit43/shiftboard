// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConversationPage extends ConversationPage {
  @override
  final BuiltList<Conversation> content;
  @override
  final int page;
  @override
  final int size;
  @override
  final int totalElements;
  @override
  final int totalPages;

  factory _$ConversationPage(
          [void Function(ConversationPageBuilder)? updates]) =>
      (ConversationPageBuilder()..update(updates))._build();

  _$ConversationPage._(
      {required this.content,
      required this.page,
      required this.size,
      required this.totalElements,
      required this.totalPages})
      : super._();
  @override
  ConversationPage rebuild(void Function(ConversationPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConversationPageBuilder toBuilder() =>
      ConversationPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConversationPage &&
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
    return (newBuiltValueToStringHelper(r'ConversationPage')
          ..add('content', content)
          ..add('page', page)
          ..add('size', size)
          ..add('totalElements', totalElements)
          ..add('totalPages', totalPages))
        .toString();
  }
}

class ConversationPageBuilder
    implements Builder<ConversationPage, ConversationPageBuilder> {
  _$ConversationPage? _$v;

  ListBuilder<Conversation>? _content;
  ListBuilder<Conversation> get content =>
      _$this._content ??= ListBuilder<Conversation>();
  set content(ListBuilder<Conversation>? content) => _$this._content = content;

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

  ConversationPageBuilder() {
    ConversationPage._defaults(this);
  }

  ConversationPageBuilder get _$this {
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
  void replace(ConversationPage other) {
    _$v = other as _$ConversationPage;
  }

  @override
  void update(void Function(ConversationPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConversationPage build() => _build();

  _$ConversationPage _build() {
    _$ConversationPage _$result;
    try {
      _$result = _$v ??
          _$ConversationPage._(
            content: content.build(),
            page: BuiltValueNullFieldError.checkNotNull(
                page, r'ConversationPage', 'page'),
            size: BuiltValueNullFieldError.checkNotNull(
                size, r'ConversationPage', 'size'),
            totalElements: BuiltValueNullFieldError.checkNotNull(
                totalElements, r'ConversationPage', 'totalElements'),
            totalPages: BuiltValueNullFieldError.checkNotNull(
                totalPages, r'ConversationPage', 'totalPages'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'content';
        content.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ConversationPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
