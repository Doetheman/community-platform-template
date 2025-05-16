import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_label_community_app/features/community/domain/entities/chat.dart';
import 'package:white_label_community_app/features/community/state/providers/chat_provider.dart';
import 'package:white_label_community_app/features/community/ui/screens/chat_screen.dart';

class ChatSearchScreen extends ConsumerStatefulWidget {
  const ChatSearchScreen({super.key});

  @override
  ConsumerState<ChatSearchScreen> createState() => _ChatSearchScreenState();
}

class _ChatSearchScreenState extends ConsumerState<ChatSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openChat(Chat chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChatScreen(
              chatId: chat.id,
              title: chat.isGroup ? 'Group Chat' : 'Chat',
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatsAsync = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search chats...',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          autofocus: true,
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
              },
            ),
        ],
      ),
      body: chatsAsync.when(
        data: (chats) {
          if (_searchQuery.isEmpty) {
            return const Center(child: Text('Start typing to search chats'));
          }

          final filteredChats =
              chats.where((chat) {
                final searchLower = _searchQuery.toLowerCase();

                // Search in chat name
                if (chat.name?.toLowerCase().contains(searchLower) ?? false) {
                  return true;
                }

                // Search in last message
                if (chat.lastMessage?.toLowerCase().contains(searchLower) ??
                    false) {
                  return true;
                }

                // Search in participant names (you'll need to implement this)
                // This would require fetching user profiles for the participants
                // For now, we'll just search in participant IDs
                if (chat.participants.any(
                  (id) => id.toLowerCase().contains(searchLower),
                )) {
                  return true;
                }

                return false;
              }).toList();

          if (filteredChats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No chats found for "$_searchQuery"',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: filteredChats.length,
            itemBuilder: (context, index) {
              final chat = filteredChats[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: chat.isGroup ? Colors.blue : Colors.green,
                  child: Icon(
                    chat.isGroup ? Icons.group : Icons.person,
                    color: Colors.white,
                  ),
                ),
                title: Text(chat.name ?? chat.id),
                subtitle: Text(chat.lastMessage ?? 'No messages yet'),
                onTap: () => _openChat(chat),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(child: Text('Error: ${error.toString()}')),
      ),
    );
  }
}
