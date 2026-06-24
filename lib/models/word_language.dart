/// Script used to fill empty grid cells for a given language.
enum LetterScript { latin, arabic, cyrillic }

/// Languages whose words fit the letter grid (single-script, no spaces).
enum WordLanguage {
  english('en', LetterScript.latin, false, 'English', '🇬🇧'),
  arabic('ar', LetterScript.arabic, true, 'العربية', '🇸🇦'),
  spanish('es', LetterScript.latin, false, 'Español', '🇪🇸'),
  french('fr', LetterScript.latin, false, 'Français', '🇫🇷'),
  german('de', LetterScript.latin, false, 'Deutsch', '🇩🇪'),
  portuguese('pt', LetterScript.latin, false, 'Português', '🇵🇹'),
  italian('it', LetterScript.latin, false, 'Italiano', '🇮🇹'),
  turkish('tr', LetterScript.latin, false, 'Türkçe', '🇹🇷'),
  russian('ru', LetterScript.cyrillic, false, 'Русский', '🇷🇺'),
  indonesian('id', LetterScript.latin, false, 'Indonesia', '🇮🇩');

  const WordLanguage(
    this.code,
    this.script,
    this.isRtl,
    this.nativeName,
    this.flag,
  );

  final String code;
  final LetterScript script;
  final bool isRtl;
  final String nativeName;
  final String flag;

  static WordLanguage fromCode(String code) {
    return WordLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => WordLanguage.english,
    );
  }
}
