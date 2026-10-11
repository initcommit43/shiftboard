// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ClientPage extends ClientPage {
  @override
  final BuiltList<Client> content;
  @override
  final int page;
  @override
  final int size;
  @override
  final int totalElements;
  @override
  final int totalPages;

  factory _$ClientPage([void Function(ClientPageBuilder)? updates]) =>
      (ClientPageBuilder()..update(updates))._build();

  _$ClientPage._(
      {required this.content,
      required this.page,
      required this.size,
      required this.totalElements,
      required this.totalPages})
      : super._();
  @override
  ClientPage rebuild(void Function(ClientPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ClientPageBuilder toBuilder() => ClientPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClientPage &&
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
    return (newBuiltValueToStringHelper(r'ClientPage')
          ..add('content', content)
          ..add('page', page)
          ..add('size', size)
          ..add('totalElements', totalElements)
          ..add('totalPages', totalPages))
        .toString();
  }
}

class ClientPageBuilder implements Builder<ClientPage, ClientPageBuilder> {
  _$ClientPage? _$v;

  ListBuilder<Client>? _content;
  ListBuilder<Client> get content => _$this._content ??= ListBuilder<Client>();
  set content(ListBuilder<Client>? content) => _$this._content = content;

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

  ClientPageBuilder() {
    ClientPage._defaults(this);
  }

  ClientPageBuilder get _$this {
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
  void replace(ClientPage other) {
    _$v = other as _$ClientPage;
  }

  @override
  void update(void Function(ClientPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ClientPage build() => _build();

  _$ClientPage _build() {
    _$ClientPage _$result;
    try {
      _$result = _$v ??
          _$ClientPage._(
            content: content.build(),
            page: BuiltValueNullFieldError.checkNotNull(
                page, r'ClientPage', 'page'),
            size: BuiltValueNullFieldError.checkNotNull(
                size, r'ClientPage', 'size'),
            totalElements: BuiltValueNullFieldError.checkNotNull(
                totalElements, r'ClientPage', 'totalElements'),
            totalPages: BuiltValueNullFieldError.checkNotNull(
                totalPages, r'ClientPage', 'totalPages'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'content';
        content.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ClientPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
