import '../../domain/entities/feed_post.dart';

class FeedPostModel {
  final String id;
  final String authorId;
  final String content;
  final String? mediaUrl;
  final String mediaType;
  final DateTime createdAt;
  final List<String> likes;
  final int commentsCount;
  final int sharesCount;
  final List<String> tags;
  final String visibility;
  final Map<String, List<String>> reactions;

  FeedPostModel({
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

  factory FeedPostModel.fromEntity(FeedPost post) => FeedPostModel(
    id: post.id,
    authorId: post.authorId,
    content: post.content,
    mediaUrl: post.mediaUrl,
    mediaType: post.mediaType,
    createdAt: post.createdAt,
    likes: post.likes,
    commentsCount: post.commentsCount,
    sharesCount: post.sharesCount,
    tags: post.tags,
    visibility: post.visibility,
    reactions: post.reactions,
  );

  FeedPost toEntity() => FeedPost(
    id: id,
    authorId: authorId,
    content: content,
    mediaUrl: mediaUrl,
    mediaType: mediaType,
    createdAt: createdAt,
    likes: likes,
    commentsCount: commentsCount,
    sharesCount: sharesCount,
    tags: tags,
    visibility: visibility,
    reactions: reactions,
  );

  factory FeedPostModel.fromJson(Map<String, dynamic> json, String id) {
    return FeedPostModel(
      id: id,
      authorId: json['authorId'],
      content: json['content'],
      mediaUrl: json['mediaUrl'],
      mediaType: json['mediaType'] ?? 'text',
      createdAt: DateTime.parse(json['createdAt']),
      likes: List<String>.from(json['likes'] ?? []),
      commentsCount: json['commentsCount'] ?? 0,
      sharesCount: json['sharesCount'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      visibility: json['visibility'] ?? 'public',
      reactions:
          (json['reactions'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, List<String>.from(value)),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorId': authorId,
      'content': content,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'tags': tags,
      'visibility': visibility,
      'reactions': reactions,
    };
  }
}
