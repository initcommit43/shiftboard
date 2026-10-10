// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qualification.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Qualification extends Qualification {
  @override
  final String id;
  @override
  final String name;

  factory _$Qualification([void Function(QualificationBuilder)? updates]) =>
      (QualificationBuilder()..update(updates))._build();

  _$Qualification._({required this.id, required this.name}) : super._();
  @override
  Qualification rebuild(void Function(QualificationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  QualificationBuilder toBuilder() => QualificationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Qualification && id == other.id && name == other.name;
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
    return (newBuiltValueToStringHelper(r'Qualification')
          ..add('id', id)
          ..add('name', name))
        .toString();
  }
}

class QualificationBuilder
    implements Builder<Qualification, QualificationBuilder> {
  _$Qualification? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  QualificationBuilder() {
    Qualification._defaults(this);
  }

  QualificationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Qualification other) {
    _$v = other as _$Qualification;
  }

  @override
  void update(void Function(QualificationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Qualification build() => _build();

  _$Qualification _build() {
    final _$result = _$v ??
        _$Qualification._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Qualification', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'Qualification', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
