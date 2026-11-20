import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../auth/account_role.dart';
import '../auth/permission.dart';
import '../navigation/screen_spec.dart';
import '../privacy/privacy_settings.dart';
import '../security/validation_issue.dart';
import 'app_formats.dart';
import 'app_language.dart';
import 'strings_bn.dart';
import 'strings_en.dart';

/// Every piece of text the app shows, in one typed list.
///
/// Both languages must write every item: a missing translation is a compile error,
/// not a blank screen. Screens read text with `context.s`, never as raw quotes.
/// Developer tools (role tester, sync tester, ...) are not translated.
abstract class AppStrings {
  const AppStrings();

  static const LocalizationsDelegate<AppStrings> delegate =
      _AppStringsDelegate();

  /// Text for the current language. Falls back to English where the app's
  /// localization is not set up (for example in small widget tests).
  static AppStrings of(BuildContext context) =>
      Localizations.of<AppStrings>(context, AppStrings) ??
      const EnglishStrings();

  AppLanguage get language;

  AppFormats get formats => AppFormats(language);

  // ---- Bottom navigation ----
  String get tabHome;
  String get tabExplore;
  String get tabCreate;
  String get tabMySports;
  String get tabProfile;

  // ---- Common ----
  String get goHome;
  String get tryAgain;
  String get signIn;
  String get continueWithoutSigningIn;
  String get notSignedIn;
  String get signInComingSoon;
  String get linkInvalid;
  String get linkTitle;
  String get pageNotFoundTitle;
  String get pageNotFoundMessage;
  String get noAccessTitle;
  String get noAccessMessage;
  String get noAccessHint;

  // ---- Home and tabs ----
  String get welcome;
  String get homeIntro;
  String get quickLinks;
  String get exploreIntro;
  String get createIntro;
  String get mySportsIntro;

  // ---- Planned screens ----
  String stepLabel(String step);
  String builtInStep(String step);
  String accessLine(String access);
  String get idLabel;
  String get accessAnyone;
  String get accessSignedIn;

  // ---- Loading, empty, error and offline ----
  String get errorTitle;
  String get offlineTitle;
  String get offlineMessage;

  // ---- Offline bar ----
  String offlineWithPending(int count);
  String get offlineNoPending;
  String get syncing;
  String changesFailed(int count);
  String changesWaiting(int count);

  // ---- Privacy settings ----
  String get privacyTitle;
  String get privacyWhoCanSee;
  String get privacyPhone;
  String get privacyAge;
  String get privacyPhoto;
  String get privacyContact;
  String get privacyWhoCanMessage;
  String get privacyFindByPhone;
  String get privacyPlayers;
  String get privacyTalentSearch;
  String get privacyTalentSearchHint;
  String get privacyShowStats;
  String get privacyFooter;

  // ---- Language screen ----
  String get languageTitle;
  String get languageIntro;

  // ---- Appearance screen ----
  String get appearanceTitle;
  String get appearanceIntro;
  String get appearanceDark;
  String get appearanceLight;
  String get appearanceSystem;

  // ---- Home and tab screens ----
  String get homeBannerTitle;
  String get homeBannerBody;
  String get actionCreateTournament;
  String get quickDiscoverTitle;
  String get quickDiscoverBody;
  String get quickCreateBody;
  String get quickJoinTitle;
  String get quickJoinBody;
  String get trendingTitle;
  String get liveMatchesTitle;
  String get seeAll;
  String get searchHint;
  String get trendingEmpty;
  String get liveEmpty;

  // ---- Sign in and profile (Step 1.1) ----
  String get authWelcomeBack;
  String get authSignInSubtitle;
  String get authPhoneLabel;
  String get authPhoneHint;
  String get authSendCode;
  String get authTermsNote;
  String get authVerifyHeading;
  String get authVerify;
  String get authResend;
  String get authChangeNumber;
  String get authCodeResent;
  String get authCodeWrong;
  String get authTooMany;
  String get authOffline;
  String get authSomethingWrong;
  String get authPreviewHint;
  String get profileSetupHeading;
  String get profileSetupIntro;
  String get profileName;
  String get profileNameHint;
  String get profileDivision;
  String get profileDivisionHint;
  String get profileDivisionNone;
  String get profileRoleTitle;
  String get roleFanTitle;
  String get roleFanBody;
  String get roleOrganizerTitle;
  String get roleOrganizerBody;
  String get rolePlayerTitle;
  String get rolePlayerBody;
  String get roleNote;
  String get photoAdd;
  String get photoChange;
  String get photoRemove;
  String get photoFailed;
  String get profileContinue;
  String get profileSave;
  String get profileSaved;
  String get profileUseOtherNumber;
  String get signOut;
  String get signOutTitle;
  String get signOutBody;
  String get actionCancel;
  String get profileSignedOutHint;
  String authCodeSentTo(String phone);
  String authResendIn(int seconds);

  // ---- Names of enum values ----
  String permission(Permission permission);
  String accountRole(AccountRole role);
  String audience(Audience audience);
  String validation(ValidationIssue issue);

  /// Who may open a screen, in words.
  String accessOf(ScreenSpec spec) {
    switch (spec.access) {
      case ScreenAccess.public:
        return accessAnyone;
      case ScreenAccess.signedIn:
        return accessSignedIn;
      case ScreenAccess.permission:
        return permission(spec.permission!);
    }
  }

  /// All plain texts, for tests that check the two languages are complete.
  /// Add new plain texts here too.
  List<String> get debugAllTexts => <String>[
        tabHome, tabExplore, tabCreate, tabMySports, tabProfile,
        goHome, tryAgain, signIn, continueWithoutSigningIn, notSignedIn,
        signInComingSoon, linkInvalid, linkTitle, pageNotFoundTitle,
        pageNotFoundMessage, noAccessTitle, noAccessMessage, noAccessHint,
        welcome, homeIntro, quickLinks, exploreIntro, createIntro,
        mySportsIntro, idLabel, accessAnyone, accessSignedIn, errorTitle,
        offlineTitle, offlineMessage, offlineNoPending, syncing,
        privacyTitle, privacyWhoCanSee, privacyPhone, privacyAge,
        privacyPhoto, privacyContact, privacyWhoCanMessage,
        privacyFindByPhone, privacyPlayers, privacyTalentSearch,
        privacyTalentSearchHint, privacyShowStats, privacyFooter,
        languageTitle, languageIntro,
        appearanceTitle, appearanceIntro, appearanceDark, appearanceLight,
        appearanceSystem,
        homeBannerTitle,
        homeBannerBody,
        actionCreateTournament,
        quickDiscoverTitle,
        quickDiscoverBody,
        quickCreateBody,
        quickJoinTitle,
        quickJoinBody,
        trendingTitle,
        liveMatchesTitle,
        seeAll,
        searchHint,
        trendingEmpty,
        liveEmpty,
        authWelcomeBack,
        authSignInSubtitle,
        authPhoneLabel,
        authPhoneHint,
        authSendCode,
        authTermsNote,
        authVerifyHeading,
        authVerify,
        authResend,
        authChangeNumber,
        authCodeResent,
        authCodeWrong,
        authTooMany,
        authOffline,
        authSomethingWrong,
        authPreviewHint,
        profileSetupHeading,
        profileSetupIntro,
        profileName,
        profileNameHint,
        profileDivision,
        profileDivisionHint,
        profileDivisionNone,
        profileRoleTitle,
        roleFanTitle,
        roleFanBody,
        roleOrganizerTitle,
        roleOrganizerBody,
        rolePlayerTitle,
        rolePlayerBody,
        roleNote,
        photoAdd,
        photoChange,
        photoRemove,
        photoFailed,
        profileContinue,
        profileSave,
        profileSaved,
        profileUseOtherNumber,
        signOut,
        signOutTitle,
        signOutBody,
        actionCancel,
        profileSignedOutHint,
      ];
}

extension AppStringsContext on BuildContext {
  /// Text in the current language: `context.s.tryAgain`.
  AppStrings get s => AppStrings.of(this);
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLanguage.values.any((language) => language.code == locale.languageCode);

  @override
  Future<AppStrings> load(Locale locale) {
    final AppStrings strings =
        AppLanguage.fromCode(locale.languageCode) == AppLanguage.bangla
            ? const BanglaStrings()
            : const EnglishStrings();
    return SynchronousFuture<AppStrings>(strings);
  }

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}
