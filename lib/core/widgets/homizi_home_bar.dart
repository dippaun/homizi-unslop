import 'package:flutter/material.dart';
import 'package:homizi/core/theme/homizi_colors.dart';
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
    this.color = HomiziColors.cream,
    super.key,
  });

  /// Bar fill. The v4 home passes a clear colour over its live backdrop.
  final Color color;

  final Widget? leading;
  final List<Widget> actions;
  final Widget? title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    // v3: a quiet stone bar on every role home; the role shows in the
    // hero below, not in the chrome.
    return Material(
      color: color,
      child: SafeArea(
        bottom: false,
        child: HomiziTabHeader(
          leading: leading,
          actions: actions,
          title: title,
        ),
      ),
    );
  }
}
