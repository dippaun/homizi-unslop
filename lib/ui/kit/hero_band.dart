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

/// Role home intro: eyebrow chip, Poppins title and one line of body on
/// the role hero band. Reused by host, owner, PG, broker, sharer and
/// tenant homes in place of their plain title/body pair.
class HomiziRoleIntro extends StatelessWidget {
  const HomiziRoleIntro({
    required this.title,
    this.body,
    this.eyebrow,
    this.palette,
    this.trailing,
    this.icon,
    this.titleKey,
    super.key,
  });

  /// Key on the title [Text], for tests and deep links.
  final Key? titleKey;
  final String title;
  final String? body;
  final String? eyebrow;
  final HomiziRolePalette? palette;
  final Widget? trailing;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = palette ?? HomiziRoleScope.of(context);
    // Small eyebrow type: deep red on the yellow heroes, pale haldi on the
    // red ones (5.0:1 on red orange; full yellow would be 4.0:1).
    final lift = p.onHero == HomiziColors.ink
        ? HomiziColors.brandDeepRed
        : HomiziColors.haldiWash;
    return HomiziHeroBand(
      palette: p,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 44),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (eyebrow ?? p.label).toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w700,
                    color: lift,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  key: titleKey,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                    color: p.onHero,
                  ),
                ),
                if (body != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    body!,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      height: 1.35,
                      color: p.onHero.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
          if (trailing == null && icon != null) ...[
            const SizedBox(width: 12),
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: p.onHero.withValues(alpha: 0.16),
                border: Border.all(color: p.onHero.withValues(alpha: 0.4)),
              ),
              child: SizedBox(
                width: 52,
                height: 52,
                child: Icon(icon, size: 26, color: p.onHero),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Round icon disc in the role gradient, for list tiles and cards.
class HomiziRoleIcon extends StatelessWidget {
  const HomiziRoleIcon(this.icon, {this.palette, this.size = 44, super.key});

  final IconData icon;
  final HomiziRolePalette? palette;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = palette ?? HomiziRoleScope.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: p.heroGradient,
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(icon, size: size * 0.5, color: p.onHero),
      ),
    );
  }
}
