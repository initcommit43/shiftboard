import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
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
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final user = ref.watch(currentUserProvider);
    // Logged out; the router is about to leave this screen.
    if (user == null) return const Scaffold();

    final tabs = [
      (
        label: l10n.navShifts,
        icon: Icons.calendar_today_outlined,
        view: ShiftsView(agencyName: user.agency.name),
      ),
      (
        label: l10n.navMyShifts,
        icon: Icons.event_available_outlined,
        view: const _ComingSoon(),
      ),
      (
        label: l10n.navMessages,
        icon: Icons.chat_bubble_outline_rounded,
        view: const _ComingSoon(),
      ),
      (
        label: l10n.navProfile,
        icon: Icons.person_outline_rounded,
        view: const _ComingSoon(),
      ),
    ];
    final worker = user.worker;
    final name = worker == null
        ? user.email
        : '${worker.firstName} ${worker.lastName}';

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        centerTitle: false,
        titleSpacing: AppSpacing.s6,
        scrolledUnderElevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(tabs[_tab].label, style: theme.textTheme.headlineSmall),
        actions: [
          IconButton(
            tooltip: l10n.accountButtonLabel,
            onPressed: () => showAccountSheet(context, name: name),
            icon: InitialsAvatar(name: name, size: 36),
          ),
          const SizedBox(width: AppSpacing.s3),
        ],
      ),
      body: SafeArea(
        top: false,
        child: IndexedStack(
          index: _tab,
          children: [for (final tab in tabs) tab.view],
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (index) => setState(() => _tab = index),
          destinations: [
            for (final tab in tabs)
              NavigationDestination(icon: Icon(tab.icon), label: tab.label),
          ],
        ),
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
        padding: const EdgeInsets.all(AppSpacing.s6),
        child: StatusMessage(
          icon: Icons.hourglass_empty_rounded,
          title: l10n.comingSoonTitle,
          message: l10n.comingSoonMessage,
        ),
      ),
    );
  }
}
