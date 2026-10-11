import 'package:flutter/widgets.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// Up to two initials of a person or an agency: "Lena Hofer" becomes "LH".
String initialsOf(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  return words.take(2).map((w) => w.characters.first.toUpperCase()).join();
}

/// The initials of [name] in a circle on the soft surface.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.name, required this.size});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        shape: BoxShape.circle,
        border: Border.all(color: colors.hairline),
      ),
      // The name is shown or announced next to the avatar.
      child: ExcludeSemantics(
        child: Text(
          initialsOf(name),
          textScaler: TextScaler.noScaling,
          style:
              (size < AppSize.touchTarget
                      ? AppTypography.badge
                      : AppTypography.headline)
                  .copyWith(color: colors.ink),
        ),
      ),
    );
  }
}
