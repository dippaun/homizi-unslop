import 'package:flutter/material.dart';
import 'package:homizi/core/theme/homizi_colors.dart';
import 'package:homizi/core/theme/role_palette.dart';

/// v3 role hero: a dark ink panel over a real Indian home photo, with a
/// soft light in the role's [HomiziRolePalette.glow]. Text inside is white;
/// the scrim keeps the copy side at least 12:1. No patterns.
class HomiziHeroBand extends StatelessWidget {
  const HomiziHeroBand({
    required this.child,
    this.palette,
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 24),
    this.radius = 24,
    this.photo,
    this.photoAlignment = Alignment.centerRight,
    super.key,
  });

  final Widget child;
  final HomiziRolePalette? palette;
  final EdgeInsets padding;
  final double radius;

  /// Overrides the role photo. An empty string shows no photo.
  final String? photo;
  final Alignment photoAlignment;

  @override
  Widget build(BuildContext context) {
    final p = palette ?? HomiziRoleScope.of(context);
    final asset = photo ?? p.photo;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: HomiziColors.shadowStrong,
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: ColoredBox(
          color: HomiziColors.ink,
          child: Stack(
            children: [
              if (asset.isNotEmpty)
                Positioned.fill(
                  child: Image.asset(
                    asset,
                    fit: BoxFit.cover,
                    alignment: photoAlignment,
                    excludeFromSemantics: true,
                    errorBuilder: (context, error, stack) =>
                        const SizedBox.shrink(),
                  ),
                ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        HomiziColors.ink.withValues(alpha: 0.97),
                        HomiziColors.ink.withValues(alpha: 0.88),
                        HomiziColors.ink.withValues(alpha: 0.38),
                      ],
                      stops: const [0, 0.5, 1],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(1.1, -1.2),
                        radius: 1.2,
                        colors: [
                          p.glow.withValues(alpha: 0.34),
                          p.glow.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: padding,
                child: DefaultTextStyle.merge(
                  style: const TextStyle(color: HomiziColors.white),
                  child: IconTheme.merge(
                    data: const IconThemeData(color: HomiziColors.white),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
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

/// Role home intro: glow eyebrow, Poppins title and one line of body on
/// the dark role photo hero. Reused by host, owner, PG, broker, sharer and
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
    return HomiziHeroBand(
      palette: p,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: p.glow,
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox(width: 6, height: 6),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        (eyebrow ?? p.label).toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w700,
                          color: p.glow,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  key: titleKey,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 26,
                    height: 1.15,
                    letterSpacing: -0.4,
                    fontWeight: FontWeight.w600,
                    color: HomiziColors.white,
                  ),
                ),
                if (body != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    body!,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      height: 1.4,
                      color: HomiziColors.onInkMuted,
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
                borderRadius: BorderRadius.circular(16),
                color: HomiziColors.inkRaised.withValues(alpha: 0.85),
                border: Border.all(color: p.glow.withValues(alpha: 0.55)),
              ),
              child: SizedBox(
                width: 52,
                height: 52,
                child: Icon(icon, size: 24, color: p.glow),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// v3 icon tile: rounded square in the role wash with the role ink icon.
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
        borderRadius: BorderRadius.circular(size * 0.32),
        color: p.wash,
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(icon, size: size * 0.5, color: p.ink),
      ),
    );
  }
}
