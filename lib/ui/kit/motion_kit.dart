import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Press feedback for any tappable surface: a 0.97 scale while the finger
/// is down and a light haptic on release. It listens to raw pointers, so
/// the child keeps its own tap handling. Reduced motion skips the scale.
class HomiziPressable extends StatefulWidget {
  const HomiziPressable({required this.child, this.haptic = true, super.key});

  final Widget child;
  final bool haptic;

  @override
  State<HomiziPressable> createState() => _HomiziPressableState();
}

class _HomiziPressableState extends State<HomiziPressable> {
  var _down = false;

  void _set(bool down) {
    if (_down != down && mounted) {
      setState(() => _down = down);
    }
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) {
        _set(false);
        if (widget.haptic) {
          HapticFeedback.lightImpact();
        }
      },
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down && !still ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// One short fade-and-rise entrance. [index] staggers siblings by 50 ms,
/// capped at six. Reduced motion shows the child at once.
class HomiziStaggerIn extends StatefulWidget {
  const HomiziStaggerIn({required this.child, this.index = 0, super.key});

  final Widget child;
  final int index;

  @override
  State<HomiziStaggerIn> createState() => _HomiziStaggerInState();
}

class _HomiziStaggerInState extends State<HomiziStaggerIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    final slot = widget.index.clamp(0, 6);
    final delay = slot * 50;
    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 360 + delay),
    );
    _t = CurvedAnimation(
      parent: _c,
      curve: Interval(
        delay / (360 + delay),
        1,
        curve: const Cubic(0.22, 1, 0.36, 1),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (still) {
      _c.value = 1;
    } else if (_c.value == 0 && !_c.isAnimating) {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) {
        final v = _t.value;
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, (1 - v) * 10),
            child: child,
          ),
        );
      },
    );
  }
}
