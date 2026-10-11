import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'form_page.dart';

/// One destination of the [AppTabBar].
class AppTab {
  const AppTab({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;

  /// The filled variant, shown while the tab is selected.
  final IconData selectedIcon;
}

/// The floating glass tab bar. It sits above the content of a top-level
/// screen, so that content needs [AppTabBar.clearance] of space at its end.
class AppTabBar extends StatelessWidget {
  const AppTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
  });

  static const double _gap = AppSpacing.sm;

  /// The height the bar covers at the bottom of the screen.
  static double clearance(BuildContext context) =>
      MediaQuery.paddingOf(context).bottom + _gap + AppSize.tabBar;

  final List<AppTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final margin = screenMargin(context);
    final radius = BorderRadius.circular(AppRadius.lg);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        margin,
        0,
        margin,
        MediaQuery.paddingOf(context).bottom + _gap,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: const BoxConstraints(minHeight: AppSize.tabBar),
            decoration: BoxDecoration(
              color: colors.surfaceGlass,
              borderRadius: radius,
              border: Border.all(color: colors.hairline),
            ),
            child: Row(
              children: [
                for (final (index, tab) in tabs.indexed)
                  Expanded(
                    child: AppTabItem(
                      tab: tab,
                      selected: index == selectedIndex,
                      onTap: () => onSelected(index),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppTabItem extends StatelessWidget {
  const AppTabItem({
    super.key,
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final AppTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = selected ? colors.primaryText : colors.inkSecondary;

    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSize.tabBar),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? tab.selectedIcon : tab.icon,
                size: AppSize.iconMd,
                color: color,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                tab.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption2.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
