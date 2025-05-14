import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_label_community_app/features/media/data/media_remote_data_source.dart';
import 'package:white_label_community_app/features/media/data/media_repository_impl.dart';
import 'package:white_label_community_app/features/media/domain/entities/media_album.dart'
    as domain;
import 'package:white_label_community_app/features/media/domain/entities/media_item.dart'
    hide MediaAlbum;
import 'package:white_label_community_app/features/media/domain/repositories/media_repository.dart';
import 'package:white_label_community_app/features/profile/state/profile_provider.dart';

// Services providers
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

// Data source providers
final mediaRemoteDataSourceProvider = Provider<MediaRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final storage = ref.watch(firebaseStorageProvider);
  return MediaRemoteDataSource(firestore, storage);
});

// Repository providers
final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  final dataSource = ref.watch(mediaRemoteDataSourceProvider);
  return MediaRepositoryImpl(dataSource);
});

// State for user's personal media
class UserMediaNotifier extends StateNotifier<AsyncValue<List<MediaItem>>> {
  final MediaRepository _repository;
  final String userId;
  final Ref _ref;

  UserMediaNotifier(this._repository, this.userId, this._ref)
    : super(const AsyncValue.loading()) {
    loadUserMedia();
  }

  Future<void> loadUserMedia() async {
    state = const AsyncValue.loading();
    try {
      final media = await _repository.getUserMedia(userId);
      state = AsyncValue.data(media);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<MediaItem?> createMediaItem({
    required String caption,
    required File mediaFile,
    required MediaType type,
    String? location,
    File? thumbnailFile,
    List<String> tags = const [],
    String? albumId,
  }) async {
    try {
      // This is not a direct repository call - we need to work around the API differences
      // between our UI needs and the repository interface

      // For simplicity, let's use the Remote Data Source directly for file uploads
      final dataSource = _ref.read(mediaRemoteDataSourceProvider);

      // Create the media item with the data source directly to handle file upload
      final mediaModel = await dataSource.createMediaItem(
        authorId: userId,
        authorName: "User", // We'll get this from profile
        authorProfileImageUrl: null,
        mediaFile: mediaFile,
        type: type,
        caption: caption,
        thumbnailFile: thumbnailFile,
        tags: tags,
        isPublic: true,
        albumId: albumId,
      );

      final mediaItem = mediaModel.toEntity();

      // Update the local state by adding the new media item
      state.whenData((media) {
        final updatedList = [mediaItem, ...media];
        state = AsyncValue.data(updatedList);
      });

      return mediaItem;
    } catch (e) {
      // Handle error
      return null;
    }
  }

  Future<void> deleteMediaItem(String mediaId) async {
    try {
      await _repository.deleteMediaItem(mediaId);

      state.whenData((media) {
        // Remove the deleted media from the list
        state = AsyncValue.data(
          media.where((item) => item.id != mediaId).toList(),
        );
      });
    } catch (e) {
      // On error, reload the entire list
      loadUserMedia();
    }
  }

  Future<void> updateMediaItem(MediaItem mediaItem) async {
    try {
      await _repository.updateMediaItem(mediaItem);

      state.whenData((media) {
        // Replace the updated media in the list
        final index = media.indexWhere((item) => item.id == mediaItem.id);
        if (index >= 0) {
          final updatedList = List<MediaItem>.from(media);
          updatedList[index] = mediaItem;
          state = AsyncValue.data(updatedList);
        }
      });
    } catch (e) {
      // On error, reload the entire list
      loadUserMedia();
    }
  }

  Future<void> toggleLike(String mediaId) async {
    try {
      await _repository.toggleLike(mediaId, userId);

      // After toggling the like, we need to refresh the media item
      final updatedMedia = await _repository.getMediaById(mediaId);

      if (updatedMedia != null) {
        state.whenData((media) {
          // Replace the updated media in the list
          final index = media.indexWhere((item) => item.id == mediaId);
          if (index >= 0) {
            final updatedList = List<MediaItem>.from(media);
            updatedList[index] = updatedMedia;
            state = AsyncValue.data(updatedList);
          }
        });
      }
    } catch (e) {
      // Just log the error, we'll try again next time
      // print('Error toggling like: $e');
    }
  }

  Future<void> addComment({
    required String mediaId,
    required String text,
    required String authorName,
    String? authorProfileImageUrl,
  }) async {
    try {
      await _repository.addComment(
        mediaId: mediaId,
        userId: userId,
        text: text,
      );

      // After adding the comment, we need to refresh the media item
      final updatedMedia = await _repository.getMediaById(mediaId);

      if (updatedMedia != null) {
        state.whenData((media) {
          // Replace the updated media in the list
          final index = media.indexWhere((item) => item.id == mediaId);
          if (index >= 0) {
            final updatedList = List<MediaItem>.from(media);
            updatedList[index] = updatedMedia;
            state = AsyncValue.data(updatedList);
          }
        });
      }
    } catch (e) {
      // Just log the error
      // print('Error adding comment: $e');
    }
  }

  Future<void> deleteComment({
    required String mediaId,
    required String commentId,
  }) async {
    try {
      await _repository.deleteComment(mediaId, commentId);

      // After deleting the comment, we need to refresh the media item
      final updatedMedia = await _repository.getMediaById(mediaId);

      if (updatedMedia != null) {
        state.whenData((media) {
          // Replace the updated media in the list
          final index = media.indexWhere((item) => item.id == mediaId);
          if (index >= 0) {
            final updatedList = List<MediaItem>.from(media);
            updatedList[index] = updatedMedia;
            state = AsyncValue.data(updatedList);
          }
        });
      }
    } catch (e) {
      // Just log the error
      // print('Error deleting comment: $e');
    }
  }
}

// State for albums
class UserAlbumsNotifier
    extends StateNotifier<AsyncValue<List<domain.MediaAlbum>>> {
  final MediaRepository _repository;
  final String userId;
  final Ref _ref;

  UserAlbumsNotifier(this._repository, this.userId, this._ref)
    : super(const AsyncValue.loading()) {
    loadUserAlbums();
  }

  Future<void> loadUserAlbums() async {
    try {
      final albums = await _repository.getUserAlbums(userId);
      state = AsyncValue.data(albums);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<domain.MediaAlbum?> createAlbum({
    required String name,
    String description = '',
    bool isPublic = true,
    File? coverFile,
  }) async {
    try {
      await _repository.createAlbum(
        name: name,
        description: description,
        isPublic: isPublic,
        coverFile: coverFile,
      );

      // Refresh the album list
      loadUserAlbums();

      // Return the created album - in practice we'd want to get its ID
      return state.whenData((albums) {
        return albums.firstWhere((a) => a.name == name);
      }).valueOrNull;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateAlbum({
    required String albumId,
    required String name,
    String description = '',
    bool isPublic = true,
    File? coverFile,
  }) async {
    try {
      await _repository.updateAlbum(
        albumId: albumId,
        name: name,
        description: description,
        isPublic: isPublic,
        coverFile: coverFile,
      );

      // Refresh the album list
      loadUserAlbums();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAlbum(String albumId) async {
    try {
      await _repository.deleteAlbum(albumId);

      // Update state by removing the album
      state.whenData((albums) {
        final updatedList =
            albums.where((album) => album.id != albumId).toList();
        state = AsyncValue.data(updatedList);
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addMediaToAlbum(String albumId, String mediaId) async {
    try {
      await _repository.addMediaToAlbum(albumId, mediaId);

      // Refresh the album list
      loadUserAlbums();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeMediaFromAlbum(String albumId, String mediaId) async {
    try {
      await _repository.removeMediaFromAlbum(albumId, mediaId);

      // Refresh the album list
      loadUserAlbums();
      return true;
    } catch (e) {
      return false;
    }
  }
}

// State for feed media
class FeedMediaNotifier extends StateNotifier<AsyncValue<List<MediaItem>>> {
  final MediaRepository _repository;
  final String currentUserId;

  FeedMediaNotifier(this._repository, this.currentUserId)
    : super(const AsyncValue.loading()) {
    loadFeedMedia();
  }

  Future<void> loadFeedMedia() async {
    state = const AsyncValue.loading();
    try {
      final media = await _repository.getFeedMedia();
      state = AsyncValue.data(media);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> toggleLike(String mediaId) async {
    try {
      await _repository.toggleLike(mediaId, currentUserId);

      // After toggling the like, we need to refresh the media item
      final updatedMedia = await _repository.getMediaById(mediaId);

      if (updatedMedia != null) {
        state.whenData((media) {
          final index = media.indexWhere((item) => item.id == mediaId);
          if (index >= 0) {
            final updatedList = List<MediaItem>.from(media);
            updatedList[index] = updatedMedia;
            state = AsyncValue.data(updatedList);
          }
        });
      }
    } catch (e) {
      // Just log the error
      // print('Error toggling like: $e');
    }
  }

  Future<void> addComment({
    required String mediaId,
    required String text,
    required String authorName,
    String? authorProfileImageUrl,
  }) async {
    try {
      await _repository.addComment(
        mediaId: mediaId,
        userId: currentUserId,
        text: text,
      );

      // After adding the comment, we need to refresh the media item
      final updatedMedia = await _repository.getMediaById(mediaId);

      if (updatedMedia != null) {
        state.whenData((media) {
          final index = media.indexWhere((item) => item.id == mediaId);
          if (index >= 0) {
            final updatedList = List<MediaItem>.from(media);
            updatedList[index] = updatedMedia;
            state = AsyncValue.data(updatedList);
          }
        });
      }
    } catch (e) {
      // Just log the error
      // print('Error adding comment: $e');
    }
  }
}

// Active providers for the app
final userMediaProvider = StateNotifierProvider.family<
  UserMediaNotifier,
  AsyncValue<List<MediaItem>>,
  String
>((ref, userId) {
  final repository = ref.watch(mediaRepositoryProvider);
  return UserMediaNotifier(repository, userId, ref);
});

final currentUserMediaProvider =
    StateNotifierProvider<UserMediaNotifier, AsyncValue<List<MediaItem>>>((
      ref,
    ) {
      final repository = ref.watch(mediaRepositoryProvider);
      final user = ref.watch(firebaseAuthProvider).currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }
      return UserMediaNotifier(repository, user.uid, ref);
    });

final userAlbumsProvider = StateNotifierProvider.family<
  UserAlbumsNotifier,
  AsyncValue<List<domain.MediaAlbum>>,
  String
>((ref, userId) {
  final repository = ref.watch(mediaRepositoryProvider);
  return UserAlbumsNotifier(repository, userId, ref);
});

final currentUserAlbumsProvider = StateNotifierProvider<
  UserAlbumsNotifier,
  AsyncValue<List<domain.MediaAlbum>>
>((ref) {
  final repository = ref.watch(mediaRepositoryProvider);
  final user = ref.watch(firebaseAuthProvider).currentUser;
  if (user == null) {
    throw Exception('User not logged in');
  }
  return UserAlbumsNotifier(repository, user.uid, ref);
});

final feedMediaProvider =
    StateNotifierProvider<FeedMediaNotifier, AsyncValue<List<MediaItem>>>((
      ref,
    ) {
      final repository = ref.watch(mediaRepositoryProvider);
      final user = ref.watch(firebaseAuthProvider).currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }
      return FeedMediaNotifier(repository, user.uid);
    });

final singleMediaProvider = FutureProvider.family<MediaItem?, String>((
  ref,
  mediaId,
) async {
  final repository = ref.watch(mediaRepositoryProvider);
  return repository.getMediaById(mediaId);
});

final singleAlbumProvider = FutureProvider.family<domain.MediaAlbum?, String>((
  ref,
  albumId,
) async {
  final repository = ref.watch(mediaRepositoryProvider);
  return repository.getAlbumById(albumId);
});

final albumMediaProvider = FutureProvider.family<List<MediaItem>, String>((
  ref,
  albumId,
) async {
  final repository = ref.watch(mediaRepositoryProvider);
  final album = await repository.getAlbumById(albumId);

  if (album == null || album.mediaIds.isEmpty) {
    return [];
  }

  // Get all media items for the album
  final mediaItems = <MediaItem>[];
  for (final mediaId in album.mediaIds) {
    final mediaItem = await repository.getMediaById(mediaId);
    if (mediaItem != null) {
      mediaItems.add(mediaItem);
    }
  }

  return mediaItems;
});

// Add providers for Firebase services
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final storageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});
