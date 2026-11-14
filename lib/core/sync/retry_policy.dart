/// How long to wait before the next attempt: 5s, 10s, 20s, ... capped at 5 minutes.
Duration retryDelay(int attempts) {
  var exponent = attempts - 1;
  if (exponent < 0) {
    exponent = 0;
  }
  if (exponent > 6) {
    exponent = 6;
  }
  final seconds = 5 * (1 << exponent);
  return Duration(seconds: seconds > 300 ? 300 : seconds);
}
