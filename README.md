# BD Sports (working name)

Bangladesh grassroots football and cricket tournament platform.
Tournament marketplace, tournament management, and sports community in one app.

Status: Steps 0.1 (Tech stack), 0.6 (GitHub and APK pipeline), 0.7 (Roles and
permissions), 0.8 (Offline-first architecture), 0.9 (Security foundation) and 0.10
(Public pages and share links), 0.3 (Screens and navigation) and 0.4 (Bangla and
English) written. Step 0.5 (Design System) all 4 parts written, waiting for the phone check (see docs/DESIGN_SYSTEM.md).

Project decision: the database and backend connection are built **last**, after all
screens and features. Until then screens use in-memory sample data behind repository
interfaces, so connecting the real backend later does not require rewriting screens.

## Project structure

```
lib/
  main.dart                 App entry, optional Supabase init
  app.dart                  MaterialApp.router and themes
  core/
    auth/                   Roles, permissions and the access policy (see docs/ROLES.md)
    network/ sync/ cache/   Offline-first: outbox, sync engine, cache (see docs/OFFLINE.md)
    security/ privacy/      Validation, log scrubbing, rate limit, audit, privacy settings (see docs/SECURITY.md)
    public_links/           Share link builder and reader, short ids (see docs/PUBLIC_PAGES.md)
    navigation/             Screen list (105 screens), access guard, address checks (see docs/SCREENS.md)
    l10n/                   Bangla and English texts, number/money/date formats (see docs/LANGUAGES.md)
    widgets/                Shared widgets: state view, permission gate, sync banner
    storage/                Shared local storage provider
    config/env.dart         Build-time config (--dart-define)
    router/                 go_router setup and route paths
    theme/                  Colours and ThemeData (full design system in Step 0.5)
    providers/              App-wide Riverpod providers
    widgets/                Shared widgets
  features/
    shell/                  Bottom navigation
    home/ explore/ create/ my_sports/ profile/
    navigation/             Hub tabs, placeholder screens, no-access and not-found screens
    auth/                   Sign-in screen (real sign-in in Step 1.1)
    dev_tools/              Role tester, screen map, offline sync and public link testers (only when DEV_TOOLS=true)
test/                       Dart tests
web_public/                 Public web pages (plain HTML/CSS/JS) with Node tests
docs/TECH_STACK.md          Technology decisions and reasons
docs/ROLES.md               Role and permission matrix
docs/OFFLINE.md             Offline-first rules, pieces and how to test
docs/SECURITY.md            Full security plan with status of every item
docs/PUBLIC_PAGES.md        Share links, public pages, what they may show
docs/SCREENS.md             All screens, navigation rules, access, layouts
docs/LANGUAGES.md           Bangla and English: how it works, style guide, word list
docs/DESIGN_SYSTEM.md       Design system parts, colour and layout rules
tool/                       Screen list source and generator (python3 tool/generate_screens.py)
SECURITY.md                 How to report a security problem
.github/workflows/          APK build pipeline
```

Each feature will follow `presentation/` (screens, widgets), `application/` (providers,
logic) and `data/` (repositories, models) as it grows.

## Build the APK on GitHub (no local setup needed)

1. Create a new GitHub repository and upload all files from this folder (keep the
   `.github` folder).
2. Push to the `main` branch. The workflow **Build Android APK** runs automatically.
   You can also run it by hand: Actions tab, Build Android APK, Run workflow.
3. When it finishes, open the run and download the **bd-sports-apk** artifact. Unzip it
   and install `app-release.apk` on your phone.

Optional, when Supabase is ready (Step 0.2): add repository secrets `SUPABASE_URL` and
`SUPABASE_ANON_KEY` (Settings, Secrets and variables, Actions). Without them the app
still runs and shows "Supabase keys not set yet" on the Home tab.

## Run locally (optional)

```
flutter create --platforms=android --org com.rakib --project-name bd_sports /tmp/scaffold
cp -r /tmp/scaffold/android ./android
flutter pub get
flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

## Share links and public pages

The public web pages live in `web_public/` (see `web_public/README.md`). To make the
app build full share links and open them, add the repository variable
`PUBLIC_BASE_URL` (Settings, Secrets and variables, Actions, Variables). Details and
limits are in `docs/PUBLIC_PAGES.md`.

## Flutter version

Builds use the newest stable Flutter. The run's Summary page shows which version was
used ("Tool versions"). To lock it so a Flutter update can never break a build by
surprise, add the repository variable `FLUTTER_VERSION` (Settings, Secrets and
variables, Actions, Variables) with that version, for example `3.47.1`. Remove the
variable to go back to the newest.

## Production build

Run the workflow by hand (Actions, Build Android APK, Run workflow) and tick
**Production build** to hide the developer tools. Normal pushes build a development
version that includes them.

## Notes

- The `android/` folder is generated by the workflow and is not stored in the repo. The
  workflow adds the internet permission and sets the app name.
- Release APKs are signed with the debug key. That is fine for testing. A proper keystore
  is needed before Google Play (see docs/SECURITY.md).
- The app defaults to the dark neon "stadium night" theme from the approved design. The light theme is kept. A user setting arrives in Step 1B.13.
- Analyze and test steps are non-blocking for now. Make them strict once the first
  build is green.
