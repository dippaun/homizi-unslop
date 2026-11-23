import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homizi/core/brand/homizi_mark.dart';
import 'package:homizi/core/l10n/translate.dart';
import 'package:homizi/core/routing/route_paths.dart';
import 'package:homizi/core/theme/homizi_colors.dart';
import 'package:homizi/core/theme/role_palette.dart';
import 'package:homizi/core/widgets/homizi_back.dart';
import 'package:homizi/features/broker/broker_auth.dart';
import 'package:homizi/features/host/host_intent.dart';
import 'package:homizi/features/roles/role_flow.dart';
import 'package:homizi/features/roles/role_provider.dart';
import 'package:homizi/features/roommates/flatmate_return.dart';
import 'package:homizi/features/session/session_controller.dart';
import 'package:homizi/features/session/session_state.dart';
import 'package:homizi/features/tenant/tenant_intent.dart';
import 'package:homizi/ui/kit/hero_band.dart';
import 'package:homizi/ui/kit/motion_kit.dart';
import 'package:homizi/ui/kit/page_background.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: HomiziColors.cream,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const HomiziBackButton(),
        title: Text(homiziText(context, 'How will you use HOMIZI?')),
      ),
      body: PageBackground(
        variant: PageBackgroundVariant.skyline,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            const BrandLockup(),
            const SizedBox(height: 20),
            Text(
              homiziText(context, 'Pick one way in. You can change it later.'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              homiziText(
                context,
                'HOMIZI is for tenants, people looking for a flatmate, hosts, and brokers.',
              ),
            ),
            const SizedBox(height: 24),
            for (final (index, option) in _options.indexed) ...[
              HomiziStaggerIn(
                index: index,
                child: HomiziPressable(
                  child: _RoleCard(
                    option: option,
                    onTap: () => unawaited(_choose(context, ref, option.role)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _RoleOption {
  const _RoleOption({
    required this.role,
    required this.title,
    required this.benefit,
    required this.icon,
    required this.palette,
    this.kinds = const [],
  });

  final HomiziRole role;
  final String title;
  final String benefit;
  final IconData icon;
  final HomiziRolePalette palette;

  /// The profiles this way in covers, shown as role chips.
  final List<(String, HomiziRolePalette)> kinds;
}

const _options = <_RoleOption>[
  _RoleOption(
    role: HomiziRole.roommate,
    title: 'Roommate',
    benefit: 'Find a flatmate',
    icon: Icons.groups_outlined,
    palette: HomiziRolePalette.roommate,
    kinds: [
      ('Flatmate', HomiziRolePalette.roommate),
      ('Room sharer', HomiziRolePalette.sharer),
    ],
  ),
  _RoleOption(
    role: HomiziRole.tenant,
    title: 'Rental',
    benefit: 'Find a home to rent',
    icon: Icons.apartment_outlined,
    palette: HomiziRolePalette.tenant,
    kinds: [
      ('Tenant', HomiziRolePalette.tenant),
      ('Family', HomiziRolePalette.tenant),
    ],
  ),
  _RoleOption(
    role: HomiziRole.host,
    title: 'Host',
    benefit: 'Rent out my property',
    icon: Icons.vpn_key_outlined,
    palette: HomiziRolePalette.owner,
    kinds: [
      ('Owner', HomiziRolePalette.owner),
      ('PG owner', HomiziRolePalette.pg),
      ('Company', HomiziRolePalette.company),
    ],
  ),
  _RoleOption(
    role: HomiziRole.broker,
    title: 'Broker',
    benefit: "I'm an agent",
    icon: Icons.badge_outlined,
    palette: HomiziRolePalette.broker,
    kinds: [
      ('Broker', HomiziRolePalette.broker),
      ('Channel partner', HomiziRolePalette.broker),
    ],
  ),
];

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.option, required this.onTap});

  final _RoleOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = option.palette;
    // v3: white card with the role's real photo as a rounded thumb and a
    // role-tinted icon badge; no stripes or patterns.
    return Card(
      key: Key('role-card-${option.role.name}'),
      elevation: 2,
      color: HomiziColors.white,
      shadowColor: HomiziColors.shadowStrong,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 76,
                    height: 76,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.asset(
                              p.photo,
                              fit: BoxFit.cover,
                              excludeFromSemantics: true,
                              errorBuilder: (context, error, stack) =>
                                  ColoredBox(color: p.wash),
                            ),
                          ),
                        ),
                        Positioned(
                          right: -6,
                          bottom: -6,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: p.wash,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: HomiziColors.white,
                                width: 2,
                              ),
                            ),
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: Icon(option.icon, color: p.ink, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          homiziText(context, option.title),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(homiziText(context, option.benefit)),
                        if (option.kinds.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final (label, palette) in option.kinds)
                                HomiziRoleChip(
                                  label: homiziText(context, label),
                                  palette: palette,
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward, color: HomiziColors.muted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _choose(
  BuildContext context,
  WidgetRef ref,
  HomiziRole role,
) async {
  if (role == HomiziRole.broker &&
      ref.read(sessionProvider).phase == SessionPhase.signedOut) {
    if (GoRouter.maybeOf(context) != null) {
      context.go(brokerProfileSignInLocation());
    }
    return;
  }
  final pending = ref.read(flatmateReturnProvider);
  final error = await ref
      .read(sessionProvider.notifier)
      .selectPrimaryRole(homiziRoleWire(role));
  if (!context.mounted) {
    return;
  }
  if (error != null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(homiziText(context, error))));
    return;
  }
  ref.read(flatmateReturnProvider.notifier).clear();
  if (GoRouter.maybeOf(context) == null) {
    return;
  }
  if (role != HomiziRole.host) {
    ref.read(hostIntentProvider.notifier).consumeAuth();
  }
  final pendingProfile = ref.read(tenantIntentProvider) == TenantIntent.profile;
  final next = switch (role) {
    HomiziRole.roommate => pending ?? RoutePaths.sharerSetup,
    HomiziRole.tenant =>
      pendingProfile ? RoutePaths.tenantSetup : RoutePaths.personalize,
    HomiziRole.host => _hostNext(ref),
    HomiziRole.broker => RoutePaths.partnerSetup,
  };
  context.go(next);
}

String _hostNext(WidgetRef ref) {
  final pending = ref.read(hostIntentProvider).afterAuth;
  ref.read(hostIntentProvider.notifier).consumeAuth();
  if (pending != null && !legacyRolePaths.contains(pending.split('?').first)) {
    return pending;
  }
  return readyLocation('host');
}
