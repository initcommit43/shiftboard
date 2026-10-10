import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A question followed by the link that answers it, such as
/// "Schon registriert? Anmelden".
class PromptLink extends StatelessWidget {
  const PromptLink({
    super.key,
    required this.prompt,
    required this.action,
    required this.onPressed,
  });

  final String prompt;
  final String action;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(AppSpacing.s12, AppSpacing.s12),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s2,
          vertical: AppSpacing.s2,
        ),
      ),
      child: Text.rich(
        TextSpan(
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
          children: [
            TextSpan(text: '$prompt '),
            TextSpan(
              text: action,
              style: TextStyle(
                color: scheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
