import '../../domain/entities/comment.dart';

class CommentModel {
  final String id;
  final String postId;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final List<String> likes;
  final List<CommentModel> replies;
  final String? parentCommentId;

  CommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.content,
    required this.createdAt,
    this.likes = const [],
    this.replies = const [],
    this.parentCommentId,
  });

  factory CommentModel.fromEntity(Comment comment) => CommentModel(
    id: comment.id,
    postId: comment.postId,
    authorId: comment.authorId,
    content: comment.content,
    createdAt: comment.createdAt,
    likes: comment.likes,
    replies:
        comment.replies.map((reply) => CommentModel.fromEntity(reply)).toList(),
    parentCommentId: comment.parentCommentId,
  );

  Comment toEntity() => Comment(
    id: id,
    postId: postId,
    authorId: authorId,
    content: content,
    createdAt: createdAt,
    likes: likes,
    replies: replies.map((reply) => reply.toEntity()).toList(),
    parentCommentId: parentCommentId,
  );

  factory CommentModel.fromJson(Map<String, dynamic> json, String id) {
    return CommentModel(
      id: id,
      postId: json['postId'],
      authorId: json['authorId'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      likes: List<String>.from(json['likes'] ?? []),
      replies:
          (json['replies'] as List<dynamic>?)?.map((reply) {
            return CommentModel.fromJson(
              reply as Map<String, dynamic>,
              reply['id'] as String,
            );
          }).toList() ??
          [],
      parentCommentId: json['parentCommentId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'authorId': authorId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'replies': replies.map((reply) => reply.toJson()).toList(),
      'parentCommentId': parentCommentId,
    };
  }
}
