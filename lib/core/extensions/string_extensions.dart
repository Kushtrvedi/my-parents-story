extension StringExtensions on String {
  String get trimmed => trim();
  bool get isBlank => trim().isEmpty;
  bool get isNotBlank => trim().isNotEmpty;

  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  List<String> extractWords() {
    return split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  }

  double similarityTo(String other) {
    if (isEmpty || other.isEmpty) return 0.0;
    final longer = length > other.length ? this : other;
    final shorter = length > other.length ? other : this;
    if (longer.isEmpty) return 1.0;

    final costs = List<int>.generate(shorter.length + 1, (i) => i);
    for (var i = 1; i <= longer.length; i++) {
      var prevCost = i - 1;
      costs[0] = i;
      for (var j = 1; j <= shorter.length; j++) {
        final cost = longer[i - 1] == shorter[j - 1] ? 0 : 1;
        final insertCost = costs[j] + 1;
        final deleteCost = costs[j - 1] + 1;
        final replaceCost = prevCost + cost;
        prevCost = costs[j];
        costs[j] = insertCost < deleteCost
            ? (insertCost < replaceCost ? insertCost : replaceCost)
            : (deleteCost < replaceCost ? deleteCost : replaceCost);
      }
    }
    return (longer.length - costs[shorter.length]) / longer.length;
  }
}
