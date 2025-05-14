import 'dart:io';

import 'package:white_label_community_app/features/media/domain/entities/media_album.dart'
    as domain;
import 'package:white_label_community_app/features/media/domain/entities/media_item.dart'
    hide MediaAlbum;

abstract class MediaRepository {
  // Media Items
  Future<List<MediaItem>> getUserMedia(String userId);
  Future<List<MediaItem>> getFeedMedia();
  Future<MediaItem?> getMediaById(String mediaId);
  Future<MediaItem> createMediaItem({
    required String authorId,
    required String url,
    required bool isImage,
    String caption = '',
    List<String> tags = const [],
    bool isPublic = true,
  });
  Future<void> updateMediaItem(MediaItem mediaItem);
  Future<void> deleteMediaItem(String mediaId);

  Future<void> toggleLike(String mediaId, String userId);
  Future<void> addComment({
    required String mediaId,
    required String userId,
    required String text,
  });
  Future<void> deleteComment(String mediaId, String commentId);

  // Albums
  Future<List<domain.MediaAlbum>> getUserAlbums(String userId);
  Future<domain.MediaAlbum?> getAlbumById(String albumId);
  Future<void> createAlbum({
    required String name,
    String description = '',
    bool isPublic = true,
    File? coverFile,
  });
  Future<void> updateAlbum({
    required String albumId,
    required String name,
    String description = '',
    bool isPublic = true,
    File? coverFile,
  });
  Future<void> deleteAlbum(String albumId);
  Future<void> addMediaToAlbum(String albumId, String mediaId);
  Future<void> removeMediaFromAlbum(String albumId, String mediaId);
}
