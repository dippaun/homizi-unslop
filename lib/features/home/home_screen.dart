import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homizi/core/l10n/translate.dart';
import 'package:homizi/core/routing/account_prompt.dart';
import 'package:homizi/core/routing/route_paths.dart';
import 'package:homizi/core/theme/homizi_colors.dart';
import 'package:homizi/core/theme/role_palette.dart';
import 'package:homizi/core/widgets/homizi_error_boundary.dart';
import 'package:homizi/core/widgets/homizi_home_bar.dart';
import 'package:homizi/features/browse/browse_place.dart';
import 'package:homizi/features/discovery/discovery_controller.dart';
import 'package:homizi/features/discovery/flats_swipe_deck.dart';
import 'package:homizi/features/home/home_listing_deck.dart';
import 'package:homizi/features/post_property/pg_owner_mode.dart';
import 'package:homizi/features/roles/role_provider.dart';
import 'package:homizi/features/session/session_controller.dart';
import 'package:homizi/features/session/sign_in_source.dart';
import 'package:homizi/features/shell/min_touch.dart';
import 'package:homizi/ui/kit/live_backdrop.dart';
import 'package:homizi/ui/kit/live_motion.dart';
import 'package:homizi/ui/kit/motion_kit.dart';

/// Phone-width column for the landing page on a wide web window.
const homeHubMaxWidth = 480.0;

const _gap = 12.0;
const _page = 16.0;
const _tileRadius = 22.0;

/// v4 "Living city" home. The page sits on [HomiziLiveBackdrop]: a slow
/// brand-orange gradient mesh with line-art apartment blocks whose window
/// lights twinkle on, rising as you scroll. On top: kinetic headline, a
/// floating stack of real Indian homes, live counters, city stories, a
/// bento of actions, a live activity ticker and the rentals deck.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(signedInProvider);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: homeHubMaxWidth),
        child: Scaffold(
          key: const Key('home-screen'),
          backgroundColor: HomiziColors.livingBase,
          extendBodyBehindAppBar: true,
          appBar: _GlassBar(
            child: HomiziHomeBar(
              color: HomiziColors.clear,
              actions: [if (signedIn) const _NotifyButton()],
            ),
          ),
          body: const HomiziErrorBoundary(child: _HomeBody()),
        ),
      ),
    );
  }
}

/// Frosted bar over the live backdrop: the mesh and skyline show through
/// a blurred peach veil, so the page reads as one surface.
class _GlassBar extends StatelessWidget implements PreferredSizeWidget {
  const _GlassBar({required this.child});

  final HomiziHomeBar child;

  @override
  Size get preferredSize => child.preferredSize;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: HomiziColors.livingVeil,
            border: Border(bottom: BorderSide(color: HomiziColors.glassLine)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _NotifyButton extends ConsumerWidget {
  const _NotifyButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      key: const Key('home-notifications'),
      tooltip: homiziText(context, 'Notifications'),
      style: minTouchIconStyle(),
      onPressed: () => openAccountPath(
        context,
        ref.read(sessionProvider),
        RoutePaths.notifications,
      ),
      icon: const Icon(Icons.notifications_outlined),
    );
  }
}

class _HomeBody extends ConsumerStatefulWidget {
  const _HomeBody();

  @override
  ConsumerState<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends ConsumerState<_HomeBody> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A plain scroll view builds every section, so the rentals deck is in
    // the tree under the hero. Pull down to refresh rentals.
    return HomiziLiveBackdrop(
      scrollController: _scroll,
      child: HomiziRefresh(
        onRefresh: () => ref.read(discoveryProvider.notifier).refresh(),
        child: SingleChildScrollView(
          key: const Key('home-scroll'),
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            top: MediaQuery.paddingOf(context).top,
            bottom: 40,
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HomiziStaggerIn(child: _Hero()),
              SizedBox(height: 18),
              HomiziStaggerIn(index: 1, child: _LiveStats()),
              SizedBox(height: 26),
              HomiziStaggerIn(index: 2, child: _CityStories()),
              SizedBox(height: 24),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: _page),
                child: _ActionGrid(),
              ),
              SizedBox(height: 18),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: _page),
                child: _LiveActivity(),
              ),
              SizedBox(height: 26),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: _page),
                child: _RentalStrip(),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: _page),
                child: _TrustBand(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ink type on the peach mesh clears 14:1; the kinetic line is a red
/// orange to deep red gradient (5.2:1 and up at display size).
const _heroGradient = LinearGradient(
  colors: [HomiziColors.brandVermilion, HomiziColors.brandDeepRed],
);

class _Hero extends StatelessWidget {
  const _Hero();

  static const _kinetic = [
    'Find your people.',
    'Find a flatmate.',
    'Find a PG nearby.',
    'Find your flat.',
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final size = width >= 400
            ? 38.0
            : width >= 360
            ? 34.0
            : 28.0;
        final heading = TextStyle(
          fontFamily: 'Poppins',
          fontSize: size,
          height: 1.1,
          letterSpacing: -1.1,
          fontWeight: FontWeight.w700,
          color: HomiziColors.ink,
        );
        return Padding(
          padding: const EdgeInsets.fromLTRB(_page, 4, _page, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _LivePill(),
              const SizedBox(height: 14),
              Text(homiziText(context, 'Find a place.'), style: heading),
              SizedBox(
                key: const Key('home-kinetic-headline'),
                height: size * 1.25,
                child: HomiziKineticLine(
                  lines: [for (final l in _kinetic) homiziText(context, l)],
                  style: heading.copyWith(color: HomiziColors.white),
                  gradient: _heroGradient,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                homiziText(context, 'Rent smarter, live better.'),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                  color: HomiziColors.inkSoft,
                ),
              ),
              const SizedBox(height: 16),
              const _SearchPill(),
              const SizedBox(height: 20),
              const _PhotoStack(),
            ],
          ),
        );
      },
    );
  }
}

class _LivePill extends StatelessWidget {
  const _LivePill();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontFamily: 'Inter',
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: HomiziColors.ink,
    );
    return DecoratedBox(
      key: const Key('home-live-pill'),
      decoration: BoxDecoration(
        color: HomiziColors.glass,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: HomiziColors.glassLine),
        boxShadow: const [
          BoxShadow(color: HomiziColors.shadow, blurRadius: 14),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 3, 12, 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const HomiziPulseDot(),
            Text(
              homiziText(context, 'LIVE'),
              style: style.copyWith(
                color: HomiziColors.success,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            const HomiziCountUp(value: 1284, liveStep: 3, style: style),
            Flexible(
              child: Text(
                ' ${homiziText(context, 'homes listed this week')}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  const _SearchPill();

  static const _hints = [
    'Try “2 BHK in Koramangala”',
    'Try “PG near Hinjewadi”',
    'Try “Flatmate in Powai”',
    'Try “1 RK in Gachibowli”',
  ];

  @override
  Widget build(BuildContext context) {
    return HomiziPressable(
      child: Material(
        color: HomiziColors.glassStrong,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: const BorderSide(color: HomiziColors.glassLine),
        ),
        shadowColor: HomiziColors.shadowStrong,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: const Key('home-search-pill'),
          onTap: () => context.push(RoutePaths.flats),
          child: Semantics(
            button: true,
            label: homiziText(context, 'Search homes, PGs and flatmates'),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 6, 6, 6),
              child: Row(
                children: [
                  const Icon(Icons.search, color: HomiziColors.ink, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ExcludeSemantics(
                      child: SizedBox(
                        height: 22,
                        child: HomiziKineticLine(
                          lines: [
                            for (final h in _hints) homiziText(context, h),
                          ],
                          period: const Duration(milliseconds: 2900),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: HomiziColors.muted,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: HomiziGradients.action,
                    ),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: HomiziColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Three real Indian homes fanned like cards, each floating on its own
/// loop with a slow Ken Burns pan. The front card tilts toward the
/// pointer. Two chips float over it.
class _PhotoStack extends StatelessWidget {
  const _PhotoStack();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        key: const Key('home-photo-stack'),
        height: 268,
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final cardW = (w * 0.62).clamp(180.0, 300.0);
            final dpr = MediaQuery.devicePixelRatioOf(context);
            final cache = (cardW * dpr * 1.2).round();
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  top: 26,
                  child: HomiziFloat(
                    period: 6.5,
                    phase: 1.2,
                    sway: 0.008,
                    child: Transform.rotate(
                      angle: -0.10,
                      child: _StackCard(
                        width: cardW * 0.82,
                        height: 200,
                        asset: 'assets/images/home/apartment.webp',
                        cache: cache,
                        phase: 2,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 18,
                  child: HomiziFloat(
                    period: 7.2,
                    phase: 2.6,
                    sway: 0.008,
                    child: Transform.rotate(
                      angle: 0.09,
                      child: _StackCard(
                        width: cardW * 0.82,
                        height: 200,
                        asset: 'assets/images/real/bedroom.webp',
                        cache: cache,
                        phase: 4,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: HomiziFloat(
                    period: 5.6,
                    amplitude: 5,
                    child: HomiziTilt(
                      child: _StackCard(
                        width: cardW,
                        height: 236,
                        asset: 'assets/images/real/living.webp',
                        cache: cache,
                        front: true,
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  right: 4,
                  top: 0,
                  child: HomiziFloat(
                    period: 4.2,
                    phase: 0.8,
                    amplitude: 7,
                    child: _MatchChip(),
                  ),
                ),
                const Positioned(
                  left: 6,
                  bottom: 10,
                  child: HomiziFloat(
                    period: 4.8,
                    phase: 2.2,
                    child: _VerifiedChip(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StackCard extends StatelessWidget {
  const _StackCard({
    required this.width,
    required this.height,
    required this.asset,
    required this.cache,
    this.phase = 0,
    this.front = false,
  });

  final double width;
  final double height;
  final String asset;
  final int cache;
  final double phase;
  final bool front;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: HomiziColors.white, width: front ? 4 : 3),
        boxShadow: [
          BoxShadow(
            color: HomiziColors.brandDeepRed.withValues(
              alpha: front ? 0.28 : 0.16,
            ),
            blurRadius: front ? 30 : 18,
            offset: Offset(0, front ? 16 : 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            HomiziKenBurns(asset: asset, phase: phase, cacheWidth: cache),
            if (front) ...[
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [HomiziColors.clear, HomiziColors.inkScrim],
                    stops: [0.45, 1],
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      homiziText(context, '2 BHK · Powai, Mumbai'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: HomiziColors.onInkMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '₹48,000 / month',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: HomiziColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MatchChip extends StatelessWidget {
  const _MatchChip();

  @override
  Widget build(BuildContext context) {
    return _GlassChip(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 0.92),
              duration: const Duration(milliseconds: 1600),
              curve: const Cubic(0.22, 1, 0.36, 1),
              builder: (context, v, _) => CircularProgressIndicator(
                value: v,
                strokeWidth: 4,
                strokeCap: StrokeCap.round,
                color: HomiziColors.success,
                backgroundColor: HomiziColors.successWash,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomiziCountUp(
                value: 92,
                suffix: '%',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  color: HomiziColors.ink,
                ),
              ),
              Text(
                homiziText(context, 'match'),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: HomiziColors.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerifiedChip extends StatelessWidget {
  const _VerifiedChip();

  @override
  Widget build(BuildContext context) {
    return _GlassChip(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, color: HomiziColors.success, size: 18),
          const SizedBox(width: 6),
          Text(
            homiziText(context, 'Owner verified · ₹0 brokerage'),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: HomiziColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  const _GlassChip({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: HomiziColors.glassStrong,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: HomiziColors.shadowStrong,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: child,
      ),
    );
  }
}

/// Three live counters on glass. Numbers count up on arrival; homes and
/// flatmates keep ticking upward while the page is open.
class _LiveStats extends StatelessWidget {
  const _LiveStats();

  @override
  Widget build(BuildContext context) {
    const number = TextStyle(
      fontFamily: 'Poppins',
      fontSize: 20,
      height: 1.1,
      fontWeight: FontWeight.w700,
      color: HomiziColors.ink,
    );
    Widget tile(Widget value, String label, IconData icon, Color tint) {
      return Expanded(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: HomiziColors.glass,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: HomiziColors.glassLine),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 18, color: tint),
                const SizedBox(height: 8),
                FittedBox(fit: BoxFit.scaleDown, child: value),
                const SizedBox(height: 2),
                Text(
                  homiziText(context, label),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: HomiziColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      key: const Key('home-live-stats'),
      padding: const EdgeInsets.symmetric(horizontal: _page),
      child: Row(
        children: [
          tile(
            const HomiziCountUp(value: 12480, liveStep: 4, style: number),
            'homes live',
            Icons.home_rounded,
            HomiziColors.brandRedOrange,
          ),
          const SizedBox(width: 10),
          tile(
            const HomiziCountUp(value: 3260, liveStep: 3, style: number),
            'flatmates looking',
            Icons.groups_rounded,
            HomiziColors.brandDeepRed,
          ),
          const SizedBox(width: 10),
          tile(
            const HomiziCountUp(value: 0, prefix: '₹', style: number),
            'brokerage, ever',
            Icons.savings_rounded,
            HomiziColors.success,
          ),
        ],
      ),
    );
  }
}

class _City {
  const _City(this.name, this.homes, this.photo);

  final String name;
  final String homes;
  final String photo;
}

const _cities = <_City>[
  _City('Mumbai', '3.2k', 'assets/images/home/apartment.webp'),
  _City('Bengaluru', '2.9k', 'assets/photos/exterior_03.webp'),
  _City('Pune', '1.8k', 'assets/images/real/apartment.webp'),
  _City('Hyderabad', '1.6k', 'assets/images/home/house.webp'),
  _City('Delhi NCR', '2.4k', 'assets/photos/balcony_02.webp'),
  _City('Chennai', '1.1k', 'assets/images/real/exterior.webp'),
];

/// Story-style city bubbles with spinning brand rings.
class _CityStories extends StatelessWidget {
  const _CityStories();

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _page),
          child: Text(
            homiziText(context, 'Explore by city'),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: HomiziColors.ink,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          key: const Key('home-city-stories'),
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: _page),
            itemCount: _cities.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final city = _cities[i];
              return HomiziPressable(
                child: InkWell(
                  key: Key('home-city-$i'),
                  borderRadius: BorderRadius.circular(40),
                  onTap: () => context.push(RoutePaths.flats),
                  child: Semantics(
                    button: true,
                    label: '${city.name}, ${city.homes} homes',
                    child: ExcludeSemantics(
                      child: Column(
                        children: [
                          HomiziSpinRing(
                            speed: 0.18 + i * 0.03,
                            child: Image.asset(
                              city.photo,
                              fit: BoxFit.cover,
                              cacheWidth: (64 * dpr).round(),
                              errorBuilder: (context, error, stack) =>
                                  const ColoredBox(color: HomiziColors.mist),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            city.name,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: HomiziColors.ink,
                            ),
                          ),
                          Text(
                            '${city.homes} homes',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: HomiziColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Live activity: what just happened on HOMIZI, cycling every few seconds.
class _LiveActivity extends StatelessWidget {
  const _LiveActivity();

  static const _events = [
    'Ananya found a flatmate in HSR Layout · 2 min ago',
    'New 2 BHK listed in Baner, Pune · just now',
    'Rohit booked a visit in Powai · 5 min ago',
    'Verified PG added in Madhapur · 8 min ago',
    'Meera matched 94% with a flat in Indiranagar · 1 min ago',
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const Key('home-live-activity'),
      decoration: BoxDecoration(
        color: HomiziColors.inkGlass,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: HomiziColors.shadowStrong,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 10, 14, 10),
        child: Row(
          children: [
            const HomiziPulseDot(color: HomiziColors.brandYellow),
            const SizedBox(width: 4),
            Expanded(
              child: SizedBox(
                height: 20,
                child: HomiziLiveTicker(
                  messages: [for (final e in _events) homiziText(context, e)],
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: HomiziColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HubAction {
  const _HubAction({
    required this.cardKey,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.palette,
    required this.path,
    this.image,
  });

  final Key cardKey;
  final IconData icon;
  final String title;
  final String subtitle;
  final HomiziRolePalette palette;
  final String path;
  final String? image;
}

const _actions = <_HubAction>[
  _HubAction(
    cardKey: Key('home-card-profile'),
    icon: Icons.verified_outlined,
    title: 'Create Your Profile',
    subtitle: 'Get verified and find genuine matches',
    palette: HomiziRolePalette.tenant,
    path: RoutePaths.profileCreate,
    image: 'assets/images/real/living.webp',
  ),
  _HubAction(
    cardKey: Key('home-card-post'),
    icon: Icons.home_work_outlined,
    title: 'Post Your Property',
    subtitle: 'List your property and reach verified tenants',
    palette: HomiziRolePalette.owner,
    path: RoutePaths.postProperty,
    image: 'assets/images/real/exterior.webp',
  ),
  _HubAction(
    cardKey: Key('home-card-post-room'),
    icon: Icons.bedroom_parent_outlined,
    title: 'Post a room',
    subtitle: 'Share a room or the whole house you live in',
    palette: HomiziRolePalette.sharer,
    path: RoutePaths.postRoom,
    image: 'assets/images/real/bedroom.webp',
  ),
  _HubAction(
    cardKey: Key('home-card-roomie'),
    icon: Icons.groups_outlined,
    title: 'Find Your Roomie',
    subtitle: 'Connect with like-minded flatmates and search together',
    palette: HomiziRolePalette.roommate,
    path: RoutePaths.roommate,
    image: 'assets/images/real/people.webp',
  ),
  _HubAction(
    cardKey: Key('home-card-search'),
    icon: Icons.search,
    title: 'Search Properties',
    subtitle: 'Find your next home across cities',
    palette: HomiziRolePalette.pg,
    path: RoutePaths.searchStart,
    image: 'assets/images/real/apartment.webp',
  ),
];

bool _hostHome(HomiziRole? role, {required bool pgOwner}) {
  return pgOwner || role == HomiziRole.host || role == HomiziRole.broker;
}

/// Slot that replaced the signed-in "Create Your Profile" tile.
///
/// Empty for now, so the other tiles reflow. A later custom section can
/// grow in this widget without moving the grid.
class HomeCustomSection extends StatelessWidget {
  const HomeCustomSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(key: Key('home-custom-section'));
  }
}

class _ActionGrid extends ConsumerWidget {
  const _ActionGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentRoleProvider);
    final signedIn = ref.watch(signedInProvider);
    final host = _hostHome(
      role,
      pgOwner: pgOwnerActive(ref.watch(pgOwnerModeProvider)),
    );
    final actions = host
        ? [
            for (final action in _actions)
              if (action.path == RoutePaths.postProperty) action,
          ]
        : [
            for (final action in _actions)
              if ((action.path != RoutePaths.profileCreate || !signedIn) &&
                  (action.path != RoutePaths.searchStart ||
                      (signedIn && role == HomiziRole.tenant)) &&
                  (action.path != RoutePaths.postRoom ||
                      role == HomiziRole.tenant ||
                      role == HomiziRole.roommate))
                action,
          ];
    final rest = actions.skip(1).toList();
    // Bento: the first action is a wide photo feature; the rest pair up
    // as glass tiles with a floating icon badge.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (signedIn) const HomeCustomSection(),
        if (actions.isNotEmpty)
          HomiziStaggerIn(
            index: 3,
            child: HomiziPressable(child: _FeatureCard(action: actions.first)),
          ),
        for (var index = 0; index < rest.length; index += 2) ...[
          const SizedBox(height: _gap),
          if (index + 1 >= rest.length)
            HomiziStaggerIn(
              index: index + 4,
              child: HomiziPressable(
                child: _ActionCard(
                  action: rest[index],
                  slot: index,
                  wide: true,
                ),
              ),
            )
          else
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: HomiziStaggerIn(
                      index: index + 4,
                      child: HomiziPressable(
                        child: _ActionCard(action: rest[index], slot: index),
                      ),
                    ),
                  ),
                  const SizedBox(width: _gap),
                  Expanded(
                    child: index + 1 < rest.length
                        ? HomiziStaggerIn(
                            index: index + 5,
                            child: HomiziPressable(
                              child: _ActionCard(
                                action: rest[index + 1],
                                slot: index + 1,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

/// Wide bento feature: a Ken Burns photo with an ink scrim, white
/// Poppins title (13:1 on the scrim) and an orange go button.
class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.action});

  final _HubAction action;

  @override
  Widget build(BuildContext context) {
    final spoken = [
      homiziText(context, action.title),
      homiziText(context, action.subtitle),
    ].join('. ');
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_tileRadius),
        boxShadow: [
          BoxShadow(
            color: HomiziColors.brandDeepRed.withValues(alpha: 0.22),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: HomiziColors.ink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_tileRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: action.cardKey,
          onTap: () => context.push(action.path),
          child: Semantics(
            button: true,
            label: spoken,
            child: SizedBox(
              height: 176,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (action.image != null)
                    HomiziKenBurns(
                      asset: action.image!,
                      period: 16,
                      cacheWidth: (480 * dpr).round(),
                    ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [HomiziColors.inkScrim, HomiziColors.clear],
                        stops: [0.15, 0.95],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ExcludeSemantics(
                          child: HomiziFloat(
                            amplitude: 3,
                            period: 3.6,
                            child: _IconBadge(
                              icon: action.icon,
                              palette: action.palette,
                            ),
                          ),
                        ),
                        const Spacer(),
                        FractionallySizedBox(
                          widthFactor: 0.7,
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                homiziText(context, action.title),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 20,
                                  height: 1.15,
                                  fontWeight: FontWeight.w700,
                                  color: HomiziColors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                homiziText(context, action.subtitle),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  height: 1.35,
                                  color: HomiziColors.onInkMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    right: 14,
                    bottom: 14,
                    child: ExcludeSemantics(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: HomiziGradients.action,
                        ),
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: HomiziColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.palette});

  final IconData icon;
  final HomiziRolePalette palette;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: HomiziColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: HomiziColors.shadowStrong,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(icon, size: 19, color: palette.ink),
      ),
    );
  }
}

/// Bento tile: glass card, real photo with a floating icon badge, Poppins
/// title and a muted line.
class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action, this.slot = 0, this.wide = false});

  final _HubAction action;
  final int slot;

  /// A lone last tile spans the row: photo left, copy right.
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final palette = action.palette;
    final spoken = [
      homiziText(context, action.title),
      homiziText(context, action.subtitle),
    ].join('. ');
    const titleStyle = TextStyle(
      fontFamily: 'Poppins',
      fontSize: 15,
      height: 1.2,
      fontWeight: FontWeight.w600,
      color: HomiziColors.ink,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_tileRadius),
        boxShadow: const [
          BoxShadow(
            color: HomiziColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: HomiziColors.glassStrong,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_tileRadius),
          side: const BorderSide(color: HomiziColors.glassLine),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: action.cardKey,
          onTap: () => context.push(action.path),
          child: Semantics(
            button: true,
            label: spoken,
            child: Flex(
              direction: wide ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: wide
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    6,
                    6,
                    wide ? 0 : 6,
                    wide ? 6 : 0,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(_tileRadius - 6),
                    child: SizedBox(
                      height: 96,
                      width: wide ? 132 : null,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (action.image != null)
                            _CoverPhoto(
                              asset: action.image!,
                              alignment: const Alignment(0, -0.1),
                            )
                          else
                            ColoredBox(color: palette.wash),
                          Positioned(
                            left: 8,
                            bottom: 8,
                            child: ExcludeSemantics(
                              child: HomiziFloat(
                                amplitude: 3,
                                period: 3.4 + slot * 0.4,
                                phase: slot * 1.3,
                                child: _IconBadge(
                                  icon: action.icon,
                                  palette: palette,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _maybeExpand(
                  wide,
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 10, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                homiziText(context, action.title),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: titleStyle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const ExcludeSemantics(
                              child: Icon(
                                Icons.arrow_outward_rounded,
                                size: 18,
                                color: HomiziColors.brandRedOrange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          homiziText(context, action.subtitle),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            height: 1.35,
                            color: HomiziColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CoverPhoto extends StatelessWidget {
  const _CoverPhoto({required this.asset, this.alignment = Alignment.center});

  final String asset;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final logical = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 180.0;
        if (!logical.isFinite || logical <= 0 || !height.isFinite) {
          return const ColoredBox(color: HomiziColors.mist);
        }
        final cacheWidth = (logical * MediaQuery.devicePixelRatioOf(context))
            .round()
            .clamp(64, 1600);
        return Image.asset(
          asset,
          fit: BoxFit.cover,
          alignment: alignment,
          width: double.infinity,
          height: double.infinity,
          cacheWidth: cacheWidth,
          excludeFromSemantics: true,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) {
            return const ColoredBox(color: HomiziColors.mist);
          },
        );
      },
    );
  }
}

class _RentalStrip extends ConsumerWidget {
  const _RentalStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discovery = ref.watch(discoveryProvider);
    final listings = homeSwipeListings(ref.watch(locatedListingsProvider));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (discovery.sample)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: _SampleTag(key: Key('home-sample-tag')),
          ),
        Row(
          children: [
            Expanded(
              child: Text(
                homiziText(context, 'Explore rentals'),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: HomiziColors.ink,
                ),
              ),
            ),
            TextButton.icon(
              key: const Key('home-see-all'),
              onPressed: () => context.push(RoutePaths.flats),
              iconAlignment: IconAlignment.end,
              icon: const Icon(
                Icons.chevron_right,
                size: 18,
                color: HomiziColors.brandRedOrange,
              ),
              label: Text(
                homiziText(context, 'See all'),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: HomiziColors.brandRedOrange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          key: const Key('home-rentals'),
          height: 560,
          child: FlatsSwipeDeck(
            listings: listings,
            returnPath: RoutePaths.home,
            cardKey: const Key('home-flats-card'),
            surfaceKey: const Key('home-flats-surface'),
            hintKey: const Key('home-flats-hint'),
          ),
        ),
      ],
    );
  }
}

class _SampleTag extends StatelessWidget {
  const _SampleTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: HomiziColors.haldiWash,
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(
            'Sample',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: HomiziColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

/// v3 trust band: a dark ink card with three proof points. White on ink
/// clears 16:1; the muted line 9:1.
/// v4 trust band: ink glass with a sunrise edge and three proof points
/// whose icons float. White on ink clears 13:1; the muted line 9:1.
class _TrustBand extends StatelessWidget {
  const _TrustBand();

  @override
  Widget build(BuildContext context) {
    Widget point(IconData icon, String label, int i) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomiziFloat(
              amplitude: 2.5,
              period: 3 + i * 0.5,
              phase: i * 1.1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: HomiziColors.inkRaised,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SizedBox(
                  width: 34,
                  height: 34,
                  child: Icon(icon, size: 18, color: HomiziColors.brandYellow),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              homiziText(context, label),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: HomiziColors.white,
              ),
            ),
          ],
        ),
      );
    }

    return DecoratedBox(
      key: const Key('home-trust-band'),
      decoration: BoxDecoration(
        gradient: HomiziGradients.sunrise,
        borderRadius: BorderRadius.circular(_tileRadius),
        boxShadow: const [
          BoxShadow(
            color: HomiziColors.shadowStrong,
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: HomiziColors.ink,
            borderRadius: BorderRadius.circular(_tileRadius - 1),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  homiziText(context, 'Homes checked in person'),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: HomiziColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  homiziText(
                    context,
                    'Owners verified with Aadhaar, photos taken on site.',
                  ),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    height: 1.35,
                    color: HomiziColors.onInkMuted,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    point(
                      Icons.verified_user_outlined,
                      'Aadhaar-verified owners',
                      0,
                    ),
                    const SizedBox(width: 12),
                    point(
                      Icons.photo_camera_outlined,
                      'Real photos, on site',
                      1,
                    ),
                    const SizedBox(width: 12),
                    point(Icons.currency_rupee, 'No brokerage', 2),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _maybeExpand(bool expand, Widget child) =>
    expand ? Expanded(child: child) : child;
