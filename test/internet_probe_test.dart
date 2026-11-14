import 'package:bd_sports/core/network/internet_probe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final urls = <Uri>[
    Uri.parse('https://a.example'),
    Uri.parse('https://b.example'),
  ];

  test('online when any address answers, even with an error status', () async {
    final probe = HttpInternetProbe(
      urls: urls,
      fetch: (url, timeout) async => 404,
    );
    expect(await probe.check(), isTrue);
  });

  test('falls back to the next address when the first fails', () async {
    final tried = <String>[];
    final probe = HttpInternetProbe(
      urls: urls,
      fetch: (url, timeout) async {
        tried.add(url.host);
        if (url.host == 'a.example') {
          throw Exception('unreachable');
        }
        return 204;
      },
    );
    expect(await probe.check(), isTrue);
    expect(tried, ['a.example', 'b.example']);
  });

  test('offline when every address fails', () async {
    final probe = HttpInternetProbe(
      urls: urls,
      fetch: (url, timeout) async => throw Exception('unreachable'),
    );
    expect(await probe.check(), isFalse);
  });
}
