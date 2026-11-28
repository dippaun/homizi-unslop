import 'package:flutter/material.dart';
import 'package:homizi/core/motion/homizi_motion.dart';
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
    this.scrollController,
    super.key,
  });

  /// When set, the bar turns to frosted glass as this list scrolls under it.
  /// The page should use `extendBodyBehindAppBar` so content passes beneath.
  final ScrollController? scrollController;

  final Widget? leading;
  final List<Widget> actions;
  final Widget? title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final controller = scrollController;
    final header = SafeArea(
      bottom: false,
      child: HomiziTabHeader(leading: leading, actions: actions, title: title),
    );
    if (controller == null) {
      return Material(color: HomiziColors.white, child: header);
    }
    return HomiziGlass(
      controller: controller,
      child: Material(type: MaterialType.transparency, child: header),
    );
  }
}
