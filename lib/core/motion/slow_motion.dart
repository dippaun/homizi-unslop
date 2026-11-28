import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Preview-only review aid: `?slowmo=4` before the `#` slows every
/// animation by that factor (1 to 10) so motion can be studied or recorded
/// frame by frame. Ignored off the web and for any other value.
void applySlowMotionFromUrl() {
  if (!kIsWeb) {
    return;
  }
  final factor = slowMotionFactor(Uri.base.queryParameters['slowmo']);
  if (factor != null) {
    timeDilation = factor;
  }
}

/// Parsed `slowmo` value, or null when it is missing or out of range.
double? slowMotionFactor(String? raw) {
  final value = double.tryParse(raw ?? '');
  if (value == null || value < 1 || value > 10) {
    return null;
  }
  return value;
}
