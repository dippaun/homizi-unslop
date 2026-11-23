import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homizi/core/l10n/translate.dart';
import 'package:homizi/core/routing/route_paths.dart';
import 'package:homizi/core/theme/homizi_colors.dart';
import 'package:homizi/core/theme/role_palette.dart';
import 'package:homizi/core/widgets/homizi_home_bar.dart';
import 'package:homizi/features/owner/owner_gateway.dart';
import 'package:homizi/features/owner/owner_models.dart';
import 'package:homizi/features/owner/owner_providers.dart';
import 'package:homizi/features/owner/owner_rules.dart';
import 'package:homizi/features/trust/trust_badge_section.dart';
import 'package:homizi/ui/kit/hero_band.dart';
import 'package:homizi/ui/kit/motion_kit.dart';

/// Stats, leads, and visits. The listing list stays on My listings.
class OwnerOverviewScreen extends ConsumerStatefulWidget {
  const OwnerOverviewScreen({super.key});

  @override
  ConsumerState<OwnerOverviewScreen> createState() =>
      _OwnerOverviewScreenState();
}

class _OwnerOverviewScreenState extends ConsumerState<OwnerOverviewScreen> {
  var _loading = true;
  String? _error;
  var _views = 0;
  var _saves = 0;
  var _interests = 0;
  var _visits = 0;
  var _live = 0;
  List<OwnerLead> _leads = const [];

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load({bool quiet = false}) async {
    setState(() {
      _loading = !quiet;
      _error = null;
    });
    try {
      final gateway = ref.read(ownerGatewayProvider);
      final listings = await gateway.myListings();
      final leads = <OwnerLead>[];
      for (final listing in listings) {
        try {
          leads.addAll(await gateway.leads(listing.id));
        } on OwnerFailure {
          // A home with no lead row still counts in the totals.
        }
      }
      leads.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (!mounted) {
        return;
      }
      setState(() {
        _views = listings.fold(0, (sum, row) => sum + row.views);
        _saves = listings.fold(0, (sum, row) => sum + row.saves);
        _interests = listings.fold(0, (sum, row) => sum + row.interests);
        _visits = listings.fold(0, (sum, row) => sum + row.visitRequests);
        _live = listings.where((row) => row.chip == 'live').length;
        _leads = leads;
        _loading = false;
      });
    } on OwnerFailure catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final visits = [
      for (final lead in _leads)
        if (lead.kind == 'visit') lead,
    ];
    return Scaffold(
      key: const Key('owner-overview'),
      backgroundColor: HomiziColors.cream,
      appBar: HomiziHomeBar(title: Text(homiziText(context, 'Owner'))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: HomiziColors.brandRedOrange,
              backgroundColor: HomiziColors.white,
              onRefresh: () => _load(quiet: true),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  HomiziStaggerIn(
                    child: HomiziHeroBand(
                      palette: HomiziRolePalette.owner,
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 48),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            homiziText(
                              context,
                              'Owner dashboard',
                            ).toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              letterSpacing: 1.6,
                              fontWeight: FontWeight.w700,
                              color: HomiziColors.haldiWash,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            homiziText(
                              context,
                              _live == 1 ? '1 live home' : '$_live live homes',
                            ),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: HomiziColors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            key: const Key('owner-overview-stats'),
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _Stat(label: '$_views views'),
                              _Stat(label: '$_saves saves'),
                              _Stat(label: '$_interests interests'),
                              _Stat(label: '$_visits visit requests'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const TrustBadgeSection(),
                  const SizedBox(height: 20),
                  Text(
                    homiziText(context, 'Leads'),
                    key: const Key('owner-overview-leads'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (_error != null)
                    Text(homiziText(context, _error!))
                  else if (_leads.isEmpty)
                    Text(homiziText(context, 'No leads yet.'))
                  else
                    for (final lead in _leads.take(5))
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: HomiziColors.terracottaWash,
                            foregroundColor: HomiziColors.brandDeepRed,
                            child: Text(
                              lead.displayName.trim().isEmpty
                                  ? '?'
                                  : lead.displayName.trim()[0].toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: HomiziColors.muted,
                          ),
                          title: Text(homiziText(context, lead.displayName)),
                          subtitle: Text(
                            homiziText(
                              context,
                              '${ownerLeadKindLabel(lead.kind)} · ${ownerLeadStatusLabel(lead.status)}',
                            ),
                          ),
                        ),
                      ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => context.push(RoutePaths.hostLeads),
                    child: Text(homiziText(context, 'Open lead inbox')),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    homiziText(context, 'Visits'),
                    key: const Key('owner-overview-visits'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (visits.isEmpty)
                    Text(homiziText(context, 'No visit requests yet.'))
                  else
                    for (final lead in visits.take(5))
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const HomiziRoleIcon(
                            Icons.event_outlined,
                            palette: HomiziRolePalette.owner,
                            size: 40,
                          ),
                          title: Text(homiziText(context, lead.displayName)),
                          subtitle: Text(
                            homiziText(
                              context,
                              ownerLeadStatusLabel(lead.status),
                            ),
                          ),
                        ),
                      ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => context.push(RoutePaths.hostVisits),
                    child: Text(homiziText(context, 'Open visits')),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.go(RoutePaths.listings),
                    child: Text(homiziText(context, 'My listings')),
                  ),
                ],
              ),
            ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    // Glass chip on the owner hero: white type on red orange to dark red
    // clears 5.2:1.
    return DecoratedBox(
      decoration: BoxDecoration(
        color: HomiziColors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: HomiziColors.white.withValues(alpha: 0.45)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          homiziText(context, label),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: HomiziColors.white,
          ),
        ),
      ),
    );
  }
}
