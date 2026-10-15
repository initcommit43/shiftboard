import 'dart:io';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftboard_api/shiftboard_api.dart';

import '../../../core/api/api_error.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/platform/url_opener.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/form_page.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/status_message.dart';
import '../../auth/data/session.dart';
import '../data/worker_shifts_provider.dart';
import '../domain/shift_facts.dart';
import 'claim_sheet.dart';
import 'shift_card.dart';
import 'shift_format.dart';

/// Everything about one shift: the card's facts plus the description, the
/// required qualifications, the address with a map link and the contact.
/// A shift the worker has not claimed yet offers the claim at the bottom.
class ShiftDetailScreen extends ConsumerWidget {
  const ShiftDetailScreen({super.key, required this.shiftId});

  final String shiftId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final provider = workerShiftProvider(shiftId);
    final shift = ref.watch(provider);
    Future<void> reload() => ref.refresh(provider.future);

    final Widget body;
    if (shift.value case final shift?) {
      body = RefreshIndicator(
        onRefresh: () async {
          try {
            await reload();
          } catch (_) {
            if (!context.mounted) return;
            _tell(context, l10n.shiftRefreshFailed);
          }
        },
        child: _Details(shift: shift),
      );
    } else if (shift.isLoading) {
      body = Center(
        child: CircularProgressIndicator(semanticsLabel: l10n.loadingLabel),
      );
    } else {
      final notFound =
          ApiError.from(shift.error!).status == HttpStatus.notFound;
      body = Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenMargin(context)),
          child: notFound
              ? StatusMessage(
                  icon: CupertinoIcons.calendar_badge_minus,
                  title: l10n.shiftNotFoundTitle,
                  message: l10n.shiftNotFoundMessage,
                )
              : StatusMessage(
                  icon: CupertinoIcons.exclamationmark_triangle,
                  tone: StatusTone.error,
                  title: l10n.shiftErrorTitle,
                  message: ApiError.from(shift.error!).isOffline
                      ? l10n.errorCheckConnection
                      : l10n.errorGeneric,
                  action: AppButton(
                    label: l10n.actionRetry,
                    variant: AppButtonVariant.soft,
                    expand: false,
                    onPressed: () => reload().ignore(),
                  ),
                ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: AppSize.navBar,
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  constraints: const BoxConstraints.tightFor(
                    width: AppSize.touchTarget,
                    height: AppSize.touchTarget,
                  ),
                  icon: const Icon(CupertinoIcons.chevron_back),
                ),
              ),
            ),
            Expanded(child: body),
            if (shift.value case final shift? when shift.assignment == null)
              _ClaimBar(shift: shift),
          ],
        ),
      ),
    );
  }
}

void _tell(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

/// The screen's one call to action, pinned below the details. Disabled with
/// the reason as its label when no spot is left.
class _ClaimBar extends ConsumerWidget {
  const _ClaimBar({required this.shift});

  final WorkerShift shift;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final margin = screenMargin(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.colors.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            margin,
            AppSpacing.md,
            margin,
            AppSpacing.sm,
          ),
          child: AppButton(
            label: shift.isFull ? l10n.shiftNoSpotsLeft : l10n.claimAction,
            onPressed: shift.isFull
                ? null
                : () async {
                    final claimed = await showClaimSheet(context, shift);
                    if (!claimed || !context.mounted) return;
                    final agency =
                        ref.read(currentUserProvider)?.agency.name ?? '';
                    _tell(context, l10n.claimSent(agency));
                  },
          ),
        ),
      ),
    );
  }
}

class _Details extends ConsumerWidget {
  const _Details({required this.shift});

  final WorkerShift shift;

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    Uri uri,
    String failure,
  ) async {
    final opened = await ref.read(urlOpenerProvider)(uri);
    if (!opened && context.mounted) _tell(context, failure);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = context.l10n;
    final format = ShiftFormat.of(context);
    final badge = shiftBadge(shift, l10n);
    final margin = screenMargin(context);
    final secondary = AppTypography.subhead.copyWith(
      color: colors.inkSecondary,
    );
    final contactPhone = shift.contact.phone;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        margin,
        AppSpacing.sm,
        margin,
        AppSpacing.xxl + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        if (badge != null) ...[
          Align(alignment: Alignment.centerLeft, child: badge),
          const SizedBox(height: AppSpacing.md),
        ],
        Semantics(
          header: true,
          child: Text(
            shift.title,
            style: AppTypography.title1.copyWith(color: colors.ink),
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(shift.client.name, style: secondary),
        const SizedBox(height: AppSpacing.xl),
        _Group(
          children: [
            ShiftFactLine(
              icon: CupertinoIcons.calendar,
              text: format.dateAndTime(shift),
            ),
            const SizedBox(height: AppSpacing.md),
            ShiftFactLine(
              icon: CupertinoIcons.location,
              text: '${shift.location.name}\n${shift.location.address}',
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: l10n.shiftOpenMap,
              variant: AppButtonVariant.outline,
              onPressed: () => _open(
                context,
                ref,
                mapsUri(shift.location.address),
                l10n.shiftOpenMapFailed,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _Group(
          children: [
            Text(
              format.earnings(shift),
              style: AppTypography.title2.copyWith(
                color: colors.ink,
                fontFeatures: tabularFigures,
              ),
            ),
            Text(
              l10n.shiftEarningsCaption(format.hourlyRate(shift)),
              style: AppTypography.caption1.copyWith(
                color: colors.inkTertiary,
                fontFeatures: tabularFigures,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(format.spots(shift), style: secondary),
          ],
        ),
        if (shift.description case final description?
            when description.trim().isNotEmpty) ...[
          _SectionTitle(l10n.shiftSectionDescription),
          Text(
            description.trim(),
            style: AppTypography.body.copyWith(color: colors.ink),
          ),
        ],
        _SectionTitle(l10n.shiftSectionQualifications),
        if (shift.qualifications.isEmpty)
          Text(l10n.shiftQualificationsNone, style: secondary)
        else
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final qualification in shift.qualifications)
                _Tag(qualification.name),
            ],
          ),
        _SectionTitle(l10n.shiftSectionContact),
        _Group(
          children: [
            Row(
              children: [
                InitialsAvatar(name: shift.contact.name, size: AppSpacing.xxl),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shift.contact.name,
                        style: AppTypography.headline.copyWith(
                          color: colors.ink,
                        ),
                      ),
                      if (contactPhone != null)
                        Text(
                          contactPhone,
                          style: secondary.copyWith(
                            fontFeatures: tabularFigures,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (contactPhone != null) ...[
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: l10n.shiftCall,
                variant: AppButtonVariant.outline,
                onPressed: () => _open(
                  context,
                  ref,
                  phoneUri(contactPhone),
                  l10n.shiftCallFailed,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// A card around related facts. Buttons in it use the outline variant: the
/// soft surface has the card's color in dark.
class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.paddingCard),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.xxl,
        bottom: AppSpacing.sm,
      ),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: AppTypography.title3.copyWith(color: context.colors.ink),
        ),
      ),
    );
  }
}

/// A plain tag, such as a qualification: information, not a status.
class _Tag extends StatelessWidget {
  const _Tag(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      constraints: const BoxConstraints(minHeight: AppSize.badge),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: ShapeDecoration(
        color: colors.surfaceSoft,
        shape: const StadiumBorder(),
      ),
      child: Text(text, style: AppTypography.badge.copyWith(color: colors.ink)),
    );
  }
}
