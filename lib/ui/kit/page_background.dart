import 'package:flutter/material.dart';
import 'package:homizi/core/theme/homizi_colors.dart';

/// Page surface. Every variant is plain white now (unslop pass 8): the
/// city skyline is the sign-in screen's one moment, so it no longer
/// repeats faintly behind every page, and the orange washes are gone.
/// The variants stay so call sites keep compiling.
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
      color: HomiziColors.white,
      child: Stack(fit: StackFit.expand, children: [child]),
    );
  }
}
