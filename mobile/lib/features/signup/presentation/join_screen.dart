import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/form_page.dart';
import '../../../core/widgets/prompt_link.dart';
import '../domain/invitation_code.dart';

/// The way into the signup without tapping the invitation link: the worker
/// pastes the link or the code.
class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _invitation = TextEditingController();

  @override
  void dispose() {
    _invitation.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final code = parseInvitationCode(_invitation.text)!;
    context.pushReplacement(AppRoutes.signup(code));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return FormPage(
      topPadding: AppSpacing.s10,
      footer: PromptLink(
        prompt: l10n.signupLoginPrompt,
        action: l10n.signupLoginAction,
        onPressed: () => context.go(AppRoutes.login),
      ),
      children: [
        Text(l10n.joinTitle, style: theme.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.s2),
        Text(
          l10n.joinSubtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        Form(
          key: _formKey,
          child: AppTextField(
            label: l10n.joinFieldLabel,
            hint: l10n.joinFieldHint,
            controller: _invitation,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.fieldRequired;
              }
              return parseInvitationCode(value) == null
                  ? l10n.joinInvalid
                  : null;
            },
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.go,
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        AppButton(label: l10n.joinSubmit, onPressed: _submit),
      ],
    );
  }
}
