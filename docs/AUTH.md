# Sign in and profile (Step 1.1)

## What the person sees

1. **Sign in** (`/sign-in`): types a mobile number (01XXXXXXXXX or +8801XXXXXXXXX,
   Bangla digits work) and taps *Send code*.
2. **Verify code** (`/sign-in/verify`): types the 6-digit code. It is checked as soon
   as the last digit is typed. *Resend* works after 60 seconds.
3. **Set up your profile** (`/welcome`), first time only: photo, name (required),
   division (optional), and role (Organizer, Player or Fan).
4. **Edit profile** (`/profile/edit`) later, from Profile. **Sign out** is on Profile.

Someone who is signed in but has no name yet is sent to the set-up screen from any
other screen.

The role (Organizer, Player, Fan) is only what the person wants to do. It gives no
permission. Permissions come from the account role and the tournament roles
(Step 0.7).

## Two modes

| Mode | When | Code |
|---|---|---|
| **Preview** | no Supabase keys in the build | always `123456`, nothing is sent, everything stays on the phone |
| **Real** | `SUPABASE_URL` and `SUPABASE_ANON_KEY` are set | Supabase sends an SMS and checks the code |

The verify screen shows a hint in preview mode. Preview mode is never used when keys
exist.

## Code map

| File | Job |
|---|---|
| `core/auth/auth_repository.dart` | The sign-in contract and the error kinds |
| `core/auth/preview_auth_repository.dart` | Preview mode |
| `core/auth/supabase_auth_repository.dart` | Real mode |
| `core/auth/auth_providers.dart` | `AuthController` (limits: 3 codes and 5 checks per 10 minutes), `ProfileController`, photo |
| `core/auth/user_store.dart` | Saves the session, profile and photo on the phone |
| `core/auth/profile_sync_handler.dart` | Sends the profile and photo to the server when online |
| `features/auth/presentation/` | Sign in, verify, welcome, profile form |
| `features/profile/presentation/edit_profile_page.dart` | Edit profile |

The profile is saved on the phone first. When the server is connected it is also put
in the sync queue and sent when there is internet.

## Setting up the real server (do this later, after Step 1.1 works in preview)

1. Create a project at supabase.com.
2. **SQL Editor**: paste `supabase/migrations/0001_profiles.sql` and run it.
3. **Authentication > Providers > Phone**: turn it on and choose an SMS provider
   (for example Twilio). SMS costs money, check prices for Bangladesh numbers first.
4. In GitHub: **Settings > Secrets and variables > Actions**, add `SUPABASE_URL` and
   `SUPABASE_ANON_KEY` (Project Settings > API).
5. Build a new APK.

## Not done here (later steps)

- Account deletion, login history, device list: Step 1B.12.
- Audit log of sign-ins: Step 4.11 (needs the audit table).
- Full location (district, upazila, union, village): Step 1.2.
