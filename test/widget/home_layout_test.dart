import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homizi/app.dart';
import 'package:homizi/core/theme/homizi_colors.dart';
import 'package:homizi/features/session/session_controller.dart';
import 'package:homizi/features/session/session_state.dart';

class _ReadySession extends SessionController {
  @override
  SessionState build() {
    return const SessionState(
      phase: SessionPhase.ready,
      contact: 'ananya@example.test',
      role: AccountRole.tenant,
      policyVersion: '2026-10-11-draft',
    );
  }
}

Future<void> _pump(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      key: ValueKey(size),
      overrides: [sessionProvider.overrideWith(_ReadySession.new)],
      child: const HomiziApp(),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

String? _assetName(ImageProvider<Object> provider) {
  if (provider is AssetImage) {
    return provider.assetName;
  }
  if (provider is ResizeImage) {
    final nested = provider.imageProvider;
    if (nested is AssetImage) {
      return nested.assetName;
    }
  }
  return null;
}

Finder _asset(String name) {
  return find.byWidgetPredicate((widget) {
    return widget is Image && _assetName(widget.image) == name;
  });
}

void main() {
  testWidgets('the v4 living-city home: kinetic hero, live sections, bento', (
    tester,
  ) async {
    await _pump(tester, const Size(390, 1400));

    expect(find.byKey(const Key('live-backdrop')), findsOneWidget);
    expect(find.text('Find a place.'), findsOneWidget);
    // Motion is off in tests, so the kinetic line rests on its first word.
    expect(find.byKey(const Key('home-kinetic-headline')), findsOneWidget);
    expect(find.text('Find your people.'), findsOneWidget);
    expect(find.text('Rent smarter, live better.'), findsOneWidget);
    expect(find.byKey(const Key('home-live-pill')), findsOneWidget);
    expect(find.byKey(const Key('home-search-pill')), findsOneWidget);
    expect(find.byKey(const Key('home-photo-stack')), findsOneWidget);
    expect(find.byKey(const Key('home-live-stats')), findsOneWidget);
    expect(find.byKey(const Key('home-city-stories')), findsOneWidget);
    expect(find.byKey(const Key('home-live-activity')), findsOneWidget);
    expect(find.text('Explore rentals'), findsOneWidget);
    expect(find.text('See all'), findsOneWidget);
    expect(find.text('Why Homizi'), findsNothing);
    expect(find.byKey(const Key('home-swipe-card')), findsNothing);
    expect(_asset('assets/images/real/living.webp'), findsOneWidget);
    expect(_asset('assets/images/real/exterior.webp'), findsWidgets);
    expect(_asset('assets/images/real/bedroom.webp'), findsWidgets);
    expect(_asset('assets/images/real/people.webp'), findsOneWidget);

    expect(find.byKey(const Key('home-card-profile')), findsNothing);
    expect(find.byKey(const Key('home-custom-section')), findsOneWidget);

    Material materialOf(String key) => tester.widget<Material>(
      find
          .ancestor(of: find.byKey(Key(key)), matching: find.byType(Material))
          .first,
    );

    // Bento: the first action is a wide ink photo feature.
    final feature = materialOf('home-card-post');
    expect(feature.color, HomiziColors.ink);
    expect(feature.elevation, 0);
    final screenWidth = tester
        .getSize(find.byKey(const Key('home-screen')))
        .width;
    expect(
      tester.getSize(find.byKey(const Key('home-card-post'))).width,
      closeTo(screenWidth - 32, 0.5),
    );

    // The rest are glass tiles with a light rim; pairs share a row.
    for (final key in [
      'home-card-post-room',
      'home-card-roomie',
      'home-card-search',
    ]) {
      final m = materialOf(key);
      expect(m.color, HomiziColors.glassStrong);
      expect(m.elevation, 0);
      final shape = m.shape! as RoundedRectangleBorder;
      expect(shape.side.color, HomiziColors.glassLine);
    }
    final post = tester.getTopLeft(find.byKey(const Key('home-card-post')));
    final room = tester.getTopLeft(
      find.byKey(const Key('home-card-post-room')),
    );
    final roomie = tester.getTopLeft(find.byKey(const Key('home-card-roomie')));
    final search = tester.getTopLeft(find.byKey(const Key('home-card-search')));
    expect(room.dy, greaterThan(post.dy + 100));
    expect(roomie.dy, closeTo(room.dy, 0.5));
    expect(roomie.dx, greaterThan(room.dx + 80));
    // A lone last tile spans the row.
    expect(search.dy, greaterThan(room.dy + 40));
    expect(search.dx, closeTo(room.dx, 0.5));
    expect(
      tester.getSize(find.byKey(const Key('home-card-search'))).width,
      closeTo(screenWidth - 32, 0.5),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a wide window centers the home column', (tester) async {
    await _pump(tester, const Size(1280, 900));
    expect(tester.takeException(), isNull);
    final screen = tester.getSize(find.byKey(const Key('home-screen')));
    expect(screen.width, lessThanOrEqualTo(480));
    expect(
      tester.getTopLeft(find.byKey(const Key('home-screen'))).dx,
      greaterThan(300),
    );
  });
}
