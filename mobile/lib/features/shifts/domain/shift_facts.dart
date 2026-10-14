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
}
