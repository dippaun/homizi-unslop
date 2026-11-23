import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:homizi/core/theme/homizi_colors.dart';
import 'package:homizi/ui/kit/live_backdrop.dart';

/// v4 live motion pieces. Every loop stops under reduced motion and in
/// widget tests ([homiziLiveMotion]), showing one finished, readable frame.

/// One line of text that cycles through [lines] with a slide-up and fade.
/// [still] is shown when motion is off.
class HomiziKineticLine extends StatefulWidget {
  const HomiziKineticLine({
    required this.lines,
    required this.style,
    this.still = 0,
    this.gradient,
    this.period = const Duration(milliseconds: 2600),
    super.key,
  });

  final List<String> lines;
  final TextStyle style;
  final int still;
  final Gradient? gradient;
  final Duration period;

  @override
  State<HomiziKineticLine> createState() => _HomiziKineticLineState();
}

class _HomiziKineticLineState extends State<HomiziKineticLine> {
  Timer? _timer;
  late int _index = widget.still;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final live = homiziLiveMotion(context);
    if (live && _timer == null) {
      _timer = Timer.periodic(widget.period, (_) {
        if (mounted) {
          setState(() => _index = (_index + 1) % widget.lines.length);
        }
      });
    } else if (!live) {
      _timer?.cancel();
      _timer = null;
      _index = widget.still;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget text(String s) {
      final t = Text(s, key: ValueKey(s), style: widget.style, maxLines: 1);
      final g = widget.gradient;
      if (g == null) {
        return t;
      }
      return ShaderMask(
        key: ValueKey('mask-$s'),
        blendMode: BlendMode.srcIn,
        shaderCallback: (r) => g.createShader(r),
        child: t,
      );
    }

    return ClipRect(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 520),
        switchInCurve: const Cubic(0.22, 1, 0.36, 1),
        switchOutCurve: Curves.easeIn,
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.centerLeft,
          children: [...previous, ?current],
        ),
        transitionBuilder: (child, animation) {
          final incoming = child.key == ValueKey('mask-${widget.lines[_index]}') ||
              child.key == ValueKey(widget.lines[_index]);
          final slide = Tween<Offset>(
            begin: Offset(0, incoming ? 0.9 : -0.9),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: text(widget.lines[_index]),
      ),
    );
  }
}

/// Indian digit grouping (12,48,000) for counters.
String homiziGroupedInt(int n) {
  final s = n.toString();
  if (s.length <= 3) {
    return s;
  }
  final last = s.substring(s.length - 3);
  var rest = s.substring(0, s.length - 3);
  final parts = <String>[];
  while (rest.length > 2) {
    parts.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) {
    parts.insert(0, rest);
  }
  return '${parts.join(',')},$last';
}

/// Number that counts up from zero once, then optionally ticks upward
/// every few seconds as if the count were live.
class HomiziCountUp extends StatefulWidget {
  const HomiziCountUp({
    required this.value,
    required this.style,
    this.prefix = '',
    this.suffix = '',
    this.liveStep = 0,
    super.key,
  });

  final int value;
  final TextStyle style;
  final String prefix;
  final String suffix;

  /// When above zero, the number grows by up to this much every ~4 s.
  final int liveStep;

  @override
  State<HomiziCountUp> createState() => _HomiziCountUpState();
}

class _HomiziCountUpState extends State<HomiziCountUp> {
  late int _target = widget.value;
  Timer? _timer;
  var _live = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _live = homiziLiveMotion(context);
    if (_live && widget.liveStep > 0 && _timer == null) {
      final rnd = math.Random(widget.value);
      _timer = Timer.periodic(const Duration(milliseconds: 4200), (_) {
        if (mounted) {
          setState(() => _target += 1 + rnd.nextInt(widget.liveStep));
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_live) {
      return Text(
        '${widget.prefix}${homiziGroupedInt(_target)}${widget.suffix}',
        style: widget.style,
      );
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(end: _target.toDouble()),
      duration: const Duration(milliseconds: 1600),
      curve: const Cubic(0.22, 1, 0.36, 1),
      builder: (context, v, _) => Text(
        '${widget.prefix}${homiziGroupedInt(v.round())}${widget.suffix}',
        style: widget.style.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// A "live" dot with an expanding halo.
class HomiziPulseDot extends StatelessWidget {
  const HomiziPulseDot({
    this.color = HomiziColors.success,
    this.size = 8,
    super.key,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return HomiziLiveClock(
      still: 0,
      builder: (context, clock, _) => ValueListenableBuilder<double>(
        valueListenable: clock,
        builder: (context, t, _) {
          final p = (t % 1.6) / 1.6;
          return SizedBox(
            width: size * 2.6,
            height: size * 2.6,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (p > 0)
                  Container(
                    width: size * (1 + 1.6 * p),
                    height: size * (1 + 1.6 * p),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.45 * (1 - p)),
                    ),
                  ),
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Gentle floating: the child bobs and sways on a slow loop.
class HomiziFloat extends StatelessWidget {
  const HomiziFloat({
    required this.child,
    this.amplitude = 6,
    this.period = 5,
    this.phase = 0,
    this.sway = 0,
    super.key,
  });

  final Widget child;
  final double amplitude;
  final double period;
  final double phase;

  /// Extra rotation in radians at the peak of the loop.
  final double sway;

  @override
  Widget build(BuildContext context) {
    return HomiziLiveClock(
      still: 0,
      child: child,
      builder: (context, clock, child) => ValueListenableBuilder<double>(
        valueListenable: clock,
        child: child,
        builder: (context, t, child) {
          final a = math.sin((t / period) * 2 * math.pi + phase);
          return Transform.translate(
            offset: Offset(0, a * amplitude),
            child: Transform.rotate(angle: a * sway, child: child),
          );
        },
      ),
    );
  }
}

/// Slow Ken Burns pan and zoom over a photo.
class HomiziKenBurns extends StatelessWidget {
  const HomiziKenBurns({
    required this.asset,
    this.period = 14,
    this.phase = 0,
    this.cacheWidth,
    super.key,
  });

  final String asset;
  final double period;
  final double phase;
  final int? cacheWidth;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      asset,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      cacheWidth: cacheWidth,
      excludeFromSemantics: true,
      gaplessPlayback: true,
      errorBuilder: (context, error, stack) =>
          const ColoredBox(color: HomiziColors.mist),
    );
    return ClipRect(
      child: HomiziLiveClock(
        still: 0,
        child: image,
        builder: (context, clock, child) => ValueListenableBuilder<double>(
          valueListenable: clock,
          child: child,
          builder: (context, t, child) {
            final a = 0.5 - 0.5 * math.cos((t / period) * 2 * math.pi + phase);
            return Transform.scale(
              scale: 1.04 + 0.10 * a,
              alignment: Alignment(-0.4 + 0.8 * a, 0.2 - 0.4 * a),
              child: child,
            );
          },
        ),
      ),
    );
  }
}

/// Circle wrapped in a slowly spinning brand gradient ring (city stories).
class HomiziSpinRing extends StatelessWidget {
  const HomiziSpinRing({
    required this.child,
    this.size = 68,
    this.width = 3,
    this.speed = 0.35,
    super.key,
  });

  final Widget child;
  final double size;
  final double width;
  final double speed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          HomiziLiveClock(
            still: 0,
            builder: (context, clock, _) => ValueListenableBuilder<double>(
              valueListenable: clock,
              builder: (context, t, _) => Transform.rotate(
                angle: t * speed * 2 * math.pi,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        HomiziColors.brandYellow,
                        HomiziColors.brandOrange,
                        HomiziColors.brandVermilion,
                        HomiziColors.brandDeepRed,
                        HomiziColors.brandGolden,
                        HomiziColors.brandYellow,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(width),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: HomiziColors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: ClipOval(child: child),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 3D tilt toward the pointer while hovered or dragged; springs back.
class HomiziTilt extends StatefulWidget {
  const HomiziTilt({required this.child, this.maxAngle = 0.12, super.key});

  final Widget child;
  final double maxAngle;

  @override
  State<HomiziTilt> createState() => _HomiziTiltState();
}

class _HomiziTiltState extends State<HomiziTilt> {
  Offset _tilt = Offset.zero;

  void _point(Offset local, Size size) {
    if (!homiziLiveMotion(context) || size.isEmpty) {
      return;
    }
    final dx = (local.dx / size.width - 0.5) * 2;
    final dy = (local.dy / size.height - 0.5) * 2;
    setState(() => _tilt = Offset(dx.clamp(-1, 1), dy.clamp(-1, 1)));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final size = Size(c.maxWidth, c.maxHeight.isFinite ? c.maxHeight : 0);
        return MouseRegion(
          onHover: (e) => _point(e.localPosition, size),
          onExit: (_) => setState(() => _tilt = Offset.zero),
          child: Listener(
            onPointerMove: (e) => _point(e.localPosition, size),
            onPointerUp: (_) => setState(() => _tilt = Offset.zero),
            onPointerCancel: (_) => setState(() => _tilt = Offset.zero),
            child: TweenAnimationBuilder<Offset>(
              tween: Tween(end: _tilt),
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              child: widget.child,
              builder: (context, o, child) => Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateX(-o.dy * widget.maxAngle)
                  ..rotateY(o.dx * widget.maxAngle),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Cycles short "live" messages with a vertical slide.
class HomiziLiveTicker extends StatelessWidget {
  const HomiziLiveTicker({
    required this.messages,
    required this.style,
    super.key,
  });

  final List<String> messages;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return HomiziKineticLine(
      lines: messages,
      style: style,
      period: const Duration(milliseconds: 3200),
    );
  }
}
