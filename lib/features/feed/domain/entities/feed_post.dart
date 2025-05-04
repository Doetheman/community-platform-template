class FeedPost {
  final String id;
  final String authorId;
  final String content;
  final String? mediaUrl;
  final DateTime createdAt;
  final List<String> likes;
  final String visibility; // e.g. 'public', 'followers', 'admin-only'

  const FeedPost({
    required this.id,
    required this.authorId,
    required this.content,
    this.mediaUrl,
    required this.createdAt,
    required this.likes,
    required this.visibility,
  });
}
