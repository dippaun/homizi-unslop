import 'package:flutter/material.dart';
import 'package:homizi/core/brand/indian_patterns.dart';
import 'package:homizi/core/theme/role_palette.dart';
import 'package:homizi/core/widgets/homizi_tab_header.dart';

/// Wordmark shared by every role home.
class HomiziLockup extends StatelessWidget {
  const HomiziLockup({super.key});

  @override
  Widget build(BuildContext context) => const HomiziWordmark();
}

/// Same app-bar height and spacing on each role home.
///
/// The wordmark stays centred. The notification bell sits on the right.
class HomiziHomeBar extends StatelessWidget implements PreferredSizeWidget {
  const HomiziHomeBar({
    this.leading,
    this.actions = const [],
    this.title,
    super.key,
  });

  final Widget? leading;
  final List<Widget> actions;
  final Widget? title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    // v2: the bar takes the role's wash with a block-print edge, so each
    // role home reads as its own space. The wordmark stays ink.
    final palette = HomiziRoleScope.of(context);
    return Material(
      color: palette.wash,
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            HomiziTabHeader(leading: leading, actions: actions, title: title),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BlockPrintBorder(
                color: palette.ink,
                height: 6,
                opacity: 0.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
