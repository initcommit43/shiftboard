import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'form_page.dart';

enum StatusTone { neutral, pending, error }

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

  static const double _circleSize = 64;

  final IconData icon;
  final String title;
  final String message;
  final StatusTone tone;

  /// Shown below the text, for example a retry button.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (background, foreground) = switch (tone) {
      StatusTone.neutral => (colors.surfaceSoft, colors.inkSecondary),
      StatusTone.pending => (colors.statusPendingBg, colors.statusPendingFg),
      StatusTone.error => (colors.statusCancelledBg, colors.statusCancelledFg),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: _circleSize,
          height: _circleSize,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          child: Icon(icon, size: 28, color: foreground),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.title2.copyWith(color: colors.ink),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.callout.copyWith(color: colors.inkSecondary),
        ),
        if (action case final action?) ...[
          const SizedBox(height: AppSpacing.xl),
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
    final margin = screenMargin(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            margin,
            AppSpacing.xl,
            margin,
            AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(child: SingleChildScrollView(child: body)),
              ),
              if (actions.isNotEmpty) const SizedBox(height: AppSpacing.xl),
              for (final (index, action) in actions.indexed) ...[
                if (index > 0) const SizedBox(height: AppSpacing.sm),
                action,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
