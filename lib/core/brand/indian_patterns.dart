import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:homizi/core/theme/homizi_colors.dart';

/// Vector Indian motifs drawn in code: no images, no licensing.
///
/// - [JaaliPainter]: carved stone lattice (quatrefoil grid), for page and
///   card backgrounds at low opacity.
/// - [KolamPainter]: dot grid with looped kolam strokes, for hero corners.
/// - [BlockPrintBorder]: a repeating hand-block-print strip used as a
///   section divider and under headers.
/// - [JharokhaClipper]: a cusped Rajasthani window arch that frames photos.
/// - [IndianSkylinePainter]: Mumbai, Delhi and Bengaluru landmarks in one
///   continuous silhouette for hero bands.

/// Carved jaali lattice: a quatrefoil in every cell with a small diamond
/// where four cells meet.
class JaaliPainter extends CustomPainter {
  const JaaliPainter({
    this.color = HomiziColors.brandOrange,
    this.opacity = 0.08,
    this.cell = 36,
    this.strokeWidth = 1,
  });

  final Color color;
  final double opacity;
  final double cell;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }
    final stroke = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final dot = Paint()
      ..color = color.withValues(alpha: opacity * 1.2)
      ..style = PaintingStyle.fill;
    final r = cell / 4;
    for (var y = 0.0; y < size.height + cell; y += cell) {
      for (var x = 0.0; x < size.width + cell; x += cell) {
        final c = Offset(x + cell / 2, y + cell / 2);
        // Four petals.
        for (var k = 0; k < 4; k++) {
          final a = k * math.pi / 2;
          final petal = c + Offset(math.cos(a), math.sin(a)) * r;
          canvas.drawCircle(petal, r, stroke);
        }
        // Diamond at the cell corner.
        final d = Offset(x, y);
        final s = cell * 0.08;
        final path = Path()
          ..moveTo(d.dx, d.dy - s)
          ..lineTo(d.dx + s, d.dy)
          ..lineTo(d.dx, d.dy + s)
          ..lineTo(d.dx - s, d.dy)
          ..close();
        canvas.drawPath(path, dot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant JaaliPainter old) =>
      old.color != color || old.opacity != opacity || old.cell != cell;
}

/// Kolam: a pulli (dot) grid with a loop drawn around each dot and the
/// diagonals joining them, like rice-flour kolam at a doorstep.
class KolamPainter extends CustomPainter {
  const KolamPainter({
    this.color = HomiziColors.white,
    this.opacity = 0.22,
    this.gap = 18,
    this.dots = 5,
  });

  final Color color;
  final double opacity;
  final double gap;
  final int dots;

  @override
  void paint(Canvas canvas, Size size) {
    final ink = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = color.withValues(alpha: opacity * 1.4);
    final span = gap * (dots - 1);
    final origin = Offset((size.width - span) / 2, (size.height - span) / 2);
    final mid = (dots - 1) / 2;
    for (var i = 0; i < dots; i++) {
      for (var j = 0; j < dots; j++) {
        // Diamond-shaped kolam: keep dots inside |i-mid|+|j-mid| <= mid.
        if ((i - mid).abs() + (j - mid).abs() > mid + 0.01) {
          continue;
        }
        final p = origin + Offset(i * gap, j * gap);
        canvas.drawCircle(p, 1.8, fill);
        canvas.drawCircle(p, gap * 0.42, ink);
      }
    }
    final c = origin + Offset(span / 2, span / 2);
    final outer = Path()
      ..moveTo(c.dx, c.dy - span / 2 - gap * 0.6)
      ..quadraticBezierTo(
        c.dx + span / 2 + gap * 0.6,
        c.dy - span / 2 - gap * 0.6,
        c.dx + span / 2 + gap * 0.6,
        c.dy,
      )
      ..quadraticBezierTo(
        c.dx + span / 2 + gap * 0.6,
        c.dy + span / 2 + gap * 0.6,
        c.dx,
        c.dy + span / 2 + gap * 0.6,
      )
      ..quadraticBezierTo(
        c.dx - span / 2 - gap * 0.6,
        c.dy + span / 2 + gap * 0.6,
        c.dx - span / 2 - gap * 0.6,
        c.dy,
      )
      ..quadraticBezierTo(
        c.dx - span / 2 - gap * 0.6,
        c.dy - span / 2 - gap * 0.6,
        c.dx,
        c.dy - span / 2 - gap * 0.6,
      );
    canvas.drawPath(outer, ink);
  }

  @override
  bool shouldRepaint(covariant KolamPainter old) =>
      old.color != color || old.opacity != opacity;
}

/// Hand block-print strip: a row of small buta (paisley-like drops) and
/// dots between two thin rules.
class BlockPrintBorder extends StatelessWidget {
  const BlockPrintBorder({
    this.color = HomiziColors.brandRedOrange,
    this.height = 12,
    this.opacity = 0.55,
    super.key,
  });

  final Color color;
  final double height;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _BlockPrintPainter(color.withValues(alpha: opacity)),
      ),
    );
  }
}

class _BlockPrintPainter extends CustomPainter {
  const _BlockPrintPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rule = Paint()
      ..color = color
      ..strokeWidth = 0.8;
    final fill = Paint()..color = color;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), rule);
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      rule,
    );
    final h = size.height;
    final step = h * 1.6;
    for (var x = step / 2; x < size.width; x += step) {
      final cy = h / 2;
      final buta = Path()
        ..moveTo(x - h * 0.28, cy + h * 0.18)
        ..quadraticBezierTo(
          x - h * 0.3,
          cy - h * 0.3,
          x + h * 0.05,
          cy - h * 0.3,
        )
        ..quadraticBezierTo(x + h * 0.32, cy - h * 0.3, x + h * 0.2, cy)
        ..quadraticBezierTo(
          x + h * 0.08,
          cy + h * 0.28,
          x - h * 0.28,
          cy + h * 0.18,
        )
        ..close();
      canvas.drawPath(buta, fill);
      canvas.drawCircle(Offset(x + step / 2, cy), h * 0.08, fill);
    }
  }

  @override
  bool shouldRepaint(covariant _BlockPrintPainter old) => old.color != color;
}

/// Jharokha window: straight sides and a cusped (multifoil) arch top.
class JharokhaClipper extends CustomClipper<Path> {
  const JharokhaClipper({this.archFraction = 0.32});

  /// Share of the height used by the arch.
  final double archFraction;

  @override
  Path getClip(Size size) => jharokhaPath(size, archFraction);

  @override
  bool shouldReclip(covariant JharokhaClipper old) =>
      old.archFraction != archFraction;
}

Path jharokhaPath(Size size, [double archFraction = 0.32]) {
  final w = size.width;
  final h = size.height;
  final archH = math.min(h * archFraction, w * 0.55);
  final top = archH;
  final path = Path()..moveTo(0, h);
  path.lineTo(0, top);
  // Three lobes up to the crown on each side, then a small finial point.
  const lobes = 3;
  final crown = Offset(w / 2, 0);
  for (var side = 0; side < 2; side++) {
    for (var i = 0; i < lobes; i++) {
      final t0 = i / lobes;
      final t1 = (i + 1) / lobes;
      Offset at(double t) {
        final x = side == 0 ? w / 2 * t : w - w / 2 * (1 - t);
        // Ogee-ish rise: steep near the springing, flat near the crown.
        final y = side == 0
            ? top - archH * math.sin(t * math.pi / 2)
            : top - archH * math.sin((1 - t) * math.pi / 2);
        return Offset(x, y);
      }

      final a = at(t0);
      final b = at(t1);
      final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
      final bulge = (b - a).distance * 0.22;
      final normal = Offset(-(b.dy - a.dy), b.dx - a.dx) / (b - a).distance;
      // Foils bulge away from the opening, so each lobe meets the next in a
      // small inward cusp.
      final ctrl = mid - normal * bulge;
      if (side == 0 && i == lobes - 1) {
        path.quadraticBezierTo(ctrl.dx, ctrl.dy, crown.dx, crown.dy);
      } else {
        path.quadraticBezierTo(ctrl.dx, ctrl.dy, b.dx, b.dy);
      }
    }
  }
  path
    ..lineTo(w, h)
    ..close();
  return path;
}

/// A continuous skyline: Gateway of India and the sea link pylons
/// (Mumbai), India Gate and Qutub Minar (Delhi), Vidhana Soudha's dome
/// (Bengaluru), with apartment towers and a temple gopuram between them.
class IndianSkylinePainter extends CustomPainter {
  const IndianSkylinePainter({
    this.color = HomiziColors.white,
    this.opacity = 0.16,
  });

  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }
    final paint = Paint()..color = color.withValues(alpha: opacity);
    final back = Paint()..color = color.withValues(alpha: opacity * 0.55);
    final w = size.width;
    final h = size.height;
    final g = h; // ground

    // Back row: plain towers.
    final backRow = Path();
    const towers = <(double, double, double)>[
      (0.00, 0.06, 0.42),
      (0.07, 0.05, 0.58),
      (0.20, 0.04, 0.50),
      (0.33, 0.05, 0.66),
      (0.47, 0.04, 0.46),
      (0.58, 0.05, 0.62),
      (0.70, 0.04, 0.54),
      (0.84, 0.05, 0.70),
      (0.93, 0.06, 0.48),
    ];
    for (final (x, tw, th) in towers) {
      backRow.addRect(Rect.fromLTWH(w * x, g - h * th, w * tw, h * th));
    }
    canvas.drawPath(backRow, back);

    final front = Path();
    // Gateway of India: block with central arch and four turrets.
    {
      final x = w * 0.03;
      final bw = w * 0.14;
      final bh = h * 0.46;
      final body = Path()..addRect(Rect.fromLTWH(x, g - bh, bw, bh));
      final arch = Path()
        ..addRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(x + bw * 0.36, g - bh * 0.62, bw * 0.28, bh * 0.62),
            topLeft: Radius.circular(bw * 0.14),
            topRight: Radius.circular(bw * 0.14),
          ),
        );
      front.addPath(
        Path.combine(PathOperation.difference, body, arch),
        Offset.zero,
      );
      for (final t in [0.0, 0.3, 0.62, 0.9]) {
        front.addRect(
          Rect.fromLTWH(x + bw * t, g - bh * 1.22, bw * 0.1, bh * 0.24),
        );
        front.addOval(
          Rect.fromLTWH(x + bw * t - 1, g - bh * 1.32, bw * 0.12, bh * 0.14),
        );
      }
    }
    // Sea link pylon with cables.
    {
      final px = w * 0.22;
      final ph = h * 0.92;
      front.addRect(Rect.fromLTWH(px, g - ph, w * 0.008, ph));
      final cable = Paint()
        ..color = color.withValues(alpha: opacity)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke;
      for (var i = 1; i <= 5; i++) {
        final y = g - ph + i * ph * 0.08;
        canvas.drawLine(
          Offset(px, y),
          Offset(px - w * 0.03 * i, g - h * 0.08),
          cable,
        );
        canvas.drawLine(
          Offset(px, y),
          Offset(px + w * 0.03 * i, g - h * 0.08),
          cable,
        );
      }
      front.addRect(Rect.fromLTWH(w * 0.17, g - h * 0.09, w * 0.11, h * 0.02));
    }
    // Temple gopuram: stepped tiers with a kalasha.
    {
      final cx = w * 0.36;
      var bw = w * 0.09;
      var y = g;
      for (var i = 0; i < 6; i++) {
        final th = h * 0.1;
        front.addRect(Rect.fromLTWH(cx - bw / 2, y - th, bw, th));
        y -= th;
        bw *= 0.8;
      }
      front.addOval(
        Rect.fromCircle(center: Offset(cx, y - h * 0.03), radius: h * 0.03),
      );
    }
    // India Gate.
    {
      final x = w * 0.46;
      final bw = w * 0.08;
      final bh = h * 0.6;
      final body = Path()..addRect(Rect.fromLTWH(x, g - bh, bw, bh));
      final arch = Path()
        ..addRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(x + bw * 0.3, g - bh * 0.62, bw * 0.4, bh * 0.62),
            topLeft: Radius.circular(bw * 0.2),
            topRight: Radius.circular(bw * 0.2),
          ),
        );
      front.addPath(
        Path.combine(PathOperation.difference, body, arch),
        Offset.zero,
      );
      front.addRect(
        Rect.fromLTWH(x - bw * 0.06, g - bh - h * 0.04, bw * 1.12, h * 0.04),
      );
      front.addRect(
        Rect.fromLTWH(x + bw * 0.2, g - bh - h * 0.1, bw * 0.6, h * 0.06),
      );
    }
    // Qutub Minar: tapered fluted tower with balconies.
    {
      final cx = w * 0.6;
      final base = w * 0.026;
      final top = w * 0.012;
      final th = h * 0.98;
      final tower = Path()
        ..moveTo(cx - base / 2, g)
        ..lineTo(cx - top / 2, g - th)
        ..lineTo(cx + top / 2, g - th)
        ..lineTo(cx + base / 2, g)
        ..close();
      front.addPath(tower, Offset.zero);
      for (final f in [0.3, 0.52, 0.7, 0.85]) {
        final bwid = base - (base - top) * f + w * 0.01;
        front.addRect(Rect.fromLTWH(cx - bwid / 2, g - th * f, bwid, h * 0.02));
      }
    }
    // Vidhana Soudha: wide block, columns, central dome with finial.
    {
      final x = w * 0.68;
      final bw = w * 0.2;
      final bh = h * 0.34;
      front.addRect(Rect.fromLTWH(x, g - bh, bw, bh));
      front.addRect(
        Rect.fromLTWH(x + bw * 0.3, g - bh - h * 0.12, bw * 0.4, h * 0.12),
      );
      final dome = Path()
        ..addArc(
          Rect.fromCenter(
            center: Offset(x + bw / 2, g - bh - h * 0.12),
            width: bw * 0.3,
            height: h * 0.34,
          ),
          math.pi,
          math.pi,
        );
      front.addPath(dome, Offset.zero);
      front.addRect(
        Rect.fromLTWH(x + bw / 2 - 1, g - bh - h * 0.36, 2, h * 0.08),
      );
      for (final t in [0.06, 0.92]) {
        front.addRect(
          Rect.fromLTWH(
            x + bw * t - bw * 0.04,
            g - bh - h * 0.08,
            bw * 0.08,
            h * 0.08,
          ),
        );
        front.addOval(
          Rect.fromLTWH(
            x + bw * t - bw * 0.05,
            g - bh - h * 0.14,
            bw * 0.1,
            h * 0.08,
          ),
        );
      }
    }
    // Apartment block with balconies at the right edge.
    {
      final x = w * 0.9;
      final bw = w * 0.1;
      final bh = h * 0.56;
      front.addRect(Rect.fromLTWH(x, g - bh, bw, bh));
    }
    canvas.drawPath(front, paint);
  }

  @override
  bool shouldRepaint(covariant IndianSkylinePainter old) =>
      old.color != color || old.opacity != opacity;
}
