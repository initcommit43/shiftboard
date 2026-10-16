import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shiftboard_api/shiftboard_api.dart';

import '../../../core/api/api_error.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/form_page.dart';
import '../../../core/widgets/status_message.dart';
import '../../auth/data/session.dart';
import 'shift_card.dart';

/// A tab with a list of shifts from [shifts]: cards that open the detail,
/// pull to refresh, placeholders while loading, and an error with retry.
/// With no shifts it shows the empty state, whose [emptyAction] defaults to
/// loading the list again.
class ShiftListView extends ConsumerWidget {
  const ShiftListView({
    super.key,
    required this.shifts,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyMessage,
    this.emptyAction,
  });

  final FutureProvider<List<WorkerShift>> shifts;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;
  final Widget? emptyAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    // A deactivated worker is refused the list; loading the account again
    // lets the router move them off this tab.
    ref.listen(shifts, (_, next) {
      if (next case AsyncError(:final error)
          when ApiError.from(error).code == ApiErrorCode.workerNotActive) {
        ref.read(sessionProvider.notifier).refresh().ignore();
      }
    });
    final result = ref.watch(shifts);
    Future<void> reload() => ref.refresh(shifts.future);

    if (result.value case final list? when list.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          try {
            await reload();
          } catch (_) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.shiftsRefreshFailed)));
          }
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: screenMargin(context),
            vertical: AppSpacing.sm,
          ),
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
          itemBuilder: (context, index) => ShiftCard(
            shift: list[index],
            onTap: () => context.push(AppRoutes.shift(list[index].id)),
          ),
        ),
      );
    }
    if (result.isLoading) return const _Skeleton();

    final retry = AppButton(
      label: result.hasError ? l10n.actionRetry : l10n.shiftsRefresh,
      variant: AppButtonVariant.soft,
      expand: false,
      onPressed: () => reload().ignore(),
    );
    if (result.error case final error?) {
      return _Centered(
        child: StatusMessage(
          icon: CupertinoIcons.exclamationmark_triangle,
          tone: StatusTone.error,
          title: l10n.shiftsErrorTitle,
          message: ApiError.from(error).isOffline
              ? l10n.errorCheckConnection
              : l10n.errorGeneric,
          action: retry,
        ),
      );
    }
    return _Centered(
      child: StatusMessage(
        icon: emptyIcon,
        title: emptyTitle,
        message: emptyMessage,
        action: emptyAction ?? retry,
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenMargin(context),
          vertical: AppSpacing.lg,
        ),
        child: child,
      ),
    );
  }
}

/// Placeholder cards in the shape of the shift list while it loads.
class _Skeleton extends StatelessWidget {
  const _Skeleton();

  // Widths of the title and subtitle bars, so the cards do not look cloned.
  static const _cards = [
    (200.0, 140.0),
    (168.0, 120.0),
    (220.0, 150.0),
    (184.0, 110.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.shiftsLoading,
      liveRegion: true,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: screenMargin(context),
          vertical: AppSpacing.sm,
        ),
        itemCount: _cards.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
        itemBuilder: (context, index) {
          final (title, subtitle) = _cards[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.paddingCard),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Bar(width: title, height: 22),
                  const SizedBox(height: AppSpacing.sm),
                  _Bar(width: subtitle, height: AppSpacing.lg),
                  const SizedBox(height: AppSpacing.lg),
                  const Row(
                    children: [
                      _Bar(width: 72, height: AppSize.badge),
                      SizedBox(width: AppSpacing.sm),
                      _Bar(width: 56, height: AppSize.badge),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.colors.hairline,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    );
  }
}
