// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agency_features.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AgencyFeatures extends AgencyFeatures {
  @override
  final bool contactButton;

  factory _$AgencyFeatures([void Function(AgencyFeaturesBuilder)? updates]) =>
      (AgencyFeaturesBuilder()..update(updates))._build();

  _$AgencyFeatures._({required this.contactButton}) : super._();
  @override
  AgencyFeatures rebuild(void Function(AgencyFeaturesBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AgencyFeaturesBuilder toBuilder() => AgencyFeaturesBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AgencyFeatures && contactButton == other.contactButton;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, contactButton.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AgencyFeatures')
          ..add('contactButton', contactButton))
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

  AgencyFeaturesBuilder() {
    AgencyFeatures._defaults(this);
  }

  AgencyFeaturesBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _contactButton = $v.contactButton;
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
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
