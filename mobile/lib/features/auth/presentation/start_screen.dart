import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/status_message.dart';
import '../data/session.dart';

/// Shown while the stored session is checked on start, and with a retry when
/// the API could not be reached for that.
class StartScreen extends ConsumerWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionProvider);

    if (session.isLoading || !session.hasError) {
      return StatusPage(
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandMark(),
            const SizedBox(height: AppSpacing.s8),
            CircularProgressIndicator(
              strokeWidth: 3,
              semanticsLabel: l10n.loadingLabel,
            ),
          ],
        ),
      );
    }

    return StatusPage(
      body: StatusMessage(
        icon: Icons.warning_amber_rounded,
        tone: StatusTone.error,
        title: l10n.startErrorTitle,
        message: l10n.errorCheckConnection,
      ),
      actions: [
        AppButton(
          label: l10n.actionRetry,
          onPressed: () => ref.invalidate(sessionProvider),
        ),
        AppButton(
          label: l10n.actionLogout,
          variant: AppButtonVariant.ghost,
          onPressed: () => ref.read(sessionProvider.notifier).logout(),
        ),
      ],
    );
  }
}
