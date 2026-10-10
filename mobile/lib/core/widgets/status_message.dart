import 'package:flutter/material.dart';

import '../theme/tokens.dart';

enum StatusTone { neutral, accent, error }

/// An icon in a circle with a centered title and text: the body of empty,
/// error and waiting states.
class StatusMessage extends StatelessWidget {
  const StatusMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.tone = StatusTone.neutral,
    this.action,
  });

  static const double _circleSize = 72;

  final IconData icon;
  final String title;
  final String message;
  final StatusTone tone;

  /// Shown below the text, for example a retry button.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (background, foreground) = switch (tone) {
      StatusTone.neutral => (
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
      ),
      StatusTone.accent => (scheme.primaryContainer, scheme.primary),
      StatusTone.error => (scheme.surfaceContainerHighest, scheme.error),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: _circleSize,
          height: _circleSize,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          child: Icon(icon, size: AppSpacing.s8, color: foreground),
        ),
        const SizedBox(height: AppSpacing.s6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.s2),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        if (action case final action?) ...[
          const SizedBox(height: AppSpacing.s6),
          action,
        ],
      ],
    );
  }
}

/// A full screen around a centered body, with its actions at the bottom.
///
/// The body scrolls when it does not fit, for example with large text.
class StatusPage extends StatelessWidget {
  const StatusPage({super.key, required this.body, this.actions = const []});

  final Widget body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s6,
            AppSpacing.s6,
            AppSpacing.s6,
            AppSpacing.s2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(child: SingleChildScrollView(child: body)),
              ),
              if (actions.isNotEmpty) const SizedBox(height: AppSpacing.s6),
              for (final (index, action) in actions.indexed) ...[
                if (index > 0) const SizedBox(height: AppSpacing.s2),
                action,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
