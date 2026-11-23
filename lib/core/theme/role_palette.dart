import 'package:flutter/material.dart';
import 'package:homizi/core/theme/homizi_colors.dart';

/// One accent family per HOMIZI role, drawn from the brand range
/// Yellow #FFD20A to Dark Red #88180B.
///
/// v3: role headers are dark ink photo heroes; the role shows through
/// [glow] (eyebrow, ring, light) and [photo]. [hero] is the role gradient
/// for small fills (icon discs, progress) with [onHero] text that clears
/// AA on every stop. [ink] is the accent as text or icon on [wash]/stone.
@immutable
class HomiziRolePalette {
  const HomiziRolePalette({
    required this.id,
    required this.label,
    required this.accent,
    required this.ink,
    required this.wash,
    required this.hero,
    required this.onHero,
    required this.glow,
    required this.photo,
  });

  /// v3: the role's bright accent on dark [HomiziColors.ink] heroes. Used
  /// for the eyebrow, glow and icon ring; every value clears 4.5:1 on ink.
  final Color glow;

  /// v3: real Indian home photo behind the role's dark hero.
  final String photo;

  final String id;
  final String label;

  /// Chips, selected tabs, small fills.
  final Color accent;

  /// Accent as text or icon on cream or [wash].
  final Color ink;

  /// Tinted section background.
  final Color wash;

  /// Hero band gradient, top-left to bottom-right.
  final List<Color> hero;

  /// Text on [hero].
  final Color onHero;

  /// Text on [accent].
  Color get onAccent =>
      accent.computeLuminance() > 0.3 ? HomiziColors.ink : HomiziColors.white;

  LinearGradient get heroGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: hero,
  );

  /// Tenant and home seeker: red-orange into deep red, white text (5.2:1+).
  static const tenant = HomiziRolePalette(
    id: 'tenant',
    label: 'Home seeker',
    accent: HomiziColors.brandOrange,
    ink: HomiziColors.brandDeepRed,
    wash: HomiziColors.saffronWash,
    hero: [HomiziColors.brandRedOrange, HomiziColors.brandDeepRed],
    onHero: HomiziColors.white,
    glow: HomiziColors.brandOrange,
    photo: 'assets/images/home/apartment.webp',
  );

  /// Roommate / flatmate finder: haldi yellow, ink text.
  static const roommate = HomiziRolePalette(
    id: 'roommate',
    label: 'Flatmate',
    accent: HomiziColors.brandYellow,
    ink: HomiziColors.brandDeepRed,
    wash: HomiziColors.haldiWash,
    hero: [HomiziColors.brandYellow, HomiziColors.brandGolden],
    onHero: HomiziColors.ink,
    glow: HomiziColors.brandYellow,
    photo: 'assets/images/real/people.webp',
  );

  /// Owner / host: terracotta.
  static const owner = HomiziRolePalette(
    id: 'owner',
    label: 'Owner',
    accent: HomiziColors.brandVermilion,
    ink: HomiziColors.brandDeepRed,
    wash: HomiziColors.terracottaWash,
    hero: [HomiziColors.brandRedOrange, HomiziColors.brandDarkRed],
    onHero: HomiziColors.white,
    glow: HomiziColors.brandDeepOrange,
    photo: 'assets/images/real/apartment.webp',
  );

  /// PG owner: deep orange chips over a deep red band.
  static const pg = HomiziRolePalette(
    id: 'pg',
    label: 'PG owner',
    accent: HomiziColors.brandDeepOrange,
    ink: HomiziColors.brandDeepRed,
    wash: HomiziColors.saffronWash,
    hero: [HomiziColors.brandDeepRed, HomiziColors.brandDarkRed],
    onHero: HomiziColors.white,
    glow: HomiziColors.brandGolden,
    photo: 'assets/images/real/bedroom.webp',
  );

  /// Broker / property partner: maroon, the most formal of the set.
  static const broker = HomiziRolePalette(
    id: 'broker',
    label: 'Property partner',
    accent: HomiziColors.brandDarkRed,
    ink: HomiziColors.brandDarkRed,
    wash: HomiziColors.maroonWash,
    hero: [HomiziColors.brandDarkRed, HomiziColors.maroon],
    onHero: HomiziColors.white,
    glow: HomiziColors.brandYellow,
    photo: 'assets/images/real/exterior.webp',
  );

  /// Room sharer / home sharer: golden into orange, ink text.
  static const sharer = HomiziRolePalette(
    id: 'sharer',
    label: 'Room sharer',
    accent: HomiziColors.brandGolden,
    ink: HomiziColors.brandRedOrange,
    wash: HomiziColors.haldiWash,
    hero: [HomiziColors.brandGolden, HomiziColors.brandOrange],
    onHero: HomiziColors.ink,
    glow: HomiziColors.brandGolden,
    photo: 'assets/images/real/living_b.webp',
  );

  /// Company / property management.
  static const company = HomiziRolePalette(
    id: 'company',
    label: 'Company',
    accent: HomiziColors.brandRedOrange,
    ink: HomiziColors.brandDeepRed,
    wash: HomiziColors.terracottaWash,
    hero: [HomiziColors.brandDeepRed, HomiziColors.maroon],
    onHero: HomiziColors.white,
    glow: HomiziColors.brandOrange,
    photo: 'assets/images/home/house.webp',
  );

  static const all = [tenant, roommate, owner, pg, broker, sharer, company];

  /// Maps any role or poster wire value to a palette.
  static HomiziRolePalette forWire(String? wire) {
    return switch (wire?.toLowerCase()) {
      'roommate' || 'flatmate' || 'roomie' => roommate,
      'host' || 'owner' => owner,
      'pg' || 'pg_owner' => pg,
      'broker' || 'partner' || 'agent' => broker,
      'room_sharer' || 'sharer' || 'shared' => sharer,
      'company' => company,
      _ => tenant,
    };
  }
}

/// Puts the current role's palette in the tree. Screens that are not
/// role-specific read it through [HomiziRoleScope.of].
class HomiziRoleScope extends InheritedWidget {
  const HomiziRoleScope({
    required this.palette,
    required super.child,
    super.key,
  });

  final HomiziRolePalette palette;

  static HomiziRolePalette of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<HomiziRoleScope>()
            ?.palette ??
        HomiziRolePalette.tenant;
  }

  @override
  bool updateShouldNotify(HomiziRoleScope oldWidget) =>
      oldWidget.palette != palette;
}

/// Palette for the page on screen. Role-specific routes win (a PG form
/// stays PG-coloured even for a tenant browsing it); otherwise the
/// person's chosen role decides.
HomiziRolePalette paletteForRoute(String path, String? roleWire) {
  bool starts(String p) => path == p || path.startsWith('$p/');
  if (starts('/post-property/pg')) {
    return HomiziRolePalette.pg;
  }
  if (starts('/post-property/shared') ||
      starts('/onboarding/sharer') ||
      starts('/shared-home') ||
      starts('/roomie')) {
    return HomiziRolePalette.sharer;
  }
  if (starts('/broker') ||
      starts('/partner') ||
      starts('/flow/broker') ||
      starts('/onboarding/partner') ||
      starts('/post-property/partner')) {
    return HomiziRolePalette.broker;
  }
  if (starts('/host') ||
      starts('/owner') ||
      starts('/owners') ||
      starts('/flow/host') ||
      starts('/onboarding/owner') ||
      starts('/post-property') ||
      starts('/profile/host')) {
    return HomiziRolePalette.owner;
  }
  if (starts('/roommate') || starts('/roommates') || starts('/flatmate')) {
    return HomiziRolePalette.roommate;
  }
  return HomiziRolePalette.forWire(roleWire);
}
