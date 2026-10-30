// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_user.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CurrentUser extends CurrentUser {
  @override
  final String id;
  @override
  final String email;
  @override
  final Role role;
  @override
  final AgencySummary agency;
  @override
  final WorkerProfile? worker;
  @override
  final ClientSummary? client;

  factory _$CurrentUser([void Function(CurrentUserBuilder)? updates]) =>
      (CurrentUserBuilder()..update(updates))._build();

  _$CurrentUser._(
      {required this.id,
      required this.email,
      required this.role,
      required this.agency,
      this.worker,
      this.client})
      : super._();
  @override
  CurrentUser rebuild(void Function(CurrentUserBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CurrentUserBuilder toBuilder() => CurrentUserBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CurrentUser &&
        id == other.id &&
        email == other.email &&
        role == other.role &&
        agency == other.agency &&
        worker == other.worker &&
        client == other.client;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, agency.hashCode);
    _$hash = $jc(_$hash, worker.hashCode);
    _$hash = $jc(_$hash, client.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CurrentUser')
          ..add('id', id)
          ..add('email', email)
          ..add('role', role)
          ..add('agency', agency)
          ..add('worker', worker)
          ..add('client', client))
        .toString();
  }
}

class CurrentUserBuilder implements Builder<CurrentUser, CurrentUserBuilder> {
  _$CurrentUser? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  Role? _role;
  Role? get role => _$this._role;
  set role(Role? role) => _$this._role = role;

  AgencySummaryBuilder? _agency;
  AgencySummaryBuilder get agency => _$this._agency ??= AgencySummaryBuilder();
  set agency(AgencySummaryBuilder? agency) => _$this._agency = agency;

  WorkerProfileBuilder? _worker;
  WorkerProfileBuilder get worker => _$this._worker ??= WorkerProfileBuilder();
  set worker(WorkerProfileBuilder? worker) => _$this._worker = worker;

  ClientSummaryBuilder? _client;
  ClientSummaryBuilder get client => _$this._client ??= ClientSummaryBuilder();
  set client(ClientSummaryBuilder? client) => _$this._client = client;

  CurrentUserBuilder() {
    CurrentUser._defaults(this);
  }

  CurrentUserBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _email = $v.email;
      _role = $v.role;
      _agency = $v.agency.toBuilder();
      _worker = $v.worker?.toBuilder();
      _client = $v.client?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CurrentUser other) {
    _$v = other as _$CurrentUser;
  }

  @override
  void update(void Function(CurrentUserBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CurrentUser build() => _build();

  _$CurrentUser _build() {
    _$CurrentUser _$result;
    try {
      _$result = _$v ??
          _$CurrentUser._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'CurrentUser', 'id'),
            email: BuiltValueNullFieldError.checkNotNull(
                email, r'CurrentUser', 'email'),
            role: BuiltValueNullFieldError.checkNotNull(
                role, r'CurrentUser', 'role'),
            agency: agency.build(),
            worker: _worker?.build(),
            client: _client?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'agency';
        agency.build();
        _$failedField = 'worker';
        _worker?.build();
        _$failedField = 'client';
        _client?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CurrentUser', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
