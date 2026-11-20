import '../../../core/auth/auth_repository.dart';
import '../../../core/auth/sports_role.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/security/validation_issue.dart';

/// The message shown to the person for a sign-in problem, in the current language.
String authFailureText(AppStrings s, AuthFailure failure) {
  switch (failure) {
    case AuthFailure.invalidPhone:
      return s.validation(ValidationIssue.phoneInvalid);
    case AuthFailure.tooManyRequests:
      return s.authTooMany;
    case AuthFailure.wrongCode:
    case AuthFailure.expiredCode:
      return s.authCodeWrong;
    case AuthFailure.offline:
      return s.authOffline;
    case AuthFailure.unknown:
      return s.authSomethingWrong;
  }
}

String sportsRoleTitle(AppStrings s, SportsRole role) {
  switch (role) {
    case SportsRole.fan:
      return s.roleFanTitle;
    case SportsRole.organizer:
      return s.roleOrganizerTitle;
    case SportsRole.player:
      return s.rolePlayerTitle;
  }
}
