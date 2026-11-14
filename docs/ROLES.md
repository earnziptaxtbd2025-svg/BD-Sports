# Roles and Permissions (Step 0.7)

Two kinds of roles:

- **Account role** (one per person): Member, Moderator, Super Admin.
- **Tournament role** (per tournament): Organizer, Scorer, Team manager. The same person
  can be Organizer in one tournament and only Scorer in another.

Visitors who are not signed in can browse public pages but cannot do anything else.
A suspended account is denied every action.

## Permission matrix

| Permission | Scope | Member | Moderator | Super Admin | Organizer | Scorer | Team manager |
|---|---|:-:|:-:|:-:|:-:|:-:|:-:|
| Create a tournament | member | yes | yes | yes | | | |
| Register a team | member | yes | yes | yes | | | |
| Post in the community | member | yes | yes | yes | | | |
| Report content or a user | member | yes | yes | yes | | | |
| Edit own profile | member | yes | yes | yes | | | |
| Edit tournament details | tournament | | | yes | yes | | |
| Approve or reject teams | tournament | | | yes | yes | | |
| Create and change fixtures | tournament | | | yes | yes | | |
| Enter live score and results | tournament | | | yes | yes | yes | |
| Edit a team squad | tournament | | | yes | yes | | yes |
| Send announcements | tournament | | | yes | yes | | |
| View tournament finance | tournament | | | yes | yes | | |
| Edit tournament finance | tournament | | | yes | yes | | |
| Decide protests | tournament | | | yes | yes | | |
| Disqualify a team | tournament | | | yes | yes | | |
| Assign scorers | tournament | | | yes | yes | | |
| Approve tournaments | admin | | yes | yes | | | |
| Verify organizers | admin | | yes | yes | | | |
| Moderate content | admin | | yes | yes | | | |
| View analytics | admin | | yes | yes | | | |
| Suspend accounts | admin | | | yes | | | |
| View audit logs | admin | | | yes | | | |
| Manage admins | admin | | | yes | | | |
| Manage payments | admin | | | yes | | | |

## How to use it in code

```dart
// Hide a button
PermissionGate(
  permission: Permission.manageFixtures,
  tournamentId: tournament.id,
  child: FilledButton(onPressed: ..., child: Text('Generate fixtures')),
)

// Check in logic
if (AccessPolicy.can(user, Permission.enterScore, tournamentId: id)) { ... }
```

## Important

These checks decide what the app shows. They are **not security on their own**: anyone
can modify a phone app. The same rules must be enforced in the database (row level
security) when the backend is connected, which is planned as the last step of the project.
