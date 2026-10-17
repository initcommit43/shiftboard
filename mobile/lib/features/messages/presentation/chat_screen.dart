import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/form_page.dart';
import 'chat_view.dart';

/// The chat on its own screen, opened from a shift to ask about it.
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, this.shift});

  final ChatShift? shift;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: AppSize.navBar,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    tooltip: MaterialLocalizations.of(context)
                        .backButtonTooltip,
                    constraints: const BoxConstraints.tightFor(
                      width: AppSize.touchTarget,
                      height: AppSize.touchTarget,
                    ),
                    icon: const Icon(CupertinoIcons.chevron_back),
                  ),
                  SizedBox(width: screenMargin(context) - AppSpacing.md),
                  Semantics(
                    header: true,
                    child: Text(
                      context.l10n.navMessages,
                      style: AppTypography.headline.copyWith(
                        color: context.colors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: ChatView(shift: shift)),
          ],
        ),
      ),
    );
  }
}
