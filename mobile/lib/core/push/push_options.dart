import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

// Passed at build time, for example from a local, ignored file:
// flutter run --dart-define-from-file=firebase.json (ADR 0024).
const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
const _senderId = String.fromEnvironment('FIREBASE_SENDER_ID');
const _androidAppId = String.fromEnvironment('FIREBASE_ANDROID_APP_ID');
const _iosAppId = String.fromEnvironment('FIREBASE_IOS_APP_ID');
const _iosBundleId = String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID');

/// The Firebase project of this build, or null when none was passed: then the
/// app runs without push notifications.
FirebaseOptions? get firebaseOptions {
  final appId = switch (defaultTargetPlatform) {
    TargetPlatform.android => _androidAppId,
    TargetPlatform.iOS => _iosAppId,
    _ => '',
  };
  if (_apiKey.isEmpty || _projectId.isEmpty || _senderId.isEmpty) return null;
  if (appId.isEmpty) return null;
  return FirebaseOptions(
    apiKey: _apiKey,
    appId: appId,
    messagingSenderId: _senderId,
    projectId: _projectId,
    iosBundleId: _iosBundleId.isEmpty ? null : _iosBundleId,
  );
}
