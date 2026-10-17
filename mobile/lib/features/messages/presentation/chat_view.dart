import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shiftboard_api/shiftboard_api.dart';

import '../../../core/api/api_error.dart';
import '../../../core/api/api_provider.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_alert.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/form_page.dart';
import '../../../core/widgets/status_message.dart';
import '../../auth/data/session.dart';
import '../../shifts/presentation/shift_format.dart';
import '../data/messages_provider.dart';

/// The shift a new message is about.
typedef ChatShift = ({String id, String title, DateTime startsAt});

/// The worker's one conversation with the agency: the latest messages at the
/// bottom, and a field to write. A message started from a shift carries that
/// shift until it is sent or the tag is removed.
class ChatView extends ConsumerStatefulWidget {
  const ChatView({super.key, this.shift});

  final ChatShift? shift;

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  final _text = TextEditingController();
  late ChatShift? _shift = widget.shift;
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _text.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref
          .read(apiProvider)
          .getMessagesApi()
          .sendMessage(
            messageRequest: MessageRequest(
              (b) => b
                ..body = body
                ..shiftId = _shift?.id,
            ),
          );
      _text.clear();
      ref.invalidate(myMessagesProvider);
      if (mounted) {
        setState(() {
          _sending = false;
          _shift = null;
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = ApiError.from(error).message(context.l10n);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final messages = ref.watch(myMessagesProvider);
    Future<void> reload() => ref.refresh(myMessagesProvider.future);

    final Widget body;
    if (messages.value case final list?) {
      body = RefreshIndicator(
        onRefresh: () async {
          try {
            await reload();
          } catch (_) {
            // The old messages stay; the next pull tries again.
          }
        },
        child: list.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(screenMargin(context)),
                children: [
                  StatusMessage(
                    icon: CupertinoIcons.chat_bubble_2,
                    title: l10n.chatEmptyTitle,
                    message: l10n.chatEmptyMessage(
                      ref.watch(currentUserProvider)?.agency.name ?? '',
                    ),
                  ),
                ],
              )
            : ListView.separated(
                // Newest at the bottom, where the field is.
                reverse: true,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: screenMargin(context),
                  vertical: AppSpacing.md,
                ),
                itemCount: list.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) =>
                    MessageBubble(message: list[index]),
              ),
      );
    } else if (messages.isLoading) {
      body = Center(
        child: CircularProgressIndicator(semanticsLabel: l10n.loadingLabel),
      );
    } else {
      body = Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenMargin(context)),
          child: StatusMessage(
            icon: CupertinoIcons.exclamationmark_triangle,
            tone: StatusTone.error,
            title: l10n.chatErrorTitle,
            message: ApiError.from(messages.error!).isOffline
                ? l10n.errorCheckConnection
                : l10n.errorGeneric,
            action: AppButton(
              label: l10n.actionRetry,
              variant: AppButtonVariant.soft,
              expand: false,
              onPressed: () => reload().ignore(),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: body),
        _Composer(
          controller: _text,
          shift: _shift,
          sending: _sending,
          error: _error,
          onRemoveShift: () => setState(() => _shift = null),
          onSend: _send,
        ),
      ],
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.shift,
    required this.sending,
    required this.error,
    required this.onRemoveShift,
    required this.onSend,
  });

  final TextEditingController controller;
  final ChatShift? shift;
  final bool sending;
  final String? error;
  final VoidCallback onRemoveShift;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final margin = screenMargin(context);
    final format = ShiftFormat.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.canvas,
        border: Border(top: BorderSide(color: colors.hairline)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          margin,
          AppSpacing.sm,
          margin - AppSpacing.xxs,
          AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (error case final error?) ...[
              AppAlert(text: error),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (shift case final shift?) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: InputChip(
                  label: Text(
                    l10n.chatAbout(shift.title, format.date(shift.startsAt)),
                  ),
                  onDeleted: onRemoveShift,
                  deleteButtonTooltipMessage: l10n.chatRemoveShift,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 5,
                    maxLength: 2000,
                    buildCounter: (
                      _, {
                      required currentLength,
                      required isFocused,
                      maxLength,
                    }) => null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: l10n.chatHint,
                      labelText: null,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                IconButton(
                  tooltip: l10n.chatSend,
                  onPressed: sending ? null : onSend,
                  constraints: const BoxConstraints.tightFor(
                    width: AppSize.touchTarget,
                    height: AppSize.touchTarget,
                  ),
                  icon: sending
                      ? const SizedBox.square(
                          dimension: AppSize.iconSm,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          CupertinoIcons.arrow_up_circle_fill,
                          color: colors.action,
                          size: AppSize.touchTarget - AppSpacing.sm,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One message: the worker's own on the right, the agency's on the left,
/// system messages centered and worded from their event.
class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final format = ShiftFormat.of(context);
    final time =
        '${format.date(message.createdAt)}, ${format.time(message.createdAt)}';

    if (message.type == MessageType.SYSTEM) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: ShapeDecoration(
              color: colors.surfaceSoft,
              shape: const StadiumBorder(),
            ),
            child: Text(
              systemText(message, l10n),
              textAlign: TextAlign.center,
              style: AppTypography.footnote.copyWith(
                color: colors.inkSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          _ShiftLine(message: message, trailing: time, centered: true),
        ],
      );
    }

    final own = message.fromWorker;
    final broadcast = message.type == MessageType.BROADCAST;
    final foreground = own ? colors.onAction : colors.ink;

    return Column(
      crossAxisAlignment: own
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.8,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: own ? colors.action : colors.surfaceSoft,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (broadcast) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ExcludeSemantics(
                        child: Icon(
                          CupertinoIcons.speaker_2,
                          size: AppSize.iconSm,
                          color: foreground,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        l10n.chatBroadcast,
                        style: AppTypography.caption1.copyWith(
                          color: foreground,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                ],
                Text(
                  message.body,
                  style: AppTypography.body.copyWith(color: foreground),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        _ShiftLine(
          message: message,
          trailing: own || message.senderName == null
              ? time
              : '${message.senderName}, $time',
          centered: false,
        ),
      ],
    );
  }
}

/// The time of a message, after the shift it is about, which opens on tap.
class _ShiftLine extends StatelessWidget {
  const _ShiftLine({
    required this.message,
    required this.trailing,
    required this.centered,
  });

  final Message message;
  final String trailing;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final format = ShiftFormat.of(context);
    final caption = AppTypography.caption1.copyWith(color: colors.inkTertiary);
    final shift = message.shift;

    return Wrap(
      alignment: centered ? WrapAlignment.center : WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.sm,
      children: [
        if (shift != null)
          // A small tag; the 44pt hit area comes from the padding around it.
          Semantics(
            button: true,
            child: InkWell(
              onTap: () => context.push(AppRoutes.shift(shift.id)),
              customBorder: const StadiumBorder(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: ShapeDecoration(
                    shape: StadiumBorder(
                      side: BorderSide(color: colors.hairlineStrong),
                    ),
                  ),
                  child: Text(
                    context.l10n.chatAbout(
                      shift.title,
                      format.date(shift.startsAt),
                    ),
                    style: AppTypography.caption1.copyWith(color: colors.ink),
                  ),
                ),
              ),
            ),
          ),
        Text(trailing, style: caption),
      ],
    );
  }
}

/// The worker's wording of what a system message reports.
String systemText(Message message, AppLocalizations l10n) {
  return switch (message.event) {
    SystemEvent.CLAIM_CONFIRMED => l10n.chatEventConfirmed,
    SystemEvent.CLAIM_REJECTED => l10n.chatEventRejected,
    SystemEvent.CLAIM_CANCELLED_BY_WORKER => l10n.chatEventCancelledByYou,
    SystemEvent.REMOVED_BY_AGENCY => l10n.chatEventRemoved,
    SystemEvent.SHIFT_CANCELLED => l10n.chatEventShiftCancelled,
    _ => message.body,
  };
}
