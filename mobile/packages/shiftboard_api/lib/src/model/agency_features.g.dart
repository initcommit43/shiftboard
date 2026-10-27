// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agency_features.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AgencyFeatures extends AgencyFeatures {
  @override
  final bool contactButton;
  @override
  final bool? checkIn;
  @override
  final bool? clientPortal;

  factory _$AgencyFeatures([void Function(AgencyFeaturesBuilder)? updates]) =>
      (AgencyFeaturesBuilder()..update(updates))._build();

  _$AgencyFeatures._(
      {required this.contactButton, this.checkIn, this.clientPortal})
      : super._();
  @override
  AgencyFeatures rebuild(void Function(AgencyFeaturesBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AgencyFeaturesBuilder toBuilder() => AgencyFeaturesBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AgencyFeatures &&
        contactButton == other.contactButton &&
        checkIn == other.checkIn &&
        clientPortal == other.clientPortal;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, contactButton.hashCode);
    _$hash = $jc(_$hash, checkIn.hashCode);
    _$hash = $jc(_$hash, clientPortal.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AgencyFeatures')
          ..add('contactButton', contactButton)
          ..add('checkIn', checkIn)
          ..add('clientPortal', clientPortal))
        .toString();
  }
}

class AgencyFeaturesBuilder
    implements Builder<AgencyFeatures, AgencyFeaturesBuilder> {
  _$AgencyFeatures? _$v;

  bool? _contactButton;
  bool? get contactButton => _$this._contactButton;
  set contactButton(bool? contactButton) =>
      _$this._contactButton = contactButton;

  bool? _checkIn;
  bool? get checkIn => _$this._checkIn;
  set checkIn(bool? checkIn) => _$this._checkIn = checkIn;

  bool? _clientPortal;
  bool? get clientPortal => _$this._clientPortal;
  set clientPortal(bool? clientPortal) => _$this._clientPortal = clientPortal;

  AgencyFeaturesBuilder() {
    AgencyFeatures._defaults(this);
  }

  AgencyFeaturesBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _contactButton = $v.contactButton;
      _checkIn = $v.checkIn;
      _clientPortal = $v.clientPortal;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AgencyFeatures other) {
    _$v = other as _$AgencyFeatures;
  }

  @override
  void update(void Function(AgencyFeaturesBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AgencyFeatures build() => _build();

  _$AgencyFeatures _build() {
    final _$result = _$v ??
        _$AgencyFeatures._(
          contactButton: BuiltValueNullFieldError.checkNotNull(
              contactButton, r'AgencyFeatures', 'contactButton'),
          checkIn: checkIn,
          clientPortal: clientPortal,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
