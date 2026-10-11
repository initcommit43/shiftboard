// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_summary.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ClientSummary extends ClientSummary {
  @override
  final String id;
  @override
  final String name;

  factory _$ClientSummary([void Function(ClientSummaryBuilder)? updates]) =>
      (ClientSummaryBuilder()..update(updates))._build();

  _$ClientSummary._({required this.id, required this.name}) : super._();
  @override
  ClientSummary rebuild(void Function(ClientSummaryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ClientSummaryBuilder toBuilder() => ClientSummaryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClientSummary && id == other.id && name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ClientSummary')
          ..add('id', id)
          ..add('name', name))
        .toString();
  }
}

class ClientSummaryBuilder
    implements Builder<ClientSummary, ClientSummaryBuilder> {
  _$ClientSummary? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  ClientSummaryBuilder() {
    ClientSummary._defaults(this);
  }

  ClientSummaryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ClientSummary other) {
    _$v = other as _$ClientSummary;
  }

  @override
  void update(void Function(ClientSummaryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ClientSummary build() => _build();

  _$ClientSummary _build() {
    final _$result = _$v ??
        _$ClientSummary._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'ClientSummary', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'ClientSummary', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
