import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';

/// Answers "can this phone really reach the internet right now?".
abstract interface class InternetProbe {
  Future<bool> check();
}

/// Fetches a URL and returns the HTTP status. Replaceable in tests.
typedef StatusFetcher = Future<int> Function(Uri url, Duration timeout);

Future<int> _httpStatus(Uri url, Duration timeout) async {
  final client = HttpClient()..connectionTimeout = timeout;
  try {
    final request = await client.getUrl(url).timeout(timeout);
    final response = await request.close().timeout(timeout);
    await response.drain<void>();
    return response.statusCode;
  } finally {
    client.close(force: true);
  }
}

/// Online means at least one of the addresses answers with any HTTP response.
///
/// This is more reliable than asking the phone for its network type, which can be
/// wrong (for example with dual SIM, data saver, or Wi-Fi without internet).
class HttpInternetProbe implements InternetProbe {
  HttpInternetProbe({
    required List<Uri> urls,
    StatusFetcher? fetch,
    Duration timeout = const Duration(seconds: 4),
  })  : _urls = urls,
        _fetch = fetch ?? _httpStatus,
        _timeout = timeout;

  final List<Uri> _urls;
  final StatusFetcher _fetch;
  final Duration _timeout;

  @override
  Future<bool> check() async {
    for (final url in _urls) {
      try {
        await _fetch(url, _timeout);
        return true;
      } catch (_) {
        // Try the next address.
      }
    }
    return false;
  }
}

final internetProbeProvider = Provider<InternetProbe>((ref) {
  return HttpInternetProbe(
    urls: <Uri>[
      if (Env.isSupabaseConfigured) Uri.parse(Env.supabaseUrl),
      Uri.parse('https://connectivitycheck.gstatic.com/generate_204'),
      Uri.parse('https://www.cloudflare.com/cdn-cgi/trace'),
    ],
  );
});
