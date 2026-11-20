import 'account_role.dart';
import 'division.dart';
import 'sports_role.dart';
import 'tournament_role.dart';

/// The signed-in person, as far as permissions and the profile are concerned.
class AppUser {
  const AppUser({
    required this.id,
    required this.displayName,
    this.accountRole = AccountRole.member,
    this.tournamentRoles = const <String, Set<TournamentRole>>{},
    this.isSuspended = false,
    this.phone,
    this.division,
    this.sportsRole = SportsRole.fan,
  });

  final String id;

  /// Empty until the person finishes setting up the profile (Step 1.1).
  final String displayName;
  final AccountRole accountRole;

  /// Tournament id to the roles held in that tournament.
  final Map<String, Set<TournamentRole>> tournamentRoles;

  final bool isSuspended;

  /// Mobile number in the form +8801XXXXXXXXX.
  final String? phone;
  final Division? division;
  final SportsRole sportsRole;

  /// true once the person has given a name.
  bool get hasProfile => displayName.trim().isNotEmpty;

  Set<TournamentRole> rolesIn(String tournamentId) =>
      tournamentRoles[tournamentId] ?? const <TournamentRole>{};

  AppUser copyWith({
    String? displayName,
    AccountRole? accountRole,
    Map<String, Set<TournamentRole>>? tournamentRoles,
    bool? isSuspended,
    String? phone,
    Division? division,
    bool clearDivision = false,
    SportsRole? sportsRole,
  }) {
    return AppUser(
      id: id,
      displayName: displayName ?? this.displayName,
      accountRole: accountRole ?? this.accountRole,
      tournamentRoles: tournamentRoles ?? this.tournamentRoles,
      isSuspended: isSuspended ?? this.isSuspended,
      phone: phone ?? this.phone,
      division: clearDivision ? null : (division ?? this.division),
      sportsRole: sportsRole ?? this.sportsRole,
    );
  }

  /// The profile as saved on the phone. Tournament roles are not saved here: they
  /// come from the server.
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'name': displayName,
        'phone': phone,
        'division': division?.name,
        'sportsRole': sportsRole.name,
        'accountRole': accountRole.name,
        'suspended': isSuspended,
      };

  /// Reads a saved profile. Returns null if the data is damaged.
  static AppUser? fromJson(Object? json) {
    if (json is! Map) {
      return null;
    }
    final id = json['id'];
    final name = json['name'];
    if (id is! String || id.isEmpty || name is! String) {
      return null;
    }

    var role = AccountRole.member;
    for (final candidate in AccountRole.values) {
      if (candidate.name == json['accountRole']) {
        role = candidate;
      }
    }

    final phone = json['phone'];
    return AppUser(
      id: id,
      displayName: name,
      accountRole: role,
      isSuspended: json['suspended'] == true,
      phone: phone is String && phone.isNotEmpty ? phone : null,
      division: Division.fromCode(json['division'] as String?),
      sportsRole: SportsRole.fromCode(json['sportsRole'] as String?),
    );
  }
}
