import 'dart:convert';
import 'dart:math';

class IdGenerator {
  static final _random = Random.secure();

  static String generate() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '').substring(0, 20);
  }

  static String generateForMemory(
      String profileId, String chapterId, String questionId) {
    return '${profileId}_${chapterId}_$questionId';
  }
}

class ChecksumCalculator {
  static String calculate(String data) {
    final bytes = utf8.encode(data);
    var hash = 0x811c9dc5;
    for (final byte in bytes) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  static bool verify(String data, String expectedChecksum) {
    return calculate(data) == expectedChecksum;
  }
}

class DateExtractor {
  static int? extractYear(String text) {
    final patterns = [
      RegExp(r'\b(19|20)\d{2}\b'),
      RegExp(r'\bin (\d{4})\b'),
      RegExp(r'\byear (\d{4})\b'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final yearStr = match.group(0)?.replaceAll(RegExp(r'[^\d]'), '') ?? '';
        final year = int.tryParse(yearStr);
        if (year != null && year >= 1900 && year <= DateTime.now().year) {
          return year;
        }
      }
    }
    return null;
  }

  static int? extractAge(String text, {int? referenceYear}) {
    final agePattern = RegExp(r'\b(\d{1,3})\s*(?:years?\s*old|saal|varsh)\b',
        caseSensitive: false);
    final match = agePattern.firstMatch(text);
    if (match != null) {
      final age = int.tryParse(match.group(1) ?? '');
      if (age != null && age >= 0 && age <= 120) {
        if (referenceYear != null) return referenceYear - age;
        return age;
      }
    }
    return null;
  }
}
