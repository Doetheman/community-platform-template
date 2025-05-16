import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_label_community_app/features/community/domain/entities/chat.dart';
import 'package:white_label_community_app/features/auth/state/auth_provider.dart';
import 'package:white_label_community_app/features/community/data/repositories/chat_repository.dart';
import 'package:white_label_community_app/features/community/data/models/chat_model.dart';
import 'package:white_label_community_app/features/community/data/models/chat_message_model.dart';
import 'package:white_label_community_app/features/media/state/media_provider.dart';
import 'package:white_label_community_app/features/community/state/providers/message_upload_provider.dart';

// Repository Provider
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(
    firestore: FirebaseFirestore.instance,
    mediaDataSource: ref.watch(mediaRemoteDataSourceProvider),
  );
});

// Chat List Providers
final chatsProvider = FutureProvider<List<ChatModel>>((ref) async {
  final repository = ref.watch(chatRepositoryProvider);
  final currentUser = ref.watch(firebaseAuthProvider).currentUser;
  return repository.fetchChats(currentUserId: currentUser?.uid);
});

final chatProvider =
    StateNotifierProvider<ChatNotifier, AsyncValue<List<Chat>>>((ref) {
      final currentUser = ref.watch(firebaseAuthProvider).currentUser;
      return ChatNotifier(
        currentUser?.uid,
        ref.watch(chatRepositoryProvider),
        ref,
      );
    });

// Chat Action Providers
final createChatProvider = FutureProvider.family<ChatModel, ChatModel>((
  ref,
  chat,
) async {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.createChat(chat);
});

final updateChatProvider = FutureProvider.family<void, ChatModel>((
  ref,
  chat,
) async {
  final repository = ref.watch(chatRepositoryProvider);
  await repository.updateChat(chat);
});

final renameChatProvider =
    FutureProvider.family<void, ({String chatId, String newName})>((
      ref,
      params,
    ) async {
      final repository = ref.watch(chatRepositoryProvider);
      await repository.renameChat(params.chatId, params.newName);
    });

final markChatAsReadProvider =
    FutureProvider.family<void, ({String chatId, String userId})>((
      ref,
      params,
    ) async {
      final repository = ref.watch(chatRepositoryProvider);
      await repository.markChatAsRead(params.chatId, params.userId);
    });

// Chat Notifier
class ChatNotifier extends StateNotifier<AsyncValue<List<Chat>>> {
  final String? currentUserId;
  final ChatRepository _repository;
  final Ref _ref;
  StreamSubscription? _chatSubscription;

  ChatNotifier(this.currentUserId, this._repository, this._ref)
    : super(const AsyncValue.loading()) {
    if (currentUserId != null) {
      _watchChats();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  void _watchChats() {
    _chatSubscription?.cancel();
    if (currentUserId == null) return;

    _chatSubscription = _repository
        .watchChats(currentUserId: currentUserId!)
        .listen(
          (chats) =>
              state = AsyncValue.data(chats.map((c) => c.toEntity()).toList()),
          onError: (error, stack) => state = AsyncValue.error(error, stack),
        );
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    super.dispose();
  }

  Future<void> createChat(String otherUserId, {String? initialMessage}) async {
    try {
      if (currentUserId == null) return;

      final newChat = ChatModel(
        participants: [currentUserId!, otherUserId],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isGroup: false,
      );

      if (initialMessage != null) {
        await _repository.createChatWithMessage(
          newChat,
          initialMessage,
          currentUserId!,
        );
      } else {
        await _repository.createChat(newChat);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> sendMessage(String chatId, String message) async {
    try {
      if (currentUserId == null) return;
      await _repository.sendMessage(chatId, message, currentUserId!);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> sendVideoMessage(String chatId) async {
    ChatMessageModel? tempMessage;
    try {
      if (currentUserId == null) return;

      // Create temporary message
      tempMessage = ChatMessageModel(
        id: FirebaseFirestore.instance.collection('chats').doc().id,
        senderId: currentUserId!,
        timestamp: DateTime.now(),
        type: MessageType.video,
      );

      // Start tracking upload state
      _ref
          .read(messageUploadStateProvider(tempMessage.id).notifier)
          .startUpload();

      // Upload video
      await _repository.sendVideoMessage(
        chatId: chatId,
        senderId: currentUserId!,
        onProgress: (progress) {
          _ref
              .read(messageUploadStateProvider(tempMessage!.id).notifier)
              .updateProgress(progress);
        },
      );

      // Complete upload
      _ref
          .read(messageUploadStateProvider(tempMessage.id).notifier)
          .completeUpload();
    } catch (e, st) {
      if (tempMessage != null) {
        _ref
            .read(messageUploadStateProvider(tempMessage.id).notifier)
            .setError(e.toString());
      }
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> renameChat(String chatId, String newName) async {
    try {
      if (currentUserId == null) return;
      await _repository.renameChat(chatId, newName);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markChatAsRead(String chatId) async {
    try {
      if (currentUserId == null) return;
      await _repository.markChatAsRead(chatId, currentUserId!);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  int getUnreadCount(Chat chat) {
    if (currentUserId == null) return 0;
    return chat.unreadCounts[currentUserId] ?? 0;
  }
}
