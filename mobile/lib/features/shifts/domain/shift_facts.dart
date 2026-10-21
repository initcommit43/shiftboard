import 'package:shiftboard_api/shiftboard_api.dart';

/// What the app derives from a shift for the worker.
extension ShiftFacts on WorkerShift {
  int get spotsLeft => slots - takenSlots < 0 ? 0 : slots - takenSlots;

  bool get isFull => spotsLeft == 0;

  /// Gross pay for the whole shift in euro cents: its length times the hourly
  /// rate. An estimate, since breaks are not known and the end may be too.
  int get estimatedEarningsCents {
    final minutes = endsAt.difference(startsAt).inMinutes;
    if (minutes <= 0) return 0;
    return (minutes * hourlyRateCents / Duration.minutesPerHour).round();
  }

  /// Whether the worker's claim holds a spot: pending or confirmed.
  bool get holdsSpot => switch (assignment?.status) {
    AssignmentStatus.PENDING || AssignmentStatus.CONFIRMED => true,
    _ => false,
  };

  /// Whether the worker can still drop out in the app at [now].
  bool canCancelAt(DateTime now) {
    final until = assignment?.cancellableUntil;
    return holdsSpot && until != null && now.isBefore(until);
  }

  /// Where the worker stands with checking in and out at [now]. Only agencies
  /// that use check-in send `checkInFrom`; without it there is nothing to do.
  CheckIn checkInAt(DateTime now) {
    final assignment = this.assignment;
    if (assignment == null || assignment.checkInFrom == null) {
      return CheckIn.none;
    }
    final attended = switch (assignment.status) {
      AssignmentStatus.CONFIRMED || AssignmentStatus.COMPLETED => true,
      _ => false,
    };
    if (!attended) return CheckIn.none;
    if (assignment.checkedInAt == null) {
      if (assignment.status != AssignmentStatus.CONFIRMED) return CheckIn.none;
      if (now.isBefore(assignment.checkInFrom!)) return CheckIn.notYetOpen;
      return now.isBefore(endsAt) ? CheckIn.open : CheckIn.none;
    }
    if (assignment.checkedOutAt != null) return CheckIn.checkedOut;
    return assignment.hoursApproved ?? false
        ? CheckIn.checkedInApproved
        : CheckIn.checkedIn;
  }
}

/// The steps of checking in and out of a shift, as far as the app offers
/// them.
enum CheckIn {
  /// Nothing to show: the agency does not use check-in, the spot is not
  /// confirmed, or the shift ended without a check-in.
  none,

  /// Check-in opens later, at `checkInFrom`.
  notYetOpen,

  /// The worker can check in now.
  open,

  /// Checked in; checking out is possible until the hours are approved.
  checkedIn,

  /// Checked in, never checked out, and the agency already approved the
  /// hours, so checking out is no longer possible.
  checkedInApproved,

  /// Checked in and out. The times are final in the app.
  checkedOut;

  /// Whether the pinned bar offers checking in or out.
  bool get hasAction => this == open || this == checkedIn;
}
