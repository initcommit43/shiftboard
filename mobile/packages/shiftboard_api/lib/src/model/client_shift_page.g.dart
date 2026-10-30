// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_shift_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ClientShiftPage extends ClientShiftPage {
  @override
  final BuiltList<ClientShift> content;
  @override
  final int page;
  @override
  final int size;
  @override
  final int totalElements;
  @override
  final int totalPages;

  factory _$ClientShiftPage([void Function(ClientShiftPageBuilder)? updates]) =>
      (ClientShiftPageBuilder()..update(updates))._build();

  _$ClientShiftPage._(
      {required this.content,
      required this.page,
      required this.size,
      required this.totalElements,
      required this.totalPages})
      : super._();
  @override
  ClientShiftPage rebuild(void Function(ClientShiftPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ClientShiftPageBuilder toBuilder() => ClientShiftPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClientShiftPage &&
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
    return (newBuiltValueToStringHelper(r'ClientShiftPage')
          ..add('content', content)
          ..add('page', page)
          ..add('size', size)
          ..add('totalElements', totalElements)
          ..add('totalPages', totalPages))
        .toString();
  }
}

class ClientShiftPageBuilder
    implements Builder<ClientShiftPage, ClientShiftPageBuilder> {
  _$ClientShiftPage? _$v;

  ListBuilder<ClientShift>? _content;
  ListBuilder<ClientShift> get content =>
      _$this._content ??= ListBuilder<ClientShift>();
  set content(ListBuilder<ClientShift>? content) => _$this._content = content;

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

  ClientShiftPageBuilder() {
    ClientShiftPage._defaults(this);
  }

  ClientShiftPageBuilder get _$this {
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
  void replace(ClientShiftPage other) {
    _$v = other as _$ClientShiftPage;
  }

  @override
  void update(void Function(ClientShiftPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ClientShiftPage build() => _build();

  _$ClientShiftPage _build() {
    _$ClientShiftPage _$result;
    try {
      _$result = _$v ??
          _$ClientShiftPage._(
            content: content.build(),
            page: BuiltValueNullFieldError.checkNotNull(
                page, r'ClientShiftPage', 'page'),
            size: BuiltValueNullFieldError.checkNotNull(
                size, r'ClientShiftPage', 'size'),
            totalElements: BuiltValueNullFieldError.checkNotNull(
                totalElements, r'ClientShiftPage', 'totalElements'),
            totalPages: BuiltValueNullFieldError.checkNotNull(
                totalPages, r'ClientShiftPage', 'totalPages'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'content';
        content.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ClientShiftPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
