import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/status_message.dart';
import '../../auth/data/session.dart';

enum _Load { idle, running, failed }

/// The tab with the open shifts.
///
/// The API has no shift list yet, so the tab is always empty. Refreshing
/// checks the account instead, which is the one thing that can change what
/// this tab shows: a deactivated worker is moved off it by the router.
class ShiftsView extends ConsumerStatefulWidget {
  const ShiftsView({super.key, required this.agencyName});

  final String agencyName;

  @override
  ConsumerState<ShiftsView> createState() => _ShiftsViewState();
}

class _ShiftsViewState extends ConsumerState<ShiftsView> {
  _Load _load = _Load.idle;

  Future<void> _refresh() async {
    setState(() => _load = _Load.running);
    var result = _Load.idle;
    try {
      await ref.read(sessionProvider.notifier).refresh();
    } on DioException {
      result = _Load.failed;
    }
    if (mounted) setState(() => _load = result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return switch (_load) {
      _Load.running => const _Skeleton(),
      _Load.idle => _Centered(
        child: StatusMessage(
          icon: Icons.calendar_today_outlined,
          title: l10n.shiftsEmptyTitle,
          message: l10n.shiftsEmptyMessage(widget.agencyName),
          action: AppButton(
            label: l10n.shiftsRefresh,
            variant: AppButtonVariant.outline,
            expand: false,
            onPressed: _refresh,
          ),
        ),
      ),
      _Load.failed => _Centered(
        child: StatusMessage(
          icon: Icons.warning_amber_rounded,
          tone: StatusTone.error,
          title: l10n.shiftsErrorTitle,
          message: l10n.errorCheckConnection,
          action: AppButton(
            label: l10n.actionRetry,
            expand: false,
            onPressed: _refresh,
          ),
        ),
      ),
    };
  }
}

class _Centered extends StatelessWidget {
  const _Centered({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s6,
          vertical: AppSpacing.s4,
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s6,
          vertical: AppSpacing.s4,
        ),
        itemCount: _cards.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s3),
        itemBuilder: (context, index) {
          final (title, subtitle) = _cards[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Bar(width: title, height: AppSpacing.s5),
                  const SizedBox(height: AppSpacing.s3),
                  _Bar(width: subtitle, height: 14),
                  const SizedBox(height: AppSpacing.s3),
                  const Row(
                    children: [
                      _Bar(width: 72, height: AppSpacing.s6),
                      SizedBox(width: AppSpacing.s2),
                      _Bar(width: 56, height: AppSpacing.s6),
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
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    );
  }
}
