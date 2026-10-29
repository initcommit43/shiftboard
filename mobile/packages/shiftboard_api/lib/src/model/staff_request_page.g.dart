// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_request_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StaffRequestPage extends StaffRequestPage {
  @override
  final BuiltList<StaffRequest> content;
  @override
  final int page;
  @override
  final int size;
  @override
  final int totalElements;
  @override
  final int totalPages;

  factory _$StaffRequestPage(
          [void Function(StaffRequestPageBuilder)? updates]) =>
      (StaffRequestPageBuilder()..update(updates))._build();

  _$StaffRequestPage._(
      {required this.content,
      required this.page,
      required this.size,
      required this.totalElements,
      required this.totalPages})
      : super._();
  @override
  StaffRequestPage rebuild(void Function(StaffRequestPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StaffRequestPageBuilder toBuilder() =>
      StaffRequestPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StaffRequestPage &&
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
    return (newBuiltValueToStringHelper(r'StaffRequestPage')
          ..add('content', content)
          ..add('page', page)
          ..add('size', size)
          ..add('totalElements', totalElements)
          ..add('totalPages', totalPages))
        .toString();
  }
}

class StaffRequestPageBuilder
    implements Builder<StaffRequestPage, StaffRequestPageBuilder> {
  _$StaffRequestPage? _$v;

  ListBuilder<StaffRequest>? _content;
  ListBuilder<StaffRequest> get content =>
      _$this._content ??= ListBuilder<StaffRequest>();
  set content(ListBuilder<StaffRequest>? content) => _$this._content = content;

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

  StaffRequestPageBuilder() {
    StaffRequestPage._defaults(this);
  }

  StaffRequestPageBuilder get _$this {
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
  void replace(StaffRequestPage other) {
    _$v = other as _$StaffRequestPage;
  }

  @override
  void update(void Function(StaffRequestPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StaffRequestPage build() => _build();

  _$StaffRequestPage _build() {
    _$StaffRequestPage _$result;
    try {
      _$result = _$v ??
          _$StaffRequestPage._(
            content: content.build(),
            page: BuiltValueNullFieldError.checkNotNull(
                page, r'StaffRequestPage', 'page'),
            size: BuiltValueNullFieldError.checkNotNull(
                size, r'StaffRequestPage', 'size'),
            totalElements: BuiltValueNullFieldError.checkNotNull(
                totalElements, r'StaffRequestPage', 'totalElements'),
            totalPages: BuiltValueNullFieldError.checkNotNull(
                totalPages, r'StaffRequestPage', 'totalPages'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'content';
        content.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'StaffRequestPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
