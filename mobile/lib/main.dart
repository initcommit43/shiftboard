import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/push/push_messaging.dart';
import 'core/push/push_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Push notifications only exist in builds that pass a Firebase project.
  final options = firebaseOptions;
  if (options != null) await Firebase.initializeApp(options: options);

  runApp(
    ProviderScope(
      overrides: [
        if (options != null)
          pushMessagingProvider.overrideWithValue(FirebasePushMessaging()),
      ],
      child: const ShiftboardApp(),
    ),
  );
}
