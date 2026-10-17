import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The current time. A provider so that tests can set it.
typedef Clock = DateTime Function();

final clockProvider = Provider<Clock>((ref) => DateTime.now);
