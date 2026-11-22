import 'package:flutter/material.dart';
import 'package:homizi/core/brand/indian_patterns.dart';
import 'package:homizi/core/theme/homizi_colors.dart';

/// Warm page surface (v2): saffron cream with a faint carved-jaali
/// lattice. [skyline] adds the Indian city line along the bottom; [soft]
/// uses the deeper cream. [plain] is cream without pattern.
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
    final patterned = variant != PageBackgroundVariant.plain;
    return ColoredBox(
      color: variant == PageBackgroundVariant.soft
          ? HomiziColors.creamDeep
          : HomiziColors.cream,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (patterned)
            const Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: JaaliPainter(opacity: 0.06, cell: 40),
                ),
              ),
            ),
          if (variant == PageBackgroundVariant.skyline)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 96,
              child: IgnorePointer(
                child: CustomPaint(
                  painter: IndianSkylinePainter(
                    color: HomiziColors.brandOrange,
                    opacity: 0.1,
                  ),
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}
