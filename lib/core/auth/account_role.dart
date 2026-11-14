/// Account-level role. Every signed-in person is at least a [member].
enum AccountRole {
  member('Member'),
  moderator('Moderator'),
  superAdmin('Super Admin');

  const AccountRole(this.label);

  final String label;
}
