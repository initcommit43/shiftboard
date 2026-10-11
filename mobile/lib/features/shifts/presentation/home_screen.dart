import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_tab_bar.dart';
import '../../../core/widgets/form_page.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/status_message.dart';
import '../../auth/data/session.dart';
import 'account_sheet.dart';
import 'shifts_view.dart';

/// The home of an approved worker: the tabs with the open shifts first.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = ref.watch(currentUserProvider);
    // Logged out; the router is about to leave this screen.
    if (user == null) return const Scaffold();

    final tabs = [
      (
        tab: AppTab(
          label: l10n.navShifts,
          icon: CupertinoIcons.square_list,
          selectedIcon: CupertinoIcons.square_list_fill,
        ),
        view: ShiftsView(agencyName: user.agency.name),
      ),
      (
        tab: AppTab(
          label: l10n.navMyShifts,
          icon: CupertinoIcons.checkmark_circle,
          selectedIcon: CupertinoIcons.checkmark_circle_fill,
        ),
        view: const _ComingSoon(),
      ),
      (
        tab: AppTab(
          label: l10n.navMessages,
          icon: CupertinoIcons.chat_bubble,
          selectedIcon: CupertinoIcons.chat_bubble_fill,
        ),
        view: const _ComingSoon(),
      ),
      (
        tab: AppTab(
          label: l10n.navProfile,
          icon: CupertinoIcons.person,
          selectedIcon: CupertinoIcons.person_fill,
        ),
        view: const _ComingSoon(),
      ),
    ];
    final worker = user.worker;
    final name = worker == null
        ? user.email
        : '${worker.firstName} ${worker.lastName}';
    final margin = screenMargin(context);

    return Scaffold(
      // The tab bar floats; the content runs behind it.
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                margin,
                AppSpacing.sm,
                margin - AppSpacing.xxs,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        tabs[_tab].tab.label,
                        style: AppTypography.largeTitle.copyWith(
                          color: context.colors.ink,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.accountButtonLabel,
                    onPressed: () => showAccountSheet(context, name: name),
                    constraints: const BoxConstraints.tightFor(
                      width: AppSize.touchTarget,
                      height: AppSize.touchTarget,
                    ),
                    padding: EdgeInsets.zero,
                    icon: InitialsAvatar(name: name, size: 36),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: AppTabBar.clearance(context)),
                child: IndexedStack(
                  index: _tab,
                  children: [for (final tab in tabs) tab.view],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppTabBar(
        tabs: [for (final tab in tabs) tab.tab],
        selectedIndex: _tab,
        onSelected: (index) => setState(() => _tab = index),
      ),
    );
  }
}

/// Placeholder for the tabs that later slices fill.
class _ComingSoon extends StatelessWidget {
  const _ComingSoon();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(screenMargin(context)),
        child: StatusMessage(
          icon: CupertinoIcons.hourglass,
          title: l10n.comingSoonTitle,
          message: l10n.comingSoonMessage,
        ),
      ),
    );
  }
}
