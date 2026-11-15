# Tech Stack (Step 0.1)

| Area | Choice | Why |
|---|---|---|
| App | Flutter 3 / Dart 3 | One codebase, good performance on low-end Android phones |
| State management | Riverpod 2 | Testable, no BuildContext dependency, scales to a large app |
| Navigation | go_router | Bottom tabs with preserved state, deep links (needed for public tournament links) |
| Backend | Supabase | See below |
| Builds | GitHub Actions | APK built on every push to `main` |

## Why Supabase (PostgreSQL) and not Firebase

This app is mostly relational data: tournaments, teams, players, fixtures, results and
points tables that join with each other. PostgreSQL handles this far better than a
document database.

- **Nearby search** (Step 3.1): PostGIS gives distance queries (1 km, 5 km, 10 km) natively.
- **Roles and permissions** (Step 0.7): Row Level Security enforces who can edit what at
  the database level.
- **Live score** (Step 2.2): Supabase Realtime pushes score changes to viewers.
- **Posters and photos**: Supabase Storage.
- **Predictable cost**: no per-read billing surprises when many viewers refresh a live match.

## Decisions deferred to the step that needs them

| Topic | Decide at | Notes |
|---|---|---|
| Phone OTP provider | Step 1.1 | Supabase built-in SMS providers are expensive for Bangladesh. Plan: a local SMS gateway called from an Edge Function. Development uses email login. |
| Local storage for offline | Step 0.8 (done) | SharedPreferences outbox and cache behind replaceable interfaces. Move to SQLite only if data volume requires it (see docs/OFFLINE.md). |
| Push notifications | Step 1.13 | Firebase Cloud Messaging |
| Maps | Step 3.2 | OpenStreetMap (flutter_map) avoids Google Maps billing |
| Secure token storage (flutter_secure_storage) | Step 1.1 | Added together with sign-in, where it is first needed |
| Public web pages | Step 0.10 (done) | Plain HTML/CSS/JS on Cloudflare Pages, no framework, tiny pages. Details in docs/PUBLIC_PAGES.md |
| Payments | Step 5.5 | bKash / Nagad merchant APIs |
| Bangla font and l10n | Step 0.4 | Bundle a Bangla font so text looks the same on every phone |
