import 'dart:io';

void main() {
  final file = File('lib/l10n/translations.dart');
  if (!file.existsSync()) {
    print('Error: translations.dart not found.');
    exit(1);
  }

  final content = file.readAsStringSync();

  // Extract all language maps
  final RegExp langPattern = RegExp(r"'([a-z]{2})':\s*\{([^}]+)\}");
  final matches = langPattern.allMatches(content);

  if (matches.isEmpty) {
    print('Error: No languages found in translations.dart');
    exit(1);
  }

  final Map<String, Set<String>> languageKeys = {};

  for (final match in matches) {
    final lang = match.group(1)!;
    final keysStr = match.group(2)!;

    final RegExp keyPattern = RegExp(r"'([^']+)':");
    final keyMatches = keyPattern.allMatches(keysStr);

    final keys = keyMatches.map((m) => m.group(1)!).toSet();
    languageKeys[lang] = keys;
  }

  final enKeys = languageKeys['en'];
  if (enKeys == null) {
    print('Error: "en" language not found. It must be the base language.');
    exit(1);
  }

  bool hasErrors = false;

  for (final entry in languageKeys.entries) {
    final lang = entry.key;
    final keys = entry.value;

    if (lang == 'en') continue;

    // Check for missing keys
    final missingKeys = enKeys.difference(keys);
    if (missingKeys.isNotEmpty) {
      print(
          'Error: Language "$lang" is missing keys: ${missingKeys.join(', ')}');
      hasErrors = true;
    }

    // Check for extra/unused keys (present in lang but not in en)
    final extraKeys = keys.difference(enKeys);
    if (extraKeys.isNotEmpty) {
      print(
          'Error: Language "$lang" has extra keys not in "en": ${extraKeys.join(', ')}');
      hasErrors = true;
    }
  }

  if (hasErrors) {
    print('Translation validation failed.');
    exit(1);
  } else {
    print('Translation validation passed successfully.');
  }
}
