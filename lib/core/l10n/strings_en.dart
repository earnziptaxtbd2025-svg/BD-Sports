import '../auth/account_role.dart';
import '../auth/permission.dart';
import '../privacy/privacy_settings.dart';
import '../security/validation_issue.dart';
import 'app_language.dart';
import 'app_strings.dart';

class EnglishStrings extends AppStrings {
  const EnglishStrings();

  @override
  AppLanguage get language => AppLanguage.english;

  @override
  String get tabHome => 'Home';
  @override
  String get tabExplore => 'Explore';
  @override
  String get tabCreate => 'Create';
  @override
  String get tabMySports => 'My Sports';
  @override
  String get tabProfile => 'Profile';

  @override
  String get goHome => 'Go to Home';
  @override
  String get tryAgain => 'Try again';
  @override
  String get signIn => 'Sign in';
  @override
  String get continueWithoutSigningIn => 'Continue without signing in';
  @override
  String get notSignedIn => 'Not signed in';
  @override
  String get signInComingSoon => 'Sign-in is built in Step 1.1.';
  @override
  String get linkInvalid => 'This link is not valid.';
  @override
  String get linkTitle => 'Link';
  @override
  String get pageNotFoundTitle => 'Not found';
  @override
  String get pageNotFoundMessage => 'This page does not exist.';
  @override
  String get noAccessTitle => 'No access';
  @override
  String get noAccessMessage => 'You do not have access to this screen.';
  @override
  String get noAccessHint =>
      'Ask the organizer for permission, or sign in with another account.';

  @override
  String get welcome => 'Welcome';
  @override
  String get homeIntro => 'Tournaments near you will appear here (Step 1.5).';
  @override
  String get quickLinks => 'Quick links';
  @override
  String get exploreIntro =>
      'Find tournaments, teams, players, coaches and grounds.';
  @override
  String get createIntro => 'Start a tournament, team, club or profile.';
  @override
  String get mySportsIntro => 'Everything that belongs to you.';

  @override
  String stepLabel(String step) => 'Step $step';
  @override
  String builtInStep(String step) => 'Built in Step $step';
  @override
  String accessLine(String access) => 'Access: $access';
  @override
  String get idLabel => 'ID';
  @override
  String get accessAnyone => 'Anyone';
  @override
  String get accessSignedIn => 'Signed in';

  @override
  String get errorTitle => 'Something went wrong';
  @override
  String get offlineTitle => 'You are offline';
  @override
  String get offlineMessage =>
      'Showing saved information. It updates when the internet is back.';

  @override
  String offlineWithPending(int count) =>
      'Offline. $count change(s) saved on this phone, will sync automatically.';
  @override
  String get offlineNoPending =>
      'You are offline. Saved changes will sync when the internet is back.';
  @override
  String get syncing => 'Syncing...';
  @override
  String changesFailed(int count) => '$count change(s) could not be saved.';
  @override
  String changesWaiting(int count) => '$count change(s) waiting to sync.';

  @override
  String get privacyTitle => 'Privacy settings';
  @override
  String get privacyWhoCanSee => 'Who can see';
  @override
  String get privacyPhone => 'Phone number';
  @override
  String get privacyAge => 'Age';
  @override
  String get privacyPhoto => 'Profile photo';
  @override
  String get privacyContact => 'Contact';
  @override
  String get privacyWhoCanMessage => 'Who can message me';
  @override
  String get privacyFindByPhone => 'People can find me by phone number';
  @override
  String get privacyPlayers => 'Players';
  @override
  String get privacyTalentSearch => 'Show me in talent search';
  @override
  String get privacyTalentSearchHint =>
      'Clubs and academies can find your profile.';
  @override
  String get privacyShowStats => 'Show my match statistics';
  @override
  String get privacyFooter =>
      'These choices are saved on this phone for now. They will be linked to '
      'your account when sign-in is added.';

  @override
  String get languageTitle => 'Language';
  @override
  String get languageIntro => 'Choose the language of the app.';

  @override
  String permission(Permission permission) {
    switch (permission) {
      case Permission.createTournament:
        return 'Create a tournament';
      case Permission.registerTeam:
        return 'Register a team';
      case Permission.createPost:
        return 'Post in the community';
      case Permission.reportContent:
        return 'Report content or a user';
      case Permission.editOwnProfile:
        return 'Edit own profile';
      case Permission.editTournament:
        return 'Edit tournament details';
      case Permission.manageRegistrations:
        return 'Approve or reject teams';
      case Permission.manageFixtures:
        return 'Create and change fixtures';
      case Permission.enterScore:
        return 'Enter live score and results';
      case Permission.manageSquad:
        return 'Edit a team squad';
      case Permission.sendAnnouncement:
        return 'Send announcements';
      case Permission.viewFinance:
        return 'View tournament finance';
      case Permission.manageFinance:
        return 'Edit tournament finance';
      case Permission.resolveProtest:
        return 'Decide protests';
      case Permission.disqualifyTeam:
        return 'Disqualify a team';
      case Permission.assignScorer:
        return 'Assign scorers';
      case Permission.approveTournament:
        return 'Approve tournaments';
      case Permission.verifyOrganizer:
        return 'Verify organizers';
      case Permission.moderateContent:
        return 'Moderate content';
      case Permission.viewAnalytics:
        return 'View analytics';
      case Permission.suspendAccount:
        return 'Suspend accounts';
      case Permission.viewAuditLogs:
        return 'View audit logs';
      case Permission.manageAdmins:
        return 'Manage admins';
      case Permission.managePayments:
        return 'Manage payments';
    }
  }

  @override
  String accountRole(AccountRole role) {
    switch (role) {
      case AccountRole.member:
        return 'Member';
      case AccountRole.moderator:
        return 'Moderator';
      case AccountRole.superAdmin:
        return 'Super Admin';
    }
  }

  @override
  String audience(Audience audience) {
    switch (audience) {
      case Audience.everyone:
        return 'Everyone';
      case Audience.teammates:
        return 'My teams only';
      case Audience.nobody:
        return 'Only me';
    }
  }

  @override
  String validation(ValidationIssue issue) {
    switch (issue) {
      case ValidationIssue.phoneRequired:
        return 'Enter a mobile number.';
      case ValidationIssue.phoneInvalid:
        return 'Enter a valid Bangladesh mobile number, like 01712345678.';
      case ValidationIssue.nameTooShort:
        return 'Name is too short.';
      case ValidationIssue.nameTooLong:
        return 'Name is too long (maximum 60 letters).';
      case ValidationIssue.nameInvalidChars:
        return 'Name can only have letters, spaces, dot, dash and apostrophe.';
      case ValidationIssue.titleTooShort:
        return 'Title is too short.';
      case ValidationIssue.titleTooLong:
        return 'Title is too long (maximum 80 characters).';
      case ValidationIssue.titleNeedsLetters:
        return 'Title needs letters or numbers.';
      case ValidationIssue.amountRequired:
        return 'Enter an amount.';
      case ValidationIssue.amountInvalid:
        return 'Enter a whole amount in taka (0 to 10,000,000).';
    }
  }
}
