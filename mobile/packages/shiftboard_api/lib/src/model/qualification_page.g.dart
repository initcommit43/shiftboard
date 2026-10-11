// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qualification_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$QualificationPage extends QualificationPage {
  @override
  final BuiltList<Qualification> content;
  @override
  final int page;
  @override
  final int size;
  @override
  final int totalElements;
  @override
  final int totalPages;

  factory _$QualificationPage(
          [void Function(QualificationPageBuilder)? updates]) =>
      (QualificationPageBuilder()..update(updates))._build();

  _$QualificationPage._(
      {required this.content,
      required this.page,
      required this.size,
      required this.totalElements,
      required this.totalPages})
      : super._();
  @override
  QualificationPage rebuild(void Function(QualificationPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  QualificationPageBuilder toBuilder() =>
      QualificationPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is QualificationPage &&
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
    return (newBuiltValueToStringHelper(r'QualificationPage')
          ..add('content', content)
          ..add('page', page)
          ..add('size', size)
          ..add('totalElements', totalElements)
          ..add('totalPages', totalPages))
        .toString();
  }
}

class QualificationPageBuilder
    implements Builder<QualificationPage, QualificationPageBuilder> {
  _$QualificationPage? _$v;

  ListBuilder<Qualification>? _content;
  ListBuilder<Qualification> get content =>
      _$this._content ??= ListBuilder<Qualification>();
  set content(ListBuilder<Qualification>? content) => _$this._content = content;

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

  QualificationPageBuilder() {
    QualificationPage._defaults(this);
  }

  QualificationPageBuilder get _$this {
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
  void replace(QualificationPage other) {
    _$v = other as _$QualificationPage;
  }

  @override
  void update(void Function(QualificationPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  QualificationPage build() => _build();

  _$QualificationPage _build() {
    _$QualificationPage _$result;
    try {
      _$result = _$v ??
          _$QualificationPage._(
            content: content.build(),
            page: BuiltValueNullFieldError.checkNotNull(
                page, r'QualificationPage', 'page'),
            size: BuiltValueNullFieldError.checkNotNull(
                size, r'QualificationPage', 'size'),
            totalElements: BuiltValueNullFieldError.checkNotNull(
                totalElements, r'QualificationPage', 'totalElements'),
            totalPages: BuiltValueNullFieldError.checkNotNull(
                totalPages, r'QualificationPage', 'totalPages'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'content';
        content.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'QualificationPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
