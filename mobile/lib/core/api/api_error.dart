import 'dart:io';

import 'package:dio/dio.dart';
import 'package:shiftboard_api/shiftboard_api.dart';

import '../l10n/l10n.dart';

/// The API's machine-readable error codes this app reacts to.
abstract final class ApiErrorCode {
  static const invalidCredentials = 'invalid_credentials';
  static const wrongClient = 'wrong_client';
  static const tooManyAttempts = 'too_many_attempts';
  static const validationFailed = 'validation_failed';
  static const signupCodeUnknown = 'signup_code_unknown';
  static const emailAlreadyRegistered = 'email_already_registered';
  static const workerNotActive = 'worker_not_active';
  static const shiftNotFound = 'shift_not_found';
  static const shiftFull = 'shift_full';
  static const shiftAlreadyClaimed = 'shift_already_claimed';
  static const shiftStarted = 'shift_started';
  static const shiftNotOpen = 'shift_not_open';
  static const shiftOverlap = 'shift_overlap';
  static const assignmentNotFound = 'assignment_not_found';
  static const assignmentNotActive = 'assignment_not_active';
  static const cancellationDeadlinePassed = 'cancellation_deadline_passed';
  static const concurrentChange = 'concurrent_change';
}

/// A failed API call, reduced to what the UI decides on.
class ApiError {
  const ApiError({this.status, this.code, this.fieldCodes = const {}});

  factory ApiError.from(Object error) {
    final response = error is DioException ? error.response : null;
    if (response == null) return const ApiError();

    final problem = _problem(response.data);
    return ApiError(
      status: response.statusCode,
      code: problem?.code,
      fieldCodes: {
        for (final error in problem?.errors ?? const <FieldError>[])
          error.field: error.code,
      },
    );
  }

  /// Null when the API did not answer at all.
  final int? status;
  final String? code;

  /// The request fields the API rejected, each with the reason's code.
  final Map<String, String> fieldCodes;

  bool get isOffline => status == null;

  /// The one place where error codes become text.
  String message(AppLocalizations l10n) {
    if (isOffline) return l10n.errorOffline;
    return switch (code) {
      ApiErrorCode.invalidCredentials ||
      ApiErrorCode.wrongClient => l10n.errorInvalidCredentials,
      ApiErrorCode.tooManyAttempts => l10n.errorTooManyAttempts,
      ApiErrorCode.validationFailed => l10n.errorValidationFailed,
      ApiErrorCode.signupCodeUnknown => l10n.signupInvalidLinkTitle,
      ApiErrorCode.emailAlreadyRegistered => l10n.errorEmailAlreadyRegistered,
      ApiErrorCode.concurrentChange => l10n.errorConcurrentChange,
      _ when status == HttpStatus.tooManyRequests => l10n.errorTooManyAttempts,
      _ => l10n.errorGeneric,
    };
  }

  /// The message for a rejected request [field], or null if it was accepted.
  String? fieldMessage(AppLocalizations l10n, String field) {
    final fieldCode = fieldCodes[field];
    if (fieldCode == null) return null;
    return switch ((field, fieldCode)) {
      (_, 'required') => l10n.fieldRequired,
      ('email', 'invalid_format' || 'invalid_length') => l10n.fieldEmailInvalid,
      ('dateOfBirth', 'invalid_format' || 'out_of_range') =>
        l10n.signupDateOfBirthInvalid,
      ('phone', 'invalid_format' || 'invalid_length') =>
        l10n.signupPhoneInvalid,
      ('password', 'invalid_length') => l10n.signupPasswordTooShort,
      _ => l10n.fieldInvalid,
    };
  }

  static Problem? _problem(Object? body) {
    if (body is! Map) return null;
    try {
      return standardSerializers.deserializeWith(Problem.serializer, body);
    } catch (_) {
      // Not a problem document, for example an error page from a proxy.
      return null;
    }
  }
}
