// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_shift_worker.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ClientShiftWorker extends ClientShiftWorker {
  @override
  final String firstName;
  @override
  final String lastName;

  factory _$ClientShiftWorker(
          [void Function(ClientShiftWorkerBuilder)? updates]) =>
      (ClientShiftWorkerBuilder()..update(updates))._build();

  _$ClientShiftWorker._({required this.firstName, required this.lastName})
      : super._();
  @override
  ClientShiftWorker rebuild(void Function(ClientShiftWorkerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ClientShiftWorkerBuilder toBuilder() =>
      ClientShiftWorkerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClientShiftWorker &&
        firstName == other.firstName &&
        lastName == other.lastName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, firstName.hashCode);
    _$hash = $jc(_$hash, lastName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ClientShiftWorker')
          ..add('firstName', firstName)
          ..add('lastName', lastName))
        .toString();
  }
}

class ClientShiftWorkerBuilder
    implements Builder<ClientShiftWorker, ClientShiftWorkerBuilder> {
  _$ClientShiftWorker? _$v;

  String? _firstName;
  String? get firstName => _$this._firstName;
  set firstName(String? firstName) => _$this._firstName = firstName;

  String? _lastName;
  String? get lastName => _$this._lastName;
  set lastName(String? lastName) => _$this._lastName = lastName;

  ClientShiftWorkerBuilder() {
    ClientShiftWorker._defaults(this);
  }

  ClientShiftWorkerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _firstName = $v.firstName;
      _lastName = $v.lastName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ClientShiftWorker other) {
    _$v = other as _$ClientShiftWorker;
  }

  @override
  void update(void Function(ClientShiftWorkerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ClientShiftWorker build() => _build();

  _$ClientShiftWorker _build() {
    final _$result = _$v ??
        _$ClientShiftWorker._(
          firstName: BuiltValueNullFieldError.checkNotNull(
              firstName, r'ClientShiftWorker', 'firstName'),
          lastName: BuiltValueNullFieldError.checkNotNull(
              lastName, r'ClientShiftWorker', 'lastName'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
