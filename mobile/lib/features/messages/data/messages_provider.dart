import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftboard_api/shiftboard_api.dart';

import '../../../core/api/api_provider.dart';

/// How many of the latest messages the chat shows.
const _pageSize = 50;

/// The worker's conversation with the agency, newest message first. Loading
/// it marks the agency's messages as read.
final myMessagesProvider = FutureProvider.autoDispose<List<Message>>(
  (ref) async {
    final response = await ref
        .watch(apiProvider)
        .getMessagesApi()
        .listMyMessages(size: _pageSize);
    // Reading changed the unread count.
    ref.invalidate(unreadMessagesProvider);
    return response.data!.content.toList();
  },
  // The chat offers a manual retry and pull to refresh.
  retry: (retryCount, error) => null,
);

/// How many messages from the agency the worker has not read, for the tab.
final unreadMessagesProvider = FutureProvider.autoDispose<int>(
  (ref) async {
    final response = await ref
        .watch(apiProvider)
        .getMessagesApi()
        .getMyConversation();
    return response.data!.unreadCount;
  },
  // A missing badge is not worth a retry.
  retry: (retryCount, error) => null,
);
