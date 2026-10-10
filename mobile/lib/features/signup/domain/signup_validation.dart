/// Client-side checks of the signup form; the API has the final say.
abstract final class SignupValidation {
  static const passwordMinLength = 8;

  /// The oldest date of birth the API accepts, in years before today.
  static const maxAgeYears = 120;

  /// Where the date of birth picker opens, in years before today.
  static const typicalAgeYears = 25;

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _phone = RegExp(r'^\+?[0-9 ()/.-]+$');
  static const _phoneMinDigits = 8;

  static bool isEmail(String value) => _email.hasMatch(value);

  /// Digits with the usual separators and an optional leading plus. Too few
  /// digits for a subscriber number count as a typo.
  static bool isPhone(String value) {
    final digits = value.replaceAll(RegExp('[^0-9]'), '').length;
    return _phone.hasMatch(value) && digits >= _phoneMinDigits;
  }
}
