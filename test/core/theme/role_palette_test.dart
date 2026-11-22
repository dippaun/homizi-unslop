import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homizi/core/theme/homizi_colors.dart';
import 'package:homizi/core/theme/role_palette.dart';

double _contrast(Color a, Color b) {
  final lighter = math.max(a.computeLuminance(), b.computeLuminance());
  final darker = math.min(a.computeLuminance(), b.computeLuminance());
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  test('every role hero keeps its text at AA on each gradient stop', () {
    for (final palette in HomiziRolePalette.all) {
      for (final stop in palette.hero) {
        expect(
          _contrast(palette.onHero, stop),
          greaterThanOrEqualTo(4.5),
          reason: '${palette.id} onHero on $stop',
        );
      }
    }
  });

  test('role ink reads at AA on its wash and on the cream page', () {
    for (final palette in HomiziRolePalette.all) {
      expect(
        _contrast(palette.ink, palette.wash),
        greaterThanOrEqualTo(4.5),
        reason: '${palette.id} ink on wash',
      );
      expect(
        _contrast(palette.ink, HomiziColors.cream),
        greaterThanOrEqualTo(4.5),
        reason: '${palette.id} ink on cream',
      );
    }
  });

  test('white never sits on the yellow or golden heroes', () {
    for (final palette in HomiziRolePalette.all) {
      final yellowish = palette.hero.any(
        (stop) =>
            stop == HomiziColors.brandYellow ||
            stop == HomiziColors.brandGolden,
      );
      if (yellowish) {
        expect(palette.onHero, HomiziColors.ink, reason: palette.id);
      }
    }
  });

  test('routes pick the role palette before the chosen role', () {
    expect(paletteForRoute('/post-property/pg', 'tenant').id, 'pg');
    expect(paletteForRoute('/broker/leads', 'tenant').id, 'broker');
    expect(paletteForRoute('/host', 'tenant').id, 'owner');
    expect(paletteForRoute('/post-property/shared', null).id, 'sharer');
    expect(paletteForRoute('/roommate', 'host').id, 'roommate');
    expect(paletteForRoute('/home', 'broker').id, 'broker');
    expect(paletteForRoute('/home', null).id, 'tenant');
  });
}
