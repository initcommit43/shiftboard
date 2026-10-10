import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

typedef AuthTokens = ({String accessToken, String refreshToken});

/// Keeps the token pair in the platform's secure storage (Keychain, Keystore).
class TokenStorage {
  TokenStorage(this._storage);

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  // Every request needs the access token, so it is read from disk only once.
  AuthTokens? _tokens;
  bool _loaded = false;

  Future<AuthTokens?> read() async {
    if (!_loaded) {
      final accessToken = await _storage.read(key: _accessTokenKey);
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      _tokens = accessToken != null && refreshToken != null
          ? (accessToken: accessToken, refreshToken: refreshToken)
          : null;
      _loaded = true;
    }
    return _tokens;
  }

  Future<void> write(AuthTokens tokens) async {
    _tokens = tokens;
    _loaded = true;
    await _storage.write(key: _accessTokenKey, value: tokens.accessToken);
    await _storage.write(key: _refreshTokenKey, value: tokens.refreshToken);
  }

  Future<void> clear() async {
    _tokens = null;
    _loaded = true;
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => TokenStorage(const FlutterSecureStorage()),
);
