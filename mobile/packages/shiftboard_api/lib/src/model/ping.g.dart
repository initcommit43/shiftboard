// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ping.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Ping extends Ping {
  @override
  final String status;
  @override
  final String version;

  factory _$Ping([void Function(PingBuilder)? updates]) =>
      (PingBuilder()..update(updates))._build();

  _$Ping._({required this.status, required this.version}) : super._();
  @override
  Ping rebuild(void Function(PingBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PingBuilder toBuilder() => PingBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Ping && status == other.status && version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Ping')
          ..add('status', status)
          ..add('version', version))
        .toString();
  }
}

class PingBuilder implements Builder<Ping, PingBuilder> {
  _$Ping? _$v;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  String? _version;
  String? get version => _$this._version;
  set version(String? version) => _$this._version = version;

  PingBuilder() {
    Ping._defaults(this);
  }

  PingBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Ping other) {
    _$v = other as _$Ping;
  }

  @override
  void update(void Function(PingBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Ping build() => _build();

  _$Ping _build() {
    final _$result = _$v ??
        _$Ping._(
          status:
              BuiltValueNullFieldError.checkNotNull(status, r'Ping', 'status'),
          version: BuiltValueNullFieldError.checkNotNull(
              version, r'Ping', 'version'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
