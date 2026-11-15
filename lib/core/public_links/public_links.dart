import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';
import 'short_id.dart';

/// What a shared link points to.
sealed class PublicLink {
  const PublicLink(this.id);

  final String id;
}

final class TournamentLink extends PublicLink {
  const TournamentLink(super.id);
}

final class MatchLink extends PublicLink {
  const MatchLink(super.id);
}

final class TeamLink extends PublicLink {
  const TeamLink(super.id);
}

/// Builds and reads the shareable links. The same address works in a browser (the
/// public web page) and in the app (opens the matching screen).
///
/// Link map:
///   /t/{id}[/{slug}]   tournament
///   /m/{id}            match
///   /team/{id}         team
class PublicLinks {
  const PublicLinks(this.baseUrl);

  /// For example `https://sports.example.com`. Empty when not set yet.
  final String baseUrl;

  bool get isConfigured => Uri.tryParse(baseUrl)?.host.isNotEmpty ?? false;

  static String tournamentPath(String id, {String? title}) {
    final slug = title == null ? null : ShortId.slugify(title);
    return slug == null ? '/t/$id' : '/t/$id/$slug';
  }

  static String matchPath(String id) => '/m/$id';

  static String teamPath(String id) => '/team/$id';

  /// Full web address for a path, or null when the base address is not set.
  String? absolute(String path) {
    if (!isConfigured) {
      return null;
    }
    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return '$base$path';
  }

  String? tournament(String id, {String? title}) =>
      absolute(tournamentPath(id, title: title));

  String? match(String id) => absolute(matchPath(id));

  String? team(String id) => absolute(teamPath(id));

  /// Reads a link. Returns null for anything that is not one of ours, including
  /// wrong ids, extra path parts, and links to another website.
  PublicLink? parse(Uri uri) {
    if (uri.hasScheme) {
      if (uri.scheme != 'https') {
        return null;
      }
      if (isConfigured && uri.host != Uri.parse(baseUrl).host) {
        return null;
      }
    }

    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.length < 2 || !ShortId.isValid(segments[1])) {
      return null;
    }
    final id = segments[1];

    switch (segments[0]) {
      case 't':
        return segments.length <= 3 ? TournamentLink(id) : null;
      case 'm':
        return segments.length == 2 ? MatchLink(id) : null;
      case 'team':
        return segments.length == 2 ? TeamLink(id) : null;
    }
    return null;
  }

  /// Reads a link from pasted text. Accepts a full https link or a path such as
  /// `/t/k7m2xq9d`.
  PublicLink? parseText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed.length > 2048) {
      return null;
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null || uri.userInfo.isNotEmpty) {
      return null;
    }
    return parse(uri);
  }

  /// The in-app path for a parsed link.
  static String pathFor(PublicLink link) {
    return switch (link) {
      TournamentLink() => tournamentPath(link.id),
      MatchLink() => matchPath(link.id),
      TeamLink() => teamPath(link.id),
    };
  }
}

final publicLinksProvider = Provider<PublicLinks>(
  (ref) => const PublicLinks(Env.publicBaseUrl),
);
