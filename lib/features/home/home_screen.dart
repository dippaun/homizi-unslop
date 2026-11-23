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
import 'package:homizi/ui/kit/hero_band.dart';
import 'package:homizi/ui/kit/motion_kit.dart';

/// Phone-width column for the landing page on a wide web window.
const homeHubMaxWidth = 480.0;

const _gap = 12.0;
const _page = 16.0;
const _tileRadius = 20.0;

/// Landing home. Role homes stay on their own routes and in the menu.
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
          backgroundColor: HomiziColors.cream,
          appBar: HomiziHomeBar(actions: [if (signedIn) const _NotifyButton()]),
          body: const HomiziErrorBoundary(child: _HomeBody()),
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

class _HomeBody extends ConsumerWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A plain scroll view builds every section, so the rentals deck is
    // in the tree under the taller v2 hero. Pull down to refresh rentals.
    return HomiziRefresh(
      onRefresh: () => ref.read(discoveryProvider.notifier).refresh(),
      child: const SingleChildScrollView(
        key: Key('home-scroll'),
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HomiziStaggerIn(child: _Hero()),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: _page),
              child: _ActionGrid(),
            ),
            SizedBox(height: 28),
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
    );
  }
}

/// v3 hero: a dark panel over a real Mumbai high-rise, the promise in
/// white Poppins, and the cities HOMIZI covers as quiet pills.
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final heading = width >= 400
            ? 34.0
            : width >= 360
            ? 31.0
            : 26.0;
        return Padding(
          padding: const EdgeInsets.fromLTRB(_page, 8, _page, 0),
          child: HomiziHeroBand(
            palette: HomiziRolePalette.tenant,
            photo: 'assets/images/home/apartment.webp',
            photoAlignment: const Alignment(0.6, 0),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: _HeroCopy(headingSize: heading),
          ),
        );
      },
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.headingSize});

  final double headingSize;

  static const _cities = ['Mumbai', 'Bengaluru', 'Pune', 'Delhi NCR'];

  @override
  Widget build(BuildContext context) {
    final heading = TextStyle(
      fontFamily: 'Poppins',
      fontSize: headingSize,
      height: 1.08,
      letterSpacing: -0.8,
      fontWeight: FontWeight.w600,
      color: HomiziColors.white,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: HomiziColors.inkRaised.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified,
                  size: 14,
                  color: HomiziColors.brandYellow,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    homiziText(context, 'Zero brokerage · verified owners'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: HomiziColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(homiziText(context, 'Find a place.'), style: heading),
        Text(
          homiziText(context, 'Find your people.'),
          style: heading.copyWith(color: HomiziColors.brandOrange),
        ),
        const SizedBox(height: 10),
        Text(
          homiziText(context, 'Rent smarter, live better.'),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            height: 1.35,
            fontWeight: FontWeight.w500,
            color: HomiziColors.onInkMuted,
          ),
        ),
        const SizedBox(height: 22),
        ExcludeSemantics(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final city in _cities)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: HomiziColors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: HomiziColors.white.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Text(
                      city,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: HomiziColors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (signedIn) const HomeCustomSection(),
        if (actions.length == 1)
          HomiziPressable(child: _ActionCard(action: actions.first))
        else
          for (var index = 0; index < actions.length; index += 2) ...[
            if (index > 0) const SizedBox(height: _gap),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: HomiziStaggerIn(
                      index: index + 1,
                      child: HomiziPressable(
                        child: _ActionCard(action: actions[index]),
                      ),
                    ),
                  ),
                  const SizedBox(width: _gap),
                  Expanded(
                    child: index + 1 < actions.length
                        ? HomiziStaggerIn(
                            index: index + 2,
                            child: HomiziPressable(
                              child: _ActionCard(action: actions[index + 1]),
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

/// v3 action card: a white card with the real photo on top, a role-tinted
/// icon tile, Poppins title and a muted line. No washes over photos.
class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action});

  final _HubAction action;

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
        color: HomiziColors.white,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 104,
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
                        left: 10,
                        bottom: 10,
                        child: ExcludeSemantics(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: HomiziColors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: HomiziColors.shadow,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: SizedBox(
                              width: 34,
                              height: 34,
                              child: Icon(
                                action.icon,
                                size: 18,
                                color: palette.ink,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
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
                          const ExcludeSemantics(
                            child: Icon(
                              Icons.arrow_forward,
                              size: 18,
                              color: HomiziColors.muted,
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
class _TrustBand extends StatelessWidget {
  const _TrustBand();

  @override
  Widget build(BuildContext context) {
    Widget point(IconData icon, String label) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: HomiziColors.brandYellow),
            const SizedBox(height: 8),
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
        color: HomiziColors.ink,
        borderRadius: BorderRadius.circular(_tileRadius),
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
                point(Icons.verified_user_outlined, 'Aadhaar-verified owners'),
                const SizedBox(width: 12),
                point(Icons.photo_camera_outlined, 'Real photos, on site'),
                const SizedBox(width: 12),
                point(Icons.currency_rupee, 'No brokerage'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
