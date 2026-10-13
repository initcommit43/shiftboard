// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker_shift_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WorkerShiftPage extends WorkerShiftPage {
  @override
  final BuiltList<WorkerShift> content;
  @override
  final int page;
  @override
  final int size;
  @override
  final int totalElements;
  @override
  final int totalPages;

  factory _$WorkerShiftPage([void Function(WorkerShiftPageBuilder)? updates]) =>
      (WorkerShiftPageBuilder()..update(updates))._build();

  _$WorkerShiftPage._(
      {required this.content,
      required this.page,
      required this.size,
      required this.totalElements,
      required this.totalPages})
      : super._();
  @override
  WorkerShiftPage rebuild(void Function(WorkerShiftPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkerShiftPageBuilder toBuilder() => WorkerShiftPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkerShiftPage &&
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
    return (newBuiltValueToStringHelper(r'WorkerShiftPage')
          ..add('content', content)
          ..add('page', page)
          ..add('size', size)
          ..add('totalElements', totalElements)
          ..add('totalPages', totalPages))
        .toString();
  }
}

class WorkerShiftPageBuilder
    implements Builder<WorkerShiftPage, WorkerShiftPageBuilder> {
  _$WorkerShiftPage? _$v;

  ListBuilder<WorkerShift>? _content;
  ListBuilder<WorkerShift> get content =>
      _$this._content ??= ListBuilder<WorkerShift>();
  set content(ListBuilder<WorkerShift>? content) => _$this._content = content;

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

  WorkerShiftPageBuilder() {
    WorkerShiftPage._defaults(this);
  }

  WorkerShiftPageBuilder get _$this {
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
  void replace(WorkerShiftPage other) {
    _$v = other as _$WorkerShiftPage;
  }

  @override
  void update(void Function(WorkerShiftPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkerShiftPage build() => _build();

  _$WorkerShiftPage _build() {
    _$WorkerShiftPage _$result;
    try {
      _$result = _$v ??
          _$WorkerShiftPage._(
            content: content.build(),
            page: BuiltValueNullFieldError.checkNotNull(
                page, r'WorkerShiftPage', 'page'),
            size: BuiltValueNullFieldError.checkNotNull(
                size, r'WorkerShiftPage', 'size'),
            totalElements: BuiltValueNullFieldError.checkNotNull(
                totalElements, r'WorkerShiftPage', 'totalElements'),
            totalPages: BuiltValueNullFieldError.checkNotNull(
                totalPages, r'WorkerShiftPage', 'totalPages'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'content';
        content.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'WorkerShiftPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
