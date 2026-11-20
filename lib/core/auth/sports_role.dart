/// What a person mainly wants to do in the app. They choose it when they set up their
/// profile and can change it later.
///
/// This is a preference only. It does NOT give any permission. Organizer tools open
/// when a person creates a tournament or is given a role in one (see TournamentRole).
enum SportsRole {
  fan,
  organizer,
  player;

  /// Reads a saved value. Anything unknown gives [fan].
  static SportsRole fromCode(String? code) {
    for (final role in SportsRole.values) {
      if (role.name == code) {
        return role;
      }
    }
    return SportsRole.fan;
  }
}
