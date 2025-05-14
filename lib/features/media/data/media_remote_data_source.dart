import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:white_label_community_app/features/media/data/models/media_model.dart';
import 'package:white_label_community_app/features/media/domain/entities/media_item.dart';

class MediaRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final Uuid _uuid = const Uuid();

  MediaRemoteDataSource(this._firestore, this._storage);

  // Collections
  CollectionReference get _mediaCollection => _firestore.collection('media');
  CollectionReference get _albumsCollection => _firestore.collection('albums');

  // Media CRUD operations
  Future<List<MediaItemModel>> getUserMedia(
    String userId, {
    int limit = 20,
    DocumentSnapshot? startAfterDoc,
  }) async {
    Query query = _mediaCollection
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfterDoc != null) {
      query = query.startAfterDocument(startAfterDoc);
    }

    final QuerySnapshot snapshot = await query.get();
    return snapshot.docs
        .map(
          (doc) => MediaItemModel.fromJson(doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<MediaItemModel>> getFeedMedia({
    int limit = 20,
    DocumentSnapshot? startAfterDoc,
  }) async {
    // Get public media for feed
    Query query = _mediaCollection
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfterDoc != null) {
      query = query.startAfterDocument(startAfterDoc);
    }

    final QuerySnapshot snapshot = await query.get();
    return snapshot.docs
        .map(
          (doc) => MediaItemModel.fromJson(doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  Future<MediaItemModel?> getMediaItem(String mediaId) async {
    final doc = await _mediaCollection.doc(mediaId).get();
    if (!doc.exists) return null;
    return MediaItemModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  Future<MediaItemModel> createMediaItem({
    required String authorId,
    required String authorName,
    String? authorProfileImageUrl,
    required File mediaFile,
    required MediaType type,
    String? caption,
    File? thumbnailFile,
    List<String> tags = const [],
    bool isPublic = true,
    String? albumId,
  }) async {
    // 1. Generate a unique ID for the media
    final String mediaId = _uuid.v4();

    // 2. Upload media file to Firebase Storage
    final String mediaExtension = path.extension(mediaFile.path);
    final String mediaPath = 'media/$authorId/$mediaId$mediaExtension';
    final Reference mediaRef = _storage.ref().child(mediaPath);
    await mediaRef.putFile(mediaFile);
    final String mediaUrl = await mediaRef.getDownloadURL();

    // 3. If it's a video, upload the thumbnail if provided
    String? thumbnailUrl;
    if (type == MediaType.video && thumbnailFile != null) {
      final String thumbExtension = path.extension(thumbnailFile.path);
      final String thumbPath =
          'media/$authorId/${mediaId}_thumb$thumbExtension';
      final Reference thumbRef = _storage.ref().child(thumbPath);
      await thumbRef.putFile(thumbnailFile);
      thumbnailUrl = await thumbRef.getDownloadURL();
    }

    // 4. Create the media model
    final MediaItemModel mediaModel = MediaItemModel(
      id: mediaId,
      authorId: authorId,
      authorName: authorName,
      authorProfileImageUrl: authorProfileImageUrl,
      url: mediaUrl,
      type: type,
      caption: caption,
      thumbnailUrl: thumbnailUrl,
      createdAt: DateTime.now(),
      tags: tags,
      isPublic: isPublic,
      albumId: albumId,
    );

    // 5. Save to Firestore
    await _mediaCollection.doc(mediaId).set(mediaModel.toJson());

    // 6. If this is being added to an album, update the album too
    if (albumId != null) {
      await _albumsCollection.doc(albumId).update({
        'mediaIds': FieldValue.arrayUnion([mediaId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    return mediaModel;
  }

  Future<void> updateMediaItem(MediaItemModel mediaModel) async {
    await _mediaCollection.doc(mediaModel.id).update(mediaModel.toJson());
  }

  Future<void> deleteMediaItem(String mediaId) async {
    // 1. Get the media item first
    final mediaDoc = await _mediaCollection.doc(mediaId).get();
    if (!mediaDoc.exists) return;

    final mediaData = mediaDoc.data() as Map<String, dynamic>;
    final String mediaUrl = mediaData['url'] as String;
    final String? thumbnailUrl = mediaData['thumbnailUrl'] as String?;
    final String? albumId = mediaData['albumId'] as String?;

    // 2. Delete from the album if it belongs to one
    if (albumId != null) {
      await _albumsCollection.doc(albumId).update({
        'mediaIds': FieldValue.arrayRemove([mediaId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    // 3. Delete from Firestore
    await _mediaCollection.doc(mediaId).delete();

    // 4. Delete the media file from Storage
    try {
      final mediaRef = _storage.refFromURL(mediaUrl);
      await mediaRef.delete();

      // 5. Delete thumbnail if it exists
      if (thumbnailUrl != null) {
        final thumbRef = _storage.refFromURL(thumbnailUrl);
        await thumbRef.delete();
      }
    } catch (e) {
      // Log error but continue - we've already deleted from Firestore
      print('Error deleting media files: $e');
    }
  }

  // Comment operations
  Future<MediaItemModel> addComment({
    required String mediaId,
    required String authorId,
    required String authorName,
    String? authorProfileImageUrl,
    required String text,
  }) async {
    // 1. Get the current media item
    final mediaDoc = await _mediaCollection.doc(mediaId).get();
    if (!mediaDoc.exists) {
      throw Exception('Media not found');
    }

    // 2. Create the comment model
    final commentModel = MediaCommentModel(
      id: _uuid.v4(),
      authorId: authorId,
      authorName: authorName,
      authorProfileImageUrl: authorProfileImageUrl,
      text: text,
      createdAt: DateTime.now(),
    );

    // 3. Update the media document with the new comment
    await _mediaCollection.doc(mediaId).update({
      'comments': FieldValue.arrayUnion([commentModel.toJson()]),
    });

    // 4. Return the updated media item
    return (await getMediaItem(mediaId))!;
  }

  Future<MediaItemModel> deleteComment({
    required String mediaId,
    required String commentId,
  }) async {
    // 1. Get the current media item
    final mediaDoc = await _mediaCollection.doc(mediaId).get();
    if (!mediaDoc.exists) {
      throw Exception('Media not found');
    }

    final mediaData = mediaDoc.data() as Map<String, dynamic>;
    final comments = List<Map<String, dynamic>>.from(
      mediaData['comments'] ?? [],
    );

    // 2. Find and remove the comment
    final commentIndex = comments.indexWhere((c) => c['id'] == commentId);
    if (commentIndex >= 0) {
      comments.removeAt(commentIndex);

      // 3. Update the media document
      await _mediaCollection.doc(mediaId).update({'comments': comments});
    }

    // 4. Return the updated media item
    return (await getMediaItem(mediaId))!;
  }

  Future<MediaItemModel> likeComment({
    required String mediaId,
    required String commentId,
    required String userId,
  }) async {
    // 1. Get the current media item
    final mediaDoc = await _mediaCollection.doc(mediaId).get();
    if (!mediaDoc.exists) {
      throw Exception('Media not found');
    }

    final mediaData = mediaDoc.data() as Map<String, dynamic>;
    final comments = List<Map<String, dynamic>>.from(
      mediaData['comments'] ?? [],
    );

    // 2. Find the comment to like/unlike
    final commentIndex = comments.indexWhere((c) => c['id'] == commentId);
    if (commentIndex >= 0) {
      final comment = comments[commentIndex];
      final likes = List<String>.from(comment['likes'] ?? []);

      // Toggle like
      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }

      comment['likes'] = likes;
      comments[commentIndex] = comment;

      // 3. Update the media document
      await _mediaCollection.doc(mediaId).update({'comments': comments});
    }

    // 4. Return the updated media item
    return (await getMediaItem(mediaId))!;
  }

  // Like operations
  Future<MediaItemModel> toggleLike({
    required String mediaId,
    required String userId,
  }) async {
    // 1. Get the current media item
    final mediaDoc = await _mediaCollection.doc(mediaId).get();
    if (!mediaDoc.exists) {
      throw Exception('Media not found');
    }

    final mediaData = mediaDoc.data() as Map<String, dynamic>;
    final likes = List<String>.from(mediaData['likes'] ?? []);

    // 2. Toggle like
    if (likes.contains(userId)) {
      likes.remove(userId);
    } else {
      likes.add(userId);
    }

    // 3. Update the media document
    await _mediaCollection.doc(mediaId).update({'likes': likes});

    // 4. Return the updated media item
    return (await getMediaItem(mediaId))!;
  }

  // Album operations
  Future<List<MediaAlbumModel>> getUserAlbums(String userId) async {
    final QuerySnapshot snapshot =
        await _albumsCollection
            .where('authorId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();

    return snapshot.docs
        .map(
          (doc) => MediaAlbumModel.fromJson(doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  Future<MediaAlbumModel?> getAlbum(String albumId) async {
    final doc = await _albumsCollection.doc(albumId).get();
    if (!doc.exists) return null;
    return MediaAlbumModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  Future<MediaAlbumModel> createAlbum({
    required String authorId,
    required String title,
    String? description,
    String? coverImageUrl,
    bool isPublic = true,
  }) async {
    // 1. Generate a unique ID for the album
    final String albumId = _uuid.v4();

    // 2. Create the album model
    final MediaAlbumModel albumModel = MediaAlbumModel(
      id: albumId,
      authorId: authorId,
      title: title,
      description: description,
      coverImageUrl: coverImageUrl,
      createdAt: DateTime.now(),
      isPublic: isPublic,
    );

    // 3. Save to Firestore
    await _albumsCollection.doc(albumId).set(albumModel.toJson());

    return albumModel;
  }

  Future<MediaAlbumModel> updateAlbum(MediaAlbumModel albumModel) async {
    final updatedAlbum = MediaAlbumModel(
      id: albumModel.id,
      authorId: albumModel.authorId,
      title: albumModel.title,
      description: albumModel.description,
      coverImageUrl: albumModel.coverImageUrl,
      createdAt: albumModel.createdAt,
      updatedAt: DateTime.now(),
      mediaIds: albumModel.mediaIds,
      isPublic: albumModel.isPublic,
    );

    await _albumsCollection.doc(updatedAlbum.id).update(updatedAlbum.toJson());
    return updatedAlbum;
  }

  Future<void> deleteAlbum(String albumId) async {
    // Note: This won't delete the media items in the album
    await _albumsCollection.doc(albumId).delete();
  }

  Future<MediaAlbumModel> addMediaToAlbum({
    required String albumId,
    required String mediaId,
  }) async {
    // 1. Update the album
    await _albumsCollection.doc(albumId).update({
      'mediaIds': FieldValue.arrayUnion([mediaId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 2. Update the media item to reference this album
    await _mediaCollection.doc(mediaId).update({'albumId': albumId});

    // 3. Return the updated album
    return (await getAlbum(albumId))!;
  }

  Future<MediaAlbumModel> removeMediaFromAlbum({
    required String albumId,
    required String mediaId,
  }) async {
    // 1. Update the album
    await _albumsCollection.doc(albumId).update({
      'mediaIds': FieldValue.arrayRemove([mediaId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 2. Update the media item to remove the album reference
    await _mediaCollection.doc(mediaId).update({'albumId': null});

    // 3. Return the updated album
    return (await getAlbum(albumId))!;
  }
}
