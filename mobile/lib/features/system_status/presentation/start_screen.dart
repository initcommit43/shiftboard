import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../data/ping_provider.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s6,
            AppSpacing.s12,
            AppSpacing.s6,
            AppSpacing.s6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppBrand.name, style: theme.textTheme.displaySmall),
              const SizedBox(height: AppSpacing.s2),
              Text(
                context.l10n.startTagline,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              const _SystemStatusCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SystemStatusCard extends ConsumerWidget {
  const _SystemStatusCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final ping = ref.watch(pingProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.systemStatusTitle,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Semantics(
              liveRegion: true,
              container: true,
              child: ping.when(
                skipLoadingOnRefresh: false,
                loading: () => _StatusRow(
                  leading: const Padding(
                    padding: EdgeInsets.all(AppSpacing.s2),
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  title: l10n.systemStatusLoading,
                ),
                data: (ping) => _StatusRow(
                  leading: _StatusIcon(
                    icon: Icons.check_rounded,
                    color: context.semanticColors.success,
                  ),
                  title: l10n.systemStatusConnected,
                  detail: l10n.systemStatusApiVersion(ping.version),
                ),
                error: (_, _) => _StatusRow(
                  leading: _StatusIcon(
                    icon: Icons.cloud_off_rounded,
                    color: theme.colorScheme.error,
                  ),
                  title: l10n.systemStatusUnreachable,
                  detail: l10n.systemStatusUnreachableHint,
                ),
              ),
            ),
            if (ping.hasError && !ping.isLoading) ...[
              const SizedBox(height: AppSpacing.s5),
              FilledButton.icon(
                onPressed: () => ref.invalidate(pingProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.actionRetry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.leading, required this.title, this.detail});

  final Widget leading;
  final String title;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: detail == null
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        SizedBox.square(dimension: AppSpacing.s10, child: leading),
        const SizedBox(width: AppSpacing.s4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              if (detail case final detail?) ...[
                const SizedBox(height: AppSpacing.s1),
                Text(
                  detail,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: AppSpacing.s6),
    );
  }
}
