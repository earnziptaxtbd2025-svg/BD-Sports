/// Where a permission applies.
enum PermissionScope {
  /// Any signed-in member.
  member,

  /// Needs a role inside a specific tournament.
  tournament,

  /// Platform administration.
  admin,
}

/// Every action that can be allowed or denied in the app.
enum Permission {
  // Member
  createTournament('Create a tournament', PermissionScope.member),
  registerTeam('Register a team', PermissionScope.member),
  createPost('Post in the community', PermissionScope.member),
  reportContent('Report content or a user', PermissionScope.member),
  editOwnProfile('Edit own profile', PermissionScope.member),

  // Tournament
  editTournament('Edit tournament details', PermissionScope.tournament),
  manageRegistrations('Approve or reject teams', PermissionScope.tournament),
  manageFixtures('Create and change fixtures', PermissionScope.tournament),
  enterScore('Enter live score and results', PermissionScope.tournament),
  manageSquad('Edit a team squad', PermissionScope.tournament),
  sendAnnouncement('Send announcements', PermissionScope.tournament),
  viewFinance('View tournament finance', PermissionScope.tournament),
  manageFinance('Edit tournament finance', PermissionScope.tournament),
  resolveProtest('Decide protests', PermissionScope.tournament),
  disqualifyTeam('Disqualify a team', PermissionScope.tournament),
  assignScorer('Assign scorers', PermissionScope.tournament),

  // Admin
  approveTournament('Approve tournaments', PermissionScope.admin),
  verifyOrganizer('Verify organizers', PermissionScope.admin),
  moderateContent('Moderate content', PermissionScope.admin),
  viewAnalytics('View analytics', PermissionScope.admin),
  suspendAccount('Suspend accounts', PermissionScope.admin),
  viewAuditLogs('View audit logs', PermissionScope.admin),
  manageAdmins('Manage admins', PermissionScope.admin),
  managePayments('Manage payments', PermissionScope.admin);

  const Permission(this.label, this.scope);

  final String label;
  final PermissionScope scope;
}
