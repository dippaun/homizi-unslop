import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:homizi/core/motion/homizi_motion.dart';
import 'package:homizi/core/theme/homizi_colors.dart';

/// Gentle arc from [from] to [to], bowed to one side by [bow] of its length.
Path homiziRoutePath(Offset from, Offset to, {double bow = 0.18}) {
  final mid = Offset.lerp(from, to, 0.5)!;
  final delta = to - from;
  final normal = Offset(-delta.dy, delta.dx);
  final control = mid + normal * bow;
  return Path()
    ..moveTo(from.dx, from.dy)
    ..quadraticBezierTo(control.dx, control.dy, to.dx, to.dy);
}

/// Draws a route that grows from A to B, with a dot riding its tip.
///
/// [progress] is 0..1. The drawn part comes from
/// [ui.PathMetric.extractPath]; the dot's place and heading come from
/// [ui.PathMetric.getTangentForOffset].
class HomiziRoutePainter extends CustomPainter {
  HomiziRoutePainter({
    required this.from,
    required this.to,
    required this.progress,
    this.color = HomiziColors.logoOrange,
  });

  /// 0..1 positions inside the painted box.
  final Offset from;
  final Offset to;
  final double progress;
  final Color color;

  /// Where the tip sits for [progress], in box pixels, or null when empty.
  static ui.Tangent? tipFor(Path path, double progress) {
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) {
      return null;
    }
    final metric = metrics.first;
    return metric.getTangentForOffset(metric.length * progress.clamp(0, 1));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final a = Offset(from.dx * size.width, from.dy * size.height);
    final b = Offset(to.dx * size.width, to.dy * size.height);
    if ((b - a).distance < 2) {
      return;
    }
    final full = homiziRoutePath(a, b);
    final metrics = full.computeMetrics().toList();
    if (metrics.isEmpty) {
      return;
    }
    final metric = metrics.first;
    final t = progress.clamp(0.0, 1.0);
    final casing = Paint()
      ..color = HomiziColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final drawn = metric.extractPath(0, metric.length * t);
    canvas
      ..drawPath(drawn, casing)
      ..drawPath(drawn, line);
    final tip = metric.getTangentForOffset(metric.length * t);
    if (tip == null || t <= 0 || t >= 1) {
      return;
    }
    canvas
      ..save()
      ..translate(tip.position.dx, tip.position.dy)
      ..rotate(-tip.angle);
    final arrow = Path()
      ..moveTo(7, 0)
      ..lineTo(-5, -5)
      ..lineTo(-2, 0)
      ..lineTo(-5, 5)
      ..close();
    canvas
      ..drawCircle(Offset.zero, 9, Paint()..color = HomiziColors.white)
      ..drawPath(arrow, Paint()..color = HomiziColors.ink)
      ..restore();
  }

  @override
  bool shouldRepaint(HomiziRoutePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.from != from ||
      oldDelegate.to != to ||
      oldDelegate.color != color;
}

/// Route line that draws itself once when it first shows.
class HomiziAnimatedRoute extends StatefulWidget {
  const HomiziAnimatedRoute({
    required this.from,
    required this.to,
    this.duration = const Duration(milliseconds: 1600),
    super.key,
  });

  /// 0..1 positions inside this box.
  final Offset from;
  final Offset to;
  final Duration duration;

  @override
  State<HomiziAnimatedRoute> createState() => _HomiziAnimatedRouteState();
}

class _HomiziAnimatedRouteState extends State<HomiziAnimatedRoute>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.15, 1, curve: Curves.easeInOutCubic),
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
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _curve,
          builder: (context, _) => CustomPaint(
            key: const Key('homizi-animated-route'),
            painter: HomiziRoutePainter(
              from: widget.from,
              to: widget.to,
              progress: _curve.value,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

/// Web Mercator pixel position of a point at [zoom], in 256px tiles.
Offset mercatorPixel(double latitude, double longitude, double zoom) {
  final scale = 256 * math.pow(2, zoom).toDouble();
  final x = (longitude + 180) / 360 * scale;
  final sinLat = math.sin(latitude * math.pi / 180).clamp(-0.9999, 0.9999);
  final y =
      (0.5 - math.log((1 + sinLat) / (1 - sinLat)) / (4 * math.pi)) * scale;
  return Offset(x, y);
}
