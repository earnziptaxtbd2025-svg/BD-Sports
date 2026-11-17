/// What is wrong with a typed value. Validators return one of these (or null when
/// the value is fine) and each screen turns it into text in the current language.
enum ValidationIssue {
  phoneRequired,
  phoneInvalid,
  nameTooShort,
  nameTooLong,
  nameInvalidChars,
  titleTooShort,
  titleTooLong,
  titleNeedsLetters,
  amountRequired,
  amountInvalid,
}
