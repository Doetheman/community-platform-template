class Poll {
  final String id;
  final String authorId;
  final String question;
  final List<PollOption> options;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isMultipleChoice;
  final String? spaceId;

  const Poll({
    required this.id,
    required this.authorId,
    required this.question,
    required this.options,
    required this.createdAt,
    required this.expiresAt,
    this.isMultipleChoice = false,
    this.spaceId,
  });
}

class PollOption {
  final String id;
  final String text;
  final List<String> voterIds;

  const PollOption({
    required this.id,
    required this.text,
    required this.voterIds,
  });

  int get voteCount => voterIds.length;
}
