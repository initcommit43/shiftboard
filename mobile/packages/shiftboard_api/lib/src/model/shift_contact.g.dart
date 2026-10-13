// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_contact.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShiftContact extends ShiftContact {
  @override
  final String name;
  @override
  final String? phone;

  factory _$ShiftContact([void Function(ShiftContactBuilder)? updates]) =>
      (ShiftContactBuilder()..update(updates))._build();

  _$ShiftContact._({required this.name, this.phone}) : super._();
  @override
  ShiftContact rebuild(void Function(ShiftContactBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShiftContactBuilder toBuilder() => ShiftContactBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShiftContact && name == other.name && phone == other.phone;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ShiftContact')
          ..add('name', name)
          ..add('phone', phone))
        .toString();
  }
}

class ShiftContactBuilder
    implements Builder<ShiftContact, ShiftContactBuilder> {
  _$ShiftContact? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  ShiftContactBuilder() {
    ShiftContact._defaults(this);
  }

  ShiftContactBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _phone = $v.phone;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShiftContact other) {
    _$v = other as _$ShiftContact;
  }

  @override
  void update(void Function(ShiftContactBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShiftContact build() => _build();

  _$ShiftContact _build() {
    final _$result = _$v ??
        _$ShiftContact._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'ShiftContact', 'name'),
          phone: phone,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
