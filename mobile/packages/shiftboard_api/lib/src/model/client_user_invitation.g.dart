// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_user_invitation.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ClientUserInvitation extends ClientUserInvitation {
  @override
  final ClientUser user;
  @override
  final String setupCode;
  @override
  final DateTime expiresAt;

  factory _$ClientUserInvitation(
          [void Function(ClientUserInvitationBuilder)? updates]) =>
      (ClientUserInvitationBuilder()..update(updates))._build();

  _$ClientUserInvitation._(
      {required this.user, required this.setupCode, required this.expiresAt})
      : super._();
  @override
  ClientUserInvitation rebuild(
          void Function(ClientUserInvitationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ClientUserInvitationBuilder toBuilder() =>
      ClientUserInvitationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClientUserInvitation &&
        user == other.user &&
        setupCode == other.setupCode &&
        expiresAt == other.expiresAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jc(_$hash, setupCode.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ClientUserInvitation')
          ..add('user', user)
          ..add('setupCode', setupCode)
          ..add('expiresAt', expiresAt))
        .toString();
  }
}

class ClientUserInvitationBuilder
    implements Builder<ClientUserInvitation, ClientUserInvitationBuilder> {
  _$ClientUserInvitation? _$v;

  ClientUserBuilder? _user;
  ClientUserBuilder get user => _$this._user ??= ClientUserBuilder();
  set user(ClientUserBuilder? user) => _$this._user = user;

  String? _setupCode;
  String? get setupCode => _$this._setupCode;
  set setupCode(String? setupCode) => _$this._setupCode = setupCode;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  ClientUserInvitationBuilder() {
    ClientUserInvitation._defaults(this);
  }

  ClientUserInvitationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _user = $v.user.toBuilder();
      _setupCode = $v.setupCode;
      _expiresAt = $v.expiresAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ClientUserInvitation other) {
    _$v = other as _$ClientUserInvitation;
  }

  @override
  void update(void Function(ClientUserInvitationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ClientUserInvitation build() => _build();

  _$ClientUserInvitation _build() {
    _$ClientUserInvitation _$result;
    try {
      _$result = _$v ??
          _$ClientUserInvitation._(
            user: user.build(),
            setupCode: BuiltValueNullFieldError.checkNotNull(
                setupCode, r'ClientUserInvitation', 'setupCode'),
            expiresAt: BuiltValueNullFieldError.checkNotNull(
                expiresAt, r'ClientUserInvitation', 'expiresAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        user.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ClientUserInvitation', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
