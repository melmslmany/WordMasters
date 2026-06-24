/// Supported UI languages (top widely-spoken languages).
class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.nativeName,
    required this.flag,
    this.isRtl = false,
  });

  final String code;
  final String nativeName;
  final String flag;
  final bool isRtl;
}

abstract final class AppLanguages {
  static const all = [
    AppLanguage(code: 'en', nativeName: 'English', flag: '🇬🇧'),
    AppLanguage(code: 'ar', nativeName: 'العربية', flag: '🇸🇦', isRtl: true),
    AppLanguage(code: 'es', nativeName: 'Español', flag: '🇪🇸'),
    AppLanguage(code: 'fr', nativeName: 'Français', flag: '🇫🇷'),
    AppLanguage(code: 'de', nativeName: 'Deutsch', flag: '🇩🇪'),
    AppLanguage(code: 'it', nativeName: 'Italiano', flag: '🇮🇹'),
    AppLanguage(code: 'tr', nativeName: 'Türkçe', flag: '🇹🇷'),
    AppLanguage(code: 'ru', nativeName: 'Русский', flag: '🇷🇺'),
    AppLanguage(code: 'pt', nativeName: 'Português', flag: '🇵🇹'),
    AppLanguage(code: 'hi', nativeName: 'हिन्दी', flag: '🇮🇳'),
    AppLanguage(code: 'id', nativeName: 'Indonesia', flag: '🇮🇩'),
  ];

  static const supportedCodes = [
    'en', 'ar', 'es', 'fr', 'de', 'it', 'tr', 'ru', 'pt', 'hi', 'id',
  ];

  static bool isRtlCode(String code) =>
      all.firstWhere((l) => l.code == code,
          orElse: () => all.first).isRtl;

  static AppLanguage byCode(String code) => all.firstWhere(
        (l) => l.code == code,
        orElse: () => all.first,
      );
}
