import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/system_status/presentation/start_screen.dart';

abstract final class AppRoutes {
  static const start = '/';
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.start,
    // Auth guards (logged out, pending approval) go here.
    redirect: (context, state) => null,
    routes: [
      GoRoute(
        path: AppRoutes.start,
        builder: (context, state) => const StartScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
