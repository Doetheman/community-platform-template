class FeedPost {
  final String id;
  final String authorId;
  final String content;
  final String? mediaUrl;
  final String mediaType; // 'text', 'image', 'video'
  final DateTime createdAt;
  final List<String> likes;
  final int commentsCount;
  final int sharesCount;
  final List<String> tags;
  final String visibility; // e.g. 'public', 'followers', 'admin-only'
  final Map<String, List<String>> reactions; // emoji -> list of user IDs

  const FeedPost({
    required this.id,
    required this.authorId,
    required this.content,
    this.mediaUrl,
    this.mediaType = 'text',
    required this.createdAt,
    required this.likes,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.tags = const [],
    required this.visibility,
    this.reactions = const {},
  });
}
