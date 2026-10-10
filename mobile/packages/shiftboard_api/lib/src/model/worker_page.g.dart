// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WorkerPage extends WorkerPage {
  @override
  final BuiltList<Worker> content;
  @override
  final int page;
  @override
  final int size;
  @override
  final int totalElements;
  @override
  final int totalPages;

  factory _$WorkerPage([void Function(WorkerPageBuilder)? updates]) =>
      (WorkerPageBuilder()..update(updates))._build();

  _$WorkerPage._(
      {required this.content,
      required this.page,
      required this.size,
      required this.totalElements,
      required this.totalPages})
      : super._();
  @override
  WorkerPage rebuild(void Function(WorkerPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkerPageBuilder toBuilder() => WorkerPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkerPage &&
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
    return (newBuiltValueToStringHelper(r'WorkerPage')
          ..add('content', content)
          ..add('page', page)
          ..add('size', size)
          ..add('totalElements', totalElements)
          ..add('totalPages', totalPages))
        .toString();
  }
}

class WorkerPageBuilder implements Builder<WorkerPage, WorkerPageBuilder> {
  _$WorkerPage? _$v;

  ListBuilder<Worker>? _content;
  ListBuilder<Worker> get content => _$this._content ??= ListBuilder<Worker>();
  set content(ListBuilder<Worker>? content) => _$this._content = content;

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

  WorkerPageBuilder() {
    WorkerPage._defaults(this);
  }

  WorkerPageBuilder get _$this {
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
  void replace(WorkerPage other) {
    _$v = other as _$WorkerPage;
  }

  @override
  void update(void Function(WorkerPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkerPage build() => _build();

  _$WorkerPage _build() {
    _$WorkerPage _$result;
    try {
      _$result = _$v ??
          _$WorkerPage._(
            content: content.build(),
            page: BuiltValueNullFieldError.checkNotNull(
                page, r'WorkerPage', 'page'),
            size: BuiltValueNullFieldError.checkNotNull(
                size, r'WorkerPage', 'size'),
            totalElements: BuiltValueNullFieldError.checkNotNull(
                totalElements, r'WorkerPage', 'totalElements'),
            totalPages: BuiltValueNullFieldError.checkNotNull(
                totalPages, r'WorkerPage', 'totalPages'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'content';
        content.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'WorkerPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
