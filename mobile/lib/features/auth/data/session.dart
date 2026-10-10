import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftboard_api/shiftboard_api.dart';

import '../../../core/api/api_provider.dart';
import 'token_storage.dart';

sealed class Session {
  const Session();
}

class SignedOut extends Session {
  const SignedOut();
}

class SignedIn extends Session {
  const SignedIn(this.user);

  /// Role, agency and, for workers, the profile with its approval status.
  final CurrentUser user;
}

/// The session of this device.
///
/// Loading while a stored session is restored on start, an error when the API
/// could not be reached for that; the stored tokens are kept in that case.
final sessionProvider = AsyncNotifierProvider<SessionController, Session>(
  SessionController.new,
  // The start screen offers a manual retry.
  retry: (retryCount, error) => null,
);

/// The signed-in user, or null without a session.
final currentUserProvider = Provider<CurrentUser?>(
  (ref) => switch (ref.watch(sessionProvider).value) {
    SignedIn(:final user) => user,
    _ => null,
  },
);

class SessionController extends AsyncNotifier<Session> {
  AuthApi get _authApi => ref.read(apiProvider).getAuthApi();
  TokenStorage get _storage => ref.read(tokenStorageProvider);

  @override
  Future<Session> build() async {
    if (await _storage.read() == null) return const SignedOut();
    return _loadUser();
  }

  Future<void> login({required String email, required String password}) async {
    final response = await _authApi.login(
      loginRequest: LoginRequest(
        (b) => b
          ..email = email
          ..password = password
          ..client = ClientType.WORKER_APP,
      ),
    );
    await start(response.data!);
  }

  /// Starts the session with a token pair from login or signup.
  ///
  /// The tokens are valid from here on, so a failure to load the user ends in
  /// the retryable start error and not back on the form.
  Future<void> start(TokenResponse tokens) async {
    await _storage.write((
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    ));
    state = await AsyncValue.guard(_loadUser);
  }

  /// Loads the user again, for example to see whether the agency has approved
  /// the signup. Throws and keeps the current state when that fails.
  Future<void> refresh() async {
    state = AsyncData(await _loadUser());
  }

  Future<void> logout() async {
    final tokens = await _storage.read();
    await _storage.clear();
    state = const AsyncData(SignedOut());
    if (tokens == null) return;
    try {
      await _authApi.logout(
        refreshTokenRequest: RefreshTokenRequest(
          (b) => b.refreshToken = tokens.refreshToken,
        ),
      );
    } on DioException {
      // Best effort: the device is logged out either way and the refresh
      // token expires on its own.
    }
  }

  /// Called when the refresh token was rejected and the tokens are gone.
  void expire() => state = const AsyncData(SignedOut());

  Future<Session> _loadUser() async {
    try {
      final response = await _authApi.getCurrentUser();
      return SignedIn(response.data!);
    } on DioException {
      if (await _storage.read() == null) return const SignedOut();
      rethrow;
    }
  }
}
