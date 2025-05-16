import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_label_community_app/features/auth/state/auth_provider.dart'
    as auth;
import 'package:white_label_community_app/features/community/ui/widgets/rename_chat_dialog.dart';
import 'package:white_label_community_app/features/community/data/repositories/chat_repository.dart'
    as repo;
import 'package:white_label_community_app/features/community/ui/widgets/message_bubble.dart';
import 'package:white_label_community_app/features/community/ui/widgets/chat_input_bar.dart';
import 'package:white_label_community_app/features/community/state/providers/paginated_messages_provider.dart';
import 'package:white_label_community_app/features/media/ui/screens/media_gallery_screen.dart';
import 'dart:io';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String title;

  const ChatScreen({super.key, required this.chatId, required this.title});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSendingMessage = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _currentUserId = ref.read(auth.firebaseAuthProvider).currentUser?.uid;
    if (_currentUserId != null) {
      // Mark all messages as read when opening the chat
      ref
          .read(repo.chatRepositoryProvider)
          .markAllMessagesAsRead(widget.chatId, _currentUserId!);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Mark messages as delivered when they become visible
      final messages =
          ref.read(paginatedMessagesProvider(widget.chatId)).messages;
      if (_currentUserId != null) {
        for (final message in messages) {
          if (!message.deliveredTo.contains(_currentUserId) &&
              message.senderId != _currentUserId) {
            ref
                .read(repo.chatRepositoryProvider)
                .markMessageAsDelivered(
                  widget.chatId,
                  message.id,
                  _currentUserId!,
                );
          }
        }
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSendingMessage) return;

    setState(() => _isSendingMessage = true);
    try {
      final message = _messageController.text.trim();
      _messageController.clear();
      await ref
          .read(repo.chatRepositoryProvider)
          .sendMessage(widget.chatId, message, _currentUserId!);
      // Scroll to bottom after sending
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingMessage = false);
      }
    }
  }

  Future<void> _sendVideoMessage() async {
    if (_isSendingMessage) return;

    final currentUser = ref.read(auth.firebaseAuthProvider).currentUser;
    if (currentUser == null) return;

    setState(() => _isSendingMessage = true);
    try {
      await ref
          .read(repo.chatRepositoryProvider)
          .sendVideoMessage(chatId: widget.chatId, senderId: currentUser.uid);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending video: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingMessage = false);
      }
    }
  }

  Future<void> _sendImageMessage() async {
    if (_isSendingMessage) return;

    setState(() => _isSendingMessage = true);
    try {
      await ref
          .read(repo.chatRepositoryProvider)
          .sendImageMessage(chatId: widget.chatId, senderId: _currentUserId!);
      // Scroll to bottom after sending image
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingMessage = false);
      }
    }
  }

  Future<void> _sendStoredVideoMessage() async {
    if (_isSendingMessage) return;
    final currentUser = ref.read(auth.firebaseAuthProvider).currentUser;
    if (currentUser == null) return;

    // Open the app's media gallery and let the user pick a video
    File? selectedVideo;
    try {
      selectedVideo = await Navigator.push<File?>(
        context,
        MaterialPageRoute(
          builder:
              (context) => MediaGalleryScreen(
                userId: currentUser.uid,
                isCurrentUser: true,
              ),
        ),
      );
    } catch (e) {
      // Handle navigation or gallery errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open gallery: ${e.toString()}')),
        );
      }
      return;
    }

    if (selectedVideo == null) return;

    setState(() => _isSendingMessage = true);
    try {
      await ref
          .read(repo.chatRepositoryProvider)
          .sendVideoMessage(
            chatId: widget.chatId,
            senderId: currentUser.uid,
            videoFile: selectedVideo,
          );
      // Scroll to bottom after sending video
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send video: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingMessage = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesState = ref.watch(paginatedMessagesProvider(widget.chatId));
    final messages = messagesState.messages;
    final isLoading = messagesState.isLoading;
    final error = messagesState.error;
    final hasMore = messagesState.hasMore;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'rename':
                  _showRenameDialog();
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Rename Chat'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (error != null)
            MaterialBanner(
              content: Text(error),
              actions: [
                TextButton(
                  onPressed: () {
                    ref
                        .read(paginatedMessagesProvider(widget.chatId).notifier)
                        .clearError();
                  },
                  child: const Text('Dismiss'),
                ),
              ],
            ),
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final message = messages[index];
                    final isMe = message.senderId == _currentUserId;

                    return MessageBubble(message: message, isMe: isMe);
                  },
                ),
                if (isLoading && messages.isEmpty)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
          ChatInputBar(
            controller: _messageController,
            onSendMessage: _sendMessage,
            onSendImage: _sendImageMessage,
            onSendVideo: _sendVideoMessage,
            onSendStoredVideo: _sendStoredVideoMessage,
            isSending: _isSendingMessage,
          ),
        ],
      ),
    );
  }

  Future<void> _showRenameDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) =>
              RenameChatDialog(currentName: widget.title, title: 'Rename Chat'),
    );

    if (result != null && result.isNotEmpty) {
      await ref
          .read(repo.chatRepositoryProvider)
          .renameChat(widget.chatId, result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat renamed successfully')),
        );
      }
    }
  }
}
