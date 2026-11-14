/// Role a person holds inside one specific tournament.
///
/// The same person can be an organizer in one tournament and only a
/// scorer in another, so these roles are stored per tournament, not per account.
enum TournamentRole {
  organizer('Organizer'),
  scorer('Scorer'),
  teamManager('Team manager');

  const TournamentRole(this.label);

  final String label;
}
