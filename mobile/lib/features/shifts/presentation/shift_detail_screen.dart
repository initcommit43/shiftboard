import 'dart:io';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shiftboard_api/shiftboard_api.dart';

import '../../../core/api/api_error.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/platform/clock.dart';
import '../../../core/platform/url_opener.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/form_page.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/status_message.dart';
import '../../auth/data/session.dart';
import '../data/worker_shifts_provider.dart';
import '../domain/shift_facts.dart';
import 'cancel_sheet.dart';
import 'check_in.dart';
import 'claim_sheet.dart';
import 'shift_card.dart';
import 'shift_format.dart';
import 'waitlist_sheet.dart';

/// Everything about one shift: the card's facts plus the description, the
/// required qualifications, the address with a map link and the contact.
/// A shift the worker has not claimed yet offers the claim at the bottom, or
/// its waitlist when it is full; a claimed one that has not started offers to
/// drop out, and a place on the waitlist to leave it. Where the agency uses
/// check-in, checking in and out takes over the bar once check-in opens.
class ShiftDetailScreen extends ConsumerWidget {
  const ShiftDetailScreen({super.key, required this.shiftId});

  final String shiftId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final provider = workerShiftProvider(shiftId);
    final shift = ref.watch(provider);
    final now = ref.watch(clockProvider)();
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
            if (shift.value case final shift?)
              if (shift.canLeaveWaitlistAt(now))
                _WaitlistBar(shift: shift)
              else if (shift.assignment == null && !shift.isWaiting)
                _ClaimBar(shift: shift, now: now)
              else if (shift.checkInAt(now).hasAction)
                CheckInBar(shift: shift, now: now)
              else if (shift.holdsSpot &&
                  shift.assignment?.cancellableUntil != null &&
                  now.isBefore(shift.startsAt))
                _CancelBar(shift: shift, now: now)
              else if (shift.checkInAt(now) == CheckIn.notYetOpen)
                CheckInBar(shift: shift, now: now),
          ],
        ),
      ),
    );
  }
}

/// Opens the chat with a new message about [shift].
void _writeAbout(BuildContext context, WorkerShift shift) {
  context.push(
    AppRoutes.chat,
    extra: (id: shift.id, title: shift.title, startsAt: shift.startsAt),
  );
}

void _tell(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

/// Opens the claim sheet for [shift] and confirms a sent claim.
Future<void> _claim(
  BuildContext context,
  WidgetRef ref,
  WorkerShift shift,
) async {
  final l10n = context.l10n;
  final claimed = await showClaimSheet(context, shift);
  if (!claimed || !context.mounted) return;
  final agency = ref.read(currentUserProvider)?.agency.name ?? '';
  _tell(context, l10n.claimSent(agency));
}

/// A bar pinned below the details, above the safe area.
class _Bar extends StatelessWidget {
  const _Bar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
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
          child: child,
        ),
      ),
    );
  }
}

/// The screen's one call to action, pinned below the details. On a full
/// shift it offers the waitlist where the agency uses one, otherwise it is
/// disabled with the reason as its label.
class _ClaimBar extends ConsumerWidget {
  const _ClaimBar({required this.shift, required this.now});

  final WorkerShift shift;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    final Widget button;
    if (!shift.isFull) {
      button = AppButton(
        label: l10n.claimAction,
        onPressed: () => _claim(context, ref, shift),
      );
    } else if (shift.canJoinWaitlistAt(now)) {
      button = AppButton(
        label: l10n.waitlistJoinAction,
        onPressed: () async {
          final joined = await showJoinWaitlistSheet(context, shift);
          final place = joined?.waitlist;
          if (place == null || !context.mounted) return;
          _tell(context, l10n.waitlistJoined(place.position));
        },
      );
    } else {
      button = AppButton(label: l10n.shiftNoSpotsLeft, onPressed: null);
    }
    return _Bar(child: button);
  }
}

/// The pinned bar while the worker waits for a spot: leave the waitlist, or
/// claim the spot that is free after the cancellation deadline, when the
/// first claim wins.
class _WaitlistBar extends ConsumerWidget {
  const _WaitlistBar({required this.shift});

  final WorkerShift shift;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    Future<void> leave() async {
      final left = await showLeaveWaitlistSheet(context, shift);
      if (!left || !context.mounted) return;
      _tell(context, l10n.waitlistLeft);
    }

    if (shift.isFull) {
      return _Bar(
        child: AppButton(
          label: l10n.waitlistLeaveAction,
          variant: AppButtonVariant.outline,
          onPressed: leave,
        ),
      );
    }
    return _Bar(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            label: l10n.claimAction,
            onPressed: () => _claim(context, ref, shift),
          ),
          const SizedBox(height: AppSpacing.xs),
          AppButton(
            label: l10n.waitlistLeaveAction,
            variant: AppButtonVariant.text,
            onPressed: leave,
          ),
        ],
      ),
    );
  }
}

/// The pinned bar of a claimed shift: drop out until the agency's deadline,
/// afterwards the reason and who to tell instead.
class _CancelBar extends ConsumerWidget {
  const _CancelBar({required this.shift, required this.now});

  final WorkerShift shift;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final phone = shift.contact.phone;

    final Widget content;
    if (shift.canCancelAt(now)) {
      content = AppButton(
        label: l10n.cancelAction,
        variant: AppButtonVariant.danger,
        onPressed: () async {
          final cancelled = await showCancelSheet(context, shift);
          if (!cancelled || !context.mounted) return;
          _tell(context, l10n.cancelDone);
        },
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // With check-in, the next step is checking in, so the disabled
          // button says when that opens instead.
          if (shift.checkInAt(now) == CheckIn.notYetOpen)
            AppButton(
              label: checkInOpensLabel(
                shift,
                now,
                l10n,
                ShiftFormat.of(context),
              ),
              onPressed: null,
            )
          else
            AppButton(
              label: l10n.cancelDeadlinePassed,
              variant: AppButtonVariant.danger,
              onPressed: null,
            ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.cancelDeadlinePassedHint(shift.contact.name),
            textAlign: TextAlign.center,
            style: AppTypography.footnote.copyWith(
              color: context.colors.inkSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: l10n.chatWriteAbout,
            variant: AppButtonVariant.outline,
            onPressed: () => _writeAbout(context, shift),
          ),
          if (phone != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.shiftCall,
              variant: AppButtonVariant.outline,
              onPressed: () async {
                final opened = await ref.read(urlOpenerProvider)(
                  phoneUri(phone),
                );
                if (!opened && context.mounted) {
                  _tell(context, l10n.shiftCallFailed);
                }
              },
            ),
          ],
        ],
      );
    }

    return _Bar(child: content);
  }
}

/// What the worker should know about their claim beyond its badge: until
/// when they can drop out, or who cancelled it. On the waitlist, how many are
/// ahead of them, or that a spot is free to claim.
String? _claimNote(
  WorkerShift shift,
  AppLocalizations l10n,
  ShiftFormat format,
  String agency,
  DateTime now,
) {
  if (shift.waitlist case final place?) {
    if (!shift.isFull) return l10n.waitlistNoteSpotFree;
    return place.position <= 1
        ? l10n.waitlistNoteNext
        : l10n.waitlistNoteAhead(place.position - 1);
  }
  final assignment = shift.assignment;
  if (assignment == null) return null;
  if (assignment.status == AssignmentStatus.CANCELLED) {
    if (assignment.cancelledBy == CancelledBy.WORKER) {
      return l10n.claimCancelledByYou;
    }
    return shift.status == ShiftStatus.CANCELLED
        ? l10n.shiftCancelledByAgency(agency)
        : l10n.claimRemovedByAgency(agency);
  }
  // Once check-in is open, the bar offers that instead of dropping out.
  if (shift.checkInAt(now).hasAction) return null;
  if (assignment.cancellableUntil case final until?
      when shift.holdsSpot && now.isBefore(until)) {
    return l10n.cancelUntil(format.date(until), format.time(until));
  }
  return null;
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
    final agencySummary = ref.watch(currentUserProvider)?.agency;
    final agency = agencySummary?.name ?? '';
    // Agencies that prefer WhatsApp switch this on (S3-6).
    final whatsApp = agencySummary?.features?.contactButton ?? false;
    final now = ref.watch(clockProvider)();
    final note = _claimNote(shift, l10n, format, agency, now);
    // While the bar still offers dropping out, say here when check-in opens.
    final checkInNote =
        shift.checkInAt(now) == CheckIn.notYetOpen && shift.canCancelAt(now)
        ? checkInOpensLabel(shift, now, l10n, format)
        : null;

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
        if (note != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(note, style: AppTypography.subhead.copyWith(color: colors.ink)),
        ],
        if (checkInNote != null) ...[
          SizedBox(height: note == null ? AppSpacing.md : AppSpacing.xxs),
          Text(
            checkInNote,
            style: AppTypography.subhead.copyWith(color: colors.ink),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        if (shift.assignment?.checkedInAt != null &&
            shift.checkInAt(now) != CheckIn.none) ...[
          AttendanceCard(shift: shift),
          const SizedBox(height: AppSpacing.lg),
        ],
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
            Text(format.spots(shift, now), style: secondary),
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
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: l10n.chatWriteAbout,
              variant: AppButtonVariant.outline,
              onPressed: () => _writeAbout(context, shift),
            ),
            if (contactPhone != null && whatsApp) ...[
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: l10n.shiftWhatsApp,
                variant: AppButtonVariant.outline,
                onPressed: () => _open(
                  context,
                  ref,
                  whatsAppUri(contactPhone),
                  l10n.shiftWhatsAppFailed,
                ),
              ),
            ],
            if (contactPhone != null) ...[
              const SizedBox(height: AppSpacing.sm),
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
