import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a link in the app that handles it, such as the maps app or the
/// phone. Returns false when no app took it.
typedef UrlOpener = Future<bool> Function(Uri uri);

/// A provider so that tests can see what would have been opened.
final urlOpenerProvider = Provider<UrlOpener>(
  (ref) => (uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on PlatformException {
      return false;
    }
  },
);

/// A search for [address] in the platform's maps app. Both links open the
/// website when the app is missing.
Uri mapsUri(String address) => defaultTargetPlatform == TargetPlatform.iOS
    ? Uri.https('maps.apple.com', '/', {'q': address})
    : Uri.https('www.google.com', '/maps/search/', {
        'api': '1',
        'query': address,
      });

/// A call to [phone], without the spaces people write numbers with.
Uri phoneUri(String phone) =>
    Uri(scheme: 'tel', path: phone.replaceAll(RegExp(r'[^\d+]'), ''));
