// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_assignment_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShiftAssignmentPage extends ShiftAssignmentPage {
  @override
  final BuiltList<ShiftAssignment> content;
  @override
  final int page;
  @override
  final int size;
  @override
  final int totalElements;
  @override
  final int totalPages;

  factory _$ShiftAssignmentPage(
          [void Function(ShiftAssignmentPageBuilder)? updates]) =>
      (ShiftAssignmentPageBuilder()..update(updates))._build();

  _$ShiftAssignmentPage._(
      {required this.content,
      required this.page,
      required this.size,
      required this.totalElements,
      required this.totalPages})
      : super._();
  @override
  ShiftAssignmentPage rebuild(
          void Function(ShiftAssignmentPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShiftAssignmentPageBuilder toBuilder() =>
      ShiftAssignmentPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShiftAssignmentPage &&
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
    return (newBuiltValueToStringHelper(r'ShiftAssignmentPage')
          ..add('content', content)
          ..add('page', page)
          ..add('size', size)
          ..add('totalElements', totalElements)
          ..add('totalPages', totalPages))
        .toString();
  }
}

class ShiftAssignmentPageBuilder
    implements Builder<ShiftAssignmentPage, ShiftAssignmentPageBuilder> {
  _$ShiftAssignmentPage? _$v;

  ListBuilder<ShiftAssignment>? _content;
  ListBuilder<ShiftAssignment> get content =>
      _$this._content ??= ListBuilder<ShiftAssignment>();
  set content(ListBuilder<ShiftAssignment>? content) =>
      _$this._content = content;

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

  ShiftAssignmentPageBuilder() {
    ShiftAssignmentPage._defaults(this);
  }

  ShiftAssignmentPageBuilder get _$this {
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
  void replace(ShiftAssignmentPage other) {
    _$v = other as _$ShiftAssignmentPage;
  }

  @override
  void update(void Function(ShiftAssignmentPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShiftAssignmentPage build() => _build();

  _$ShiftAssignmentPage _build() {
    _$ShiftAssignmentPage _$result;
    try {
      _$result = _$v ??
          _$ShiftAssignmentPage._(
            content: content.build(),
            page: BuiltValueNullFieldError.checkNotNull(
                page, r'ShiftAssignmentPage', 'page'),
            size: BuiltValueNullFieldError.checkNotNull(
                size, r'ShiftAssignmentPage', 'size'),
            totalElements: BuiltValueNullFieldError.checkNotNull(
                totalElements, r'ShiftAssignmentPage', 'totalElements'),
            totalPages: BuiltValueNullFieldError.checkNotNull(
                totalPages, r'ShiftAssignmentPage', 'totalPages'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'content';
        content.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ShiftAssignmentPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
