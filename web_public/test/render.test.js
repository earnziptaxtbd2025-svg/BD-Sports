// Runs assets/app.js against a small fake page to check it builds without errors.
// Run with: node web_public/test/render.test.js
const assert = require('assert');
const fs = require('fs');
const path = require('path');
const vm = require('vm');
const L = require('../assets/logic.js');

class FakeNode {
  constructor(tag) { this.tag = tag; this.children = []; this.attrs = {}; this.className = ''; this.hidden = false; this._text = ''; this.listeners = {}; }
  appendChild(c) { this.children.push(c); return c; }
  removeChild(c) { this.children = this.children.filter((x) => x !== c); }
  get firstChild() { return this.children[0] || null; }
  setAttribute(k, v) { this.attrs[k] = String(v); }
  getAttribute(k) { return k in this.attrs ? this.attrs[k] : null; }
  addEventListener(name, fn) { this.listeners[name] = fn; }
  set textContent(v) { this._text = String(v); this.children = []; }
  get textContent() { return this._text + this.children.map((c) => c.textContent).join(' '); }
  find(tag) { return [].concat(this.tag === tag ? [this] : [], ...this.children.map((c) => c.find(tag))); }
}

async function run(pathname, responder) {
  const root = new FakeNode('main');
  const doc = {
    title: '',
    getElementById: () => root,
    createElement: (tag) => new FakeNode(tag),
    querySelector: () => ({ getAttribute: () => '' }),
  };
  const sandbox = {
    window: { BDLogic: L, location: { pathname } },
    document: doc,
    fetch: responder,
    console,
  };
  vm.runInNewContext(fs.readFileSync(path.join(__dirname, '../assets/app.js'), 'utf8'), sandbox);
  await new Promise((r) => setTimeout(r, 50));
  return { root, doc };
}

const demo = JSON.parse(fs.readFileSync(path.join(__dirname, '../sample-data/demo.json'), 'utf8'));
const ok = (body) => () => Promise.resolve({ status: 200, ok: true, json: () => Promise.resolve(body) });

let passed = 0;
async function test(name, fn) {
  try { await fn(); passed++; console.log('ok   ' + name); }
  catch (e) { console.error('FAIL ' + name + '\n' + e.stack); process.exitCode = 1; }
}

(async () => {
  await test('demo tournament renders title, tabs, table and matches', async () => {
    const { root, doc } = await run('/t/demo', ok(demo));
    assert.ok(doc.title.includes('পীরগাছা প্রিমিয়ার'));
    const text = root.textContent;
    assert.ok(text.includes('পীরগাছা প্রিমিয়ার ফুটবল টুর্নামেন্ট ২০২৬'));
    assert.ok(text.includes('পয়েন্ট টেবিল'));
    assert.strictEqual(root.find('button').length, 4);
    const rows = root.find('tbody')[0].children;
    assert.strictEqual(rows.length, 4);
    assert.ok(rows[0].textContent.includes('ইউনিয়ন স্টার'));
    assert.strictEqual(root.find('section').length, 4);
    assert.strictEqual(root.find('section').filter((s) => !s.hidden).length, 1);
  });

  await test('invalid link shows a message and does not load data', async () => {
    let called = false;
    const { root } = await run('/t/123', () => { called = true; return Promise.reject(new Error('no')); });
    assert.ok(root.textContent.includes('সঠিক নয়'));
    assert.strictEqual(called, false);
  });

  await test('real id with no data source yet says not ready', async () => {
    let called = false;
    const { root } = await run('/t/abcd2345', () => { called = true; return Promise.resolve(); });
    assert.ok(root.textContent.includes('চালু হয়নি'));
    assert.strictEqual(called, false);
  });

  await test('server 404 shows not found', async () => {
    const { root } = await run('/t/demo', () => Promise.resolve({ status: 404, ok: false, json: () => Promise.resolve({}) }));
    assert.ok(root.textContent.includes('পাওয়া যায়নি'));
  });

  await test('network failure shows retry button', async () => {
    const { root } = await run('/t/demo', () => Promise.reject(new Error('offline')));
    assert.ok(root.textContent.includes('ইন্টারনেট'));
    assert.strictEqual(root.find('button').length, 1);
  });

  await test('broken data shape shows an error, not a crash', async () => {
    const { root } = await run('/t/demo', ok({ tournament: { title: 5 } }));
    assert.ok(root.textContent.includes('আবার চেষ্টা'));
  });

  await test('text from data is never treated as HTML', async () => {
    const evil = JSON.parse(JSON.stringify(demo));
    evil.tournament.title = '<img src=x onerror=alert(1)>';
    evil.teams[0].name = '<script>alert(2)</script>';
    const { root } = await run('/t/demo', ok(evil));
    // Shown as plain text, and no element was created from it.
    assert.ok(root.textContent.includes('<img src=x onerror=alert(1)>'));
    assert.strictEqual(root.find('img').length, 0);
    assert.strictEqual(root.find('script').length, 0);
  });

  await test('organizer link only when https', async () => {
    const withLink = JSON.parse(JSON.stringify(demo));
    withLink.tournament.organizer.pageUrl = 'https://facebook.com/example';
    let r = await run('/t/demo', ok(withLink));
    assert.strictEqual(r.root.find('a').length, 1);

    withLink.tournament.organizer.pageUrl = 'javascript:alert(1)';
    r = await run('/t/demo', ok(withLink));
    assert.strictEqual(r.root.find('a').length, 0);
  });

  console.log(passed + ' passed' + (process.exitCode ? ', some FAILED' : ''));
})();
