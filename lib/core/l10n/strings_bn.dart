import '../auth/account_role.dart';
import '../auth/permission.dart';
import '../privacy/privacy_settings.dart';
import '../security/validation_issue.dart';
import 'app_language.dart';
import 'app_strings.dart';

class BanglaStrings extends AppStrings {
  const BanglaStrings();

  @override
  AppLanguage get language => AppLanguage.bangla;

  @override
  String get tabHome => 'হোম';
  @override
  String get tabExplore => 'খুঁজুন';
  @override
  String get tabCreate => 'তৈরি করুন';
  @override
  String get tabMySports => 'আমার খেলা';
  @override
  String get tabProfile => 'প্রোফাইল';

  @override
  String get goHome => 'হোমে যান';
  @override
  String get tryAgain => 'আবার চেষ্টা করুন';
  @override
  String get signIn => 'সাইন ইন';
  @override
  String get continueWithoutSigningIn => 'সাইন ইন ছাড়াই চালিয়ে যান';
  @override
  String get notSignedIn => 'সাইন ইন করা নেই';
  @override
  String get signInComingSoon => 'সাইন ইন সুবিধা ধাপ ১.১-এ তৈরি হবে।';
  @override
  String get linkInvalid => 'এই লিংকটি সঠিক নয়।';
  @override
  String get linkTitle => 'লিংক';
  @override
  String get pageNotFoundTitle => 'পাওয়া যায়নি';
  @override
  String get pageNotFoundMessage => 'এই পাতাটি নেই।';
  @override
  String get noAccessTitle => 'প্রবেশ নেই';
  @override
  String get noAccessMessage => 'এই পাতাটি দেখার অনুমতি আপনার নেই।';
  @override
  String get noAccessHint =>
      'আয়োজকের কাছে অনুমতি চান, অথবা অন্য অ্যাকাউন্টে সাইন ইন করুন।';

  @override
  String get welcome => 'স্বাগতম';
  @override
  String get homeIntro => 'আপনার এলাকার টুর্নামেন্ট এখানে দেখা যাবে (ধাপ ১.৫)।';
  @override
  String get quickLinks => 'দ্রুত লিংক';
  @override
  String get exploreIntro => 'টুর্নামেন্ট, দল, খেলোয়াড়, কোচ ও মাঠ খুঁজুন।';
  @override
  String get createIntro => 'টুর্নামেন্ট, দল, ক্লাব বা প্রোফাইল তৈরি করুন।';
  @override
  String get mySportsIntro => 'আপনার সব খেলার তথ্য এক জায়গায়।';

  @override
  String stepLabel(String step) => 'ধাপ ${formats.digits(step)}';
  @override
  String builtInStep(String step) =>
      'ধাপ ${formats.digits(step)}-এ তৈরি হবে';
  @override
  String accessLine(String access) => 'প্রবেশাধিকার: $access';
  @override
  String get idLabel => 'আইডি';
  @override
  String get accessAnyone => 'যে কেউ';
  @override
  String get accessSignedIn => 'সাইন ইন করা ব্যক্তি';

  @override
  String get errorTitle => 'কিছু একটা সমস্যা হয়েছে';
  @override
  String get offlineTitle => 'আপনি অফলাইনে আছেন';
  @override
  String get offlineMessage =>
      'সংরক্ষিত তথ্য দেখানো হচ্ছে। ইন্টারনেট ফিরলে নতুন তথ্য আসবে।';

  @override
  String offlineWithPending(int count) =>
      'অফলাইন। ${formats.number(count)}টি পরিবর্তন এই ফোনে জমা আছে, '
      'ইন্টারনেট এলে নিজে থেকেই সিঙ্ক হবে।';
  @override
  String get offlineNoPending =>
      'আপনি অফলাইনে আছেন। ইন্টারনেট ফিরলে সংরক্ষিত পরিবর্তন সিঙ্ক হবে।';
  @override
  String get syncing => 'সিঙ্ক হচ্ছে...';
  @override
  String changesFailed(int count) =>
      '${formats.number(count)}টি পরিবর্তন সংরক্ষণ করা যায়নি।';
  @override
  String changesWaiting(int count) =>
      '${formats.number(count)}টি পরিবর্তন সিঙ্কের অপেক্ষায় আছে।';

  @override
  String get privacyTitle => 'গোপনীয়তা সেটিংস';
  @override
  String get privacyWhoCanSee => 'কে দেখতে পারবে';
  @override
  String get privacyPhone => 'ফোন নম্বর';
  @override
  String get privacyAge => 'বয়স';
  @override
  String get privacyPhoto => 'প্রোফাইল ছবি';
  @override
  String get privacyContact => 'যোগাযোগ';
  @override
  String get privacyWhoCanMessage => 'কে আমাকে মেসেজ পাঠাতে পারবে';
  @override
  String get privacyFindByPhone => 'ফোন নম্বর দিয়ে অন্যরা আমাকে খুঁজে পাবে';
  @override
  String get privacyPlayers => 'খেলোয়াড়';
  @override
  String get privacyTalentSearch => 'প্রতিভা খোঁজায় আমাকে দেখান';
  @override
  String get privacyTalentSearchHint =>
      'ক্লাব ও একাডেমি আপনার প্রোফাইল খুঁজে পাবে।';
  @override
  String get privacyShowStats => 'আমার ম্যাচের পরিসংখ্যান দেখান';
  @override
  String get privacyFooter =>
      'এই পছন্দগুলো আপাতত এই ফোনে সংরক্ষিত থাকে। সাইন ইন চালু হলে এগুলো '
      'আপনার অ্যাকাউন্টের সাথে যুক্ত হবে।';

  @override
  String get languageTitle => 'ভাষা';
  @override
  String get languageIntro => 'অ্যাপের ভাষা বেছে নিন।';

  @override
  String get appearanceTitle => 'চেহারা';

  @override
  String get appearanceIntro => 'অ্যাপ কেমন দেখাবে তা বেছে নিন।';

  @override
  String get appearanceDark => 'ডার্ক';

  @override
  String get appearanceLight => 'লাইট';

  @override
  String get appearanceSystem => 'ফোনের মতো';

  @override
  String get homeBannerTitle => 'নিজের টুর্নামেন্ট তৈরি করুন!';

  @override
  String get homeBannerBody => 'আপনার খেলার আয়োজনকে জীবন্ত করে তুলুন।';

  @override
  String get actionCreateTournament => 'টুর্নামেন্ট তৈরি করুন';

  @override
  String get quickDiscoverTitle => 'টুর্নামেন্ট খুঁজুন';

  @override
  String get quickDiscoverBody => 'খুঁজুন ও যোগ দিন';

  @override
  String get quickCreateBody => 'আয়োজন শুরু করুন';

  @override
  String get quickJoinTitle => 'টুর্নামেন্টে যোগ দিন';

  @override
  String get quickJoinBody => 'অংশ নিন';

  @override
  String get trendingTitle => 'জনপ্রিয় টুর্নামেন্ট';

  @override
  String get liveMatchesTitle => 'লাইভ ম্যাচ';

  @override
  String get seeAll => 'সব দেখুন';

  @override
  String get searchHint => 'টুর্নামেন্ট খুঁজুন...';

  @override
  String get trendingEmpty => 'জনপ্রিয় টুর্নামেন্ট এখানে দেখা যাবে।';

  @override
  String get liveEmpty => 'এখন যে ম্যাচ চলছে তা এখানে দেখা যাবে।';

  @override
  String get authWelcomeBack => 'আবার স্বাগতম!';

  @override
  String get authSignInSubtitle => 'চালিয়ে যেতে মোবাইল নম্বর দিয়ে সাইন ইন করুন।';

  @override
  String get authPhoneLabel => 'মোবাইল নম্বর';

  @override
  String get authPhoneHint => 'যেমন 01712345678';

  @override
  String get authSendCode => 'কোড পাঠান';

  @override
  String get authTermsNote => 'চালিয়ে গেলে আপনি শর্তাবলি ও গোপনীয়তা নীতিতে সম্মত হচ্ছেন।';

  @override
  String get authVerifyHeading => 'কোড লিখুন';

  @override
  String get authVerify => 'যাচাই করুন';

  @override
  String get authResend => 'কোড আবার পাঠান';

  @override
  String get authChangeNumber => 'নম্বর বদলান';

  @override
  String get authCodeResent => 'নতুন কোড পাঠানো হয়েছে।';

  @override
  String get authCodeWrong => 'কোডটি ঠিক নয় বা মেয়াদ শেষ। দেখে নিন বা নতুন কোড নিন।';

  @override
  String get authTooMany => 'অনেকবার চেষ্টা হয়েছে। কয়েক মিনিট অপেক্ষা করুন।';

  @override
  String get authOffline => 'ইন্টারনেট নেই। সংযোগ দিয়ে আবার চেষ্টা করুন।';

  @override
  String get authSomethingWrong => 'কিছু ভুল হয়েছে। আবার চেষ্টা করুন।';

  @override
  String get authPreviewHint => 'প্রিভিউ মোড: এসএমএস যায় না। কোড হিসেবে 123456 দিন।';

  @override
  String get profileSetupHeading => 'আপনার পরিচয় দিন';

  @override
  String get profileSetupIntro => 'এতে আয়োজক ও দল আপনাকে চিনতে পারবে।';

  @override
  String get profileName => 'পুরো নাম';

  @override
  String get profileNameHint => 'আপনার নাম';

  @override
  String get profileDivision => 'বিভাগ';

  @override
  String get profileDivisionHint => 'বিভাগ বেছে নিন';

  @override
  String get profileDivisionNone => 'বাছা হয়নি';

  @override
  String get profileRoleTitle => 'আমি মূলত চাই';

  @override
  String get roleFanTitle => 'দর্শক';

  @override
  String get roleFanBody => 'অনুসরণ করুন ও খবর রাখুন';

  @override
  String get roleOrganizerTitle => 'আয়োজক';

  @override
  String get roleOrganizerBody => 'টুর্নামেন্ট বানান ও চালান';

  @override
  String get rolePlayerTitle => 'খেলোয়াড়';

  @override
  String get rolePlayerBody => 'টুর্নামেন্টে যোগ দিন ও খেলুন';

  @override
  String get roleNote => 'পরে বদলাতে পারবেন। এতে আপনার অনুমতি বদলায় না।';

  @override
  String get photoAdd => 'ছবি দিন';

  @override
  String get photoChange => 'ছবি বদলান';

  @override
  String get photoRemove => 'ছবি সরান';

  @override
  String get photoFailed => 'ছবিটি নেওয়া যায়নি। অন্য ছবি চেষ্টা করুন।';

  @override
  String get profileContinue => 'চালিয়ে যান';

  @override
  String get profileSave => 'সংরক্ষণ করুন';

  @override
  String get profileSaved => 'প্রোফাইল সংরক্ষণ হয়েছে।';

  @override
  String get profileUseOtherNumber => 'অন্য নম্বর ব্যবহার করুন';

  @override
  String get signOut => 'সাইন আউট';

  @override
  String get signOutTitle => 'সাইন আউট করবেন?';

  @override
  String get signOutBody => 'আবার মোবাইল নম্বর দিয়ে সাইন ইন করতে পারবেন।';

  @override
  String get actionCancel => 'বাতিল';

  @override
  String get profileSignedOutHint => 'টুর্নামেন্ট বানাতে ও যোগ দিতে সাইন ইন করুন।';

  @override
  String authCodeSentTo(String phone) => '$phone নম্বরে ৬ সংখ্যার কোড পাঠানো হয়েছে।';

  @override
  String authResendIn(int seconds) => '$seconds সেকেন্ড পরে কোড আবার পাঠানো যাবে';

  @override
  String permission(Permission permission) {
    switch (permission) {
      case Permission.createTournament:
        return 'টুর্নামেন্ট তৈরি করা';
      case Permission.registerTeam:
        return 'দল নিবন্ধন করা';
      case Permission.createPost:
        return 'কমিউনিটিতে পোস্ট করা';
      case Permission.reportContent:
        return 'কনটেন্ট বা ব্যবহারকারীকে রিপোর্ট করা';
      case Permission.editOwnProfile:
        return 'নিজের প্রোফাইল সম্পাদনা';
      case Permission.editTournament:
        return 'টুর্নামেন্টের তথ্য সম্পাদনা';
      case Permission.manageRegistrations:
        return 'দল অনুমোদন বা বাতিল';
      case Permission.manageFixtures:
        return 'ফিক্সচার তৈরি ও পরিবর্তন';
      case Permission.enterScore:
        return 'লাইভ স্কোর ও ফলাফল লেখা';
      case Permission.manageSquad:
        return 'দলের খেলোয়াড় তালিকা সম্পাদনা';
      case Permission.sendAnnouncement:
        return 'ঘোষণা পাঠানো';
      case Permission.viewFinance:
        return 'টুর্নামেন্টের হিসাব দেখা';
      case Permission.manageFinance:
        return 'টুর্নামেন্টের হিসাব সম্পাদনা';
      case Permission.resolveProtest:
        return 'প্রতিবাদের সিদ্ধান্ত দেওয়া';
      case Permission.disqualifyTeam:
        return 'দল বাতিল করা';
      case Permission.assignScorer:
        return 'স্কোরার নিয়োগ';
      case Permission.approveTournament:
        return 'টুর্নামেন্ট অনুমোদন';
      case Permission.verifyOrganizer:
        return 'আয়োজক যাচাই';
      case Permission.moderateContent:
        return 'কনটেন্ট মডারেশন';
      case Permission.viewAnalytics:
        return 'পরিসংখ্যান দেখা';
      case Permission.suspendAccount:
        return 'অ্যাকাউন্ট স্থগিত করা';
      case Permission.viewAuditLogs:
        return 'অডিট লগ দেখা';
      case Permission.manageAdmins:
        return 'অ্যাডমিন ব্যবস্থাপনা';
      case Permission.managePayments:
        return 'পেমেন্ট ব্যবস্থাপনা';
    }
  }

  @override
  String accountRole(AccountRole role) {
    switch (role) {
      case AccountRole.member:
        return 'সদস্য';
      case AccountRole.moderator:
        return 'মডারেটর';
      case AccountRole.superAdmin:
        return 'সুপার অ্যাডমিন';
    }
  }

  @override
  String audience(Audience audience) {
    switch (audience) {
      case Audience.everyone:
        return 'সবাই';
      case Audience.teammates:
        return 'শুধু আমার দলের সদস্যরা';
      case Audience.nobody:
        return 'শুধু আমি';
    }
  }

  @override
  String validation(ValidationIssue issue) {
    switch (issue) {
      case ValidationIssue.phoneRequired:
        return 'মোবাইল নম্বর দিন।';
      case ValidationIssue.phoneInvalid:
        return 'সঠিক বাংলাদেশি মোবাইল নম্বর দিন, যেমন ০১৭১২৩৪৫৬৭৮।';
      case ValidationIssue.nameTooShort:
        return 'নামটি খুব ছোট।';
      case ValidationIssue.nameTooLong:
        return 'নামটি খুব বড় (সর্বোচ্চ ৬০ অক্ষর)।';
      case ValidationIssue.nameInvalidChars:
        return 'নামে শুধু অক্ষর, ফাঁকা জায়গা, ডট, ড্যাশ ও অ্যাপোস্ট্রফি থাকতে পারবে।';
      case ValidationIssue.titleTooShort:
        return 'শিরোনাম খুব ছোট।';
      case ValidationIssue.titleTooLong:
        return 'শিরোনাম খুব বড় (সর্বোচ্চ ৮০ অক্ষর)।';
      case ValidationIssue.titleNeedsLetters:
        return 'শিরোনামে অক্ষর বা সংখ্যা থাকতে হবে।';
      case ValidationIssue.amountRequired:
        return 'টাকার পরিমাণ লিখুন।';
      case ValidationIssue.amountInvalid:
        return 'টাকায় একটি পূর্ণ সংখ্যা লিখুন (০ থেকে ১,০০,০০,০০০)।';
    }
  }
}
