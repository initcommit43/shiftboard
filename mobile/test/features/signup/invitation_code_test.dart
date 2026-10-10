import 'package:flutter_test/flutter_test.dart';
import 'package:shiftboard/features/signup/domain/invitation_code.dart';

void main() {
  group('parseInvitationCode', () {
    const valid = {
      'DONAU24': 'DONAU24',
      '  donau-24_x  ': 'donau-24_x',
      'shiftboard://join/DONAU24': 'DONAU24',
      'shiftboard://join/DONAU24/': 'DONAU24',
      ' shiftboard://join/DONAU24\n': 'DONAU24',
      'https://app.example.com/join/DONAU24': 'DONAU24',
      'https://app.example.com/de/join/DONAU24?utm_source=mail': 'DONAU24',
      'app.example.com/join/DONAU24#top': 'DONAU24',
    };

    for (final MapEntry(key: input, value: code) in valid.entries) {
      test('reads "$code" from "${input.trim()}"', () {
        expect(parseInvitationCode(input), code);
      });
    }

    final invalid = [
      '',
      '   ',
      'zwei Wörter',
      'shiftboard://join',
      'shiftboard://join/',
      'https://app.example.com/login',
      'https://app.example.com/join/',
      'https://app.example.com/join/a b',
      'A' * 65,
    ];

    for (final input in invalid) {
      test('finds no code in "$input"', () {
        expect(parseInvitationCode(input), isNull);
      });
    }
  });
}
