import 'package:flutter/material.dart';
import 'package:white_label_community_app/features/community/data/models/chat_model.dart';

class ChatDetailScreen extends StatelessWidget {
  final ChatModel chat;

  const ChatDetailScreen({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          chat.isGroup
              ? 'Group Chat'
              : 'Chat with ${chat.participants.join(", ")}',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Participants: ${chat.participants.join(", ")}'),
            const SizedBox(height: 8),
            Text('Last Message: ${chat.lastMessage ?? "No messages yet"}'),
            const SizedBox(height: 8),
            Text('Created At: ${chat.createdAt}'),
            if (chat.updatedAt != null) Text('Updated At: ${chat.updatedAt}'),
          ],
        ),
      ),
    );
  }
}
