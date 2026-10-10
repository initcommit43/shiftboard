import 'package:flutter/material.dart';

/// Up to two initials of a person or an agency: "Lena Hofer" becomes "LH".
String initialsOf(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  return words.take(2).map((w) => w.characters.first.toUpperCase()).join();
}

/// The initials of [name] on the accent color.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.name,
    required this.size,
    this.borderRadius,
  });

  final String name;
  final double size;

  /// A circle when null.
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textStyle = size < 40
        ? theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)
        : theme.textTheme.titleSmall;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        shape: borderRadius == null ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: borderRadius == null
            ? null
            : BorderRadius.circular(borderRadius!),
      ),
      // The name is shown or announced next to the avatar.
      child: ExcludeSemantics(
        child: Text(
          initialsOf(name),
          textScaler: TextScaler.noScaling,
          style: textStyle?.copyWith(color: scheme.onPrimaryContainer),
        ),
      ),
    );
  }
}
