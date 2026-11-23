import 'package:flutter/material.dart';
import 'package:homizi/core/theme/homizi_colors.dart';

/// Page surface (v3): plain stone, no pattern. [soft] uses the deeper
/// stone. [skyline] is kept as an alias of [plain] for older call sites.
enum PageBackgroundVariant { plain, skyline, soft }

class PageBackground extends StatelessWidget {
  const PageBackground({
    required this.child,
    this.variant = PageBackgroundVariant.plain,
    super.key,
  });

  final Widget child;
  final PageBackgroundVariant variant;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: variant == PageBackgroundVariant.soft
          ? HomiziColors.creamDeep
          : HomiziColors.cream,
      child: child,
    );
  }
}
