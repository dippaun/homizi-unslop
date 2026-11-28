import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:homizi/core/motion/animated_route.dart';
import 'package:homizi/core/motion/homizi_motion.dart';
import 'package:homizi/core/motion/slow_motion.dart';

Widget _app(Widget child, {bool still = false}) {
  return MaterialApp(
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: still),
        child: Scaffold(body: child),
      ),
    ),
  );
}

double _opacityOf(WidgetTester tester, Key key) {
  final fade = tester.widget<FadeTransition>(
    find
        .ancestor(of: find.byKey(key), matching: find.byType(FadeTransition))
        .first,
  );
  return fade.opacity.value;
}

void main() {
  group('HomiziStagger', () {
    Widget column() => const HomiziStagger(
      count: 3,
      child: Column(
        children: [
          HomiziStaggerItem(
            index: 0,
            child: SizedBox(key: Key('a'), height: 10),
          ),
          HomiziStaggerItem(
            index: 2,
            child: SizedBox(key: Key('c'), height: 10),
          ),
        ],
      ),
    );

    testWidgets('later items start after earlier ones and all finish', (
      tester,
    ) async {
      await tester.pumpWidget(_app(column()));
      expect(_opacityOf(tester, const Key('a')), 0);
      await tester.pump(const Duration(milliseconds: 200));
      expect(
        _opacityOf(tester, const Key('a')),
        greaterThan(_opacityOf(tester, const Key('c'))),
      );
      await tester.pumpAndSettle();
      expect(_opacityOf(tester, const Key('a')), 1);
      expect(_opacityOf(tester, const Key('c')), 1);
    });

    testWidgets('reduced motion shows everything at once', (tester) async {
      await tester.pumpWidget(_app(column(), still: true));
      expect(_opacityOf(tester, const Key('c')), 1);
    });

    test('windows stay inside the timeline', () {
      for (var i = 0; i < 5; i++) {
        final (start, end) = HomiziStaggerItem.window(i, 5);
        expect(start, inInclusiveRange(0, 1));
        expect(end, inInclusiveRange(start, 1));
      }
      expect(HomiziStaggerItem.window(4, 5).$2, 1);
    });
  });

  test('parallax lags the scroll and zooms a little', () {
    expect(HomiziParallax.at(0), (0.0, 1.0));
    final (dy, scale) = HomiziParallax.at(200);
    expect(dy, closeTo(70, 0.001));
    expect(scale, closeTo(1.1, 0.001));
    expect(HomiziParallax.at(5000).$2, 1.12);
    expect(HomiziParallax.at(-40).$2, greaterThan(1));
  });

  testWidgets('glass bar is solid at rest and frosts once scrolled', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _app(
        Stack(
          children: [
            ListView(
              controller: controller,
              children: [
                for (var i = 0; i < 40; i++)
                  SizedBox(height: 60, child: Text('Row $i')),
              ],
            ),
            HomiziGlass(
              controller: controller,
              child: const SizedBox(height: 56, width: 300),
            ),
          ],
        ),
      ),
    );
    BackdropFilter filter() => tester.widget(find.byType(BackdropFilter));
    expect(filter().enabled, isFalse);
    controller.jumpTo(200);
    await tester.pump();
    expect(filter().enabled, isTrue);
    final box = tester.widget<DecoratedBox>(
      find.byKey(const Key('homizi-glass-surface')),
    );
    final color = (box.decoration as BoxDecoration).color!;
    expect(color.a, closeTo(0.72, 0.01));
  });

  testWidgets('press scale shrinks while held and springs back', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _app(
        Center(
          child: HomiziPressScale(
            child: ElevatedButton(
              key: const Key('btn'),
              onPressed: () => taps++,
              child: const Text('Book visit'),
            ),
          ),
        ),
      ),
    );
    double scale() =>
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('btn'))),
    );
    await tester.pump();
    expect(scale(), 0.97);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(scale(), 1);
    expect(taps, 1);
  });

  test('spring curve settles at 1 with a small overshoot', () {
    expect(homiziSpring.transform(0), 0);
    expect(homiziSpring.transform(1), 1);
    var peak = 0.0;
    for (var i = 0; i <= 100; i++) {
      final v = homiziSpring.transform(i / 100);
      if (v > peak) {
        peak = v;
      }
    }
    expect(peak, greaterThan(1));
    expect(peak, lessThan(1.06));
  });

  testWidgets('route draws itself from A to B', (tester) async {
    await tester.pumpWidget(
      _app(
        const SizedBox(
          width: 300,
          height: 160,
          child: HomiziAnimatedRoute(
            from: Offset(0.1, 0.8),
            to: Offset(0.9, 0.2),
          ),
        ),
      ),
    );
    HomiziRoutePainter painter() =>
        tester
                .widget<CustomPaint>(
                  find.byKey(const Key('homizi-animated-route')),
                )
                .painter!
            as HomiziRoutePainter;
    expect(painter().progress, 0);
    await tester.pump(const Duration(milliseconds: 900));
    expect(painter().progress, inExclusiveRange(0, 1));
    await tester.pumpAndSettle();
    expect(painter().progress, 1);

    final path = homiziRoutePath(const Offset(0, 100), const Offset(200, 100));
    final ui.Tangent tip = HomiziRoutePainter.tipFor(path, 1)!;
    expect(tip.position.dx, closeTo(200, 0.5));
    expect(tip.position.dy, closeTo(100, 0.5));
  });

  testWidgets('card photo flies into the listing on a spring route', (
    tester,
  ) async {
    Widget hero(Key key, double height) => Hero(
      tag: 'listing-hero-mum-1',
      curve: homiziSpring,
      createRectTween: homiziHeroRectTween,
      flightShuttleBuilder: homiziCardShuttle,
      child: SizedBox(key: key, height: height, width: double.infinity),
    );
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Column(
              children: [
                const SizedBox(height: 300),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.push('/listing/mum-1'),
                  child: hero(const Key('card-photo'), 120),
                ),
              ],
            ),
          ),
        ),
        GoRoute(
          path: '/listing/:id',
          pageBuilder: (context, state) => homiziSpringPage<void>(
            state: state,
            child: Scaffold(body: hero(const Key('detail-photo'), 320)),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.byKey(const Key('card-photo')), warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    // Mid-flight the shuttle is the card's own photo; the listing's photo
    // waits hidden until it lands.
    expect(find.byKey(const Key('card-photo')), findsOneWidget);
    expect(find.byKey(const Key('detail-photo')), findsNothing);
    final mid = tester.getRect(find.byKey(const Key('card-photo')));
    expect(mid.top, lessThan(300));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('detail-photo')), findsOneWidget);
    expect(tester.getRect(find.byKey(const Key('detail-photo'))).top, 0);

    router.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.byKey(const Key('card-photo')), findsOneWidget);
    expect(find.byKey(const Key('detail-photo')), findsNothing);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('detail-photo')), findsNothing);
    expect(tester.getRect(find.byKey(const Key('card-photo'))).top, 300);
  });

  test('slow-motion review flag only accepts 1 to 10', () {
    expect(slowMotionFactor('4'), 4);
    expect(slowMotionFactor(null), isNull);
    expect(slowMotionFactor('0.5'), isNull);
    expect(slowMotionFactor('50'), isNull);
    expect(slowMotionFactor('fast'), isNull);
  });
}
