import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:white_label_community_app/features/media/domain/entities/media_item.dart';

class MediaCommentModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorProfileImageUrl;
  final String text;
  final DateTime createdAt;
  final List<String> likes;

  const MediaCommentModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorProfileImageUrl,
    required this.text,
    required this.createdAt,
    this.likes = const [],
  });

  factory MediaCommentModel.fromEntity(MediaComment comment) {
    return MediaCommentModel(
      id: comment.id,
      authorId: comment.authorId,
      authorName: comment.authorName,
      authorProfileImageUrl: comment.authorProfileImageUrl,
      text: comment.text,
      createdAt: comment.createdAt,
      likes: comment.likes,
    );
  }

  MediaComment toEntity() {
    return MediaComment(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorProfileImageUrl: authorProfileImageUrl,
      text: text,
      createdAt: createdAt,
      likes: likes,
    );
  }

  factory MediaCommentModel.fromJson(Map<String, dynamic> json) {
    return MediaCommentModel(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorProfileImageUrl: json['authorProfileImageUrl'] as String?,
      text: json['text'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      likes: List<String>.from(json['likes'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorProfileImageUrl': authorProfileImageUrl,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
    };
  }
}

class MediaItemModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorProfileImageUrl;
  final String url;
  final MediaType type;
  final String? caption;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final List<String> likes;
  final List<MediaCommentModel> comments;
  final Map<String, dynamic> metadata;
  final List<String> tags;
  final bool isPublic;
  final String? albumId;

  const MediaItemModel({
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

  factory MediaItemModel.fromEntity(MediaItem item) {
    return MediaItemModel(
      id: item.id,
      authorId: item.authorId,
      authorName: item.authorName,
      authorProfileImageUrl: item.authorProfileImageUrl,
      url: item.url,
      type: item.type,
      caption: item.caption,
      thumbnailUrl: item.thumbnailUrl,
      createdAt: item.createdAt,
      likes: item.likes,
      comments:
          item.comments.map((c) => MediaCommentModel.fromEntity(c)).toList(),
      metadata: item.metadata,
      tags: item.tags,
      isPublic: item.isPublic,
      albumId: item.albumId,
    );
  }

  MediaItem toEntity() {
    return MediaItem(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorProfileImageUrl: authorProfileImageUrl,
      url: url,
      type: type,
      caption: caption,
      thumbnailUrl: thumbnailUrl,
      createdAt: createdAt,
      likes: likes,
      comments: comments.map((c) => c.toEntity()).toList(),
      metadata: metadata,
      tags: tags,
      isPublic: isPublic,
      albumId: albumId,
    );
  }

  factory MediaItemModel.fromJson(Map<String, dynamic> json) {
    return MediaItemModel(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorProfileImageUrl: json['authorProfileImageUrl'] as String?,
      url: json['url'] as String,
      type: MediaType.values.byName(json['type'] as String),
      caption: json['caption'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      likes: List<String>.from(json['likes'] ?? []),
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map(
                (c) => MediaCommentModel.fromJson(c as Map<String, dynamic>),
              )
              .toList() ??
          [],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      tags: List<String>.from(json['tags'] ?? []),
      isPublic: json['isPublic'] as bool? ?? true,
      albumId: json['albumId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorProfileImageUrl': authorProfileImageUrl,
      'url': url,
      'type': type.name,
      'caption': caption,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
      'comments': comments.map((c) => c.toJson()).toList(),
      'metadata': metadata,
      'tags': tags,
      'isPublic': isPublic,
      'albumId': albumId,
    };
  }
}

class MediaAlbumModel {
  final String id;
  final String authorId;
  final String title;
  final String? description;
  final String? coverImageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> mediaIds;
  final bool isPublic;

  const MediaAlbumModel({
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

  MediaAlbumModel copyWith({
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
    return MediaAlbumModel(
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

  factory MediaAlbumModel.fromEntity(MediaAlbum album) {
    return MediaAlbumModel(
      id: album.id,
      authorId: album.authorId,
      title: album.title,
      description: album.description,
      coverImageUrl: album.coverImageUrl,
      createdAt: album.createdAt,
      updatedAt: album.updatedAt,
      mediaIds: album.mediaIds,
      isPublic: album.isPublic,
    );
  }

  MediaAlbum toEntity() {
    return MediaAlbum(
      id: id,
      authorId: authorId,
      title: title,
      description: description,
      coverImageUrl: coverImageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      mediaIds: mediaIds,
      isPublic: isPublic,
    );
  }

  factory MediaAlbumModel.fromJson(Map<String, dynamic> json) {
    return MediaAlbumModel(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
      mediaIds: List<String>.from(json['mediaIds'] ?? []),
      isPublic: json['isPublic'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'title': title,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'mediaIds': mediaIds,
      'isPublic': isPublic,
    };
  }
}
