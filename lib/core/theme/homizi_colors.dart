import 'package:flutter/material.dart';

/// HOMIZI design tokens. Hex values live only in this file.
///
/// Yellow and golden orange never take white text: those pairs are about
/// 1.5:1 and 1.9:1. Ink on them clears 4.5:1. White is used on success,
/// warning, and error, where those pairs also clear 4.5:1.
abstract final class HomiziColors {
  static const Color brandYellow = Color(0xFFFFD20A);
  static const Color brandGolden = Color(0xFFF9AD0B);
  static const Color brandOrange = Color(0xFFF47B0B);
  static const Color brandDeepOrange = Color(0xFFED5419);
  static const Color brandVermilion = Color(0xFFE43C1B);
  static const Color brandRedOrange = Color(0xFFCC3015);
  static const Color brandDeepRed = Color(0xFFA92310);
  static const Color brandDarkRed = Color(0xFF88180B);

  /// Primary CTA. Ink on this orange is about 6.0:1. White is about 2.7:1.
  static const Color accent = brandOrange;

  /// Logo and splash orange from the mark (`#F75620`). Not the CTA accent.
  /// White text is not used on this colour.
  static const Color logoOrange = Color(0xFFF75620);

  /// Warm peach wash for selected cards, info panels and empty states.
  /// Replaces the old Post Property lavender (unslop pass 2: no purple).
  static const Color warmWash = Color(0xFFFFF1E8);

  static const Color white = Color(0xFFFFFFFF);
  static const Color surface = white;

  /// Warm off-white page background. Cards sit on it in white.
  static const Color soft = Color(0xFFFAF8F5);

  /// Main text. About 16:1 on white.
  static const Color ink = Color(0xFF172033);

  /// Body copy. About 9.4:1 on white.
  static const Color inkSoft = Color(0xFF3A4660);

  /// Secondary text. About 5.7:1 on white and 5.4:1 on [soft].
  static const Color muted = Color(0xFF5C677A);

  /// Quiet hairline, ink at about 8% on the warm page.
  static const Color line = Color(0xFFEAE6E1);
  static const Color mist = soft;

  /// Pale yellow for selected chips. Ink on this stays well above 4.5:1.
  static const Color accentWash = Color(0xFFFFF6D0);

  static const Color success = Color(0xFF16803C);
  static const Color onSuccess = white;
  static const Color successWash = Color(0xFFE7F6EC);

  static const Color warning = Color(0xFF9A6700);
  static const Color onWarning = white;
  static const Color warningWash = Color(0xFFFFF6D6);

  static const Color error = Color(0xFFB42318);
  static const Color onError = white;
  static const Color errorWash = Color(0xFFFDECEC);

  /// Secondary information only (room-sharer tag, info notes). Never a
  /// primary action and never decoration.
  static const Color info = Color(0xFF1D4E9E);
  static const Color infoWash = Color(0xFFE8F1FF);

  static const Color unread = error;

  /// Neutral shadows only, soft and small (unslop pass 7).
  static const Color shadow = Color(0x12172033);
  static const Color shadowSoft = Color(0x0D172033);
  static const Color shadowStrong = Color(0x1F172033);
  static const Color shadowNight = Color(0x66000000);

  static const Color accentDisabled = Color(0x7AF47B0B);
  static const Color accentHover = Color(0x14F47B0B);
  static const Color inkPressed = Color(0x24172033);
  static const Color inkHover = Color(0x14172033);
  static const Color accentWashHover = Color(0x66FFF6D0);

  static const Color whiteVeil = Color(0xF7FFFFFF);
  static const Color whiteClear = Color(0x00FFFFFF);
  static const Color clear = Color(0x00000000);

  /// Photo scrim behind names on portrait cards.
  static const Color inkScrim = Color(0xF0172033);

  /// Offline map drawing: land, paper roads and parks.
  static const Color mapLand = Color(0xFFE7F0E4);
  static const Color mapPaper = Color(0xFFF7F4EA);
  static const Color mapPark = Color(0xFFD5E8C8);
  static const Color mapBlank = Color(0xFFF4F1EA);

  static const Color night = Color(0xFF121212);
  static const Color nightRaised = Color(0xFF1E1E1E);
  static const Color nightHigh = Color(0xFF2A2A2A);
  static const Color nightHighest = Color(0xFF333333);
  static const Color nightInk = Color(0xFFF5F5F5);
  static const Color nightMuted = Color(0xFFC8C8C8);
  static const Color nightLine = Color(0xFF3A3A3A);
  static const Color nightAccentContainer = brandDarkRed;
}

/// The one gradient in the app. Orange into red, only on the primary
/// action of a screen (Continue, Verify, Message, Interested).
abstract final class HomiziGradients {
  static const LinearGradient action = LinearGradient(
    colors: [HomiziColors.logoOrange, HomiziColors.brandRedOrange],
  );
}

/// Spacing scale. Every margin, padding, gap and fixed height sits on the
/// 4px grid (unslop pass 1). A 2px step is fine for nudges inside small
/// controls. Space inside a group is smaller than space between groups.
abstract final class HomiziSpace {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double section = 48;

  /// Page edge on phones.
  static const double page = 20;

  /// Inside cards.
  static const double card = 16;

  /// Control radius (buttons, inputs). Kept for older call sites.
  static const double radius = HomiziRadius.control;

  /// Card radius. Kept for older call sites.
  static const double cardRadius = HomiziRadius.card;
}

/// Radius scale. Nested radius: inner = outer minus padding, never below 4.
/// Not everything is a pill: only avatars, dots and the round back button.
abstract final class HomiziRadius {
  /// Tags, keycaps, small badges.
  static const double tag = 6;

  /// Chips and segmented choices.
  static const double chip = 8;

  /// Buttons, inputs, rows.
  static const double control = 12;

  /// Cards and tiles.
  static const double card = 16;

  /// Sheets, panels, large hero blocks.
  static const double panel = 20;
}

/// Two depths on the light theme. Small things get a 1px lift; things that
/// float (sheets, decks, sticky bars) get one soft neutral shadow.
abstract final class HomiziElevation {
  static const List<BoxShadow> small = [
    BoxShadow(
      color: HomiziColors.shadowSoft,
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];
  static const List<BoxShadow> floating = [
    BoxShadow(color: HomiziColors.shadow, blurRadius: 24, offset: Offset(0, 8)),
  ];
}
