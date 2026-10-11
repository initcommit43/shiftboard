import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// The margin between the screen edge and the content: wider on large phones.
double screenMargin(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= AppSize.screenWide
    ? AppSpacing.marginScreenWide
    : AppSpacing.marginScreen;

/// A scrolling screen for a form. Its [action], the one call to action, and
/// the [footer] below it stay at the bottom of the screen, above the keyboard.
///
/// A screen that was pushed gets the inline bar with the back chevron.
class FormPage extends StatelessWidget {
  const FormPage({
    super.key,
    required this.children,
    required this.action,
    this.footer,
  });

  final List<Widget> children;
  final Widget action;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final margin = screenMargin(context);
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (canPop)
              SizedBox(
                height: AppSize.navBar,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    tooltip: MaterialLocalizations.of(context)
                        .backButtonTooltip,
                    constraints: const BoxConstraints.tightFor(
                      width: AppSize.touchTarget,
                      height: AppSize.touchTarget,
                    ),
                    icon: const Icon(CupertinoIcons.chevron_back),
                  ),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  margin,
                  canPop ? AppSpacing.sm : AppSpacing.xxl,
                  margin,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(margin, 0, margin, AppSpacing.sm),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [action, ?footer],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
