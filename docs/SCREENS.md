# Screens and Navigation (Step 0.3)

Every screen of the app, where it lives, who may open it, and which roadmap step builds
it. The list below is generated from `tool/screens_data.py`, the same list the app uses
for its routes, tab hubs and the developer **Screen map**. Run
`python3 tool/generate_screens.py` after changing it, and
`python3 tool/check_screens.py` to verify the code and this file agree.

## Navigation structure

```
Bottom tabs (always visible)
  Home  |  Explore  |  Create  |  My Sports  |  Profile
```

| Tab | What it is | Opens |
|---|---|---|
| Home | Today's picture: nearby tournaments, today's matches, shortcuts | Tournament, match, search, map, calendar, notifications |
| Explore | Finding things | Lists of tournaments, teams, players, clubs, coaches, referees, grounds, talent, trending, rankings, map, calendar, QR scan, community feed |
| Create | Starting things | Tournament wizard, team, club, player/coach/referee profile, ground, post |
| My Sports | Things that belong to you | My tournaments, teams, matches, registrations, following, career, ID, certificates |
| Profile | You and the app | Edit profile, privacy, notifications, language, appearance, security, data, verification, help |

Screens that are not tabs (a tournament, a match, organizer tools, admin) open **on top
of** the tabs with a back arrow, so the bottom bar is hidden and the person focuses on
the task.

## Rules every screen follows

1. **Access is declared once.** Each screen is Anyone, Signed in, or needs a permission.
   Opening a screen the person may not see sends them to Sign in (not signed in) or to
   "No access" (signed in but not allowed). Tournament permissions are checked against
   the tournament id in the address, so an organizer of one tournament cannot open the
   tools of another.
2. **After sign-in, return to where they were.** The sign-in address carries a `from`
   value. Only plain in-app paths are accepted, never a web address (stops redirect tricks).
3. **Links are safe.** An id in an address must be a well-formed short id. Otherwise the
   screen says "This link is not valid." and shows nothing from the address.
4. **Unknown address** shows a friendly "This page does not exist" with a Home button.
5. **Back button.** If there is nowhere to go back to (opened from a shared link), the
   arrow becomes a Home button.
6. **Every data screen has four states**, built with the shared `StateView`:
   loading, empty (with a next action), error (with Retry), and offline (shows saved
   data and the offline bar).
7. **Offline.** Screens show the last saved data first. Writes go through the offline
   outbox (see `docs/OFFLINE.md`).
8. **Sensitive actions confirm first** (delete, disqualify, finalize a result) and are
   recorded in the audit log.

## Main journeys

**Visitor (watches).** Opens a shared link, `/t/{id}`: sees fixtures and table, taps a
match for live score, follows the tournament (asks to sign in only at that moment).

**Organizer (runs it).** Create, Create a tournament (quick wizard), publish after
approval, Manage: approve teams, generate fixtures, assign scorers, send announcements,
share the link and QR, finish and give awards.

**Player, coach or official (grows).** Create a profile, join a team or apply to a trial,
play, see career statistics, get found by clubs. Coaches and referees advertise.

## Key screen layouts

```
HOME                          TOURNAMENT  /t/{id}
+------------------------+    +------------------------+
| BD Sports      (bell)  |    | <  Pirgachha Premier   |
| My area: Pirgachha  v  |    | Football | Ongoing | OK  |
| [Search tournaments..] |    | [Overview|Fixtures|     |
| Live now               |    |  Table | Teams | More]  |
|  [match card]          |    | Where / When / Prize   |
| Near you               |    | Organizer (verified)   |
|  [tournament card]     |    | [Register team]  [Follow]|
|  [tournament card]     |    | [Share]                |
| Today and tomorrow     |    +------------------------+
+------------------------+
| Home Explore + Mine Me |

CREATE WIZARD (5 to 10 min)   SCORE MATCH  (offline ready)
+------------------------+    +------------------------+
| 1 Sport    [Fb] [Cr]   |    | Team A  2 - 1  Team B  |
| 2 Format   Knockout    |    | 54'  second half       |
| 3 Teams    16          |    | [Goal][Card][Sub]      |
| 4 Dates and ground     |    | [Timeline]             |
| 5 Review and publish   |    | Waiting to sync: 2     |
| [Back]        [Next]   |    | [Half time] [Full time]|
+------------------------+    +------------------------+
```

## Screen list

**105 screens: 7 built, 98 planned.**

### Main tabs

| Screen | Path | Access | Step | Status |
|---|---|---|---|---|
| Home | `/home` | Anyone | 0.3 | Built |
| Explore | `/explore` | Anyone | 0.3 | Built |
| Create | `/create` | Anyone | 0.3 | Built |
| My Sports | `/my-sports` | Anyone | 0.3 | Built |
| Profile | `/profile` | Anyone | 0.3 | Built |

### Sign in

| Screen | Path | Access | Step | Status |
|---|---|---|---|---|
| Sign in | `/sign-in` | Anyone | 1.1 | Planned |
| Verify code | `/sign-in/verify` | Anyone | 1.1 | Planned |
| Set up your profile | `/welcome` | Signed in | 1.1 | Planned |

### Discover

| Screen | Path | Access | Step | Status |
|---|---|---|---|---|
| Tournaments | `/explore/tournaments` | Anyone | 1.6 | Planned |
| Teams | `/explore/teams` | Anyone | 3.16 | Planned |
| Players | `/explore/players` | Anyone | 3.16 | Planned |
| Clubs | `/explore/clubs` | Anyone | 3.16 | Planned |
| Coaches | `/explore/coaches` | Anyone | 3.3 | Planned |
| Referees and scorers | `/explore/referees` | Anyone | 3.4 | Planned |
| Grounds | `/explore/grounds` | Anyone | 3.12 | Planned |
| Talent search | `/explore/talent` | Signed in | 3.17 | Planned |
| Trending tournaments | `/explore/trending` | Anyone | 3.8 | Planned |
| Rankings | `/explore/rankings` | Anyone | 4.5 | Planned |
| Nearby map | `/map` | Anyone | 3.2 | Planned |
| Tournament calendar | `/calendar` | Anyone | 4.7 | Planned |
| Scan QR code | `/scan` | Anyone | 4.4 | Planned |
| Search | `/search` | Anyone | 1.6 | Planned |

### Community

| Screen | Path | Access | Step | Status |
|---|---|---|---|---|
| Community feed | `/feed` | Anyone | 3.5 | Planned |
| Post | `/post/:id` | Anyone | 3.5 | Planned |
| Chats | `/chats` | Signed in | 3.13 | Planned |
| Chat | `/chats/:id` | Signed in | 3.13 | Planned |

### Create

| Screen | Path | Access | Step | Status |
|---|---|---|---|---|
| Create a tournament | `/create/tournament` | Permission: createTournament | 1.3 | Planned |
| Create a team | `/create/team` | Permission: registerTeam | 1.7 | Planned |
| Create a club | `/create/club` | Signed in | 2.7 | Planned |
| Player profile | `/create/player-profile` | Signed in | 2.5 | Planned |
| Coach profile | `/create/coach-profile` | Signed in | 3.3 | Planned |
| Referee or scorer profile | `/create/referee-profile` | Signed in | 3.4 | Planned |
| List a ground | `/create/ground` | Signed in | 3.12 | Planned |
| Write a post | `/create/post` | Permission: createPost | 3.5 | Planned |

### My Sports

| Screen | Path | Access | Step | Status |
|---|---|---|---|---|
| My tournaments | `/my-sports/tournaments` | Signed in | 1.3 | Planned |
| My teams | `/my-sports/teams` | Signed in | 1.7 | Planned |
| My matches | `/my-sports/matches` | Signed in | 2.1 | Planned |
| My registrations | `/my-sports/registrations` | Signed in | 1.7 | Planned |
| Following | `/my-sports/following` | Signed in | 2.18 | Planned |
| Career and statistics | `/my-sports/career` | Signed in | 2.17 | Planned |
| Digital ID card | `/my-sports/id` | Signed in | 4.4 | Planned |
| Certificates and trophies | `/my-sports/certificates` | Signed in | 4.3 | Planned |

### Tournament

| Screen | Path | Access | Step | Status |
|---|---|---|---|---|
| Tournament | `/t/:id` | Anyone | 1.3 | Planned |
| Tournament rules | `/t/:id/rules` | Anyone | 1B.1 | Planned |
| Register a team | `/t/:id/register` | Permission: registerTeam | 1.7 | Planned |
| Awards | `/t/:id/awards` | Anyone | 2.8 | Planned |
| Gallery and highlights | `/t/:id/gallery` | Anyone | 4.6 | Planned |
| Sponsors | `/t/:id/sponsors` | Anyone | 4.2 | Planned |
| Tournament chat | `/t/:id/chat` | Signed in | 3.13 | Planned |

### Organizer tools

| Screen | Path | Access | Step | Status |
|---|---|---|---|---|
| Manage tournament | `/t/:id/manage` | Permission: editTournament | 1.3 | Planned |
| Edit tournament | `/t/:id/manage/edit` | Permission: editTournament | 1.3 | Planned |
| Teams and registrations | `/t/:id/manage/teams` | Permission: manageRegistrations | 1.7 | Planned |
| Fixtures | `/t/:id/manage/fixtures` | Permission: manageFixtures | 1.8 | Planned |
| Matches and results | `/t/:id/manage/matches` | Permission: manageFixtures | 1.9 | Planned |
| Rules builder | `/t/:id/manage/rules` | Permission: editTournament | 1B.1 | Planned |
| Announcements | `/t/:id/manage/announcements` | Permission: sendAnnouncement | 1B.11 | Planned |
| Protests | `/t/:id/manage/protests` | Permission: resolveProtest | 1B.9 | Planned |
| Scorers | `/t/:id/manage/scorers` | Permission: assignScorer | 2.1 | Planned |
| Finance | `/t/:id/manage/finance` | Permission: viewFinance | 4.1 | Planned |
| Sponsor packages | `/t/:id/manage/sponsors` | Permission: editTournament | 4.2 | Planned |
| Share, QR and poster | `/t/:id/manage/share` | Permission: editTournament | 1B.10 | Planned |
| Certificates | `/t/:id/manage/certificates` | Permission: editTournament | 4.3 | Planned |

### Match

| Screen | Path | Access | Step | Status |
|---|---|---|---|---|
| Match | `/m/:id` | Anyone | 1.9 | Planned |
| Line-up | `/t/:id/match/:matchId/lineup` | Permission: manageSquad | 2.12 | Planned |
| Score the match | `/t/:id/match/:matchId/score` | Permission: enterScore | 2.2 | Planned |

### Team

| Screen | Path | Access | Step | Status |
|---|---|---|---|---|
| Team | `/team/:id` | Anyone | 1.7 | Planned |
| Team squad | `/team/:id/squad` | Signed in | 1.7 | Planned |
| Edit team | `/team/:id/edit` | Signed in | 1.7 | Planned |

### Player

| Screen | Path | Access | Step | Status |
|---|---|---|---|---|
| Player | `/p/:id` | Anyone | 2.5 | Planned |
| Edit player profile | `/p/:id/edit` | Signed in | 2.5 | Planned |
| Compare players | `/p/:id/compare` | Anyone | 2.17 | Planned |

### Club

| Screen | Path | Access | Step | Status |
|---|---|---|---|---|
| Club | `/c/:id` | Anyone | 2.7 | Planned |
| Edit club | `/c/:id/edit` | Signed in | 2.7 | Planned |
| Club trials | `/c/:id/trials` | Anyone | 3.10 | Planned |

### Coach

| Screen | Path | Access | Step | Status |
|---|---|---|---|---|
| Coach | `/coach/:id` | Anyone | 3.3 | Planned |

### Referee

| Screen | Path | Access | Step | Status |
|---|---|---|---|---|
| Referee or scorer | `/ref/:id` | Anyone | 3.4 | Planned |

### Ground

| Screen | Path | Access | Step | Status |
|---|---|---|---|---|
| Ground | `/g/:id` | Anyone | 3.12 | Planned |
| Book a ground | `/g/:id/book` | Signed in | 3.12 | Planned |

### Organizer

| Screen | Path | Access | Step | Status |
|---|---|---|---|---|
| Organizer | `/o/:id` | Anyone | 3.6 | Planned |

### Settings and help

| Screen | Path | Access | Step | Status |
|---|---|---|---|---|
| Edit profile | `/profile/edit` | Signed in | 1.1 | Planned |
| Notification settings | `/profile/notifications` | Signed in | 1B.13 | Planned |
| Language | `/profile/language` | Anyone | 0.4 | Planned |
| Appearance | `/profile/appearance` | Anyone | 1B.13 | Planned |
| Login history and devices | `/profile/security` | Signed in | 1B.12 | Planned |
| Download or delete my data | `/profile/data` | Signed in | 1B.12 | Planned |
| Get verified | `/profile/verification` | Signed in | 3.6 | Planned |
| Payment history | `/profile/payments` | Signed in | 5.9 | Planned |
| Privacy settings | `/privacy` | Anyone | 0.9 | Built |
| Help and support | `/help` | Anyone | 1.15 | Planned |
| About | `/about` | Anyone | 0.3 | Planned |
| Terms and privacy policy | `/terms` | Anyone | 1.1 | Planned |

### System

| Screen | Path | Access | Step | Status |
|---|---|---|---|---|
| No access | `/no-access` | Anyone | 0.3 | Built |
| Notifications | `/notifications` | Signed in | 1.13 | Planned |
| Report | `/report/:type/:id` | Signed in | 1.15 | Planned |

### Admin

| Screen | Path | Access | Step | Status |
|---|---|---|---|---|
| Admin dashboard | `/admin` | Permission: viewAnalytics | 1.14 | Planned |
| Approve tournaments | `/admin/tournaments` | Permission: approveTournament | 1.14 | Planned |
| Users and organizers | `/admin/users` | Permission: verifyOrganizer | 1.14 | Planned |
| Reports | `/admin/reports` | Permission: moderateContent | 1.14 | Planned |
| Verification requests | `/admin/verifications` | Permission: verifyOrganizer | 3.6 | Planned |
| Suspensions and appeals | `/admin/suspensions` | Permission: suspendAccount | 3.14 | Planned |
| Payments | `/admin/payments` | Permission: managePayments | 4.8 | Planned |
| Advertisements | `/admin/ads` | Permission: managePayments | 4.8 | Planned |
| Analytics | `/admin/analytics` | Permission: viewAnalytics | 4.8 | Planned |
| Audit logs | `/admin/audit` | Permission: viewAuditLogs | 4.11 | Planned |
| Admins and roles | `/admin/roles` | Permission: manageAdmins | 1B.12 | Planned |


## Notes

- "Built" means a real screen exists. "Planned" screens open a clear placeholder that
  states which step builds them, so every path in the app already works end to end.
- The developer **Screen map** (Profile, development build) lists every screen with its
  status and lets you open each one, to check navigation and access rules on a phone.
- Sample ids use the format of real ones (for example `abcd2345`).
