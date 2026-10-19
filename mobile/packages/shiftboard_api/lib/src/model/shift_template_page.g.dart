// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_template_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShiftTemplatePage extends ShiftTemplatePage {
  @override
  final BuiltList<ShiftTemplate> content;
  @override
  final int page;
  @override
  final int size;
  @override
  final int totalElements;
  @override
  final int totalPages;

  factory _$ShiftTemplatePage(
          [void Function(ShiftTemplatePageBuilder)? updates]) =>
      (ShiftTemplatePageBuilder()..update(updates))._build();

  _$ShiftTemplatePage._(
      {required this.content,
      required this.page,
      required this.size,
      required this.totalElements,
      required this.totalPages})
      : super._();
  @override
  ShiftTemplatePage rebuild(void Function(ShiftTemplatePageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShiftTemplatePageBuilder toBuilder() =>
      ShiftTemplatePageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShiftTemplatePage &&
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
    return (newBuiltValueToStringHelper(r'ShiftTemplatePage')
          ..add('content', content)
          ..add('page', page)
          ..add('size', size)
          ..add('totalElements', totalElements)
          ..add('totalPages', totalPages))
        .toString();
  }
}

class ShiftTemplatePageBuilder
    implements Builder<ShiftTemplatePage, ShiftTemplatePageBuilder> {
  _$ShiftTemplatePage? _$v;

  ListBuilder<ShiftTemplate>? _content;
  ListBuilder<ShiftTemplate> get content =>
      _$this._content ??= ListBuilder<ShiftTemplate>();
  set content(ListBuilder<ShiftTemplate>? content) => _$this._content = content;

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

  ShiftTemplatePageBuilder() {
    ShiftTemplatePage._defaults(this);
  }

  ShiftTemplatePageBuilder get _$this {
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
  void replace(ShiftTemplatePage other) {
    _$v = other as _$ShiftTemplatePage;
  }

  @override
  void update(void Function(ShiftTemplatePageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShiftTemplatePage build() => _build();

  _$ShiftTemplatePage _build() {
    _$ShiftTemplatePage _$result;
    try {
      _$result = _$v ??
          _$ShiftTemplatePage._(
            content: content.build(),
            page: BuiltValueNullFieldError.checkNotNull(
                page, r'ShiftTemplatePage', 'page'),
            size: BuiltValueNullFieldError.checkNotNull(
                size, r'ShiftTemplatePage', 'size'),
            totalElements: BuiltValueNullFieldError.checkNotNull(
                totalElements, r'ShiftTemplatePage', 'totalElements'),
            totalPages: BuiltValueNullFieldError.checkNotNull(
                totalPages, r'ShiftTemplatePage', 'totalPages'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'content';
        content.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ShiftTemplatePage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
