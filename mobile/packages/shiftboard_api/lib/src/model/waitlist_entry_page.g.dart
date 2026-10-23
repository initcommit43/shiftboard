// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'waitlist_entry_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WaitlistEntryPage extends WaitlistEntryPage {
  @override
  final BuiltList<WaitlistEntry> content;
  @override
  final int page;
  @override
  final int size;
  @override
  final int totalElements;
  @override
  final int totalPages;

  factory _$WaitlistEntryPage(
          [void Function(WaitlistEntryPageBuilder)? updates]) =>
      (WaitlistEntryPageBuilder()..update(updates))._build();

  _$WaitlistEntryPage._(
      {required this.content,
      required this.page,
      required this.size,
      required this.totalElements,
      required this.totalPages})
      : super._();
  @override
  WaitlistEntryPage rebuild(void Function(WaitlistEntryPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WaitlistEntryPageBuilder toBuilder() =>
      WaitlistEntryPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WaitlistEntryPage &&
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
    return (newBuiltValueToStringHelper(r'WaitlistEntryPage')
          ..add('content', content)
          ..add('page', page)
          ..add('size', size)
          ..add('totalElements', totalElements)
          ..add('totalPages', totalPages))
        .toString();
  }
}

class WaitlistEntryPageBuilder
    implements Builder<WaitlistEntryPage, WaitlistEntryPageBuilder> {
  _$WaitlistEntryPage? _$v;

  ListBuilder<WaitlistEntry>? _content;
  ListBuilder<WaitlistEntry> get content =>
      _$this._content ??= ListBuilder<WaitlistEntry>();
  set content(ListBuilder<WaitlistEntry>? content) => _$this._content = content;

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

  WaitlistEntryPageBuilder() {
    WaitlistEntryPage._defaults(this);
  }

  WaitlistEntryPageBuilder get _$this {
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
  void replace(WaitlistEntryPage other) {
    _$v = other as _$WaitlistEntryPage;
  }

  @override
  void update(void Function(WaitlistEntryPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WaitlistEntryPage build() => _build();

  _$WaitlistEntryPage _build() {
    _$WaitlistEntryPage _$result;
    try {
      _$result = _$v ??
          _$WaitlistEntryPage._(
            content: content.build(),
            page: BuiltValueNullFieldError.checkNotNull(
                page, r'WaitlistEntryPage', 'page'),
            size: BuiltValueNullFieldError.checkNotNull(
                size, r'WaitlistEntryPage', 'size'),
            totalElements: BuiltValueNullFieldError.checkNotNull(
                totalElements, r'WaitlistEntryPage', 'totalElements'),
            totalPages: BuiltValueNullFieldError.checkNotNull(
                totalPages, r'WaitlistEntryPage', 'totalPages'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'content';
        content.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'WaitlistEntryPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
