import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_label_community_app/features/community/data/models/chat_message_model.dart';
import 'package:white_label_community_app/features/community/data/repositories/chat_repository.dart';

class PaginatedMessagesState {
  final List<ChatMessageModel> messages;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final ChatMessageModel? lastMessage;
  final bool isRealtimeEnabled;

  const PaginatedMessagesState({
    this.messages = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.lastMessage,
    this.isRealtimeEnabled = false,
  });

  PaginatedMessagesState copyWith({
    List<ChatMessageModel>? messages,
    bool? isLoading,
    bool? hasMore,
    String? error,
    ChatMessageModel? lastMessage,
    bool? isRealtimeEnabled,
  }) {
    return PaginatedMessagesState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      lastMessage: lastMessage ?? this.lastMessage,
      isRealtimeEnabled: isRealtimeEnabled ?? this.isRealtimeEnabled,
    );
  }
}

class PaginatedMessagesNotifier extends StateNotifier<PaginatedMessagesState> {
  final ChatRepository _repository;
  final String _chatId;
  static const int _pageSize = 20;
  StreamSubscription<List<ChatMessageModel>>? _realtimeSubscription;
  DateTime? _lastRealtimeUpdate;

  PaginatedMessagesNotifier(this._repository, this._chatId)
    : super(const PaginatedMessagesState()) {
    loadInitialMessages();
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadInitialMessages() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final messages = await _repository.getMessages(_chatId, limit: _pageSize);
      state = state.copyWith(
        messages: messages,
        isLoading: false,
        hasMore: messages.length == _pageSize,
        lastMessage: messages.isNotEmpty ? messages.last : null,
      );
      _startRealtimeUpdates();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _startRealtimeUpdates() {
    if (state.isRealtimeEnabled) return;

    _realtimeSubscription?.cancel();
    _realtimeSubscription = _repository
        .watchMessages(_chatId)
        .listen(
          (newMessages) {
            if (newMessages.isEmpty) return;

            // Get the most recent message timestamp
            final latestMessageTime = newMessages.first.timestamp;

            // If we've already processed this message, skip it
            if (_lastRealtimeUpdate != null &&
                latestMessageTime.isBefore(_lastRealtimeUpdate!)) {
              return;
            }

            // Update our last processed timestamp
            _lastRealtimeUpdate = latestMessageTime;

            // Find new messages that aren't in our current list
            final existingIds = state.messages.map((m) => m.id).toSet();
            final newMessagesToAdd =
                newMessages
                    .where((message) => !existingIds.contains(message.id))
                    .toList();

            if (newMessagesToAdd.isNotEmpty) {
              state = state.copyWith(
                messages: [...newMessagesToAdd, ...state.messages],
                isRealtimeEnabled: true,
              );
            }
          },
          onError: (error) {
            state = state.copyWith(
              error: 'Error receiving real-time updates: ${error.toString()}',
            );
          },
        );
  }

  Future<void> loadMoreMessages() async {
    if (state.isLoading || !state.hasMore || state.lastMessage == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final messages = await _repository.getMessages(
        _chatId,
        limit: _pageSize,
        lastMessage: state.lastMessage,
      );

      if (messages.isEmpty) {
        state = state.copyWith(isLoading: false, hasMore: false);
        return;
      }

      state = state.copyWith(
        messages: [...state.messages, ...messages],
        isLoading: false,
        hasMore: messages.length == _pageSize,
        lastMessage: messages.last,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void addNewMessage(ChatMessageModel message) {
    // Only add if it's not already in the list
    if (!state.messages.any((m) => m.id == message.id)) {
      state = state.copyWith(messages: [message, ...state.messages]);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void pauseRealtimeUpdates() {
    _realtimeSubscription?.cancel();
    state = state.copyWith(isRealtimeEnabled: false);
  }

  void resumeRealtimeUpdates() {
    if (!state.isRealtimeEnabled) {
      _startRealtimeUpdates();
    }
  }
}

final paginatedMessagesProvider = StateNotifierProvider.family<
  PaginatedMessagesNotifier,
  PaginatedMessagesState,
  String
>((ref, chatId) {
  final repository = ref.watch(chatRepositoryProvider);
  return PaginatedMessagesNotifier(repository, chatId);
});
