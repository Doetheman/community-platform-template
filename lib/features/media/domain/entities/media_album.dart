class MediaAlbum {
  final String id;
  final String authorId;
  final String name;
  final String description;
  final String coverUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> mediaIds;
  final bool isPublic;

  const MediaAlbum({
    required this.id,
    required this.authorId,
    required this.name,
    this.description = '',
    this.coverUrl = '',
    required this.createdAt,
    required this.updatedAt,
    this.mediaIds = const [],
    this.isPublic = true,
  });

  int get mediaCount => mediaIds.length;

  factory MediaAlbum.fromOtherAlbum(dynamic other) {
    return MediaAlbum(
      id: other.id,
      authorId: other.authorId,
      name: other.name ?? other.title,
      description: other.description ?? '',
      coverUrl: other.coverUrl ?? other.coverImageUrl ?? '',
      createdAt: other.createdAt,
      updatedAt: other.updatedAt ?? other.createdAt,
      mediaIds: other.mediaIds?.cast<String>() ?? const [],
      isPublic: other.isPublic ?? true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MediaAlbum &&
        other.id == id &&
        other.authorId == authorId &&
        other.name == name &&
        other.description == description &&
        other.coverUrl == coverUrl &&
        other.isPublic == isPublic &&
        other.mediaCount == mediaCount &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        authorId.hashCode ^
        name.hashCode ^
        description.hashCode ^
        coverUrl.hashCode ^
        isPublic.hashCode ^
        mediaIds.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  MediaAlbum copyWith({
    String? id,
    String? authorId,
    String? name,
    String? description,
    String? coverUrl,
    List<String>? mediaIds,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MediaAlbum(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      name: name ?? this.name,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      mediaIds: mediaIds ?? this.mediaIds,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
