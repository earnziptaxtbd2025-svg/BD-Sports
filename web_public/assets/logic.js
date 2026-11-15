/* Pure helpers for the public pages. No DOM here, so they can be tested with Node. */
(function (root, factory) {
  if (typeof module === 'object' && module.exports) {
    module.exports = factory();
  } else {
    root.BDLogic = factory();
  }
})(typeof self !== 'undefined' ? self : this, function () {
  'use strict';

  // Same rule as ShortId in the app: 8 readable characters, no 0/o/1/l/i.
  var ID_PATTERN = /^[2-9a-hj-km-np-z]{8}$/;

  function isValidId(id) {
    return typeof id === 'string' && ID_PATTERN.test(id);
  }

  /**
   * Reads the tournament id from /t/{id} or /t/{id}/{readable-ending}.
   * Returns null for anything else. The id "demo" is accepted only when allowDemo
   * is true (sample page).
   */
  function parseTournamentPath(pathname, allowDemo) {
    if (typeof pathname !== 'string') return null;
    var parts = pathname.split('/').filter(function (p) { return p.length > 0; });
    if (parts.length < 2 || parts.length > 3 || parts[0] !== 't') return null;
    var id = parts[1];
    if (isValidId(id)) return id;
    if (allowDemo && id === 'demo') return id;
    return null;
  }

  /** Only normal https links, without a hidden user name. Otherwise null. */
  function safeHttpsUrl(value) {
    if (typeof value !== 'string' || value.length === 0 || value.length > 2048) return null;
    var url;
    try {
      url = new URL(value);
    } catch (e) {
      return null;
    }
    if (url.protocol !== 'https:' || url.username || url.password || !url.hostname) return null;
    return url.href;
  }

  function isCount(n) {
    return typeof n === 'number' && isFinite(n) && n >= 0 && Math.floor(n) === n;
  }

  /**
   * Football points table. A win is 3 points, a draw is 1.
   * Order: points, goal difference, goals scored, then name.
   * Only finished matches between known teams are counted.
   */
  function computeStandings(teams, matches) {
    var rows = {};
    (teams || []).forEach(function (team) {
      rows[team.id] = {
        teamId: team.id, name: team.name,
        played: 0, won: 0, drawn: 0, lost: 0, gf: 0, ga: 0, gd: 0, points: 0
      };
    });

    (matches || []).forEach(function (m) {
      if (!m || m.status !== 'finished') return;
      if (!isCount(m.homeGoals) || !isCount(m.awayGoals)) return;
      var home = rows[m.homeId];
      var away = rows[m.awayId];
      if (!home || !away || home === away) return;

      home.played++; away.played++;
      home.gf += m.homeGoals; home.ga += m.awayGoals;
      away.gf += m.awayGoals; away.ga += m.homeGoals;

      if (m.homeGoals > m.awayGoals) {
        home.won++; away.lost++; home.points += 3;
      } else if (m.homeGoals < m.awayGoals) {
        away.won++; home.lost++; away.points += 3;
      } else {
        home.drawn++; away.drawn++; home.points += 1; away.points += 1;
      }
    });

    var list = Object.keys(rows).map(function (key) {
      var r = rows[key];
      r.gd = r.gf - r.ga;
      return r;
    });

    list.sort(function (a, b) {
      return (b.points - a.points) ||
             (b.gd - a.gd) ||
             (b.gf - a.gf) ||
             String(a.name).localeCompare(String(b.name));
    });
    return list;
  }

  var TOURNAMENT_STATUS = {
    upcoming: 'শুরু হয়নি',
    registration: 'রেজিস্ট্রেশন চলছে',
    ongoing: 'চলছে',
    completed: 'শেষ হয়েছে',
    cancelled: 'বাতিল'
  };

  var MATCH_STATUS = {
    scheduled: 'নির্ধারিত',
    live: 'লাইভ',
    finished: 'শেষ',
    postponed: 'স্থগিত',
    walkover: 'ওয়াকওভার'
  };

  function tournamentStatusLabel(status) {
    return TOURNAMENT_STATUS[status] || '';
  }

  function matchStatusLabel(status) {
    return MATCH_STATUS[status] || '';
  }

  return {
    isValidId: isValidId,
    parseTournamentPath: parseTournamentPath,
    safeHttpsUrl: safeHttpsUrl,
    computeStandings: computeStandings,
    tournamentStatusLabel: tournamentStatusLabel,
    matchStatusLabel: matchStatusLabel
  };
});
