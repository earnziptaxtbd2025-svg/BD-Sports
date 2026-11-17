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
