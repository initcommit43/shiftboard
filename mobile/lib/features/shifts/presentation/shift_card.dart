import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftboard_api/shiftboard_api.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/platform/clock.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import 'shift_format.dart';

/// Times and money line up in tabular figures.
const tabularFigures = [FontFeature.tabularFigures()];

/// From this text scale on, side-by-side content is stacked.
const _stackFromTextScale = 1.5;

/// One shift in the list: what an agency's SMS says, plus spots left and the
/// estimated pay. Tapping it opens the detail.
class ShiftCard extends ConsumerWidget {
  const ShiftCard({super.key, required this.shift, this.onTap});

  final WorkerShift shift;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final format = ShiftFormat.of(context);
    final now = ref.watch(clockProvider)();
    final badge = shiftBadge(shift, context.l10n);
    final stacked =
        MediaQuery.textScalerOf(context).scale(1) >= _stackFromTextScale;

    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          shift.title,
          style: AppTypography.headline.copyWith(color: colors.ink),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          shift.client.name,
          style: AppTypography.subhead.copyWith(color: colors.inkSecondary),
        ),
      ],
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        highlightColor: colors.surfaceSoft,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.paddingCard),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (stacked) ...[
                if (badge != null) ...[
                  Align(alignment: Alignment.centerLeft, child: badge),
                  const SizedBox(height: AppSpacing.sm),
                ],
                heading,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: heading),
                    if (badge != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      badge,
                    ],
                  ],
                ),
              const SizedBox(height: AppSpacing.md),
              ShiftFactLine(
                icon: CupertinoIcons.calendar,
                text: format.dateAndTime(shift),
              ),
              const SizedBox(height: AppSpacing.xs),
              ShiftFactLine(
                icon: CupertinoIcons.location,
                text: shift.location.name,
              ),
              const SizedBox(height: AppSpacing.lg),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.sm,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        format.earnings(shift),
                        style: AppTypography.title2.copyWith(
                          color: colors.ink,
                          fontFeatures: tabularFigures,
                        ),
                      ),
                      Text(
                        context.l10n.shiftEarningsCaption(
                          format.hourlyRate(shift),
                        ),
                        style: AppTypography.caption1.copyWith(
                          color: colors.inkTertiary,
                          fontFeatures: tabularFigures,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    format.spots(shift, now),
                    style: AppTypography.footnote.copyWith(
                      color: colors.inkSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A fact of a shift with its icon, such as the date or the place.
class ShiftFactLine extends StatelessWidget {
  const ShiftFactLine({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.inkSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: ExcludeSemantics(
            child: Icon(icon, size: AppSize.iconSm, color: color),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTypography.subhead.copyWith(
              color: color,
              fontFeatures: tabularFigures,
            ),
          ),
        ),
      ],
    );
  }
}
