import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homizi/core/l10n/translate.dart';
import 'package:homizi/core/theme/homizi_colors.dart';
import 'package:homizi/core/theme/role_palette.dart';
import 'package:homizi/features/roles/role_flow.dart';
import 'package:homizi/features/roles/role_onboarding_widgets.dart';
import 'package:homizi/features/session/session_controller.dart';
import 'package:homizi/ui/kit/hero_band.dart';
import 'package:homizi/ui/kit/motion_kit.dart';

class _RoleOption {
  const _RoleOption({
    required this.wire,
    required this.title,
    required this.detail,
    required this.icon,
    required this.cardKey,
    required this.palette,
    this.kinds = const [],
  });

  final HomiziRolePalette palette;

  /// Every profile this way in covers, as role chips.
  final List<(String, HomiziRolePalette)> kinds;
  final String wire;
  final String title;
  final String detail;
  final IconData icon;
  final Key cardKey;
}

const _options = <_RoleOption>[
  _RoleOption(
    wire: 'tenant',
    title: 'Tenant / Home-Seeker',
    detail: 'Find a home to rent in your city.',
    icon: Icons.apartment_outlined,
    cardKey: Key('role-card-tenant'),
    palette: HomiziRolePalette.tenant,
    kinds: [
      ('Tenant', HomiziRolePalette.tenant),
      ('Family', HomiziRolePalette.tenant),
      ('Student', HomiziRolePalette.tenant),
    ],
  ),
  _RoleOption(
    wire: 'host',
    title: 'Host / Owner',
    detail: 'List a home and hear from tenants.',
    icon: Icons.vpn_key_outlined,
    cardKey: Key('role-card-host'),
    palette: HomiziRolePalette.owner,
    kinds: [
      ('Owner', HomiziRolePalette.owner),
      ('PG owner', HomiziRolePalette.pg),
      ('Company', HomiziRolePalette.company),
    ],
  ),
  _RoleOption(
    wire: 'broker',
    title: 'Property Partner',
    detail: 'Broker or agent for seekers and owners.',
    icon: Icons.badge_outlined,
    cardKey: Key('role-card-broker'),
    palette: HomiziRolePalette.broker,
    kinds: [
      ('Broker', HomiziRolePalette.broker),
      ('Channel partner', HomiziRolePalette.broker),
    ],
  ),
  _RoleOption(
    wire: 'roommate',
    title: 'Home-Sharer',
    detail: 'You have a room and want a flatmate.',
    icon: Icons.groups_outlined,
    cardKey: Key('role-card-roommate'),
    palette: HomiziRolePalette.sharer,
    kinds: [
      ('Room sharer', HomiziRolePalette.sharer),
      ('Flatmate', HomiziRolePalette.roommate),
    ],
  ),
];

class RoleOnboardingScreen extends ConsumerStatefulWidget {
  const RoleOnboardingScreen({super.key});

  @override
  ConsumerState<RoleOnboardingScreen> createState() =>
      _RoleOnboardingScreenState();
}

class _RoleOnboardingScreenState extends ConsumerState<RoleOnboardingScreen> {
  String? _selected;
  String? _error;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    final session = ref.read(sessionProvider).homiziWire;
    _selected = session;
  }

  Future<void> _continue() async {
    final wire = _selected;
    if (wire == null || _busy) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = await persistChosenRole(ref, wire);
    if (!mounted) {
      return;
    }
    if (error != null) {
      setState(() {
        _busy = false;
        _error = error;
      });
      return;
    }
    setState(() => _busy = false);
    openRoleSetup(context, ref, wire);
  }

  @override
  Widget build(BuildContext context) {
    return RoleFlowScaffold(
      screenKey: const Key('role-onboarding-screen'),
      title: 'How will you use HOMIZI?',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const RoleFlowIntro(
            'Pick one way in. You can change it later from Profile.',
          ),
          const SizedBox(height: 20),
          for (final (index, option) in _options.indexed) ...[
            HomiziStaggerIn(
              index: index,
              child: HomiziPressable(
                child: _RoleCard(
                  option: option,
                  selected: _selected == option.wire,
                  onTap: () => setState(() => _selected = option.wire),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          RoleFlowError(message: _error, errorKey: const Key('role-error')),
          const SizedBox(height: 8),
          RoleFlowContinue(
            buttonKey: const Key('role-continue'),
            label: 'Continue',
            onPressed: _selected == null || _busy
                ? null
                : () => unawaited(_continue()),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _RoleOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = homiziText(context, option.title);
    final detail = homiziText(context, option.detail);
    final p = option.palette;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 200);
    return AnimatedContainer(
      duration: duration,
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: selected
                ? p.accent.withValues(alpha: 0.3)
                : HomiziColors.shadowWarm,
            blurRadius: selected ? 18 : 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: selected ? p.wash : HomiziColors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: selected ? p.accent : p.accent.withValues(alpha: 0.35),
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          key: option.cardKey,
          onTap: onTap,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    HomiziRoleIcon(option.icon, palette: p, size: 52),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: HomiziColors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            detail,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              height: 1.35,
                              color: HomiziColors.inkSoft,
                            ),
                          ),
                          if (option.kinds.isNotEmpty) ...[
                            const SizedBox(height: 8),
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
                    Icon(
                      selected ? Icons.check_circle : Icons.circle_outlined,
                      color: selected ? p.ink : HomiziColors.muted,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
