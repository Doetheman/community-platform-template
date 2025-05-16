import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_label_community_app/features/community/data/models/chat_message_model.dart';
import 'package:white_label_community_app/features/community/state/providers/message_upload_provider.dart';
import 'package:white_label_community_app/features/community/domain/utils/chat_formatter.dart';
import 'video_message_widget.dart';
import 'image_message_widget.dart';

class MessageBubble extends ConsumerWidget {
  final ChatMessageModel message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  Widget _buildStatusIcon(BuildContext context) {
    if (!isMe) return const SizedBox.shrink();

    IconData icon;
    Color color;

    switch (message.status) {
      case MessageStatus.sending:
        icon = Icons.access_time;
        color = Colors.grey;
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        color = Colors.grey;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.grey;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = Colors.blue;
        break;
      case MessageStatus.error:
        icon = Icons.error_outline;
        color = Colors.red;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Icon(icon, size: 16, color: color),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text!,
              style: TextStyle(color: isMe ? Colors.white : null),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ChatFormatter.formatMessageTime(message.timestamp),
                  style: ChatFormatter.getMessageTimeStyle(context, isMe),
                ),
                _buildStatusIcon(context),
              ],
            ),
          ],
        );
      case MessageType.video:
        if (message.videoUrl == null) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VideoMessageWidget(
              videoUrl: message.videoUrl!,
              isMe: isMe,
              timestamp: message.timestamp,
              formatMessageTime: ChatFormatter.formatMessageTime,
            ),
            if (isMe) _buildStatusIcon(context),
          ],
        );
      case MessageType.image:
        if (message.imageUrl == null) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ImageMessageWidget(
              imageUrl: message.imageUrl!,
              isMe: isMe,
              timestamp: message.timestamp,
              formatMessageTime: ChatFormatter.formatMessageTime,
            ),
            if (isMe) _buildStatusIcon(context),
          ],
        );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.only(
        left: isMe ? 64 : 16,
        right: isMe ? 16 : 64,
        top: 4,
        bottom: 4,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? Theme.of(context).colorScheme.primary : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: _buildMessageContent(context),
    );
  }
}
