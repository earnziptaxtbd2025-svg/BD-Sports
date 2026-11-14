/// Allows at most [maxActions] actions in any [window] of time.
///
/// Use it to stop accidental or abusive repeats, for example "resend code" or
/// posting too fast. This only protects the screen. The server must enforce its own
/// limits, because a modified app can skip this one.
class RateLimiter {
  RateLimiter({
    required this.maxActions,
    required this.window,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final int maxActions;
  final Duration window;
  final DateTime Function() _clock;
  final List<DateTime> _times = <DateTime>[];

  /// Returns true and records the action if allowed, false if the limit is reached.
  bool tryAcquire() {
    _prune();
    if (_times.length >= maxActions) {
      return false;
    }
    _times.add(_clock());
    return true;
  }

  /// How long until the next action is allowed, or null if one is allowed now.
  Duration? retryAfter() {
    _prune();
    if (_times.length < maxActions) {
      return null;
    }
    final wait = _times.first.add(window).difference(_clock());
    return wait.isNegative ? Duration.zero : wait;
  }

  void _prune() {
    final cutoff = _clock().subtract(window);
    _times.removeWhere((time) => !time.isAfter(cutoff));
  }
}
