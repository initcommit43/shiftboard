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
    this.semanticLabel,
    this.badge = 0,
  });

  /// A count that needs the worker's attention, such as unread messages; shown
  /// as a red oval on the icon when above zero.
  final int badge;

  /// One short word; four tabs share the width of the screen.
  final String label;

  /// What screen readers say instead of a [label] that is abbreviated.
  final String? semanticLabel;
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

  static const double _maxLabelScale = 1.2;

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
      label: tab.semanticLabel,
      excludeSemantics: tab.semanticLabel != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSize.tabBar),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Badge(
                isLabelVisible: tab.badge > 0,
                label: Text('${tab.badge}'),
                backgroundColor: colors.danger,
                textColor: colors.onDanger,
                child: Icon(
                  selected ? tab.selectedIcon : tab.icon,
                  size: AppSize.iconMd,
                  color: color,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                tab.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                // As in a native tab bar, the labels grow only a little with
                // the system text size: a quarter of the width has no room
                // for more, and the screen title above carries the full name.
                textScaler: MediaQuery.textScalerOf(context)
                    .clamp(maxScaleFactor: _maxLabelScale),
                style: AppTypography.caption2.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
