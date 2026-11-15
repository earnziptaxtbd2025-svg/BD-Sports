/* Public tournament page. Builds the page with textContent only, never innerHTML,
   so text from the server can never run as code. */
(function () {
  'use strict';

  var L = window.BDLogic;
  var root = document.getElementById('app');

  var STR = {
    loading: 'লোড হচ্ছে…',
    invalid: 'এই লিংকটি সঠিক নয়।',
    notFound: 'এই টুর্নামেন্টটি পাওয়া যায়নি।',
    notReady: 'এই পেজ এখনো চালু হয়নি।',
    error: 'তথ্য আনা যায়নি। ইন্টারনেট দেখে আবার চেষ্টা করুন।',
    retry: 'আবার চেষ্টা করুন',
    tabs: { overview: 'বিবরণ', fixtures: 'খেলা', table: 'পয়েন্ট টেবিল', teams: 'দল' },
    place: 'স্থান', ground: 'মাঠ', dates: 'তারিখ', organizer: 'আয়োজক',
    champion: 'চ্যাম্পিয়ন', runnerUp: 'রানার্স-আপ', verified: 'যাচাই করা আয়োজক',
    noMatches: 'এখনো কোনো খেলার সময়সূচি নেই।',
    noTeams: 'এখনো কোনো দল নেই।',
    cols: ['দল', 'খেলা', 'জয়', 'ড্র', 'হার', 'গোল', 'পার্থক্য', 'পয়েন্ট'],
    taka: 'টাকা',
    sports: { football: 'ফুটবল', cricket: 'ক্রিকেট' },
    getApp: 'অ্যাপে দেখুন'
  };

  function el(tag, className, text) {
    var node = document.createElement(tag);
    if (className) node.className = className;
    if (text !== undefined && text !== null) node.textContent = String(text);
    return node;
  }

  function clear(node) {
    while (node.firstChild) node.removeChild(node.firstChild);
  }

  function num(n) {
    try { return new Intl.NumberFormat('bn-BD').format(n); } catch (e) { return String(n); }
  }

  function date(iso) {
    try {
      return new Date(iso).toLocaleDateString('bn-BD', {
        day: 'numeric', month: 'long', year: 'numeric', timeZone: 'Asia/Dhaka'
      });
    } catch (e) { return ''; }
  }

  function dateTime(iso) {
    try {
      var d = new Date(iso);
      return d.toLocaleDateString('bn-BD', { day: 'numeric', month: 'short', timeZone: 'Asia/Dhaka' }) +
        ', ' + d.toLocaleTimeString('bn-BD', { hour: 'numeric', minute: '2-digit', timeZone: 'Asia/Dhaka' });
    } catch (e) { return ''; }
  }

  function showState(message, withRetry) {
    clear(root);
    var box = el('div', 'state');
    box.appendChild(el('p', null, message));
    if (withRetry) {
      var button = el('button', 'btn', STR.retry);
      button.type = 'button';
      button.addEventListener('click', function () { start(); });
      box.appendChild(button);
    }
    root.appendChild(box);
  }

  function metaContent(name) {
    var node = document.querySelector('meta[name="' + name + '"]');
    return node ? (node.getAttribute('content') || '') : '';
  }

  function dataUrl(id) {
    if (id === 'demo') return '/sample-data/demo.json';
    var base = metaContent('api-base');
    if (!base) return null;
    return base.replace(/\/$/, '') + '/public/tournaments/' + encodeURIComponent(id);
  }

  function fact(list, label, value) {
    if (!value) return;
    list.appendChild(el('dt', null, label));
    var dd = el('dd', null);
    if (typeof value === 'string') dd.textContent = value; else dd.appendChild(value);
    list.appendChild(dd);
  }

  function renderOverview(data) {
    var t = data.tournament;
    var section = el('section', 'panel');
    var list = el('dl', 'facts');

    var loc = t.location || {};
    fact(list, STR.place, [loc.village, loc.upazila, loc.district, loc.division]
      .filter(Boolean).join(', '));
    fact(list, STR.ground, loc.ground);
    if (t.startDate) {
      var range = date(t.startDate) + (t.endDate ? ' – ' + date(t.endDate) : '');
      fact(list, STR.dates, range);
    }

    if (t.organizer && t.organizer.name) {
      var org = el('span', null, t.organizer.name);
      var link = L.safeHttpsUrl(t.organizer.pageUrl);
      if (link) {
        var a = el('a', null, t.organizer.name);
        a.href = link;
        a.rel = 'noopener noreferrer nofollow';
        org = a;
      }
      fact(list, STR.organizer, org);
    }

    var prize = t.prize || {};
    if (typeof prize.champion === 'number') fact(list, STR.champion, num(prize.champion) + ' ' + STR.taka);
    if (typeof prize.runnerUp === 'number') fact(list, STR.runnerUp, num(prize.runnerUp) + ' ' + STR.taka);

    section.appendChild(list);
    if (t.description) section.appendChild(el('p', 'desc', t.description));
    return section;
  }

  function teamName(teams, id) {
    for (var i = 0; i < teams.length; i++) if (teams[i].id === id) return teams[i].name;
    return '';
  }

  function renderFixtures(data) {
    var section = el('section', 'panel');
    var matches = Array.isArray(data.matches) ? data.matches : [];
    if (matches.length === 0) {
      section.appendChild(el('p', 'muted', STR.noMatches));
      return section;
    }
    matches.forEach(function (m) {
      var card = el('div', 'match');
      var teamsRow = el('div', 'match-teams');
      teamsRow.appendChild(el('span', 'team', teamName(data.teams, m.homeId)));

      var hasScore = (m.status === 'finished' || m.status === 'live') &&
        typeof m.homeGoals === 'number' && typeof m.awayGoals === 'number';
      teamsRow.appendChild(el('span', 'score', hasScore ? num(m.homeGoals) + ' – ' + num(m.awayGoals) : 'vs'));
      teamsRow.appendChild(el('span', 'team right', teamName(data.teams, m.awayId)));
      card.appendChild(teamsRow);

      var meta = el('div', 'match-meta');
      var chip = el('span', 'chip chip-' + (m.status === 'live' ? 'live' : m.status === 'finished' ? 'done' : 'soon'),
        L.matchStatusLabel(m.status));
      meta.appendChild(chip);
      if (m.kickoff) meta.appendChild(el('span', null, dateTime(m.kickoff)));
      if (m.ground) meta.appendChild(el('span', null, m.ground));
      card.appendChild(meta);
      section.appendChild(card);
    });
    return section;
  }

  function renderTable(data) {
    var section = el('section', 'panel');
    var rows = L.computeStandings(data.teams, data.matches);
    if (rows.length === 0) {
      section.appendChild(el('p', 'muted', STR.noTeams));
      return section;
    }
    var wrap = el('div', 'scroll');
    var table = el('table', 'table');
    var head = el('tr');
    STR.cols.forEach(function (c, i) {
      var th = el('th', i === 0 ? 'left' : null, c);
      th.scope = 'col';
      head.appendChild(th);
    });
    var thead = el('thead'); thead.appendChild(head); table.appendChild(thead);

    var tbody = el('tbody');
    rows.forEach(function (r, i) {
      var tr = el('tr');
      var name = el('td', 'left', (i + 1) + '. ' + r.name);
      tr.appendChild(name);
      [r.played, r.won, r.drawn, r.lost, r.gf + ':' + r.ga, r.gd, r.points].forEach(function (v, j) {
        var shown = typeof v === 'number' ? num(v) : v;
        tr.appendChild(el('td', j === 6 ? 'pts' : null, shown));
      });
      tbody.appendChild(tr);
    });
    table.appendChild(tbody);
    wrap.appendChild(table);
    section.appendChild(wrap);
    return section;
  }

  function renderTeams(data) {
    var section = el('section', 'panel');
    if (!data.teams.length) {
      section.appendChild(el('p', 'muted', STR.noTeams));
      return section;
    }
    var list = el('ul', 'teams');
    data.teams.forEach(function (team) { list.appendChild(el('li', null, team.name)); });
    section.appendChild(list);
    return section;
  }

  function render(data) {
    var t = data && data.tournament;
    if (!t || typeof t.title !== 'string' || !Array.isArray(data.teams)) {
      showState(STR.error, true);
      return;
    }
    if (!Array.isArray(data.matches)) data.matches = [];

    document.title = t.title + ' | BD Sports';
    clear(root);

    var hero = el('div', 'hero');
    hero.appendChild(el('h1', null, t.title));
    var chips = el('div', 'chips');
    if (STR.sports[t.sport]) chips.appendChild(el('span', 'chip', STR.sports[t.sport]));
    var statusText = L.tournamentStatusLabel(t.status);
    if (statusText) chips.appendChild(el('span', 'chip chip-' + (t.status === 'ongoing' ? 'live' : 'soon'), statusText));
    if (t.organizer && t.organizer.verified) chips.appendChild(el('span', 'chip chip-ok', STR.verified));
    hero.appendChild(chips);
    root.appendChild(hero);

    var tabs = el('div', 'tabs');
    tabs.setAttribute('role', 'tablist');
    var panels = {
      overview: renderOverview(data),
      fixtures: renderFixtures(data),
      table: renderTable(data),
      teams: renderTeams(data)
    };
    var buttons = {};

    function select(key) {
      Object.keys(panels).forEach(function (k) {
        panels[k].hidden = k !== key;
        buttons[k].setAttribute('aria-selected', k === key ? 'true' : 'false');
        buttons[k].className = 'tab' + (k === key ? ' active' : '');
      });
    }

    Object.keys(panels).forEach(function (key) {
      var b = el('button', 'tab', STR.tabs[key]);
      b.type = 'button';
      b.setAttribute('role', 'tab');
      b.addEventListener('click', function () { select(key); });
      buttons[key] = b;
      tabs.appendChild(b);
    });
    root.appendChild(tabs);
    Object.keys(panels).forEach(function (key) { root.appendChild(panels[key]); });
    select('overview');

    var appUrl = L.safeHttpsUrl(metaContent('app-download'));
    if (appUrl) {
      var cta = el('a', 'btn cta', STR.getApp);
      cta.href = appUrl;
      cta.rel = 'noopener noreferrer';
      root.appendChild(cta);
    }
  }

  function start() {
    var id = L.parseTournamentPath(window.location.pathname, true);
    if (!id) { showState(STR.invalid); return; }

    var url = dataUrl(id);
    if (!url) { showState(STR.notReady); return; }

    showState(STR.loading);
    fetch(url, { headers: { Accept: 'application/json' } })
      .then(function (response) {
        if (response.status === 404) { var e = new Error('not found'); e.notFound = true; throw e; }
        if (!response.ok) throw new Error('http ' + response.status);
        return response.json();
      })
      .then(render)
      .catch(function (error) {
        if (error && error.notFound) showState(STR.notFound);
        else showState(STR.error, true);
      });
  }

  start();
})();
