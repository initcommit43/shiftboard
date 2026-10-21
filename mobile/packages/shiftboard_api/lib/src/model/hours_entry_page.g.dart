// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hours_entry_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$HoursEntryPage extends HoursEntryPage {
  @override
  final BuiltList<HoursEntry> content;
  @override
  final int page;
  @override
  final int size;
  @override
  final int totalElements;
  @override
  final int totalPages;

  factory _$HoursEntryPage([void Function(HoursEntryPageBuilder)? updates]) =>
      (HoursEntryPageBuilder()..update(updates))._build();

  _$HoursEntryPage._(
      {required this.content,
      required this.page,
      required this.size,
      required this.totalElements,
      required this.totalPages})
      : super._();
  @override
  HoursEntryPage rebuild(void Function(HoursEntryPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  HoursEntryPageBuilder toBuilder() => HoursEntryPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HoursEntryPage &&
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
    return (newBuiltValueToStringHelper(r'HoursEntryPage')
          ..add('content', content)
          ..add('page', page)
          ..add('size', size)
          ..add('totalElements', totalElements)
          ..add('totalPages', totalPages))
        .toString();
  }
}

class HoursEntryPageBuilder
    implements Builder<HoursEntryPage, HoursEntryPageBuilder> {
  _$HoursEntryPage? _$v;

  ListBuilder<HoursEntry>? _content;
  ListBuilder<HoursEntry> get content =>
      _$this._content ??= ListBuilder<HoursEntry>();
  set content(ListBuilder<HoursEntry>? content) => _$this._content = content;

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

  HoursEntryPageBuilder() {
    HoursEntryPage._defaults(this);
  }

  HoursEntryPageBuilder get _$this {
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
  void replace(HoursEntryPage other) {
    _$v = other as _$HoursEntryPage;
  }

  @override
  void update(void Function(HoursEntryPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  HoursEntryPage build() => _build();

  _$HoursEntryPage _build() {
    _$HoursEntryPage _$result;
    try {
      _$result = _$v ??
          _$HoursEntryPage._(
            content: content.build(),
            page: BuiltValueNullFieldError.checkNotNull(
                page, r'HoursEntryPage', 'page'),
            size: BuiltValueNullFieldError.checkNotNull(
                size, r'HoursEntryPage', 'size'),
            totalElements: BuiltValueNullFieldError.checkNotNull(
                totalElements, r'HoursEntryPage', 'totalElements'),
            totalPages: BuiltValueNullFieldError.checkNotNull(
                totalPages, r'HoursEntryPage', 'totalPages'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'content';
        content.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'HoursEntryPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
