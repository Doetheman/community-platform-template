import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:white_label_community_app/features/community/data/models/chat_model.dart';
import 'package:white_label_community_app/features/community/data/models/chat_message_model.dart';
import 'package:white_label_community_app/features/media/data/media_remote_data_source.dart';
import 'package:white_label_community_app/features/media/domain/entities/media_item.dart';
import 'package:white_label_community_app/features/media/ui/utils/media_picker_utils.dart';
import 'package:white_label_community_app/features/media/state/media_provider.dart';
import 'dart:io';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(
    firestore: FirebaseFirestore.instance,
    mediaDataSource: ref.watch(mediaRemoteDataSourceProvider),
  );
});

class ChatRepository {
  final FirebaseFirestore _firestore;
  final MediaRemoteDataSource _mediaDataSource;
  final String _collection = 'chats';

  ChatRepository({
    required FirebaseFirestore firestore,
    required MediaRemoteDataSource mediaDataSource,
  }) : _firestore = firestore,
       _mediaDataSource = mediaDataSource;

  Stream<List<ChatModel>> watchChats({required String currentUserId}) {
    return _firestore
        .collection(_collection)
        .where('participants', arrayContains: currentUserId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return ChatModel.fromJson(data);
              }).toList(),
        );
  }

  Future<List<ChatModel>> fetchChats({String? currentUserId}) async {
    if (currentUserId == null) return [];

    final snapshot =
        await _firestore
            .collection(_collection)
            .where('participants', arrayContains: currentUserId)
            .orderBy('updatedAt', descending: true)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return ChatModel.fromJson(data);
    }).toList();
  }

  Future<ChatModel> createChat(ChatModel chat) async {
    final now = DateTime.now();
    final chatWithTimestamps = chat.copyWith(createdAt: now, updatedAt: now);
    final docRef = await _firestore
        .collection(_collection)
        .add(chatWithTimestamps.toJson());
    return chatWithTimestamps.copyWith(id: docRef.id);
  }

  Future<ChatModel> createChatWithMessage(
    ChatModel chat,
    String message,
    String senderId,
  ) async {
    final now = DateTime.now();
    final chatWithTimestamps = chat.copyWith(
      createdAt: now,
      updatedAt: now,
      lastMessage: message,
    );

    // Create the chat document
    final docRef = await _firestore
        .collection(_collection)
        .add(chatWithTimestamps.toJson());

    // Add the initial message to the messages subcollection
    final messageModel = ChatMessageModel(
      id: docRef.id,
      senderId: senderId,
      timestamp: now,
      type: MessageType.text,
      text: message,
      status: MessageStatus.delivered,
    );

    await docRef.collection('messages').add(messageModel.toJson());

    return chatWithTimestamps.copyWith(id: docRef.id);
  }

  Future<void> updateChat(ChatModel chat) async {
    if (chat.id == null) throw Exception('Chat ID is required for update');
    await _firestore.collection(_collection).doc(chat.id).update(chat.toJson());
  }

  Future<void> sendMessage(
    String chatId,
    String message,
    String senderId,
  ) async {
    if (chatId.isEmpty) {
      throw Exception('Chat ID is required for sending message');
    }

    final now = DateTime.now();
    final messageModel = ChatMessageModel(
      id: _firestore.collection(_collection).doc().id,
      senderId: senderId,
      timestamp: now,
      type: MessageType.text,
      text: message,
      status: MessageStatus.delivered,
    );

    // Use a batch write to ensure atomicity
    final batch = _firestore.batch();
    final chatRef = _firestore.collection(_collection).doc(chatId);

    // Add the message to the messages subcollection
    final messageRef = chatRef.collection('messages').doc(messageModel.id);
    batch.set(messageRef, messageModel.toJson());

    // Update the chat document
    batch.update(chatRef, {'lastMessage': message, 'updatedAt': now});

    try {
      await batch.commit();
      // Update message status to sent after successful commit
      await messageRef.update({'status': MessageStatus.sent.name});
    } catch (e) {
      // Update message status to error if sending fails
      await messageRef.update({'status': MessageStatus.error.name});
      rethrow;
    }

    // TODO: Consider using Firestore's real-time listeners to update message statuses (e.g., mark as delivered when a recipient's device receives the message).
    // TODO: Use a separate collection (or subcollection) for message statuses to avoid touching the message document itself.
    // TODO: Use Firestore's server timestamps to track when a status change occurred.
    // TODO: For text messages, consider starting with a status like "sending" (or "pending") and then updating to "delivered" once the message is confirmed to be sent.
    // TODO: If a message fails to send (status "error"), implement a retry mechanism (e.g., using a queue or a background task) to attempt sending again.
    // TODO: Log errors (e.g., upload failures) to a separate collection or a logging service for debugging and analytics.
    // TODO: If the user is offline, queue messages locally and update their status to "sending" once the device is back online.
    // TODO: Write unit tests for your status update logic to ensure it behaves as expected.
    // TODO: Use Firebase Analytics or a custom logging solution to monitor message statuses and identify issues (e.g., messages stuck in "sending" or "error" states).
  }

  Future<void> sendVideoMessage({
    required String chatId,
    required String senderId,
    File? videoFile,
    void Function(double)? onProgress,
  }) async {
    DocumentReference? tempMessageRef;
    try {
      // Create a temporary message to show upload progress
      tempMessageRef =
          _firestore
              .collection(_collection)
              .doc(chatId)
              .collection('messages')
              .doc();

      final tempMessage = ChatMessageModel(
        id: '', // dummy id, will be overwritten by copyWith
        senderId: senderId,
        timestamp: DateTime.now(),
        type: MessageType.video,
        status: MessageStatus.sending,
      ).copyWith(id: tempMessageRef.id);
      await tempMessageRef.set(tempMessage.toJson());

      // Use provided videoFile or pick one from gallery
      File? pickedVideoFile = videoFile;
      pickedVideoFile ??= await MediaPickerUtils.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );

      if (pickedVideoFile == null) {
        // User cancelled the video pick
        await tempMessageRef.delete();
        return;
      }

      // Check file size using MediaPickerUtils
      if (!MediaPickerUtils.isFileSizeAllowed(
        pickedVideoFile,
        maxSizeMB: 100,
      )) {
        throw Exception('Video file too large. Maximum size is 100MB');
      }

      // Generate thumbnail using MediaPickerUtils
      final thumbnailFile = await MediaPickerUtils.generateVideoThumbnail(
        pickedVideoFile,
      );

      // Upload video using MediaRemoteDataSource with progress tracking
      final mediaModel = await _mediaDataSource.createMediaItem(
        authorId: senderId,
        authorName: 'User', // We'll get this from profile later
        authorProfileImageUrl: null,
        mediaFile: pickedVideoFile,
        type: MediaType.video,
        thumbnailFile: thumbnailFile,
        isPublic: false, // Chat videos are always private
      );

      // Update message with video URL and status
      await tempMessageRef.update({
        'videoUrl': mediaModel.url,
        'thumbnailUrl': mediaModel.thumbnailUrl,
        'status': MessageStatus.delivered.name,
      });

      // Update chat document
      await _firestore.collection(_collection).doc(chatId).update({
        'lastMessage': '📹 Video',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Update message status to error if upload fails
      if (tempMessageRef != null) {
        await tempMessageRef.update({'status': MessageStatus.error.name});
      }
      rethrow;
    }
  }

  Future<void> sendImageMessage({
    required String chatId,
    required String senderId,
    void Function(double)? onProgress,
  }) async {
    DocumentReference? tempMessageRef;
    try {
      // Create a temporary message to show upload progress
      tempMessageRef =
          _firestore
              .collection(_collection)
              .doc(chatId)
              .collection('messages')
              .doc();

      final tempMessage = ChatMessageModel(
        id: '', // dummy id, will be overwritten by copyWith
        senderId: senderId,
        timestamp: DateTime.now(),
        type: MessageType.image,
        status: MessageStatus.sending,
      ).copyWith(id: tempMessageRef.id);
      await tempMessageRef.set(tempMessage.toJson());

      // Pick image using MediaPickerUtils
      final imageFile = await MediaPickerUtils.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920, // Max width for better performance
        maxHeight: 1920,
        imageQuality: 85, // Good quality with reasonable file size
      );

      if (imageFile == null) {
        // User cancelled the image pick
        await tempMessageRef.delete();
        return;
      }

      // Check file size using MediaPickerUtils
      if (!MediaPickerUtils.isFileSizeAllowed(imageFile, maxSizeMB: 10)) {
        throw Exception('Image file too large. Maximum size is 10MB');
      }

      // Upload image using MediaRemoteDataSource
      final mediaModel = await _mediaDataSource.createMediaItem(
        authorId: senderId,
        authorName: 'User', // We'll get this from profile later
        authorProfileImageUrl: null,
        mediaFile: imageFile,
        type: MediaType.image,
        thumbnailFile: null, // No thumbnail needed for images
        isPublic: false, // Chat images are always private
      );

      // Update message with image URL and status
      await tempMessageRef.update({
        'imageUrl': mediaModel.url,
        'status': MessageStatus.delivered.name,
      });

      // Update chat document
      await _firestore.collection(_collection).doc(chatId).update({
        'lastMessage': '🖼️ Image',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Update message status to error if upload fails
      if (tempMessageRef != null) {
        await tempMessageRef.update({'status': MessageStatus.error.name});
      }
      rethrow;
    }
  }

  Stream<List<ChatMessageModel>> watchMessages(String chatId) {
    return _firestore
        .collection(_collection)
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            // Convert string status back to enum
            if (data['status'] is String) {
              data['status'] = MessageStatus.values.firstWhere(
                (e) => e.toString() == data['status'],
                orElse: () => MessageStatus.sending,
              );
            }
            return ChatMessageModel.fromFirestore(doc);
          }).toList();
        });
  }

  Future<List<ChatMessageModel>> getMessages(
    String chatId, {
    int limit = 20,
    ChatMessageModel? lastMessage,
  }) async {
    var query = _firestore
        .collection(_collection)
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (lastMessage != null) {
      query = query.startAfter([lastMessage.timestamp]);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => ChatMessageModel.fromJson(doc.data()))
        .toList();
  }

  Future<void> renameChat(String chatId, String newName) async {
    await _firestore.collection(_collection).doc(chatId).update({
      'name': newName,
      'updatedAt': DateTime.now(),
    });
  }

  Future<void> markChatAsRead(String chatId, String userId) async {
    await _firestore.collection(_collection).doc(chatId).update({
      'unreadCounts.$userId': 0,
      'updatedAt': DateTime.now(),
    });
  }

  Future<void> incrementUnreadCount(String chatId, String userId) async {
    await _firestore.collection(_collection).doc(chatId).update({
      'unreadCounts.$userId': FieldValue.increment(1),
      'updatedAt': DateTime.now(),
    });
  }

  Future<void> markMessageAsDelivered(
    String chatId,
    String messageId,
    String userId,
  ) async {
    final messageRef = _firestore
        .collection(_collection)
        .doc(chatId)
        .collection('messages')
        .doc(messageId);

    final messageDoc = await messageRef.get();
    if (!messageDoc.exists) return;

    final message = ChatMessageModel.fromFirestore(messageDoc);
    final updatedMessage = message.markAsDelivered(userId);

    await messageRef.update({
      'deliveredTo': updatedMessage.deliveredTo.toList(),
      'status': updatedMessage.status.name,
    });
  }

  Future<void> markMessageAsRead(
    String chatId,
    String messageId,
    String userId,
  ) async {
    final messageRef = _firestore
        .collection(_collection)
        .doc(chatId)
        .collection('messages')
        .doc(messageId);

    final messageDoc = await messageRef.get();
    if (!messageDoc.exists) return;

    final message = ChatMessageModel.fromFirestore(messageDoc);
    final updatedMessage = message.markAsRead(userId);

    await messageRef.update({
      'readBy': updatedMessage.readBy.toList(),
      'status': updatedMessage.status.name,
    });

    // Also mark the chat as read
    await markChatAsRead(chatId, userId);
  }

  Future<void> markAllMessagesAsRead(String chatId, String userId) async {
    final messagesRef = _firestore
        .collection(_collection)
        .doc(chatId)
        .collection('messages');

    final unreadMessages =
        await messagesRef.where('readBy', arrayContains: userId).get();

    final batch = _firestore.batch();
    for (var doc in unreadMessages.docs) {
      final message = ChatMessageModel.fromFirestore(doc);
      final updatedMessage = message.markAsRead(userId);
      batch.update(doc.reference, {
        'readBy': updatedMessage.readBy.toList(),
        'status': updatedMessage.status.name,
      });
    }

    await batch.commit();
    await markChatAsRead(chatId, userId);
  }
}
