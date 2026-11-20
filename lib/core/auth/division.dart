import '../l10n/app_language.dart';

/// The eight divisions of Bangladesh. Step 1.1 asks only for the division. Step 1.2
/// adds district, upazila, union and village.
enum Division {
  dhaka('Dhaka', 'ঢাকা'),
  chattogram('Chattogram', 'চট্টগ্রাম'),
  rajshahi('Rajshahi', 'রাজশাহী'),
  khulna('Khulna', 'খুলনা'),
  barishal('Barishal', 'বরিশাল'),
  sylhet('Sylhet', 'সিলেট'),
  rangpur('Rangpur', 'রংপুর'),
  mymensingh('Mymensingh', 'ময়মনসিংহ');

  const Division(this.en, this.bn);

  final String en;
  final String bn;

  String labelFor(AppLanguage language) =>
      language == AppLanguage.bangla ? bn : en;

  /// Reads a saved value. Unknown or empty gives null.
  static Division? fromCode(String? code) {
    for (final division in Division.values) {
      if (division.name == code) {
        return division;
      }
    }
    return null;
  }
}
