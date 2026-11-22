import 'package:flutter/material.dart';
import 'package:homizi/core/brand/indian_patterns.dart';
import 'package:homizi/core/theme/homizi_colors.dart';
import 'package:homizi/core/theme/role_palette.dart';

/// Layered role hero: the role gradient, a warm glow, a jaali lattice, a
/// kolam in the corner, a city skyline on the ground line and a
/// block-print edge. Text and icons inside take [HomiziRolePalette.onHero].
class HomiziHeroBand extends StatelessWidget {
  const HomiziHeroBand({
    required this.child,
    this.palette,
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 28),
    this.radius = 28,
    this.skyline = true,
    this.kolam = true,
    super.key,
  });

  final Widget child;
  final HomiziRolePalette? palette;
  final EdgeInsets padding;
  final double radius;
  final bool skyline;
  final bool kolam;

  @override
  Widget build(BuildContext context) {
    final p = palette ?? HomiziRoleScope.of(context);
    final light = p.onHero == HomiziColors.ink;
    final motif = light ? HomiziColors.brandDeepRed : HomiziColors.white;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: p.heroGradient),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.9, -0.9),
                    radius: 1.1,
                    colors: [
                      HomiziColors.brandGolden.withValues(
                        alpha: light ? 0.0 : 0.38,
                      ),
                      HomiziColors.brandGolden.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: JaaliPainter(
                    color: motif,
                    opacity: light ? 0.08 : 0.07,
                    cell: 30,
                  ),
                ),
              ),
            ),
            if (kolam)
              Positioned(
                right: -18,
                top: -18,
                width: 120,
                height: 120,
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: KolamPainter(
                      color: motif,
                      opacity: light ? 0.2 : 0.24,
                    ),
                  ),
                ),
              ),
            if (skyline)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 56,
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: IndianSkylinePainter(
                      color: motif,
                      opacity: light ? 0.14 : 0.16,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: padding,
              child: DefaultTextStyle.merge(
                style: TextStyle(color: p.onHero),
                child: IconTheme.merge(
                  data: IconThemeData(color: p.onHero),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small role chip: palette wash, palette ink text.
class HomiziRoleChip extends StatelessWidget {
  const HomiziRoleChip({
    required this.label,
    this.palette,
    this.icon,
    super.key,
  });

  final String label;
  final HomiziRolePalette? palette;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = palette ?? HomiziRoleScope.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.wash,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: p.accent.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: p.ink),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: p.ink,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
