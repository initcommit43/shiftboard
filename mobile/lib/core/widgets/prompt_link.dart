import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
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
    final colors = context.colors;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(AppSize.touchTarget, AppSize.touchTarget),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        shape: const StadiumBorder(),
        overlayColor: Colors.transparent,
      ),
      child: Text.rich(
        TextSpan(
          style: AppTypography.subhead.copyWith(color: colors.inkSecondary),
          children: [
            TextSpan(text: '$prompt '),
            TextSpan(
              text: action,
              style: TextStyle(
                color: colors.ink,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
