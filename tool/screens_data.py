"""Single source of truth for the screen list. Run tool/generate_screens.py after editing.

Columns: id, title, path, area, icon, step, access, permission, hub, status, description
access: public | signedIn | permission
hub:    explore | create | mySports | None   (which tab hub lists the screen)
"""

PUBLIC, SIGNED_IN, PERM = "public", "signedIn", "permission"
B, PL = "built", "planned"

SCREENS = [
    # ---- Main tabs ----
    ("tab.home", "Home", "/home", "tabs", "home_outlined", "0.3", PUBLIC, None, None, B, "Tournaments near you, today's matches, shortcuts."),
    ("tab.explore", "Explore", "/explore", "tabs", "search", "0.3", PUBLIC, None, None, B, "Find tournaments, teams, players, coaches, grounds."),
    ("tab.create", "Create", "/create", "tabs", "add_circle_outline", "0.3", PUBLIC, None, None, B, "Start a tournament, team, club or profile."),
    ("tab.mySports", "My Sports", "/my-sports", "tabs", "emoji_events_outlined", "0.3", PUBLIC, None, None, B, "Your tournaments, teams, matches and registrations."),
    ("tab.profile", "Profile", "/profile", "tabs", "person_outline", "0.3", PUBLIC, None, None, B, "Your account, privacy and settings."),

    # ---- Sign in ----
    ("auth.signIn", "Sign in", "/sign-in", "auth", "login", "1.1", PUBLIC, None, None, PL, "Sign in with your mobile number."),
    ("auth.verify", "Verify code", "/sign-in/verify", "auth", "sms_outlined", "1.1", PUBLIC, None, None, PL, "Enter the code sent by SMS."),
    ("auth.welcome", "Set up your profile", "/welcome", "auth", "waving_hand_outlined", "1.1", SIGNED_IN, None, None, PL, "Name, photo and home area after first sign-in."),

    # ---- Discover (Explore tab) ----
    ("explore.tournaments", "Tournaments", "/explore/tournaments", "discover", "emoji_events_outlined", "1.6", PUBLIC, None, "explore", PL, "Search and filter tournaments."),
    ("explore.teams", "Teams", "/explore/teams", "discover", "groups_outlined", "3.16", PUBLIC, None, "explore", PL, "Find teams."),
    ("explore.players", "Players", "/explore/players", "discover", "person_search", "3.16", PUBLIC, None, "explore", PL, "Find players."),
    ("explore.clubs", "Clubs", "/explore/clubs", "discover", "shield_outlined", "3.16", PUBLIC, None, "explore", PL, "Find clubs and academies."),
    ("explore.coaches", "Coaches", "/explore/coaches", "discover", "sports", "3.3", PUBLIC, None, "explore", PL, "Find coaches and coaching centers."),
    ("explore.referees", "Referees and scorers", "/explore/referees", "discover", "gavel", "3.4", PUBLIC, None, "explore", PL, "Find referees, umpires and scorers."),
    ("explore.grounds", "Grounds", "/explore/grounds", "discover", "stadium_outlined", "3.12", PUBLIC, None, "explore", PL, "Find grounds and book them."),
    ("explore.talent", "Talent search", "/explore/talent", "discover", "star_outline", "3.17", SIGNED_IN, None, "explore", PL, "Clubs and academies look for players."),
    ("explore.trending", "Trending tournaments", "/explore/trending", "discover", "trending_up", "3.8", PUBLIC, None, "explore", PL, "Popular tournaments right now."),
    ("explore.rankings", "Rankings", "/explore/rankings", "discover", "leaderboard_outlined", "4.5", PUBLIC, None, "explore", PL, "Player and team rankings."),
    ("discover.map", "Nearby map", "/map", "discover", "map_outlined", "3.2", PUBLIC, None, "explore", PL, "Tournaments around you on a map."),
    ("discover.calendar", "Tournament calendar", "/calendar", "discover", "calendar_month_outlined", "4.7", PUBLIC, None, "explore", PL, "All tournaments by date."),
    ("discover.scan", "Scan QR code", "/scan", "discover", "qr_code_scanner", "4.4", PUBLIC, None, "explore", PL, "Open a tournament or check a player ID."),
    ("discover.search", "Search", "/search", "discover", "search", "1.6", PUBLIC, None, None, PL, "Search everything by name or place."),
    ("community.feed", "Community feed", "/feed", "community", "feed_outlined", "3.5", PUBLIC, None, "explore", PL, "Posts, photos and updates."),

    # ---- Create tab ----
    ("create.tournament", "Create a tournament", "/create/tournament", "create", "add_circle_outline", "1.3", PERM, "createTournament", "create", PL, "Quick wizard, ready in 5 to 10 minutes."),
    ("create.team", "Create a team", "/create/team", "create", "groups_outlined", "1.7", PERM, "registerTeam", "create", PL, "Team name, logo and players."),
    ("create.club", "Create a club", "/create/club", "create", "shield_outlined", "2.7", SIGNED_IN, None, "create", PL, "Club profile and trials."),
    ("create.playerProfile", "Player profile", "/create/player-profile", "create", "person_add_outlined", "2.5", SIGNED_IN, None, "create", PL, "Your football or cricket profile."),
    ("create.coachProfile", "Coach profile", "/create/coach-profile", "create", "sports", "3.3", SIGNED_IN, None, "create", PL, "Advertise your coaching."),
    ("create.refereeProfile", "Referee or scorer profile", "/create/referee-profile", "create", "gavel", "3.4", SIGNED_IN, None, "create", PL, "Offer your services to organizers."),
    ("create.ground", "List a ground", "/create/ground", "create", "stadium_outlined", "3.12", SIGNED_IN, None, "create", PL, "Add a ground, rent and facilities."),
    ("create.post", "Write a post", "/create/post", "create", "edit_note", "3.5", PERM, "createPost", "create", PL, "Share a photo, video or update."),

    # ---- My Sports tab ----
    ("mine.tournaments", "My tournaments", "/my-sports/tournaments", "mySports", "emoji_events_outlined", "1.3", SIGNED_IN, None, "mySports", PL, "Tournaments you organize."),
    ("mine.teams", "My teams", "/my-sports/teams", "mySports", "groups_outlined", "1.7", SIGNED_IN, None, "mySports", PL, "Teams you manage or play in."),
    ("mine.matches", "My matches", "/my-sports/matches", "mySports", "sports_soccer", "2.1", SIGNED_IN, None, "mySports", PL, "Matches you score or play."),
    ("mine.registrations", "My registrations", "/my-sports/registrations", "mySports", "how_to_reg_outlined", "1.7", SIGNED_IN, None, "mySports", PL, "Where your teams are registered."),
    ("mine.following", "Following", "/my-sports/following", "mySports", "bookmark_border", "2.18", SIGNED_IN, None, "mySports", PL, "Tournaments and organizers you follow."),
    ("mine.career", "Career and statistics", "/my-sports/career", "mySports", "timeline", "2.17", SIGNED_IN, None, "mySports", PL, "Your matches, goals, runs and wickets."),
    ("mine.id", "Digital ID card", "/my-sports/id", "mySports", "badge_outlined", "4.4", SIGNED_IN, None, "mySports", PL, "Your player or organizer ID with QR."),
    ("mine.certificates", "Certificates and trophies", "/my-sports/certificates", "mySports", "workspace_premium_outlined", "4.3", SIGNED_IN, None, "mySports", PL, "Certificates you earned."),

    # ---- Tournament (public) ----
    ("tournament.detail", "Tournament", "/t/:id", "tournament", "emoji_events_outlined", "1.3", PUBLIC, None, None, PL, "Details, fixtures, points table and teams."),
    ("tournament.rules", "Tournament rules", "/t/:id/rules", "tournament", "rule", "1B.1", PUBLIC, None, None, PL, "Rules set by the organizer."),
    ("tournament.register", "Register a team", "/t/:id/register", "tournament", "how_to_reg_outlined", "1.7", PERM, "registerTeam", None, PL, "Enter your team in this tournament."),
    ("tournament.awards", "Awards", "/t/:id/awards", "tournament", "workspace_premium_outlined", "2.8", PUBLIC, None, None, PL, "Top scorer, best goalkeeper and more."),
    ("tournament.gallery", "Gallery and highlights", "/t/:id/gallery", "tournament", "photo_library_outlined", "4.6", PUBLIC, None, None, PL, "Photos and match videos."),
    ("tournament.sponsors", "Sponsors", "/t/:id/sponsors", "tournament", "business_center_outlined", "4.2", PUBLIC, None, None, PL, "Who supports this tournament."),
    ("tournament.chat", "Tournament chat", "/t/:id/chat", "tournament", "forum_outlined", "3.13", SIGNED_IN, None, None, PL, "Group chat for teams and organizers."),

    # ---- Organizer tools ----
    ("manage.home", "Manage tournament", "/t/:id/manage", "manage", "dashboard_outlined", "1.3", PERM, "editTournament", None, PL, "Organizer dashboard."),
    ("manage.edit", "Edit tournament", "/t/:id/manage/edit", "manage", "edit_outlined", "1.3", PERM, "editTournament", None, PL, "Change details, dates and prizes."),
    ("manage.teams", "Teams and registrations", "/t/:id/manage/teams", "manage", "groups_outlined", "1.7", PERM, "manageRegistrations", None, PL, "Approve or reject teams."),
    ("manage.fixtures", "Fixtures", "/t/:id/manage/fixtures", "manage", "event_note_outlined", "1.8", PERM, "manageFixtures", None, PL, "Generate and change fixtures."),
    ("manage.matches", "Matches and results", "/t/:id/manage/matches", "manage", "sports_soccer", "1.9", PERM, "manageFixtures", None, PL, "Set times, grounds, referees and results."),
    ("manage.rules", "Rules builder", "/t/:id/manage/rules", "manage", "rule", "1B.1", PERM, "editTournament", None, PL, "Write the rules of your tournament."),
    ("manage.announcements", "Announcements", "/t/:id/manage/announcements", "manage", "campaign_outlined", "1B.11", PERM, "sendAnnouncement", None, PL, "Message all teams and followers."),
    ("manage.protests", "Protests", "/t/:id/manage/protests", "manage", "gavel", "1B.9", PERM, "resolveProtest", None, PL, "Review and decide protests."),
    ("manage.scorers", "Scorers", "/t/:id/manage/scorers", "manage", "assignment_ind_outlined", "2.1", PERM, "assignScorer", None, PL, "Choose who scores each match."),
    ("manage.finance", "Finance", "/t/:id/manage/finance", "manage", "account_balance_wallet_outlined", "4.1", PERM, "viewFinance", None, PL, "Income, expenses and balance."),
    ("manage.sponsors", "Sponsor packages", "/t/:id/manage/sponsors", "manage", "business_center_outlined", "4.2", PERM, "editTournament", None, PL, "Publish sponsorship packages."),
    ("manage.share", "Share, QR and poster", "/t/:id/manage/share", "manage", "share_outlined", "1B.10", PERM, "editTournament", None, PL, "Link, QR code and poster to share."),
    ("manage.certificates", "Certificates", "/t/:id/manage/certificates", "manage", "workspace_premium_outlined", "4.3", PERM, "editTournament", None, PL, "Make certificates for teams and players."),

    # ---- Match ----
    ("match.detail", "Match", "/m/:id", "match", "sports_soccer", "1.9", PUBLIC, None, None, PL, "Score, timeline and details."),
    ("match.lineup", "Line-up", "/t/:id/match/:matchId/lineup", "match", "list_alt", "2.12", PERM, "manageSquad", None, PL, "Starting players and substitutes."),
    ("match.score", "Score the match", "/t/:id/match/:matchId/score", "match", "edit_note", "2.2", PERM, "enterScore", None, PL, "Live scoring, works offline."),

    # ---- Team / player / club / others ----
    ("team.detail", "Team", "/team/:id", "team", "groups_outlined", "1.7", PUBLIC, None, None, PL, "Players, results and achievements."),
    ("team.squad", "Team squad", "/team/:id/squad", "team", "list_alt", "1.7", SIGNED_IN, None, None, PL, "Manage players and jersey numbers."),
    ("team.edit", "Edit team", "/team/:id/edit", "team", "edit_outlined", "1.7", SIGNED_IN, None, None, PL, "Name, logo and contact."),
    ("player.detail", "Player", "/p/:id", "player", "person_outline", "2.5", PUBLIC, None, None, PL, "Profile, statistics and videos."),
    ("player.edit", "Edit player profile", "/p/:id/edit", "player", "edit_outlined", "2.5", SIGNED_IN, None, None, PL, "Position, photo and videos."),
    ("player.compare", "Compare players", "/p/:id/compare", "player", "compare_arrows", "2.17", PUBLIC, None, None, PL, "Two players side by side."),
    ("club.detail", "Club", "/c/:id", "club", "shield_outlined", "2.7", PUBLIC, None, None, PL, "Players, history and trophies."),
    ("club.edit", "Edit club", "/c/:id/edit", "club", "edit_outlined", "2.7", SIGNED_IN, None, None, PL, "Club details."),
    ("club.trials", "Club trials", "/c/:id/trials", "club", "event_available_outlined", "3.10", PUBLIC, None, None, PL, "Trial announcements and applications."),
    ("coach.detail", "Coach", "/coach/:id", "coach", "sports", "3.3", PUBLIC, None, None, PL, "Experience, fees and reviews."),
    ("referee.detail", "Referee or scorer", "/ref/:id", "referee", "gavel", "3.4", PUBLIC, None, None, PL, "Experience and work area."),
    ("ground.detail", "Ground", "/g/:id", "ground", "stadium_outlined", "3.12", PUBLIC, None, None, PL, "Photos, facilities, rent and availability."),
    ("ground.book", "Book a ground", "/g/:id/book", "ground", "event_available_outlined", "3.12", SIGNED_IN, None, None, PL, "Send a booking request."),
    ("organizer.detail", "Organizer", "/o/:id", "organizer", "verified_outlined", "3.6", PUBLIC, None, None, PL, "Tournaments by this organizer."),

    # ---- Community ----
    ("community.post", "Post", "/post/:id", "community", "feed_outlined", "3.5", PUBLIC, None, None, PL, "A post with comments."),
    ("community.chats", "Chats", "/chats", "community", "chat_bubble_outline", "3.13", SIGNED_IN, None, None, PL, "Your conversations."),
    ("community.chat", "Chat", "/chats/:id", "community", "forum_outlined", "3.13", SIGNED_IN, None, None, PL, "One conversation."),

    # ---- Settings and help ----
    ("settings.edit", "Edit profile", "/profile/edit", "settings", "edit_outlined", "1.1", SIGNED_IN, None, None, PL, "Name, photo and home area."),
    ("settings.notifications", "Notification settings", "/profile/notifications", "settings", "notifications_outlined", "1B.13", SIGNED_IN, None, None, PL, "Choose what you get notified about."),
    ("settings.language", "Language", "/profile/language", "settings", "language", "0.4", PUBLIC, None, None, B, "Bangla or English."),
    ("settings.appearance", "Appearance", "/profile/appearance", "settings", "dark_mode_outlined", "1B.13", PUBLIC, None, None, PL, "Light or dark mode."),
    ("settings.security", "Login history and devices", "/profile/security", "settings", "security", "1B.12", SIGNED_IN, None, None, PL, "Where your account is signed in."),
    ("settings.data", "Download or delete my data", "/profile/data", "settings", "download_outlined", "1B.12", SIGNED_IN, None, None, PL, "Export your data or delete your account."),
    ("settings.verification", "Get verified", "/profile/verification", "settings", "verified_outlined", "3.6", SIGNED_IN, None, None, PL, "Apply for a verified badge."),
    ("settings.payments", "Payment history", "/profile/payments", "settings", "payments_outlined", "5.9", SIGNED_IN, None, None, PL, "Receipts, refunds and disputes."),
    ("settings.privacy", "Privacy settings", "/privacy", "settings", "lock_outline", "0.9", PUBLIC, None, None, B, "Choose who can see your details."),
    ("settings.help", "Help and support", "/help", "settings", "help_outline", "1.15", PUBLIC, None, None, PL, "Questions, problems and contact."),
    ("settings.about", "About", "/about", "settings", "info_outline", "0.3", PUBLIC, None, None, PL, "Version and credits."),
    ("settings.terms", "Terms and privacy policy", "/terms", "settings", "description_outlined", "1.1", PUBLIC, None, None, PL, "Rules for using the app."),

    # ---- System ----
    ("system.noAccess", "No access", "/no-access", "system", "lock_outline", "0.3", PUBLIC, None, None, B, "Shown when you may not open a screen."),
    ("system.notifications", "Notifications", "/notifications", "system", "notifications_outlined", "1.13", SIGNED_IN, None, None, PL, "Your updates."),
    ("system.report", "Report", "/report/:type/:id", "system", "flag_outlined", "1.15", SIGNED_IN, None, None, PL, "Report a tournament, user, post or match."),

    # ---- Admin ----
    ("admin.home", "Admin dashboard", "/admin", "admin", "dashboard_outlined", "1.14", PERM, "viewAnalytics", None, PL, "Overview for admins and moderators."),
    ("admin.tournaments", "Approve tournaments", "/admin/tournaments", "admin", "fact_check_outlined", "1.14", PERM, "approveTournament", None, PL, "Review new tournaments."),
    ("admin.users", "Users and organizers", "/admin/users", "admin", "manage_accounts_outlined", "1.14", PERM, "verifyOrganizer", None, PL, "Look up and verify people."),
    ("admin.reports", "Reports", "/admin/reports", "admin", "flag_outlined", "1.14", PERM, "moderateContent", None, PL, "Handle reported content."),
    ("admin.verifications", "Verification requests", "/admin/verifications", "admin", "verified_outlined", "3.6", PERM, "verifyOrganizer", None, PL, "Check documents and badges."),
    ("admin.suspensions", "Suspensions and appeals", "/admin/suspensions", "admin", "block", "3.14", PERM, "suspendAccount", None, PL, "Suspend accounts and review appeals."),
    ("admin.payments", "Payments", "/admin/payments", "admin", "payments_outlined", "4.8", PERM, "managePayments", None, PL, "Payment monitoring and disputes."),
    ("admin.ads", "Advertisements", "/admin/ads", "admin", "campaign_outlined", "4.8", PERM, "managePayments", None, PL, "Control ads and featured tournaments."),
    ("admin.analytics", "Analytics", "/admin/analytics", "admin", "analytics_outlined", "4.8", PERM, "viewAnalytics", None, PL, "App statistics."),
    ("admin.audit", "Audit logs", "/admin/audit", "admin", "history", "4.11", PERM, "viewAuditLogs", None, PL, "Who did what, and when."),
    ("admin.roles", "Admins and roles", "/admin/roles", "admin", "admin_panel_settings_outlined", "1B.12", PERM, "manageAdmins", None, PL, "Add and remove admins."),
]

AREA_LABELS = {
    "tabs": "Main tabs",
    "auth": "Sign in",
    "discover": "Discover",
    "create": "Create",
    "mySports": "My Sports",
    "tournament": "Tournament",
    "manage": "Organizer tools",
    "match": "Match",
    "team": "Team",
    "player": "Player",
    "club": "Club",
    "coach": "Coach",
    "referee": "Referee",
    "ground": "Ground",
    "organizer": "Organizer",
    "community": "Community",
    "settings": "Settings and help",
    "system": "System",
    "admin": "Admin",
}
