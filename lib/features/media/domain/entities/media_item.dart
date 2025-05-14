import 'package:cloud_firestore/cloud_firestore.dart';

enum MediaType { image, video }

class MediaComment {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorProfileImageUrl;
  final String text;
  final DateTime createdAt;
  final List<String> likes;

  const MediaComment({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorProfileImageUrl,
    required this.text,
    required this.createdAt,
    this.likes = const [],
  });

  MediaComment copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorProfileImageUrl,
    String? text,
    DateTime? createdAt,
    List<String>? likes,
  }) {
    return MediaComment(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorProfileImageUrl:
          authorProfileImageUrl ?? this.authorProfileImageUrl,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
    );
  }
}

class MediaItem {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorProfileImageUrl;
  final String url;
  final MediaType type;
  final String? caption;
  final String? thumbnailUrl; // For videos
  final DateTime createdAt;
  final List<String> likes;
  final List<MediaComment> comments;
  final Map<String, dynamic>
  metadata; // For additional data like dimensions, size, etc.
  final List<String> tags;
  final bool isPublic;
  final String? albumId;

  const MediaItem({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorProfileImageUrl,
    required this.url,
    required this.type,
    this.caption,
    this.thumbnailUrl,
    required this.createdAt,
    this.likes = const [],
    this.comments = const [],
    this.metadata = const {},
    this.tags = const [],
    this.isPublic = true,
    this.albumId,
  });

  bool get isImage => type == MediaType.image;
  bool get isVideo => type == MediaType.video;
  int get likeCount => likes.length;
  int get commentCount => comments.length;

  MediaItem copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorProfileImageUrl,
    String? url,
    MediaType? type,
    String? caption,
    String? thumbnailUrl,
    DateTime? createdAt,
    List<String>? likes,
    List<MediaComment>? comments,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    bool? isPublic,
    String? albumId,
  }) {
    return MediaItem(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorProfileImageUrl:
          authorProfileImageUrl ?? this.authorProfileImageUrl,
      url: url ?? this.url,
      type: type ?? this.type,
      caption: caption ?? this.caption,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      metadata: metadata ?? this.metadata,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
      albumId: albumId ?? this.albumId,
    );
  }

  // Helper methods for likes and comments
  bool isLikedBy(String userId) => likes.contains(userId);

  MediaItem toggleLike(String userId) {
    final newLikes = List<String>.from(likes);
    if (isLikedBy(userId)) {
      newLikes.remove(userId);
    } else {
      newLikes.add(userId);
    }
    return copyWith(likes: newLikes);
  }

  MediaItem addComment(MediaComment comment) {
    final newComments = List<MediaComment>.from(comments);
    newComments.add(comment);
    return copyWith(comments: newComments);
  }

  MediaItem removeComment(String commentId) {
    final newComments = comments.where((c) => c.id != commentId).toList();
    return copyWith(comments: newComments);
  }
}

class MediaAlbum {
  final String id;
  final String authorId;
  final String title;
  final String? description;
  final String? coverImageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> mediaIds;
  final bool isPublic;

  const MediaAlbum({
    required this.id,
    required this.authorId,
    required this.title,
    this.description,
    this.coverImageUrl,
    required this.createdAt,
    this.updatedAt,
    this.mediaIds = const [],
    this.isPublic = true,
  });

  int get mediaCount => mediaIds.length;

  MediaAlbum copyWith({
    String? id,
    String? authorId,
    String? title,
    String? description,
    String? coverImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? mediaIds,
    bool? isPublic,
  }) {
    return MediaAlbum(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mediaIds: mediaIds ?? this.mediaIds,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}
