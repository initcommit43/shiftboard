import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shiftboard_api/shiftboard_api.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/widgets/app_badge.dart';
import '../domain/shift_facts.dart';

/// Dates, times and money of a shift in the app's locale, in the worker's
/// time zone.
class ShiftFormat {
  ShiftFormat.of(BuildContext context)
    : _l10n = context.l10n,
      _locale = Localizations.localeOf(context).toLanguageTag();

  final AppLocalizations _l10n;
  final String _locale;

  /// For example "Sa., 17. Okt.".
  String date(DateTime time) =>
      DateFormat.MMMEd(_locale).format(time.toLocal());

  /// For example "18:00 – ca. 23:30".
  String timeRange(WorkerShift shift) {
    final start = time(shift.startsAt);
    final end = time(shift.endsAt);
    return shift.endIsEstimate
        ? _l10n.shiftTimeRangeEstimate(start, end)
        : _l10n.shiftTimeRange(start, end);
  }

  /// For example "Sa., 17. Okt. · 18:00 – 23:30".
  String dateAndTime(WorkerShift shift) =>
      _l10n.shiftDateAndTime(date(shift.startsAt), timeRange(shift));

  /// For example "14,50 €".
  String money(int cents) => NumberFormat.simpleCurrency(
    locale: _locale,
    name: 'EUR',
  ).format(cents / 100);

  /// The estimated pay for the whole shift, with "ca." when its end is.
  String earnings(WorkerShift shift) {
    final amount = money(shift.estimatedEarningsCents);
    return shift.endIsEstimate ? _l10n.shiftEarningsEstimate(amount) : amount;
  }

  String hourlyRate(WorkerShift shift) =>
      _l10n.shiftHourlyRate(money(shift.hourlyRateCents));

  /// The spots left, and on a full shift whether its waitlist is open to the
  /// worker.
  String spots(WorkerShift shift) {
    if (!shift.isFull) {
      return _l10n.shiftSpotsLeft(shift.spotsLeft, shift.slots);
    }
    final waitlistOpen =
        (shift.waitlistEnabled ?? false) &&
        shift.status == ShiftStatus.PUBLISHED &&
        shift.assignment == null &&
        !shift.isWaiting;
    return waitlistOpen ? _l10n.shiftSpotsWaitlist : _l10n.shiftNoSpotsLeft;
  }

  /// For example "18:00".
  String time(DateTime time) => DateFormat.Hm(_locale).format(time.toLocal());
}

/// The badge of a shift: the worker's own claim if there is one ("Eingecheckt"
/// while checked in), their place on the waitlist, otherwise whether the
/// shift is full. Null for an open shift, which is the normal
/// case and needs no mark.
AppBadge? shiftBadge(WorkerShift shift, AppLocalizations l10n) {
  final claim = shift.assignment?.status;
  // On the job: checked in, not yet out.
  if (claim == AssignmentStatus.CONFIRMED &&
      shift.assignment?.checkedInAt != null &&
      shift.assignment?.checkedOutAt == null) {
    return AppBadge(status: AppStatus.confirmed, label: l10n.checkedInBadge);
  }
  if (claim != null) {
    final (status, label) = switch (claim) {
      AssignmentStatus.CONFIRMED => (AppStatus.confirmed, l10n.claimConfirmed),
      AssignmentStatus.REJECTED => (AppStatus.cancelled, l10n.claimRejected),
      AssignmentStatus.CANCELLED => (AppStatus.cancelled, l10n.claimCancelled),
      AssignmentStatus.COMPLETED => (AppStatus.confirmed, l10n.claimCompleted),
      AssignmentStatus.NO_SHOW => (AppStatus.cancelled, l10n.claimNoShow),
      _ => (AppStatus.pending, l10n.claimPending),
    };
    return AppBadge(status: status, label: label);
  }
  if (shift.waitlist case final place?) {
    return AppBadge(
      status: AppStatus.waiting,
      label: l10n.waitlistBadge(place.position),
    );
  }
  if (shift.isFull) {
    return AppBadge(status: AppStatus.full, label: l10n.shiftFull);
  }
  return null;
}
