bool containsBannedWords(String message, List<String> bannedWords) {
  final pattern = RegExp(
    '\\b(${bannedWords.join('|')})\\b',
    caseSensitive: false,
  );
  return pattern.hasMatch(message);
}
