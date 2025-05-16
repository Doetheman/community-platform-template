class Chat {
  final String id;
  final List<String> participants;
  final String? lastMessage;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isGroup;
  final String? name;
  final Map<String, int> unreadCounts; // Map of userId to unread count

  Chat({
    required this.id,
    required this.participants,
    this.lastMessage,
    required this.createdAt,
    this.updatedAt,
    this.isGroup = false,
    this.name,
    this.unreadCounts = const {},
  });
}
