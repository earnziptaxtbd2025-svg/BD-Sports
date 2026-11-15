# Public pages (Step 0.10)

Light web pages that show a tournament in any browser, with no app install. A link
shared on WhatsApp or Facebook opens here, or in the app if it is installed.

This folder is plain HTML, CSS and JavaScript with no build step and no libraries,
so pages stay tiny and load fast on weak mobile internet.

| File | Job |
|---|---|
| `t.html` | Tournament page shell. Served for every `/t/...` link |
| `assets/logic.js` | Points table, link and id rules. Tested with Node |
| `assets/app.js` | Builds the page from data (text only, no raw HTML) |
| `assets/style.css` | White and green design |
| `sample-data/demo.json` | Sample tournament, opens at `/t/demo` |
| `_headers`, `_redirects`, `robots.txt` | Security headers, link rewrite, indexing off |
| `serve.js` | Local test server (not published) |
| `test/` | Node tests for the logic and for page building |

## Try it on your computer

```
node web_public/serve.js
```

Then open `http://localhost:8080/t/demo`. The small server applies the same
`/t/...` rewrite as production.

## Test the logic

```
node web_public/test/logic.test.js
node web_public/test/render.test.js
```

## Put it online (Cloudflare Pages, free)

1. Cloudflare dashboard, Workers and Pages, Create, Pages, connect your GitHub repo.
2. Build command: leave empty. Build output directory: `web_public`.
3. After the first deploy, open `https://your-project.pages.dev/t/demo`.
4. Later, set the repository variable `PUBLIC_BASE_URL` to this address so the app
   builds full share links.

See `docs/PUBLIC_PAGES.md` for the full plan, including what this page must never show.
