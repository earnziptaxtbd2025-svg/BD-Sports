// Run with: node web_public/test/logic.test.js
const assert = require('assert');
const fs = require('fs');
const path = require('path');
const L = require('../assets/logic.js');

let passed = 0;
function test(name, fn) {
  try { fn(); passed++; console.log('ok   ' + name); }
  catch (e) { console.error('FAIL ' + name + '\n' + e.stack); process.exitCode = 1; }
}

test('ids: readable 8 characters only', () => {
  assert.strictEqual(L.isValidId('abcd2345'), true);
  ['abc', 'ABCD2345', 'abcd234o', 'abcd23<5', '', null, undefined, 12345678].forEach((v) =>
    assert.strictEqual(L.isValidId(v), false, String(v)));
});

test('path: reads tournament id with or without ending', () => {
  assert.strictEqual(L.parseTournamentPath('/t/abcd2345'), 'abcd2345');
  assert.strictEqual(L.parseTournamentPath('/t/abcd2345/pirgachha-premier'), 'abcd2345');
  assert.strictEqual(L.parseTournamentPath('/t/abcd2345/'), 'abcd2345');
});

test('path: rejects wrong paths', () => {
  ['/t', '/t/', '/x/abcd2345', '/t/abcd2345/a/b', '/t/123', '/t/ABCD2345', '/m/abcd2345', ''].forEach((p) =>
    assert.strictEqual(L.parseTournamentPath(p), null, p));
  assert.strictEqual(L.parseTournamentPath(undefined), null);
});

test('path: demo id only when allowed', () => {
  assert.strictEqual(L.parseTournamentPath('/t/demo'), null);
  assert.strictEqual(L.parseTournamentPath('/t/demo', true), 'demo');
});

test('links: only plain https', () => {
  assert.strictEqual(L.safeHttpsUrl('https://facebook.com/page'), 'https://facebook.com/page');
  ['http://x.com', 'javascript:alert(1)', 'https://good.com@evil.com', 'data:text/html,x', 'not a url', '', null]
    .forEach((v) => assert.strictEqual(L.safeHttpsUrl(v), null, String(v)));
});

test('standings: sample tournament', () => {
  const data = JSON.parse(fs.readFileSync(path.join(__dirname, '../sample-data/demo.json'), 'utf8'));
  const rows = L.computeStandings(data.teams, data.matches);
  assert.deepStrictEqual(rows.map((r) => r.teamId), ['c', 'a', 'd', 'b']);
  assert.deepStrictEqual(rows.map((r) => r.points), [4, 3, 2, 1]);
  const c = rows[0];
  assert.strictEqual(c.played, 2); assert.strictEqual(c.won, 1); assert.strictEqual(c.drawn, 1);
  assert.strictEqual(c.gf, 3); assert.strictEqual(c.ga, 1); assert.strictEqual(c.gd, 2);
});

test('standings: goal difference, then goals scored, then name break ties', () => {
  const teams = [{ id: 'x', name: 'B team' }, { id: 'y', name: 'A team' }, { id: 'z', name: 'C team' }];
  const matches = [
    { homeId: 'x', awayId: 'z', status: 'finished', homeGoals: 2, awayGoals: 0 },
    { homeId: 'y', awayId: 'z', status: 'finished', homeGoals: 2, awayGoals: 0 },
  ];
  const rows = L.computeStandings(teams, matches);
  // x and y are level on points, goal difference and goals scored: name decides.
  assert.deepStrictEqual(rows.map((r) => r.teamId), ['y', 'x', 'z']);
});

test('standings: ignores unfinished, broken and unknown matches', () => {
  const teams = [{ id: 'a', name: 'A' }, { id: 'b', name: 'B' }];
  const matches = [
    { homeId: 'a', awayId: 'b', status: 'scheduled', homeGoals: 5, awayGoals: 0 },
    { homeId: 'a', awayId: 'b', status: 'finished', homeGoals: -1, awayGoals: 0 },
    { homeId: 'a', awayId: 'b', status: 'finished', homeGoals: 1.5, awayGoals: 0 },
    { homeId: 'a', awayId: 'zzz', status: 'finished', homeGoals: 1, awayGoals: 0 },
    { homeId: 'a', awayId: 'a', status: 'finished', homeGoals: 1, awayGoals: 0 },
    null,
  ];
  const rows = L.computeStandings(teams, matches);
  rows.forEach((r) => { assert.strictEqual(r.played, 0); assert.strictEqual(r.points, 0); });
});

test('standings: handles no teams or no matches', () => {
  assert.deepStrictEqual(L.computeStandings([], []), []);
  assert.deepStrictEqual(L.computeStandings(undefined, undefined), []);
});

test('status labels', () => {
  assert.strictEqual(L.tournamentStatusLabel('ongoing'), 'চলছে');
  assert.strictEqual(L.matchStatusLabel('live'), 'লাইভ');
  assert.strictEqual(L.tournamentStatusLabel('hacked'), '');
});

test('sample data has no private fields', () => {
  const raw = fs.readFileSync(path.join(__dirname, '../sample-data/demo.json'), 'utf8');
  ['phone', 'email', 'birth', 'address', 'nid'].forEach((word) =>
    assert.strictEqual(raw.toLowerCase().includes(word), false, word));
});

console.log(passed + ' passed' + (process.exitCode ? ', some FAILED' : ''));
