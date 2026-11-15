import 'package:bd_sports/core/public_links/public_links.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const id = 'abcd2345';
  const links = PublicLinks('https://sports.example.com');
  const notSet = PublicLinks('');

  group('building', () {
    test('tournament link with and without a readable ending', () {
      expect(
        links.tournament(id, title: 'Pirgachha Premier 2026'),
        'https://sports.example.com/t/abcd2345/pirgachha-premier-2026',
      );
      expect(links.tournament(id), 'https://sports.example.com/t/abcd2345');
      expect(
        links.tournament(id, title: 'পীরগাছা'),
        'https://sports.example.com/t/abcd2345',
      );
    });

    test('match and team links', () {
      expect(links.match(id), 'https://sports.example.com/m/abcd2345');
      expect(links.team(id), 'https://sports.example.com/team/abcd2345');
    });

    test('a trailing slash on the base address is fine', () {
      expect(
        const PublicLinks('https://sports.example.com/').match(id),
        'https://sports.example.com/m/abcd2345',
      );
    });

    test('no full link until the web address is set', () {
      expect(notSet.isConfigured, isFalse);
      expect(notSet.tournament(id), isNull);
      expect(PublicLinks.tournamentPath(id), '/t/abcd2345');
    });
  });

  group('reading', () {
    test('reads full links and plain paths', () {
      expect(links.parseText('https://sports.example.com/t/abcd2345'),
          isA<TournamentLink>());
      expect(links.parseText('https://sports.example.com/t/abcd2345/some-name'),
          isA<TournamentLink>());
      expect(links.parseText('/m/abcd2345'), isA<MatchLink>());
      expect(links.parseText('/team/abcd2345'), isA<TeamLink>());
      expect(links.parseText('  /m/abcd2345  ')!.id, id);
    });

    test('rejects links to another website', () {
      expect(links.parseText('https://evil.example.org/t/abcd2345'), isNull);
    });

    test('rejects plain http and other schemes', () {
      expect(links.parseText('http://sports.example.com/t/abcd2345'), isNull);
      expect(links.parseText('javascript:alert(1)'), isNull);
      expect(links.parseText('file:///t/abcd2345'), isNull);
    });

    test('rejects hidden user names', () {
      expect(
        links.parseText('https://sports.example.com@evil.com/t/abcd2345'),
        isNull,
      );
    });

    test('rejects wrong ids and unknown or too-long paths', () {
      expect(links.parseText('/t/123'), isNull);
      expect(links.parseText('/t/ABCD2345'), isNull);
      expect(links.parseText('/x/abcd2345'), isNull);
      expect(links.parseText('/m/abcd2345/extra'), isNull);
      expect(links.parseText('/t/abcd2345/a/b/c'), isNull);
      expect(links.parseText('/t'), isNull);
      expect(links.parseText(''), isNull);
    });

    test('path for an in-app link', () {
      expect(PublicLinks.pathFor(const TournamentLink(id)), '/t/abcd2345');
      expect(PublicLinks.pathFor(const MatchLink(id)), '/m/abcd2345');
      expect(PublicLinks.pathFor(const TeamLink(id)), '/team/abcd2345');
    });
  });
}
