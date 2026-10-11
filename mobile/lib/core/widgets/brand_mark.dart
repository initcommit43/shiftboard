import 'package:flutter/widgets.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// The wordmark. There is no logo yet, so the name set in the display face
/// is the brand.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      AppBrand.name,
      style: AppTypography.title2.copyWith(color: context.colors.ink),
    );
  }
}
