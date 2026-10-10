import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_error.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_alert.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/form_page.dart';
import '../../../core/widgets/prompt_link.dart';
import '../data/session.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _submitting = false;
  ApiError? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref
          .read(sessionProvider.notifier)
          .login(email: _email.text.trim(), password: _password.text);
      // The router leaves this screen as soon as the session is there.
    } on DioException catch (error) {
      if (mounted) setState(() => _error = ApiError.from(error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    String? required(String? value) =>
        value == null || value.trim().isEmpty ? l10n.fieldRequired : null;

    return FormPage(
      topPadding: AppSpacing.s10,
      footer: PromptLink(
        prompt: l10n.loginSignupPrompt,
        action: l10n.loginSignupAction,
        onPressed: _submitting ? null : () => context.push(AppRoutes.join),
      ),
      children: [
        const Align(alignment: Alignment.centerLeft, child: BrandMark()),
        const SizedBox(height: AppSpacing.s8),
        Text(l10n.loginTitle, style: theme.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.s2),
        Text(
          l10n.loginSubtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error case final error?) ...[
                  AppAlert(text: error.message(l10n)),
                  const SizedBox(height: AppSpacing.s4),
                ],
                AppTextField(
                  label: l10n.fieldEmailLabel,
                  hint: l10n.fieldEmailHint,
                  controller: _email,
                  enabled: !_submitting,
                  validator: required,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  maxLength: 254,
                ),
                const SizedBox(height: AppSpacing.s4),
                AppTextField(
                  label: l10n.fieldPasswordLabel,
                  hint: l10n.loginPasswordHint,
                  controller: _password,
                  enabled: !_submitting,
                  validator: (value) => value == null || value.isEmpty
                      ? l10n.fieldRequired
                      : null,
                  obscure: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  autofillHints: const [AutofillHints.password],
                  maxLength: 128,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        AppButton(
          label: _submitting ? l10n.loginSubmitting : l10n.loginSubmit,
          loading: _submitting,
          onPressed: _submit,
        ),
      ],
    );
  }
}
