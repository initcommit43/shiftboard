// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agency_summary.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AgencySummary extends AgencySummary {
  @override
  final String id;
  @override
  final String name;

  factory _$AgencySummary([void Function(AgencySummaryBuilder)? updates]) =>
      (AgencySummaryBuilder()..update(updates))._build();

  _$AgencySummary._({required this.id, required this.name}) : super._();
  @override
  AgencySummary rebuild(void Function(AgencySummaryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AgencySummaryBuilder toBuilder() => AgencySummaryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AgencySummary && id == other.id && name == other.name;
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
    return (newBuiltValueToStringHelper(r'AgencySummary')
          ..add('id', id)
          ..add('name', name))
        .toString();
  }
}

class AgencySummaryBuilder
    implements Builder<AgencySummary, AgencySummaryBuilder> {
  _$AgencySummary? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  AgencySummaryBuilder() {
    AgencySummary._defaults(this);
  }

  AgencySummaryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AgencySummary other) {
    _$v = other as _$AgencySummary;
  }

  @override
  void update(void Function(AgencySummaryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AgencySummary build() => _build();

  _$AgencySummary _build() {
    final _$result = _$v ??
        _$AgencySummary._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'AgencySummary', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'AgencySummary', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
