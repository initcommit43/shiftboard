import 'package:flutter_test/flutter_test.dart';
import 'package:shiftboard/features/shifts/domain/shift_facts.dart';
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
}
