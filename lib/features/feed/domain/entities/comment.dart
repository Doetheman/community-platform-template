class Comment {
  final String id;
  final String postId;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final List<String> likes;
  final List<Comment> replies;
  final String? parentCommentId;

  const Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.content,
    required this.createdAt,
    this.likes = const [],
    this.replies = const [],
    this.parentCommentId,
  });
}
