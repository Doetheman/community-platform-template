import '../../domain/entities/feed_post.dart';

class FeedPostModel {
  final String id;
  final String authorId;
  final String content;
  final String? mediaUrl;
  final DateTime createdAt;
  final List<String> likes;
  final String visibility;

  FeedPostModel({
    required this.id,
    required this.authorId,
    required this.content,
    this.mediaUrl,
    required this.createdAt,
    required this.likes,
    required this.visibility,
  });

  factory FeedPostModel.fromEntity(FeedPost post) => FeedPostModel(
    id: post.id,
    authorId: post.authorId,
    content: post.content,
    mediaUrl: post.mediaUrl,
    createdAt: post.createdAt,
    likes: post.likes,
    visibility: post.visibility,
  );

  FeedPost toEntity() => FeedPost(
    id: id,
    authorId: authorId,
    content: content,
    mediaUrl: mediaUrl,
    createdAt: createdAt,
    likes: likes,
    visibility: visibility,
  );

  factory FeedPostModel.fromJson(Map<String, dynamic> json, String id) {
    return FeedPostModel(
      id: id,
      authorId: json['authorId'],
      content: json['content'],
      mediaUrl: json['mediaUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      likes: List<String>.from(json['likes'] ?? []),
      visibility: json['visibility'] ?? 'public',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorId': authorId,
      'content': content,
      'mediaUrl': mediaUrl,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'visibility': visibility,
    };
  }
}
