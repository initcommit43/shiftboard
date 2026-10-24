import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftboard/core/l10n/generated/app_localizations.dart';
import 'package:shiftboard/features/shifts/domain/shift_facts.dart';
import 'package:shiftboard/features/shifts/presentation/shift_format.dart';
import 'package:shiftboard_api/shiftboard_api.dart';

import '../../support/fake_backend.dart';

WorkerShift shift({
  DateTime? start,
  DateTime? end,
  int hourlyRateCents = 1450,
  int slots = 5,
  int takenSlots = 2,
}) => standardSerializers.deserializeWith(
  WorkerShift.serializer,
  workerShift(
    start: start,
    end: end,
    hourlyRateCents: hourlyRateCents,
    slots: slots,
    takenSlots: takenSlots,
  ),
)!;

void main() {
  test('counts the spots left', () {
    expect(shift(slots: 5, takenSlots: 2).spotsLeft, 3);
    expect(shift(slots: 5, takenSlots: 2).isFull, isFalse);
  });

  test('a shift with every spot taken is full', () {
    expect(shift(slots: 3, takenSlots: 3).spotsLeft, 0);
    expect(shift(slots: 3, takenSlots: 3).isFull, isTrue);
  });

  test('never counts fewer than zero spots', () {
    expect(shift(slots: 2, takenSlots: 3).spotsLeft, 0);
  });

  test('estimates the pay as length times hourly rate', () {
    final fiveAndAHalfHours = shift(
      start: DateTime(2026, 10, 17, 18),
      end: DateTime(2026, 10, 17, 23, 30),
      hourlyRateCents: 1450,
    );

    expect(fiveAndAHalfHours.estimatedEarningsCents, 7975);
  });

  test('rounds the pay to whole cents', () {
    // 20 minutes at 13.33 per hour is 4.4433.
    final twentyMinutes = shift(
      start: DateTime(2026, 10, 17, 18),
      end: DateTime(2026, 10, 17, 18, 20),
      hourlyRateCents: 1333,
    );

    expect(twentyMinutes.estimatedEarningsCents, 444);
  });

  test('counts a shift over midnight in full', () {
    final overnight = shift(
      start: DateTime(2026, 10, 17, 22),
      end: DateTime(2026, 10, 18, 6),
      hourlyRateCents: 1500,
    );

    expect(overnight.estimatedEarningsCents, 12000);
  });

  group('check-in', () {
    final start = DateTime(2026, 10, 17, 7);
    final end = DateTime(2026, 10, 17, 16);
    final from = DateTime(2026, 10, 17, 6, 30);
    final arrived = DateTime(2026, 10, 17, 6, 58);

    WorkerShift claimed({
      String status = 'CONFIRMED',
      DateTime? checkInFrom,
      DateTime? checkedInAt,
      DateTime? checkedOutAt,
      bool? hoursApproved,
    }) => standardSerializers.deserializeWith(
      WorkerShift.serializer,
      workerShift(
        start: start,
        end: end,
        assignmentStatus: status,
        checkInFrom: checkInFrom,
        checkedInAt: checkedInAt,
        checkedOutAt: checkedOutAt,
        hoursApproved: hoursApproved,
      ),
    )!;

    test('has nothing to offer without checkInFrom', () {
      expect(claimed().checkInAt(DateTime(2026, 10, 17, 7)), CheckIn.none);
      expect(shift().checkInAt(DateTime(2026, 10, 17, 7)), CheckIn.none);
    });

    test('opens at checkInFrom and closes at the planned end', () {
      final confirmed = claimed(checkInFrom: from);
      expect(
        confirmed.checkInAt(from.subtract(const Duration(minutes: 1))),
        CheckIn.notYetOpen,
      );
      expect(confirmed.checkInAt(from), CheckIn.open);
      expect(
        confirmed.checkInAt(end.subtract(const Duration(minutes: 1))),
        CheckIn.open,
      );
      expect(confirmed.checkInAt(end), CheckIn.none);
    });

    test('needs a confirmed spot to check in', () {
      for (final status in ['PENDING', 'CANCELLED', 'COMPLETED', 'NO_SHOW']) {
        expect(
          claimed(status: status, checkInFrom: from).checkInAt(arrived),
          CheckIn.none,
          reason: status,
        );
      }
    });

    test('allows checking out until the hours are approved', () {
      final late = DateTime(2026, 10, 18, 9);
      for (final status in ['CONFIRMED', 'COMPLETED']) {
        expect(
          claimed(
            status: status,
            checkInFrom: from,
            checkedInAt: arrived,
          ).checkInAt(late),
          CheckIn.checkedIn,
        );
      }
      final approved = claimed(
        status: 'COMPLETED',
        checkInFrom: from,
        checkedInAt: arrived,
        hoursApproved: true,
      );
      expect(approved.checkInAt(late), CheckIn.checkedInApproved);
      expect(approved.checkInAt(late).hasAction, isFalse);
    });

    test('is done once checked out', () {
      final done = claimed(
        checkInFrom: from,
        checkedInAt: arrived,
        checkedOutAt: DateTime(2026, 10, 17, 16, 4),
      );
      expect(done.checkInAt(DateTime(2026, 10, 17, 17)), CheckIn.checkedOut);
    });
  });

  group('waitlist', () {
    // The fixture shift starts on Saturday, 17 October at 18:00.
    final before = DateTime(2026, 10, 15, 10);
    final start = DateTime(2026, 10, 17, 18);

    WorkerShift full({
      bool? waitlistEnabled = true,
      int takenSlots = 5,
      String status = 'PUBLISHED',
      String? assignmentStatus,
      int? waitlistPosition,
    }) => standardSerializers.deserializeWith(
      WorkerShift.serializer,
      workerShift(
        takenSlots: takenSlots,
        status: status,
        assignmentStatus: assignmentStatus,
        waitlistEnabled: waitlistEnabled,
        waitlistPosition: waitlistPosition,
      ),
    )!;

    test('can be joined on a full published shift before its start', () {
      expect(full().canJoinWaitlistAt(before), isTrue);
      expect(full().canJoinWaitlistAt(start), isFalse);
    });

    test('needs the agency setting', () {
      expect(full(waitlistEnabled: false).canJoinWaitlistAt(before), isFalse);
      expect(full(waitlistEnabled: null).canJoinWaitlistAt(before), isFalse);
    });

    test('is not offered while spots are free or the shift is closed', () {
      expect(full(takenSlots: 4).canJoinWaitlistAt(before), isFalse);
      expect(full(status: 'CANCELLED').canJoinWaitlistAt(before), isFalse);
    });

    test('is not offered after a claim of any status or a second time', () {
      for (final status in ['PENDING', 'CONFIRMED', 'REJECTED', 'CANCELLED']) {
        expect(
          full(assignmentStatus: status).canJoinWaitlistAt(before),
          isFalse,
          reason: status,
        );
      }
      expect(full(waitlistPosition: 1).canJoinWaitlistAt(before), isFalse);
    });

    test('can be left until the start, also once switched off', () {
      final waiting = full(waitlistEnabled: false, waitlistPosition: 3);
      expect(waiting.isWaiting, isTrue);
      expect(waiting.canLeaveWaitlistAt(before), isTrue);
      expect(waiting.canLeaveWaitlistAt(start), isFalse);
      expect(full().canLeaveWaitlistAt(before), isFalse);
    });
  });

  group('a claim status newer than the app', () {
    // The generated client maps values it does not know to a fallback (ADR 0030).
    final shift = standardSerializers.deserializeWith(
      WorkerShift.serializer,
      workerShift(
        assignmentStatus: 'ON_HOLD',
        cancellableUntil: DateTime(2026, 10, 17, 12),
        checkInFrom: DateTime(2026, 10, 17, 17, 30),
      ),
    )!;

    test('arrives as the fallback value', () {
      expect(shift.assignment!.status, AssignmentStatus.unknownDefaultOpenApi);
    });

    test('holds no spot and allows nothing', () {
      final now = DateTime(2026, 10, 17, 10);
      expect(shift.holdsSpot, isFalse);
      expect(shift.canCancelAt(now), isFalse);
      expect(shift.checkInAt(DateTime(2026, 10, 17, 18)), CheckIn.none);
    });

    test('shows no badge rather than a wrong one', () {
      expect(
        shiftBadge(shift, lookupAppLocalizations(const Locale('de'))),
        isNull,
      );
    });
  });
}
