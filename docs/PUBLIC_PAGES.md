# Public Pages and Share Links (Step 0.10)

Goal: a tournament link shared on WhatsApp or Facebook opens for anyone, with or
without the app. A person in Dhaka can follow a 16-team village tournament in
Hatibandha by tapping one link.

## Link map (same address in the browser and in the app)

| Link | Shows | App screen built in |
|---|---|---|
| `/t/{id}` or `/t/{id}/{readable-name}` | Tournament: details, fixtures, points table, teams | Step 1.3 |
| `/m/{id}` | One match: score, timeline | Step 1.9 |
| `/team/{id}` | Team: players, results | Step 1.7 |

- `{id}` is a short id like `k7m2xq9d`: 8 easy-to-read characters (no 0, o, 1, l, i).
  It is not a secret. A tournament is visible only when its status is published.
- `{readable-name}` is optional and only decorates the link
  (`/t/k7m2xq9d/pirgachha-premier-2026`). The id decides. Bangla-only titles simply
  have no ending.
- Later additions use the same pattern: `/c/{id}` club, `/p/{id}` player, `/o/{id}`
  organizer.

## What is built now (Step 0.10)

| Piece | Where | Status |
|---|---|---|
| Link builder and reader, id generator | `lib/core/public_links` | DONE, tested |
| App routes for `/t`, `/m`, `/team` (a tapped link lands on a screen, a broken link shows a friendly message) | `lib/core/router`, `features/public` | DONE, tested |
| Public link tester screen (Profile, development build) | `features/dev_tools` | DONE |
| Public web page prototype with sample tournament, points table, security headers | `web_public/` | DONE, tested with Node (19 tests) |
| Build adds app links for your web address when `PUBLIC_BASE_URL` is set | `.github/workflows/build-apk.yml` | DONE |
| Real data on the page, per-tournament share preview | Step 1B.10 | later |
| Page for matches and teams | Step 1B.10 / 2.x | later |

## Data the public page may show

Every public page is built from one **public view** of the data, never from the raw
tables. This keeps private data from leaking by mistake.

Allowed:

- Tournament: title, sport, status, dates, place (village, upazila, district, division),
  ground name, prize amounts, rules summary, organizer name and verified badge,
  organizer's public page link (https only).
- Teams: name, logo.
- Matches: teams, kickoff time, ground, status, score, timeline.
- Points table (calculated).
- Players, only if the player's privacy settings allow it (name, photo, stats).

Never shown on a public page:

- Phone numbers, email, date of birth, address, ID numbers.
- Payment details, fees collected, finance records, internal notes.
- Internal user ids. Public ids only.
- Under-18 players: no photo, no full name, no age unless the player and guardian
  allowed it. Default is initials only.
- Anything from a draft, cancelled-and-hidden, or unapproved tournament. These return
  "not found", the same as a wrong id, so nobody can tell they exist.

## Share previews (WhatsApp, Facebook)

Link previews need the title and description in the page HTML itself, because those
apps do not run JavaScript. The plan for Step 1B.10:

1. A small Cloudflare Pages Function handles `/t/{id}`.
2. It reads the tournament from the public API, then writes the title, description
   and an image into the `<meta property="og:...">` tags of `t.html`.
3. Draft or unknown ids get a plain "not found" page with no tournament details.
4. Responses are cached for a short time (about 1 minute for live tournaments).

Today the page has a generic preview (`BD Sports`).

## Speed on weak internet

- No framework and no libraries. Plain HTML, one CSS file, two small scripts.
- Target: whole page under 100 KB. Currently about 19 KB before compression (smaller over the network).
- System fonts (Bangla comes from the phone). No web fonts to download.
- Works with one request for the page plus one for the data.
- Tables scroll sideways instead of shrinking text.

## Security of the public pages

- Page text is added with `textContent` only. Data from the server can never become
  code (tested with a script-injection sample).
- Links from data are allowed only if they are plain `https` without a hidden user name.
- Security headers in `web_public/_headers`: strict Content Security Policy (only own
  scripts and styles), no framing, no sniffing, no camera, microphone or location.
- Read-only. The pages never send data to the server.
- The public API (BACKEND stage) reads only the public views, has rate limits, and
  returns the same "not found" for unknown and hidden tournaments.
- Search engines are kept out (`noindex`, `robots.txt`) until real data is connected.
  Then published tournaments are allowed and drafts stay blocked.

## Hosting

Cloudflare Pages, free plan, connected to the GitHub repository.

- Build command: none. Output folder: `web_public`.
- `_redirects` makes every `/t/...` address serve `t.html`.
- Test locally with `node web_public/serve.js`, then open `http://localhost:8080/t/demo`.

## Opening shared links in the app (Android app links)

A tapped `https://your-site/t/k7m2xq9d` can open the app directly when it is installed.

Setup (once, you do this):

1. Put the page online and note the address, for example `https://sports.example.com`.
2. In GitHub: Settings, Secrets and variables, Actions, Variables, add
   `PUBLIC_BASE_URL` = that address. The next build adds the app links and builds full
   share links into the app.
3. Publish a file at `/.well-known/assetlinks.json` on the same site:

```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.rakib.bd_sports",
    "sha256_cert_fingerprints": ["SHA-256 OF YOUR RELEASE SIGNING KEY"]
  }
}]
```

Honest limit: Android only opens the app automatically if that file matches the key the
APK is signed with. The test builds are signed with a debug key that changes, so until
the app has its own release keystore (a LAUNCH item), shared links will open in the
browser. The in-app routes and the link tester work now.

## Open decisions for later

- Final web address (needs a domain, or the free `*.pages.dev` address to start).
- Whether the public API is a Supabase view with an edge function, or a Pages Function
  (decided in Step 1B.10 with the backend).
- Languages on the public page: Bangla now, English toggle with Step 0.4 strings.
