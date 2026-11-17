# Bangla and English (Step 0.4)

The whole app speaks Bangla and English. Bangla is the default, because most people
using this app read Bangla. Anyone can switch in **Profile, Language** (or the language
icon on Home). The choice is saved on the phone and applies at once, with no restart.

## How it works

| Piece | Where | Job |
|---|---|---|
| `AppLanguage` | `lib/core/l10n/app_language.dart` | The two languages, Bangla is the default |
| `languageProvider` | `lib/core/l10n/language_provider.dart` | The chosen language, saved on the phone |
| `AppStrings` | `lib/core/l10n/app_strings.dart` | Every text in the app, as a typed list |
| `EnglishStrings`, `BanglaStrings` | `strings_en.dart`, `strings_bn.dart` | The two translations |
| `AppFormats` | `lib/core/l10n/app_formats.dart` | Numbers, money, dates, times |
| Screen titles | `tool/screens_bn.py` | Bangla title and description of each of the 105 screens |
| Phone's own texts | `flutter_localizations` | Bangla for system dialogs, date pickers, back buttons |

In a screen, read text with `context.s`:

```dart
final s = context.s;
Text(s.tryAgain)
Text(spec.titleFor(s.language))
```

Never type user-facing text directly in a screen.

## Why a typed list and not .arb files

Both languages are Dart classes that must implement the same list. If someone adds a
text to one language and forgets the other, **the app does not compile**. A forgotten
translation can never reach a user as a blank or English-only screen. There is no code
generation step that could break the build.

Tests also check that every text exists in both languages, that English texts contain no
Bangla letters, that Bangla texts do, and that all 105 screens have Bangla titles.

## Adding a new text

1. Add a getter or method to `AppStrings` (and to `debugAllTexts` if it is plain text).
2. Write it in `EnglishStrings` and in `BanglaStrings`.
3. Use it as `context.s.yourText`.

Adding a value to an enum that has translations (Permission, Audience, AccountRole,
ValidationIssue) forces a translation too, because those lists must cover every value.

New screen: add it to `tool/screens_data.py` and its Bangla title and description to
`tool/screens_bn.py`, then run `python3 tool/generate_screens.py`.

## Numbers, money, dates (Bangladesh style)

| Item | English | Bangla |
|---|---|---|
| Number | 2026 | ২০২৬ |
| Amount | ৳1,00,000 | ১,০০,০০০ টাকা |
| Date | 15 December 2026 | ১৫ ডিসেম্বর ২০২৬ |
| Time | 3:30 PM | বিকেল ৩:৩০ |

- Amounts group in lakh and crore: 12,34,567.
- Times always show **Bangladesh time (UTC+6)**, whatever the phone's time zone is.
- Bangla parts of the day: ভোর (4-6), সকাল (6-12), দুপুর (12-3), বিকেল (3-5),
  সন্ধ্যা (5-7), রাত (7-4).
- Phone numbers typed with Bangla digits are accepted (`InputValidators`).

## Writing style for Bangla

- Polite and simple: use আপনি, short sentences, end with ।
- Do not mix languages inside one sentence, except names such as BD Sports and
  words people already say in English (সাইন ইন, নোটিফিকেশন, কিউআর).
- Keep the same word for the same thing everywhere. Use this list:

| English | Bangla |
|---|---|
| Tournament | টুর্নামেন্ট |
| Match | ম্যাচ |
| Fixture | ফিক্সচার |
| Points table | পয়েন্ট টেবিল |
| Team / Squad | দল / দলের খেলোয়াড় তালিকা |
| Player | খেলোয়াড় |
| Club / Academy | ক্লাব / একাডেমি |
| Coach | কোচ |
| Referee / Umpire / Scorer | রেফারি / আম্পায়ার / স্কোরার |
| Organizer | আয়োজক |
| Ground | মাঠ |
| Registration | নিবন্ধন |
| Line-up / Substitute | লাইন-আপ / বদলি |
| Half time / Full time | হাফ টাইম / পূর্ণ সময় |
| Yellow / Red card | হলুদ / লাল কার্ড |
| Knockout / League / Group stage | নকআউট / লিগ / গ্রুপ পর্ব |
| Quarter-final / Semi-final / Final | কোয়ার্টার ফাইনাল / সেমিফাইনাল / ফাইনাল |
| Champion / Runner-up | চ্যাম্পিয়ন / রানার্স-আপ |
| Prize / Award | পুরস্কার |
| Walkover / Protest / Disqualify | ওয়াকওভার / প্রতিবাদ / দল বাতিল |
| Run / Wicket / Over | রান / উইকেট / ওভার |
| Sponsor | স্পন্সর |
| Verified | ভেরিফাইড |
| Follow | অনুসরণ |
| Privacy | গোপনীয়তা |
| Offline / Sync | অফলাইন / সিঙ্ক |

## Fonts

The app uses the phone's own Bangla font. Android phones sold in Bangladesh include one,
so text shows correctly without adding anything to the app. If some phone shows empty
boxes, the fix is to bundle a Bangla font file (for example Noto Sans Bengali) in the
app. That needs the font file, so it is left for the Design System step.

## What is not translated

- Developer tools (role tester, screen map, sync tester, link tester). They are removed
  from the production build.
- Text that comes from the server later (SMS, push notifications). The server will send
  each person's language with the request.
- The public web page is Bangla only for now. An English version arrives with Step 1B.10.
