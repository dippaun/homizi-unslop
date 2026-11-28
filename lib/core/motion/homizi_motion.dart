import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:go_router/go_router.dart';
import 'package:homizi/core/theme/homizi_colors.dart';

/// Motion helpers for the smooth pass: staggered entrances, scroll parallax,
/// a frosted bar, a spring route and press feedback.
///
/// Every widget here reads [MediaQuery.disableAnimationsOf] and falls back to
/// a still, finished state when the user has asked for reduced motion.

/// True when the platform asked for reduced motion.
bool homiziReduceMotion(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Spring with a touch of overshoot (about 2%), sampled as a [Curve].
///
/// Driven by a real [SpringSimulation] so push and pop share one feel.
class HomiziSpringCurve extends Curve {
  const HomiziSpringCurve({
    this.stiffness = 170,
    this.dampingRatio = 0.78,
    this.settleSeconds = 0.62,
  });

  final double stiffness;
  final double dampingRatio;
  final double settleSeconds;

  @override
  double transformInternal(double t) {
    final spring = SpringDescription.withDampingRatio(
      mass: 1,
      stiffness: stiffness,
      ratio: dampingRatio,
    );
    final simulation = SpringSimulation(spring, 0, 1, 0);
    return simulation.x(t * settleSeconds);
  }
}

const homiziSpring = HomiziSpringCurve();

/// Route time for the listing push and pop.
const homiziSpringDuration = Duration(milliseconds: 560);

/// Linear rect tween so the spring's small overshoot reads as a settle.
RectTween homiziHeroRectTween(Rect? begin, Rect? end) =>
    RectTween(begin: begin, end: end);

/// Flies the card's photo both ways, since it is already decoded while the
/// listing page's own photo may still be loading.
///
/// The photo is laid out once at the card's size and scaled into the flight
/// rect, so its decode size never changes mid-flight (no re-decode, no flash).
Widget homiziCardShuttle(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection direction,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final card = direction == HeroFlightDirection.push
      ? fromHeroContext
      : toHeroContext;
  final hero = card.widget as Hero;
  final box = card.findRenderObject();
  final size = box is RenderBox && box.hasSize && !box.size.isEmpty
      ? box.size
      : const Size(360, 240);
  return ClipRect(
    child: FittedBox(
      fit: BoxFit.cover,
      child: SizedBox.fromSize(size: size, child: hero.child),
    ),
  );
}

/// go_router page that rises in on [homiziSpring]. Pop plays the same spring
/// in reverse. Reduced motion is a plain fade.
CustomTransitionPage<T> homiziSpringPage<T>({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    name: state.name,
    arguments: state.extra,
    child: child,
    transitionDuration: homiziSpringDuration,
    reverseTransitionDuration: homiziSpringDuration,
    transitionsBuilder: homiziSpringTransition,
  );
}

Widget homiziSpringTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  if (homiziReduceMotion(context)) {
    return FadeTransition(opacity: animation, child: child);
  }
  final spring = CurvedAnimation(
    parent: animation,
    curve: homiziSpring,
    reverseCurve: homiziSpring.flipped,
  );
  final fade = CurvedAnimation(
    parent: animation,
    curve: const Interval(0, 0.45, curve: Curves.easeOutCubic),
    reverseCurve: const Interval(0, 0.6, curve: Curves.easeInCubic),
  );
  return FadeTransition(
    opacity: fade,
    child: AnimatedBuilder(
      animation: spring,
      builder: (context, child) {
        final lift = (1 - spring.value) * 28;
        return Transform.translate(offset: Offset(0, lift), child: child);
      },
      child: child,
    ),
  );
}

/// Holds the one controller for a staggered entrance.
class HomiziStagger extends StatefulWidget {
  const HomiziStagger({
    required this.child,
    this.count = 5,
    this.duration = const Duration(milliseconds: 640),
    super.key,
  });

  final Widget child;

  /// How many [HomiziStaggerItem]s share the timeline.
  final int count;
  final Duration duration;

  @override
  State<HomiziStagger> createState() => _HomiziStaggerState();
}

class _HomiziStaggerState extends State<HomiziStagger>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    if (homiziReduceMotion(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _StaggerScope(
      controller: _controller,
      count: widget.count,
      child: widget.child,
    );
  }
}

class _StaggerScope extends InheritedWidget {
  const _StaggerScope({
    required this.controller,
    required this.count,
    required super.child,
  });

  final AnimationController controller;
  final int count;

  @override
  bool updateShouldNotify(_StaggerScope oldWidget) =>
      controller != oldWidget.controller || count != oldWidget.count;
}

/// One step of a [HomiziStagger]: fades in and rises [distance] px.
///
/// Each step owns an [Interval] of the shared controller, so later items
/// start a little after earlier ones.
class HomiziStaggerItem extends StatelessWidget {
  const HomiziStaggerItem({
    required this.index,
    required this.child,
    this.distance = 20,
    super.key,
  });

  final int index;
  final double distance;
  final Widget child;

  /// Start and end of step [index] out of [count] on a 0..1 timeline.
  static (double, double) window(int index, int count) {
    const span = 0.55;
    final steps = math.max(1, count - 1);
    final start = (index.clamp(0, steps) / steps) * (1 - span);
    return (start, math.min(1, start + span));
  }

  @override
  Widget build(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_StaggerScope>();
    if (scope == null) {
      return child;
    }
    final (start, end) = window(index, scope.count);
    final fade = CurvedAnimation(
      parent: scope.controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    final rise = CurvedAnimation(
      parent: scope.controller,
      curve: Interval(start, end, curve: Curves.easeOutQuart),
    );
    return FadeTransition(
      opacity: fade,
      child: AnimatedBuilder(
        animation: rise,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, (1 - rise.value) * distance),
          child: child,
        ),
        child: child,
      ),
    );
  }
}

/// 0..1 progress of [controller]'s offset between [start] and [end].
double homiziScrollProgress(
  ScrollController controller, {
  double start = 0,
  double end = 32,
}) {
  if (!controller.hasClients || controller.positions.length != 1) {
    return 0;
  }
  final position = controller.position;
  if (!position.hasPixels) {
    return 0;
  }
  if (end <= start) {
    return position.pixels > start ? 1 : 0;
  }
  return ((position.pixels - start) / (end - start)).clamp(0.0, 1.0);
}

double _offsetOf(ScrollController controller) {
  if (!controller.hasClients || controller.positions.length != 1) {
    return 0;
  }
  final position = controller.position;
  return position.hasPixels ? position.pixels : 0;
}

/// Photo that drifts slower than the page and swells a little as it scrolls.
///
/// Pull past the top (overscroll) zooms it in like a stretch.
class HomiziParallax extends StatelessWidget {
  const HomiziParallax({
    required this.controller,
    required this.child,
    this.factor = 0.35,
    this.zoomPerPixel = 0.0005,
    this.maxZoom = 1.12,
    super.key,
  });

  final ScrollController controller;
  final Widget child;

  /// Share of the scroll the photo moves down by, so it lags the page.
  final double factor;
  final double zoomPerPixel;
  final double maxZoom;

  /// Translate and scale for a scroll [offset].
  static (double, double) at(
    double offset, {
    double factor = 0.35,
    double zoomPerPixel = 0.0005,
    double maxZoom = 1.12,
  }) {
    if (offset < 0) {
      return (0, math.min(maxZoom + 0.1, 1 + (-offset) * 0.002));
    }
    final clamped = math.min(offset, 800.0);
    return (clamped * factor, math.min(maxZoom, 1 + clamped * zoomPerPixel));
  }

  @override
  Widget build(BuildContext context) {
    if (homiziReduceMotion(context)) {
      return child;
    }
    return ClipRect(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final (dy, scale) = at(
            _offsetOf(controller),
            factor: factor,
            zoomPerPixel: zoomPerPixel,
            maxZoom: maxZoom,
          );
          return Transform.translate(
            offset: Offset(0, dy),
            child: Transform.scale(scale: scale, child: child),
          );
        },
        child: RepaintBoundary(child: child),
      ),
    );
  }
}

/// Frosted glass behind a bar once content scrolls under it.
///
/// At rest it is a solid white surface, the same as before. As the page
/// scrolls the surface turns translucent, the blur rises to [sigma], and a
/// hairline fades in under it.
class HomiziGlass extends StatelessWidget {
  const HomiziGlass({
    required this.controller,
    required this.child,
    this.start = 0,
    this.end = 32,
    this.sigma = 12,
    this.restOpaque = true,
    super.key,
  });

  final ScrollController controller;
  final Widget child;
  final double start;
  final double end;
  final double sigma;

  /// Solid white at rest. False starts fully clear (for bars that appear).
  final bool restOpaque;

  /// Surface alpha for a progress [t].
  static double surfaceAlpha(double t, {bool restOpaque = true}) =>
      restOpaque ? 1 - 0.28 * t : 0.72 * t;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = homiziScrollProgress(controller, start: start, end: end);
        final surface = HomiziColors.white.withValues(
          alpha: surfaceAlpha(t, restOpaque: restOpaque),
        );
        final decorated = DecoratedBox(
          key: const Key('homizi-glass-surface'),
          decoration: BoxDecoration(
            color: surface,
            border: Border(
              bottom: BorderSide(color: HomiziColors.line.withValues(alpha: t)),
            ),
          ),
          child: child,
        );
        return ClipRect(
          child: BackdropFilter(
            enabled: t > 0,
            filter: ui.ImageFilter.blur(sigmaX: sigma * t, sigmaY: sigma * t),
            child: decorated,
          ),
        );
      },
      child: child,
    );
  }
}

/// Scales to [scale] while pressed. Pointer listener only, so taps, drags
/// and ink still reach the child.
class HomiziPressScale extends StatefulWidget {
  const HomiziPressScale({
    required this.child,
    this.scale = 0.97,
    this.enabled = true,
    super.key,
  });

  final Widget child;
  final double scale;
  final bool enabled;

  @override
  State<HomiziPressScale> createState() => _HomiziPressScaleState();
}

class _HomiziPressScaleState extends State<HomiziPressScale> {
  var _down = false;
  var _origin = Offset.zero;

  void _set(bool down) {
    if (_down != down && mounted) {
      setState(() => _down = down);
    }
  }

  @override
  Widget build(BuildContext context) {
    final still = !widget.enabled || homiziReduceMotion(context);
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        _origin = event.position;
        _set(true);
      },
      onPointerMove: (event) {
        if ((event.position - _origin).distance > 12) {
          _set(false);
        }
      },
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down && !still ? widget.scale : 1,
        duration: Duration(milliseconds: _down ? 90 : 160),
        curve: _down ? Curves.easeOutCubic : Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}

/// Swaps a small value (a count or an icon) with a quick fade and scale.
class HomiziSwap extends StatelessWidget {
  const HomiziSwap({required this.child, super.key});

  /// Give [child] a [ValueKey] of the value it shows.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: homiziReduceMotion(context)
          ? Duration.zero
          : const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.7, end: 1).animate(animation),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
