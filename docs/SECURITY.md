# Security Plan (Step 0.9)

This is the complete security checklist for the whole project. Every item has a status
so nothing is forgotten and nothing is claimed as done when it is not.

**Status labels**

| Label | Meaning |
|---|---|
| DONE | Written in code or configuration now (Step 0.9) |
| STEP x | Built when that roadmap step is built |
| BACKEND | Built in the final stage, when the database and backend are connected |
| LAUNCH | Must be finished before the app goes to real users or Google Play |
| OWNER | Account or service setting you do yourself (cannot be done in code) |

## What we protect, and from whom

| We protect | From |
|---|---|
| Users' phone numbers, photos, age (many players are under 18) | Scrapers, stalkers, data leaks |
| Tournament results, fixtures and prize information | Cheating, fake edits by a non-organizer |
| Registration fees and prize money | Fraud, fake tournaments, payment tampering |
| Accounts (organizers, admins) | Password or OTP attacks, stolen phones, takeover |
| The platform itself | Spam, bots, fake accounts, abuse, outages, lost data |

The most important idea: **a phone app can always be modified or bypassed.** So every
rule must be enforced on the server. The checks inside the app only make the app
friendly and stop accidents.

## 1. Accounts and sign-in

| Item | Status |
|---|---|
| Phone OTP sign-in with a Bangladesh SMS gateway | STEP 1.1 |
| OTP expires in a few minutes, works once, max 5 tries | BACKEND |
| Limit OTP requests per phone and per device (stops SMS bombing and SMS cost abuse) | BACKEND |
| Resend-code cooldown on the screen (`RateLimiter`) | DONE (tool ready, used in Step 1.1) |
| Login tokens kept in secure storage (Android Keystore), not plain preferences | STEP 1.1 |
| Short-lived access token, refresh token rotation, log out on all devices | STEP 1.1 / BACKEND |
| Login history and "new device" alert | STEP 1B.12 |
| Account suspension and appeal | STEP 1B.12 / 3.14 |
| Admins and moderators must use a second step (2FA) | BACKEND / OWNER |
| Account deletion that really removes personal data | STEP 1B.12 / BACKEND |

## 2. Who may do what (authorization)

| Item | Status |
|---|---|
| Roles and permission matrix | DONE (Step 0.7, `docs/ROLES.md`) |
| Screens hide actions the person is not allowed to do (`PermissionGate`) | DONE |
| Row level security on **every** table, with the same rules as the matrix | BACKEND |
| Tournament-scoped roles checked on the server (organizer of A cannot edit B) | BACKEND |
| Check ownership on every record id (stops "change the id in the request") | BACKEND |
| Only the server can grant roles. The app can never set its own role | BACKEND |
| Score and result edits after a match is finished need a reason and are logged | STEP 1.9 / 1B |
| Automated tests that try forbidden actions and expect them to fail | BACKEND |

## 3. Data on the phone

| Item | Status |
|---|---|
| Cloud backup of app data switched off (`allowBackup=false`) | DONE (workflow) |
| Plain `http` traffic blocked, HTTPS only (`usesCleartextTraffic=false`) | DONE (workflow) |
| App code obfuscated in release builds (`--obfuscate`) | DONE (workflow) |
| Developer tools hidden in production builds (`production` option when running the workflow) | DONE |
| No secrets inside the app. Only the public Supabase "anon" key is ever used. The "service role" key never goes in the app, the repo or a build | DONE (rule) / OWNER |
| Logs print nothing in release builds and scrub phone, email and tokens in development (`AppLogger`, `Redactor`) | DONE |
| Offline queue holds only what is needed to resend. Never passwords or tokens | DONE (rule) |
| Sensitive offline data (if ever needed) goes in encrypted storage | STEP 1.1 |
| Certificate pinning | LAUNCH (decide: it blocks the app if certificates change, so only if needed) |
| Root and tamper detection | LAUNCH (optional, easy to bypass, low value for this app) |

## 4. Input and files

| Item | Status |
|---|---|
| Phone, name, title, taka amount and link validation, Bangla digits supported (`InputValidators`) | DONE |
| Text cleaning: control characters, hidden direction tricks removed, Bangla joiners kept | DONE |
| Links must be https and without a hidden user name (phishing trick) | DONE |
| Same checks repeated on the server with database constraints (length, type, range) | BACKEND |
| Never build database queries by joining text. Use the Supabase client or parameters only | DONE (rule) / BACKEND |
| Public web pages escape all user text (no script injection) and send security headers (CSP) | STEP 0.10 / 1B.10 |
| Photo and video upload: allowed types, size limit, rename, strip location data from photos | STEP 2.6 / 3.5 |
| Private files (ID documents, payment proof) in private storage, opened with short-lived links | BACKEND |
| Check uploaded files by content, not just the file name | BACKEND |

## 5. Abuse, spam and bots

| Item | Status |
|---|---|
| Rate limits on sign-up, OTP, posting, reporting, messages, search | BACKEND |
| Limits on the screen to avoid accidental repeats (`RateLimiter`) | DONE (tool ready) |
| Report content or user, and moderator tools | STEP 1.15 / 3.7 |
| Block user, mute, and who-can-message setting | STEP 3.5 |
| Bot protection on sign-up (challenge) if abuse appears | LAUNCH |
| Limit how many tournaments a new unverified account can post | BACKEND |

## 6. Fraud (the biggest risk for a tournament marketplace)

| Item | Status |
|---|---|
| Admin approval before a tournament is public | STEP 1.14 |
| Verified organizer badge with document check | STEP 3.6 / 3.11 |
| Warning on tournaments that charge a fee and have an unverified organizer | STEP 3.6 |
| Report tournament, fake prize and dispute handling | STEP 1.15 / 3.6 |
| Show prize and fee clearly. Admin can freeze a tournament | BACKEND |
| Duplicate and look-alike tournament detection | STEP 3.6 |
| Prize-money claims can be reported and reviewed | STEP 3.6 |

## 7. Payments

| Item | Status |
|---|---|
| Never store card numbers or PINs. Use bKash/Nagad hosted payment pages | STEP 5.5 |
| Payment status is set only by the server after verifying the gateway, never by the app | STEP 5.5 / BACKEND |
| Verify gateway callbacks with their signature or by calling the gateway back | STEP 5.8 |
| Each payment has a unique id, so a repeated request is not charged twice | STEP 5.8 |
| Refund and dispute process with proof kept | STEP 5.9 / 5.10 |
| Daily reconciliation of the gateway report against the database | STEP 5.8 |
| Check Bangladesh rules for collecting money for other people | LAUNCH / OWNER |

## 8. Privacy and children

Many players are under 18, so this matters more than usual.

| Item | Status |
|---|---|
| Privacy settings: who sees phone, age, photo; who can message; findable by phone; talent search; stats | DONE (screen in Profile, saved on the phone) |
| Private by default. Under-18 defaults stricter. Unknown values fall back to the most private | DONE |
| Privacy settings stored on the account and enforced by the server, so hidden data is never even sent | BACKEND |
| Collect only what is needed (data minimization) | DONE (rule) |
| Under-18: no public phone number, no exact location, no direct messages from strangers | STEP 2.5 / 3.5 |
| Parent or guardian consent for under-18 profiles | LAUNCH (check local law) |
| Privacy policy and terms inside the app, accepted at sign-up | LAUNCH |
| Download my data and delete my data | STEP 1B.12 / BACKEND |
| Photos of children: removal on request, no tagging of exact location | STEP 3.5 |
| Legal review of Bangladesh data and cyber law | LAUNCH / OWNER |

## 9. Records, monitoring and backups

| Item | Status |
|---|---|
| Audit record format and logger (who, what, which item, when), kept through the offline queue | DONE (`AuditLogger`, not used by screens yet) |
| Audit table is append-only: no edit, no delete, even for admins | BACKEND |
| Record these actions: sign-in, role change, suspension, tournament approval, fixtures, scores, result corrections, payments, finance edits, content removal, data export, account deletion | STEP 1.9 onward |
| Error reports with personal data removed | STEP 1B |
| Alerts for unusual activity (many failed sign-ins, mass posting) | LAUNCH |
| Daily database backup, point-in-time recovery, restore tested every few months | BACKEND / OWNER |
| Backups stored in another location | OWNER |

## 10. Code, build and accounts

| Item | Status |
|---|---|
| Secret scanner on every push (`security-scan.yml`, gitleaks) | DONE |
| Weekly dependency update checks (`dependabot.yml`) | DONE |
| Keep the repository private while building | OWNER |
| 2FA on GitHub, Supabase, Google Play and email accounts | OWNER |
| Branch protection on `main` once there is a team | OWNER |
| Release signing with your own keystore, kept offline and backed up in two places | LAUNCH |
| The debug signing key must never be used for Google Play | LAUNCH |
| Review of every new package before adding it | DONE (rule) |
| Security test (try to break it) by someone other than the author before launch | LAUNCH |

## 11. When something goes wrong

| Item | Status |
|---|---|
| Written plan: who decides, how to switch off sign-ups or a feature, who tells users | LAUNCH |
| Ability to rotate keys fast (Supabase keys, gateway secrets, signing key) | OWNER |
| Tell affected users and the authority if personal data leaks | LAUNCH |
| Contact for reporting a security problem (`SECURITY.md` in the repo root) | DONE |

## What Step 0.9 delivered in code

- `lib/core/security/input_validators.dart`: phone, name, title, amount, link checks
- `lib/core/security/redactor.dart` and `app_logger.dart`: no personal data in logs
- `lib/core/security/rate_limiter.dart`: limits on the screen
- `lib/core/security/audit_event.dart`: audit action list and logger
- `lib/core/privacy/privacy_settings.dart` and the Privacy settings screen
- Workflow: backup off, HTTPS only, obfuscation, production switch, secret scan, dependency checks
- Real internet check for the offline banner (`lib/core/network`)
- 6 new test files

## Honest limits

- None of this makes the app secure on its own. The strongest protections (row level
  security, rate limits, payment checks, audit table) live on the server and arrive in
  the final BACKEND stage. Until then the app has no real users and no real data.
- Do not publish the app to real users before the BACKEND and LAUNCH items are done.
- No system is perfectly secure. The aim is to make attacks hard, limit the damage, and
  notice quickly.
