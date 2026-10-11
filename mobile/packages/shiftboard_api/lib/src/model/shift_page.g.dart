// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShiftPage extends ShiftPage {
  @override
  final BuiltList<Shift> content;
  @override
  final int page;
  @override
  final int size;
  @override
  final int totalElements;
  @override
  final int totalPages;

  factory _$ShiftPage([void Function(ShiftPageBuilder)? updates]) =>
      (ShiftPageBuilder()..update(updates))._build();

  _$ShiftPage._(
      {required this.content,
      required this.page,
      required this.size,
      required this.totalElements,
      required this.totalPages})
      : super._();
  @override
  ShiftPage rebuild(void Function(ShiftPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShiftPageBuilder toBuilder() => ShiftPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShiftPage &&
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
    return (newBuiltValueToStringHelper(r'ShiftPage')
          ..add('content', content)
          ..add('page', page)
          ..add('size', size)
          ..add('totalElements', totalElements)
          ..add('totalPages', totalPages))
        .toString();
  }
}

class ShiftPageBuilder implements Builder<ShiftPage, ShiftPageBuilder> {
  _$ShiftPage? _$v;

  ListBuilder<Shift>? _content;
  ListBuilder<Shift> get content => _$this._content ??= ListBuilder<Shift>();
  set content(ListBuilder<Shift>? content) => _$this._content = content;

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

  ShiftPageBuilder() {
    ShiftPage._defaults(this);
  }

  ShiftPageBuilder get _$this {
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
  void replace(ShiftPage other) {
    _$v = other as _$ShiftPage;
  }

  @override
  void update(void Function(ShiftPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShiftPage build() => _build();

  _$ShiftPage _build() {
    _$ShiftPage _$result;
    try {
      _$result = _$v ??
          _$ShiftPage._(
            content: content.build(),
            page: BuiltValueNullFieldError.checkNotNull(
                page, r'ShiftPage', 'page'),
            size: BuiltValueNullFieldError.checkNotNull(
                size, r'ShiftPage', 'size'),
            totalElements: BuiltValueNullFieldError.checkNotNull(
                totalElements, r'ShiftPage', 'totalElements'),
            totalPages: BuiltValueNullFieldError.checkNotNull(
                totalPages, r'ShiftPage', 'totalPages'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'content';
        content.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ShiftPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
