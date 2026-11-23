import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homizi/core/theme/homizi_colors.dart';

/// Material 3 theme. Component size, shape, elevation, and state layers come
/// from the Material defaults (`useMaterial3: true`). The seed is the logo
/// orange. Surfaces stay white. Labels on that orange stay near-black.
abstract final class HomiziTheme {
  static const fontFamily = 'PlusJakartaSans';

  /// Plus Jakarta Sans for headings, Inter for body and labels.
  ///
  /// Headings stay near-black at 600. Hierarchy comes from size and colour,
  /// not from 800 or 900 weights (unslop pass 5). Body copy is a step softer. Captions
  /// use the muted grey that still clears 4.5:1 on white.
  static TextTheme _type(TextTheme base) {
    final headings = GoogleFonts.plusJakartaSansTextTheme(base);
    final reading = GoogleFonts.interTextTheme(headings);
    // v2: Poppins carries display and headline sizes (bundled, OFL).
    TextStyle? display(TextStyle? style) {
      return style?.copyWith(
        fontFamily: 'Poppins',
        color: HomiziColors.ink,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
      );
    }

    TextStyle? title(TextStyle? style) {
      return style?.copyWith(
        color: HomiziColors.ink,
        fontWeight: FontWeight.w600,
      );
    }

    TextStyle? body(TextStyle? style, Color color) {
      return style?.copyWith(color: color);
    }

    return reading
        .copyWith(
          displayLarge: display(headings.displayLarge),
          displayMedium: display(headings.displayMedium),
          displaySmall: display(headings.displaySmall),
          headlineLarge: display(headings.headlineLarge),
          headlineMedium: display(headings.headlineMedium),
          headlineSmall: display(headings.headlineSmall),
          titleLarge: title(headings.titleLarge),
          titleMedium: title(headings.titleMedium),
          titleSmall: title(headings.titleSmall),
          bodyLarge: body(reading.bodyLarge, HomiziColors.ink),
          bodyMedium: body(reading.bodyMedium, HomiziColors.inkSoft),
          bodySmall: body(reading.bodySmall, HomiziColors.muted),
          labelLarge: body(reading.labelLarge, HomiziColors.ink),
          labelMedium: body(reading.labelMedium, HomiziColors.ink),
          labelSmall: body(reading.labelSmall, HomiziColors.muted),
        )
        .apply(
          // Plus Jakarta has no rupee sign. Roboto and the platform sans do.
          fontFamilyFallback: const ['Roboto', 'Noto Sans', 'sans-serif'],
        );
  }

  static const _radius = BorderRadius.all(
    Radius.circular(HomiziRadius.control),
  );

  static final ButtonStyle _filled =
      FilledButton.styleFrom(
        backgroundColor: HomiziColors.accent,
        foregroundColor: HomiziColors.ink,
        disabledBackgroundColor: HomiziColors.accentDisabled,
        disabledForegroundColor: HomiziColors.ink,
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: _radius),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: HomiziColors.ink,
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return HomiziColors.inkPressed;
          }
          if (states.contains(WidgetState.hovered)) {
            return HomiziColors.inkHover;
          }
          return null;
        }),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return const BorderSide(color: HomiziColors.ink, width: 3);
          }
          return BorderSide.none;
        }),
      );

  static final ButtonStyle _outlined =
      OutlinedButton.styleFrom(
        foregroundColor: HomiziColors.ink,
        backgroundColor: HomiziColors.white,
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        side: const BorderSide(color: HomiziColors.accent, width: 1.5),
        shape: const RoundedRectangleBorder(borderRadius: _radius),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: HomiziColors.ink,
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return HomiziColors.accentWash;
          }
          if (states.contains(WidgetState.hovered)) {
            return HomiziColors.accentWashHover;
          }
          return null;
        }),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return const BorderSide(color: HomiziColors.ink, width: 3);
          }
          return const BorderSide(color: HomiziColors.accent, width: 1.5);
        }),
      );

  static final ButtonStyle _text =
      TextButton.styleFrom(
        foregroundColor: HomiziColors.ink,
        minimumSize: const Size(48, 48),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ).copyWith(
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return const BorderSide(color: HomiziColors.ink, width: 3);
          }
          return BorderSide.none;
        }),
      );

  static final ButtonStyle _icon =
      IconButton.styleFrom(
        foregroundColor: HomiziColors.ink,
        hoverColor: HomiziColors.accentWash,
        minimumSize: const Size(48, 48),
      ).copyWith(
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return const BorderSide(color: HomiziColors.ink, width: 3);
          }
          return BorderSide.none;
        }),
      );

  static ThemeData light() {
    final seeded = ColorScheme.fromSeed(
      seedColor: HomiziColors.accent,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );
    final scheme = seeded.copyWith(
      primary: HomiziColors.accent,
      onPrimary: HomiziColors.ink,
      primaryContainer: HomiziColors.accentWash,
      onPrimaryContainer: HomiziColors.ink,
      secondaryContainer: HomiziColors.accentWash,
      onSecondaryContainer: HomiziColors.ink,
      outline: HomiziColors.line,
      outlineVariant: HomiziColors.line,
      surface: HomiziColors.cream,
      onSurface: HomiziColors.ink,
      onSurfaceVariant: HomiziColors.muted,
      surfaceTint: HomiziColors.cream,
      surfaceContainerLowest: HomiziColors.white,
      surfaceContainerLow: HomiziColors.cream,
      surfaceContainer: HomiziColors.cream,
      surfaceContainerHigh: HomiziColors.creamDeep,
      surfaceContainerHighest: HomiziColors.creamDeep,
      secondary: HomiziColors.brandRedOrange,
      onSecondary: HomiziColors.white,
      tertiary: HomiziColors.brandDeepRed,
      onTertiary: HomiziColors.white,
      inverseSurface: HomiziColors.ink,
      onInverseSurface: HomiziColors.white,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: HomiziColors.soft,
      canvasColor: HomiziColors.cream,
    );
    final text = _type(base.textTheme);
    return base.copyWith(
      focusColor: HomiziColors.accentWash,
      textTheme: text,
      primaryTextTheme: _type(base.primaryTextTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: HomiziColors.cream,
        foregroundColor: HomiziColors.ink,
        surfaceTintColor: HomiziColors.cream,
        elevation: 0,
        scrolledUnderElevation: 3,
        centerTitle: false,
        toolbarHeight: 64,
        titleTextStyle: text.titleLarge?.copyWith(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          color: HomiziColors.ink,
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: HomiziColors.cream,
        surfaceTintColor: HomiziColors.cream,
        indicatorColor: HomiziColors.saffronWash,
        height: 80,
        elevation: 3,
      ),
      dialogTheme: const DialogThemeData(backgroundColor: HomiziColors.cream),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: HomiziColors.accent,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: HomiziColors.accent,
        foregroundColor: HomiziColors.ink,
      ),
      splashFactory: InkRipple.splashFactory,
      hoverColor: HomiziColors.accentHover,
      // v3: white cards lift off the stone page with a soft shadow and
      // no outline.
      cardTheme: const CardThemeData(
        color: HomiziColors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: HomiziColors.shadowStrong,
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(HomiziRadius.panel)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(style: _filled),
      outlinedButtonTheme: OutlinedButtonThemeData(style: _outlined),
      elevatedButtonTheme: ElevatedButtonThemeData(style: _filled),
      textButtonTheme: TextButtonThemeData(style: _text),
      iconButtonTheme: IconButtonThemeData(style: _icon),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: HomiziColors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(
          fontFamily: 'Inter',
          color: HomiziColors.muted,
          fontSize: 14,
        ),
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          color: HomiziColors.ink,
          fontWeight: FontWeight.w600,
        ),
        floatingLabelStyle: TextStyle(
          fontFamily: 'Inter',
          color: HomiziColors.ink,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(HomiziRadius.control)),
          borderSide: BorderSide(color: HomiziColors.creamLine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(HomiziRadius.control)),
          borderSide: BorderSide(color: HomiziColors.creamLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(HomiziRadius.control)),
          borderSide: BorderSide(color: HomiziColors.accent, width: 2),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: HomiziColors.creamDeep,
        selectedColor: HomiziColors.saffronWash,
        disabledColor: HomiziColors.mist,
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          color: HomiziColors.ink,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily: 'Inter',
          color: HomiziColors.ink,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(HomiziRadius.chip)),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: HomiziColors.ink,
        textColor: HomiziColors.ink,
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
      dividerTheme: const DividerThemeData(
        color: HomiziColors.creamLine,
        space: 16,
        thickness: 1,
      ),
      dropdownMenuTheme: _dropdownMenu,
      menuTheme: _menu,
      menuButtonTheme: _menuButton,
      popupMenuTheme: _popupMenu,
      pageTransitionsTheme: _transitions,
    );
  }

  /// Contrast-safe dark scheme. The app still boots in [light].
  static ThemeData dark() {
    final seeded = ColorScheme.fromSeed(
      seedColor: HomiziColors.accent,
      brightness: Brightness.dark,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );
    final scheme = seeded.copyWith(
      primary: HomiziColors.accent,
      onPrimary: HomiziColors.ink,
      primaryContainer: HomiziColors.nightAccentContainer,
      onPrimaryContainer: HomiziColors.accentWash,
      secondaryContainer: HomiziColors.nightAccentContainer,
      onSecondaryContainer: HomiziColors.accentWash,
      surface: HomiziColors.night,
      onSurface: HomiziColors.nightInk,
      onSurfaceVariant: HomiziColors.nightMuted,
      outline: HomiziColors.nightLine,
      outlineVariant: HomiziColors.nightLine,
      surfaceTint: HomiziColors.night,
      surfaceContainerLowest: HomiziColors.night,
      surfaceContainerLow: HomiziColors.nightRaised,
      surfaceContainer: HomiziColors.nightRaised,
      surfaceContainerHigh: HomiziColors.nightHigh,
      surfaceContainerHighest: HomiziColors.nightHighest,
      inverseSurface: HomiziColors.white,
      onInverseSurface: HomiziColors.ink,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: HomiziColors.night,
      canvasColor: HomiziColors.night,
    );
    final text = base.textTheme.apply(
      fontFamily: fontFamily,
      bodyColor: HomiziColors.nightInk,
      displayColor: HomiziColors.nightInk,
    );
    return base.copyWith(
      focusColor: HomiziColors.accentWash,
      textTheme: text,
      primaryTextTheme: base.primaryTextTheme.apply(
        fontFamily: fontFamily,
        bodyColor: HomiziColors.ink,
        displayColor: HomiziColors.ink,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: HomiziColors.night,
        foregroundColor: HomiziColors.nightInk,
        surfaceTintColor: HomiziColors.night,
        elevation: 0,
        scrolledUnderElevation: 3,
        centerTitle: false,
        toolbarHeight: 64,
        titleTextStyle: text.titleLarge?.copyWith(color: HomiziColors.nightInk),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: HomiziColors.night,
        surfaceTintColor: HomiziColors.night,
        indicatorColor: HomiziColors.nightAccentContainer,
        height: 80,
        elevation: 3,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: HomiziColors.nightRaised,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: HomiziColors.accent,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: HomiziColors.accent,
        foregroundColor: HomiziColors.ink,
      ),
      splashFactory: InkRipple.splashFactory,
      cardTheme: const CardThemeData(
        color: HomiziColors.nightRaised,
        surfaceTintColor: Colors.transparent,
        shadowColor: HomiziColors.shadowNight,
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(HomiziRadius.card)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(style: _filled),
      outlinedButtonTheme: OutlinedButtonThemeData(style: _outlined),
      dividerTheme: const DividerThemeData(
        color: HomiziColors.nightLine,
        space: 16,
        thickness: 1,
      ),
      dropdownMenuTheme: _dropdownMenu,
      menuTheme: _menu,
      menuButtonTheme: _menuButton,
      popupMenuTheme: _popupMenu,
      pageTransitionsTheme: _transitions,
    );
  }
}

/// Type scale (unslop pass 5). Use these sizes; weights are 400, 500 and
/// 600 only, except the HOMIZI wordmark and swipe stamps.
abstract final class HomiziType {
  /// Meta, counts, small labels. Nothing in the app goes below this.
  static const double meta = 11;
  static const double caption = 12;
  static const double secondary = 13;
  static const double body = 14;
  static const double bodyLarge = 16;
  static const double title = 18;
  static const double titleLarge = 20;
  static const double headline = 24;
  static const double display = 28;
  static const double hero = 32;

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight strong = FontWeight.w600;
}

/// Motion tokens (unslop pass 9). One ease-out curve, no overshoot, no
/// loops on things that are not live.
abstract final class HomiziMotion {
  static const Curve curve = Cubic(0.22, 1, 0.36, 1);

  /// Hover, press, toggles.
  static const Duration fast = Duration(milliseconds: 150);

  /// Menus, popovers, chips.
  static const Duration menu = Duration(milliseconds: 200);

  /// Entrances, sheets, layout changes.
  static const Duration enter = Duration(milliseconds: 360);
}

/// Menus stay a white surface with ink type. The selected row is a pale
/// orange wash. A solid navy focus colour used to paint the dropdown header
/// and hide the items.
const _menuShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(HomiziRadius.control)),
);

const _menuStyle = MenuStyle(
  backgroundColor: WidgetStatePropertyAll(HomiziColors.white),
  surfaceTintColor: WidgetStatePropertyAll(HomiziColors.clear),
  elevation: WidgetStatePropertyAll(3),
  shape: WidgetStatePropertyAll(_menuShape),
);

const _menuLabel = TextStyle(
  color: HomiziColors.ink,
  fontSize: 16,
  fontFamily: 'Inter',
);

const _dropdownMenu = DropdownMenuThemeData(
  textStyle: _menuLabel,
  menuStyle: _menuStyle,
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: HomiziColors.white,
  ),
);

const _menu = MenuThemeData(style: _menuStyle);

final MenuButtonThemeData _menuButton = MenuButtonThemeData(
  style: ButtonStyle(
    foregroundColor: const WidgetStatePropertyAll(HomiziColors.ink),
    iconColor: const WidgetStatePropertyAll(HomiziColors.ink),
    overlayColor: const WidgetStatePropertyAll(HomiziColors.accentWash),
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected) ||
          states.contains(WidgetState.focused)) {
        return HomiziColors.accentWash;
      }
      return HomiziColors.white;
    }),
    textStyle: const WidgetStatePropertyAll(_menuLabel),
    shape: const WidgetStatePropertyAll(_menuShape),
  ),
);

const PopupMenuThemeData _popupMenu = PopupMenuThemeData(
  color: HomiziColors.white,
  surfaceTintColor: HomiziColors.clear,
  textStyle: _menuLabel,
  labelTextStyle: WidgetStatePropertyAll(
    TextStyle(color: HomiziColors.ink, fontSize: 16, fontFamily: 'Inter'),
  ),
  shape: _menuShape,
);

const _transitions = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: HomiziPageTransitionsBuilder(),
    TargetPlatform.fuchsia: HomiziPageTransitionsBuilder(),
    TargetPlatform.iOS: HomiziPageTransitionsBuilder(),
    TargetPlatform.linux: HomiziPageTransitionsBuilder(),
    TargetPlatform.macOS: HomiziPageTransitionsBuilder(),
    TargetPlatform.windows: HomiziPageTransitionsBuilder(),
  },
);

/// Smooth shared-axis move. Reduced motion shows the page immediately.
///
/// The zoom builder is the fallback when motion is allowed so route timing
/// stays the same as the rest of the app's tests.
class HomiziPageTransitionsBuilder extends PageTransitionsBuilder {
  const HomiziPageTransitionsBuilder();

  static const _zoom = ZoomPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return FadeTransition(opacity: animation, child: child);
    }
    return _zoom.buildTransitions(
      route,
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }
}
