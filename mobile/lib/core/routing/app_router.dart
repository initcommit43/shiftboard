import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shiftboard_api/shiftboard_api.dart';

import '../../features/approval/presentation/not_active_screen.dart';
import '../../features/approval/presentation/waiting_screen.dart';
import '../../features/auth/data/session.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/start_screen.dart';
import '../../features/messages/presentation/chat_screen.dart';
import '../../features/messages/presentation/chat_view.dart';
import '../../features/shifts/presentation/home_screen.dart';
import '../../features/shifts/presentation/shift_detail_screen.dart';
import '../../features/signup/domain/invitation_code.dart';
import '../../features/signup/presentation/join_screen.dart';
import '../../features/signup/presentation/signup_screen.dart';

abstract final class AppRoutes {
  /// Shown while the session is restored, and when that failed.
  static const start = '/';
  static const login = '/login';

  /// Entering an invitation by hand.
  static const join = '/$invitationLinkSegment';
  static const waiting = '/waiting';
  static const notActive = '/not-active';
  static const shifts = '/shifts';

  /// The chat on its own screen, on top of the tabs; pass a [ChatShift] as
  /// `extra` to write about that shift.
  static const chat = '$shifts/messages';

  /// The detail of one shift, on top of the tabs.
  static String shift(String shiftId) =>
      '$shifts/${Uri.encodeComponent(shiftId)}';

  /// The signup form of an invitation; also the target of the invitation
  /// link `shiftboard://join/<code>`.
  static String signup(String signupCode) =>
      '$join/${Uri.encodeComponent(signupCode)}';

  static const _signupCode = 'signupCode';
  static const _shiftId = 'shiftId';
}

/// The URL scheme of links into the app, registered in the Android manifest
/// and the iOS Info.plist.
const appLinkScheme = 'shiftboard';

final routerProvider = Provider<GoRouter>((ref) {
  final session = ValueNotifier(ref.read(sessionProvider));
  ref.listen(sessionProvider, (_, next) => session.value = next);

  final router = GoRouter(
    initialLocation: AppRoutes.start,
    refreshListenable: session,
    redirect: (context, state) {
      final target = _guard(session.value, _location(state.uri));
      return target == state.matchedLocation ? null : target;
    },
    routes: [
      GoRoute(
        path: AppRoutes.start,
        builder: (context, state) => const StartScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.join,
        builder: (context, state) => const JoinScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.join}/:${AppRoutes._signupCode}',
        builder: (context, state) => SignupScreen(
          signupCode: state.pathParameters[AppRoutes._signupCode]!,
        ),
      ),
      GoRoute(
        path: AppRoutes.waiting,
        builder: (context, state) => const WaitingScreen(),
      ),
      GoRoute(
        path: AppRoutes.notActive,
        builder: (context, state) => const NotActiveScreen(),
      ),
      GoRoute(
        path: AppRoutes.shifts,
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'messages',
            builder: (context, state) =>
                ChatScreen(shift: state.extra as ChatShift?),
          ),
          GoRoute(
            path: ':${AppRoutes._shiftId}',
            builder: (context, state) => ShiftDetailScreen(
              shiftId: state.pathParameters[AppRoutes._shiftId]!,
            ),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  ref.onDispose(session.dispose);
  return router;
});

/// The path the router matches for [uri].
///
/// In an app link the first segment arrives as the host:
/// `shiftboard://join/abc` is `/join/abc`.
String _location(Uri uri) =>
    uri.scheme == appLinkScheme ? '/${uri.host}${uri.path}' : uri.path;

/// Where someone with this [session] belongs when they ask for [location].
String _guard(AsyncValue<Session> session, String location) {
  final isSignup = location.startsWith(AppRoutes.join);

  return switch (session) {
    AsyncData(value: SignedIn(:final user)) => switch (user.worker?.status) {
      WorkerStatus.ACTIVE =>
        location.startsWith('${AppRoutes.shifts}/')
            ? location
            : AppRoutes.shifts,
      WorkerStatus.PENDING => AppRoutes.waiting,
      _ => AppRoutes.notActive,
    },
    AsyncData(value: SignedOut()) =>
      isSignup || location == AppRoutes.login ? location : AppRoutes.login,
    // An invitation link that started the app stays open while the stored
    // session is looked up.
    AsyncLoading() when isSignup => location,
    _ => AppRoutes.start,
  };
}
