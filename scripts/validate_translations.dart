#!/usr/bin/env dart
// Translation validator — ensures all languages have identical keys.
// Run: dart run scripts/validate_translations.dart

import 'dart:io';

void main() {
  final file = File('lib/l10n/translations.dart');
  if (!file.existsSync()) {
    print('ERROR: translations.dart not found');
    exit(1);
  }

  final content = file.readAsStringSync();

  // Extract English keys (first language block)
  final enKeys = _extractKeys(content, "'en'");
  if (enKeys.isEmpty) {
    print('ERROR: Could not extract English keys');
    exit(1);
  }

  print('English keys: ${enKeys.length}');

  // Find all language codes
  final langPattern = RegExp(r"    '(\w+)': \{");
  final matches = langPattern.allMatches(content);
  final languages =
      matches.map((m) => m.group(1)!).where((l) => l != 'en').toList();

  print('Languages found: ${languages.join(', ')}');
  print('');

  var hasErrors = false;

  for (final lang in languages) {
    final langKeys = _extractKeys(content, "'$lang'");
    final missing = enKeys.difference(langKeys);
    final extra = langKeys.difference(enKeys);

    if (missing.isEmpty && extra.isEmpty) {
      print('  $lang — OK (${langKeys.length} keys)');
    } else {
      hasErrors = true;
      print('  $lang — MISMATCH');
      if (missing.isNotEmpty) {
        print('    Missing: ${missing.join(', ')}');
      }
      if (extra.isNotEmpty) {
        print('    Extra:   ${extra.join(', ')}');
      }
    }
  }

  print('');
  if (hasErrors) {
    print('VALIDATION FAILED — some languages are missing keys');
    exit(1);
  } else {
    print(
        'ALL LANGUAGES VALID — ${languages.length + 1} languages, ${enKeys.length} keys each');
  }
}

Set<String> _extractKeys(String content, String langMarker) {
  final keys = <String>{};
  final startIdx = content.indexOf(langMarker);
  if (startIdx == -1) return keys;

  // Find the opening brace
  final braceStart = content.indexOf('{', startIdx);
  if (braceStart == -1) return keys;

  // Find the closing brace by counting
  var depth = 0;
  var i = braceStart;
  while (i < content.length) {
    if (content[i] == '{') depth++;
    if (content[i] == '}') {
      depth--;
      if (depth == 0) break;
    }
    i++;
  }

  final block = content.substring(braceStart, i + 1);

  // Extract all keys
  final keyPattern = RegExp(r"^\s+'(\w+)':", multiLine: true);
  for (final match in keyPattern.allMatches(block)) {
    keys.add(match.group(1)!);
  }

  return keys;
}
