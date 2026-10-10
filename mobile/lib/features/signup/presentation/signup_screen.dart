import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shiftboard_api/shiftboard_api.dart';

import '../../../core/api/api_error.dart';
import '../../../core/api/api_provider.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_alert.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/form_page.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/prompt_link.dart';
import '../../../core/widgets/status_message.dart';
import '../../auth/data/session.dart';
import '../data/signup_info_provider.dart';
import '../domain/signup_validation.dart';

/// The signup behind an agency's invitation: looks the code up, then shows
/// the form, or says that the invitation is not valid.
class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key, required this.signupCode});

  final String signupCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final info = ref.watch(signupInfoProvider(signupCode));

    Widget toLogin(AppButtonVariant variant) => AppButton(
      label: l10n.signupToLogin,
      variant: variant,
      onPressed: () => context.go(AppRoutes.login),
    );

    return info.when(
      skipLoadingOnRefresh: false,
      data: (info) => _SignupForm(signupCode: signupCode, info: info),
      loading: () => StatusPage(
        body: CircularProgressIndicator(
          strokeWidth: 3,
          semanticsLabel: l10n.loadingLabel,
        ),
      ),
      error: (error, _) => ApiError.from(error).status == HttpStatus.notFound
          ? StatusPage(
              body: StatusMessage(
                icon: Icons.link_rounded,
                title: l10n.signupInvalidLinkTitle,
                message: l10n.signupInvalidLinkMessage,
              ),
              actions: [toLogin(AppButtonVariant.primary)],
            )
          : StatusPage(
              body: StatusMessage(
                icon: Icons.warning_amber_rounded,
                tone: StatusTone.error,
                title: l10n.signupLoadErrorTitle,
                message: l10n.errorCheckConnection,
              ),
              actions: [
                AppButton(
                  label: l10n.actionRetry,
                  onPressed: () =>
                      ref.invalidate(signupInfoProvider(signupCode)),
                ),
                toLogin(AppButtonVariant.ghost),
              ],
            ),
    );
  }
}

/// Request fields the API can reject, by their names in the contract.
enum _Field { firstName, lastName, email, phone, password }

class _SignupForm extends ConsumerStatefulWidget {
  const _SignupForm({required this.signupCode, required this.info});

  final String signupCode;
  final SignupInfo info;

  @override
  ConsumerState<_SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends ConsumerState<_SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  bool _submitting = false;

  /// What the API rejected: messages for single fields, or one for the form.
  Map<_Field, String> _fieldErrors = const {};
  String? _formError;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final invalid = _formKey.currentState!.validateGranularly();
    if (invalid.isNotEmpty) {
      await Scrollable.ensureVisible(
        invalid.first.context,
        alignment: 0.2,
        duration: Durations.short4,
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _fieldErrors = const {};
      _formError = null;
    });

    try {
      final response = await ref
          .read(apiProvider)
          .getSignupApi()
          .signUp(
            signupCode: widget.signupCode,
            workerSignupRequest: WorkerSignupRequest(
              (b) => b
                ..firstName = _firstName.text.trim()
                ..lastName = _lastName.text.trim()
                ..email = _email.text.trim()
                ..phone = _phone.text.trim()
                ..password = _password.text,
            ),
          );
      // The router moves on to the waiting screen with the new session.
      await ref.read(sessionProvider.notifier).start(response.data!);
    } on DioException catch (error) {
      if (mounted) _showError(ApiError.from(error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showError(ApiError error) {
    final l10n = context.l10n;
    if (error.code == ApiErrorCode.signupCodeUnknown) {
      // The invitation was withdrawn in the meantime.
      ref.invalidate(signupInfoProvider(widget.signupCode));
      return;
    }

    final fieldErrors = {
      for (final field in _Field.values)
        field: ?error.fieldMessage(l10n, field.name),
      if (error.code == ApiErrorCode.emailAlreadyRegistered)
        _Field.email: l10n.errorEmailAlreadyRegistered,
    };
    setState(() {
      _fieldErrors = fieldErrors;
      _formError = fieldErrors.isEmpty ? error.message(l10n) : null;
    });
  }

  void _clearError(_Field field) {
    if (!_fieldErrors.containsKey(field)) return;
    setState(() => _fieldErrors = {..._fieldErrors}..remove(field));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final info = widget.info;
    final muted = theme.colorScheme.onSurfaceVariant;

    String? required(String? value) =>
        value == null || value.trim().isEmpty ? l10n.fieldRequired : null;

    return FormPage(
      footer: PromptLink(
        prompt: l10n.signupLoginPrompt,
        action: l10n.signupLoginAction,
        onPressed: _submitting ? null : () => context.go(AppRoutes.login),
      ),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: InitialsAvatar(
            name: info.agencyName,
            size: AppSpacing.s12,
            borderRadius: AppRadius.lg,
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          l10n.signupTitle(info.agencyName),
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.s2),
        Text(
          l10n.signupSubtitle(info.agencyName),
          style: theme.textTheme.bodyLarge?.copyWith(color: muted),
        ),
        const SizedBox(height: AppSpacing.s6),
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_formError case final formError?) ...[
                  AppAlert(text: formError),
                  const SizedBox(height: AppSpacing.s4),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: l10n.signupFirstNameLabel,
                        controller: _firstName,
                        enabled: !_submitting,
                        validator: required,
                        errorText: _fieldErrors[_Field.firstName],
                        onChanged: (_) => _clearError(_Field.firstName),
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.givenName],
                        maxLength: 100,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s3),
                    Expanded(
                      child: AppTextField(
                        label: l10n.signupLastNameLabel,
                        controller: _lastName,
                        enabled: !_submitting,
                        validator: required,
                        errorText: _fieldErrors[_Field.lastName],
                        onChanged: (_) => _clearError(_Field.lastName),
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.familyName],
                        maxLength: 100,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s4),
                AppTextField(
                  label: l10n.fieldEmailLabel,
                  controller: _email,
                  enabled: !_submitting,
                  validator: (value) =>
                      required(value) ??
                      (SignupValidation.isEmail(value!.trim())
                          ? null
                          : l10n.fieldEmailInvalid),
                  errorText: _fieldErrors[_Field.email],
                  onChanged: (_) => _clearError(_Field.email),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  maxLength: 254,
                ),
                const SizedBox(height: AppSpacing.s4),
                AppTextField(
                  label: l10n.signupPhoneLabel,
                  controller: _phone,
                  enabled: !_submitting,
                  validator: (value) =>
                      required(value) ??
                      (SignupValidation.isPhone(value!.trim())
                          ? null
                          : l10n.signupPhoneInvalid),
                  errorText: _fieldErrors[_Field.phone],
                  onChanged: (_) => _clearError(_Field.phone),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  maxLength: 30,
                ),
                const SizedBox(height: AppSpacing.s4),
                AppTextField(
                  label: l10n.fieldPasswordLabel,
                  controller: _password,
                  enabled: !_submitting,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.fieldRequired;
                    }
                    return value.length < SignupValidation.passwordMinLength
                        ? l10n.signupPasswordTooShort
                        : null;
                  },
                  errorText: _fieldErrors[_Field.password],
                  onChanged: (_) => _clearError(_Field.password),
                  obscure: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  maxLength: 128,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s6),
        AppButton(
          label: _submitting ? l10n.signupSubmitting : l10n.signupSubmit,
          loading: _submitting,
          onPressed: _submit,
        ),
        const SizedBox(height: AppSpacing.s3),
        Text(
          l10n.signupPrivacyNote(info.agencyName),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(color: muted),
        ),
      ],
    );
  }
}
