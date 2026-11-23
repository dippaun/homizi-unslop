import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:homizi/core/theme/homizi_colors.dart';
import 'package:homizi/features/maps/map_runtime.dart';

/// Animated page backgrounds (v4). Swap the look in one place by passing a
/// different [HomiziBackdropStyle]; every screen that uses
/// [HomiziLiveBackdrop] follows.
enum HomiziBackdropStyle {
  /// "Living city": a slow gradient mesh in brand oranges and reds, faint
  /// line-art apartment blocks that rise and parallax with the scroll, and
  /// window lights that twinkle on as homes are found.
  livingCity,

  /// Static warm wash, no motion. Fallback for low-power screens.
  calm,
}

/// True when looping, decorative motion may run: not under reduced motion
/// and not inside widget tests (loops would never let a test settle).
bool homiziLiveMotion(BuildContext context) {
  if (suppressMapTiles) {
    return false;
  }
  return !(MediaQuery.maybeDisableAnimationsOf(context) ?? false);
}

/// A seconds clock shared by live widgets. Frozen clocks hold [still].
class HomiziLiveClock extends StatefulWidget {
  const HomiziLiveClock({
    required this.builder,
    this.still = 12,
    this.child,
    super.key,
  });

  final double still;
  final Widget? child;
  final Widget Function(BuildContext, ValueListenable<double>, Widget?)
  builder;

  @override
  State<HomiziLiveClock> createState() => _HomiziLiveClockState();
}

class _HomiziLiveClockState extends State<HomiziLiveClock>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<double> _seconds = ValueNotifier(widget.still);
  Ticker? _ticker;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final live = homiziLiveMotion(context);
    if (live && _ticker == null) {
      _ticker = createTicker((elapsed) {
        _seconds.value = elapsed.inMicroseconds / 1e6;
      })..start();
    } else if (!live && _ticker != null) {
      _ticker!.dispose();
      _ticker = null;
      _seconds.value = widget.still;
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _seconds.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _seconds, widget.child);
}

/// Full-bleed animated background behind [child].
///
/// Pass the page's [scrollController] so the skyline rises and parallaxes
/// as the user scrolls. Reduced motion shows one still, finished frame.
class HomiziLiveBackdrop extends StatelessWidget {
  const HomiziLiveBackdrop({
    required this.child,
    this.style = HomiziBackdropStyle.livingCity,
    this.scrollController,
    super.key,
  });

  final Widget child;
  final HomiziBackdropStyle style;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final backdrop = switch (style) {
      HomiziBackdropStyle.calm => const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [HomiziColors.livingBase, HomiziColors.livingBaseDeep],
          ),
        ),
      ),
      HomiziBackdropStyle.livingCity => HomiziLiveClock(
        builder: (context, clock, _) => RepaintBoundary(
          child: CustomPaint(
            painter: LivingCityPainter(
              clock: clock,
              scroll: scrollController,
            ),
            isComplex: true,
            willChange: true,
          ),
        ),
      ),
    };
    return Stack(
      fit: StackFit.expand,
      children: [
        ExcludeSemantics(
          child: IgnorePointer(
            key: const Key('live-backdrop'),
            child: backdrop,
          ),
        ),
        child,
      ],
    );
  }
}

class _Orb {
  const _Orb(this.color, this.alpha, this.radius, this.cx, this.cy,
      this.ax, this.ay, this.speed, this.phase);

  final Color color;
  final double alpha;
  final double radius; // fraction of the shorter side, times 1.6
  final double cx, cy, ax, ay, speed, phase;
}

const _orbs = <_Orb>[
  _Orb(HomiziColors.brandOrange, 0.55, 0.95, 0.92, 0.06, 0.10, 0.05, 0.11, 0),
  _Orb(HomiziColors.brandVermilion, 0.34, 0.85, 0.05, 0.16, 0.12, 0.06, 0.09, 2),
  _Orb(HomiziColors.brandGolden, 0.42, 0.70, 0.62, 0.34, 0.16, 0.07, 0.13, 4),
  _Orb(HomiziColors.brandYellow, 0.30, 0.55, 0.18, 0.52, 0.14, 0.08, 0.10, 1),
  _Orb(HomiziColors.brandDeepOrange, 0.26, 0.90, 0.95, 0.72, 0.10, 0.06, 0.08, 3),
  _Orb(HomiziColors.brandDeepRed, 0.14, 1.00, 0.10, 0.96, 0.08, 0.04, 0.07, 5),
];

class _Block {
  _Block(this.x, this.w, this.h, this.cols, this.floors, this.tank,
      this.seed);

  final double x, w, h;
  final int cols, floors;
  final bool tank;
  final int seed;
}

/// Paints the "living city" backdrop. Public so a golden or a preview can
/// draw one frame at a fixed time.
class LivingCityPainter extends CustomPainter {
  LivingCityPainter({required this.clock, this.scroll})
    : super(repaint: Listenable.merge([clock, ?scroll]));

  final ValueListenable<double> clock;
  final ScrollController? scroll;

  static final Map<int, List<List<_Block>>> _cache = {};

  static List<List<_Block>> _layers(double width) {
    final key = width.round();
    return _cache.putIfAbsent(key, () {
      final rnd = math.Random(7);
      List<_Block> layer(double minH, double maxH, double minW, double maxW) {
        final out = <_Block>[];
        var x = -rnd.nextDouble() * 20;
        while (x < width + 10) {
          final w = minW + rnd.nextDouble() * (maxW - minW);
          final h = minH + rnd.nextDouble() * (maxH - minH);
          out.add(
            _Block(
              x,
              w,
              h,
              math.max(2, (w / 15).floor()),
              math.max(3, (h / 17).floor()),
              rnd.nextDouble() < 0.5,
              rnd.nextInt(1 << 20),
            ),
          );
          x += w + 4 + rnd.nextDouble() * 14;
        }
        return out;
      }

      return [layer(150, 290, 46, 84), layer(90, 200, 40, 70)];
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }
    final t = clock.value;
    final w = size.width;
    final h = size.height;
    final offset = (scroll?.hasClients ?? false)
        ? scroll!.positions.first.pixels
        : 0.0;

    // Warm base.
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [HomiziColors.livingBase, HomiziColors.livingBaseDeep],
        ).createShader(rect),
    );

    // Gradient mesh: soft drifting orbs.
    final side = math.min(w, 520.0) * 1.6;
    for (final o in _orbs) {
      final c = Offset(
        w * (o.cx + o.ax * math.sin(t * o.speed + o.phase)),
        h * (o.cy + o.ay * math.cos(t * o.speed * 0.8 + o.phase)) -
            offset * 0.08,
      );
      final r = side * o.radius * 0.5;
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [
              o.color.withValues(alpha: o.alpha),
              o.color.withValues(alpha: o.alpha * 0.35),
              o.color.withValues(alpha: 0),
            ],
            stops: const [0, 0.45, 1],
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      );
    }

    // Skyline: rises in over the first 1.8 s, then with the scroll.
    final intro = Curves.easeOutCubic.transform((t / 1.8).clamp(0.0, 1.0));
    final layers = _layers(w);
    for (var li = 0; li < layers.length; li++) {
      final near = li == 1;
      final rise = (1 - intro) * (near ? 160 : 220);
      final parallax = math.min(offset * (near ? 0.10 : 0.05), near ? 70 : 40);
      final sink = near ? 30.0 : 70.0;
      final baseY = h + sink + rise - parallax;
      final line = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = near ? 1.3 : 1
        ..color = HomiziColors.ink.withValues(alpha: near ? 0.13 : 0.08);
      final fill = Paint()
        ..color = HomiziColors.white.withValues(alpha: near ? 0.30 : 0.18);
      final unlit = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = HomiziColors.ink.withValues(alpha: near ? 0.09 : 0.06);
      for (final b in layers[li]) {
        final top = baseY - b.h;
        final body = Rect.fromLTWH(b.x, top, b.w, b.h);
        canvas.drawRect(body, fill);
        canvas.drawRect(body, line);
        if (b.tank) {
          // Rooftop water tank on legs, a common Indian skyline detail.
          final tx = b.x + b.w * 0.62;
          canvas.drawRect(Rect.fromLTWH(tx, top - 12, 12, 8), line);
          canvas.drawLine(Offset(tx + 2, top - 4), Offset(tx + 2, top), line);
          canvas.drawLine(
            Offset(tx + 10, top - 4),
            Offset(tx + 10, top),
            line,
          );
        } else {
          canvas.drawLine(
            Offset(b.x + 6, top - 9),
            Offset(b.x + 6, top),
            line,
          );
        }
        // Windows.
        final cw = b.w / b.cols;
        const fh = 17.0;
        for (var f = 0; f < b.floors - 1; f++) {
          final wy = top + 8 + f * fh;
          if (wy > h + 4) {
            break;
          }
          if (wy + 8 < 0) {
            continue;
          }
          for (var c = 0; c < b.cols; c++) {
            final wx = b.x + c * cw + cw * 0.28;
            final win = Rect.fromLTWH(wx, wy, cw * 0.44, 8);
            final hash = (b.seed * 31 + f * 131 + c * 977) & 0xffff;
            final eligible = hash % 100 < (near ? 34 : 24);
            var glow = 0.0;
            if (eligible) {
              final speed = 0.25 + (hash % 37) / 60;
              final phase = (hash % 628) / 100;
              final s = math.sin(t * speed + phase);
              glow = ((s - 0.35) / 0.4).clamp(0.0, 1.0) * intro;
            }
            if (glow > 0.02) {
              canvas.drawCircle(
                win.center,
                9,
                Paint()
                  ..shader = RadialGradient(
                    colors: [
                      HomiziColors.brandYellow.withValues(alpha: 0.45 * glow),
                      HomiziColors.brandYellow.withValues(alpha: 0),
                    ],
                  ).createShader(Rect.fromCircle(center: win.center, radius: 9)),
              );
              canvas.drawRRect(
                RRect.fromRectAndRadius(win, const Radius.circular(1.5)),
                Paint()
                  ..color = Color.lerp(
                    HomiziColors.brandGolden,
                    HomiziColors.brandYellow,
                    glow,
                  )!.withValues(alpha: (near ? 0.95 : 0.7) * glow),
              );
            } else {
              canvas.drawRect(win, unlit);
            }
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant LivingCityPainter old) =>
      old.clock != clock || old.scroll != scroll;
}
