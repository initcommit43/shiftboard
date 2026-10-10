import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A scrolling screen for a form with a [footer] that sits at the bottom of
/// the screen while there is room and follows the content when there is not,
/// for example with the keyboard open.
class FormPage extends StatelessWidget {
  const FormPage({
    super.key,
    required this.children,
    required this.footer,
    this.topPadding = AppSpacing.s6,
  });

  final List<Widget> children;
  final Widget footer;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.s6,
                  topPadding,
                  AppSpacing.s6,
                  AppSpacing.s2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...children,
                    const Spacer(),
                    const SizedBox(height: AppSpacing.s6),
                    Center(child: footer),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
