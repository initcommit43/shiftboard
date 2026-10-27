import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/live_chat.dart';

/// Keeps the chat live while the app is open: holds [liveChatProvider],
/// which opens and closes the stream as the app and the session change.
class LiveChat extends ConsumerWidget {
  const LiveChat({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(liveChatProvider, (_, _) {});
    return child;
  }
}
