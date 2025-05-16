import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_label_community_app/features/community/state/providers/chat_provider.dart';
import 'package:white_label_community_app/features/community/data/models/chat_model.dart';
import 'package:white_label_community_app/features/community/ui/screens/chat_screen.dart';
import 'package:white_label_community_app/features/community/ui/screens/new_chat_screen.dart';
import 'package:white_label_community_app/features/community/domain/utils/chat_formatter.dart';
import 'package:white_label_community_app/features/community/ui/widgets/rename_chat_dialog.dart';
// Placeholder imports for navigation targets
import 'chat_screen.dart';
import 'new_chat_screen.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(chatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement chat search
            },
          ),
        ],
      ),
      body: chatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No chats yet'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _startNewChat(context),
                    child: const Text('Start a Chat'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return _ConversationTile(
                avatar: CircleAvatar(
                  backgroundColor: chat.isGroup ? Colors.blue : Colors.green,
                  child: Icon(
                    chat.isGroup ? Icons.group : Icons.person,
                    color: Colors.white,
                  ),
                ),
                title:
                    chat.name ??
                    ChatFormatter.formatChatTitle(
                      chat.participants,
                      isGroup: chat.isGroup,
                    ),
                subtitle: chat.lastMessage ?? 'No messages yet',
                time:
                    chat.updatedAt != null
                        ? ChatFormatter.formatTimeAgo(chat.updatedAt!)
                        : 'Just now',
                unreadCount: chat.unreadCounts.values.fold(
                  0,
                  (sum, count) => sum + count,
                ),
                pinned: false,
                chatId: chat.id ?? '',
                onTap: () {
                  if (chat.id != null) {
                    ref.read(chatProvider.notifier).markChatAsRead(chat.id!);
                    _openChat(context, chat);
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(child: Text('Error: ${error.toString()}')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startNewChat(context),
        icon: const Icon(Icons.edit),
        label: const Text('New Chat'),
        tooltip: 'Start a new chat',
      ),
    );
  }

  void _startNewChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewChatScreen()),
    );
  }

  void _openChat(BuildContext context, ChatModel chat) {
    if (chat.id == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChatScreen(
              chatId: chat.id!,
              title:
                  chat.name ??
                  ChatFormatter.formatChatTitle(
                    chat.participants,
                    isGroup: chat.isGroup,
                  ),
            ),
      ),
    );
  }
}

class _ConversationTile extends ConsumerWidget {
  final Widget avatar;
  final String title;
  final String subtitle;
  final String time;
  final int unreadCount;
  final bool pinned;
  final VoidCallback onTap;
  final String chatId;

  const _ConversationTile({
    required this.avatar,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.unreadCount,
    required this.pinned,
    required this.onTap,
    required this.chatId,
  });

  Future<void> _showRenameDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) =>
              RenameChatDialog(currentName: title, title: 'Rename Chat'),
    );

    if (result != null && result.isNotEmpty) {
      await ref.read(chatProvider.notifier).renameChat(chatId, result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat renamed successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListTile(
      leading: avatar,
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(time, style: theme.textTheme.bodySmall),
          if (unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: onTap,
      onLongPress: () => _showRenameDialog(context, ref),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
