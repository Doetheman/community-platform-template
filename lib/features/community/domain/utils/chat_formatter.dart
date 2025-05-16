import 'package:flutter/material.dart';

/// A utility class for formatting chat-related data.
class ChatFormatter {
  /// Formats a message timestamp into a human-readable time string.
  ///
  /// Returns:
  /// - Time in HH:mm format for today's messages
  /// - "Yesterday" for yesterday's messages
  /// - Date in DD/MM/YYYY format for older messages
  static String formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  /// Formats a timestamp into a relative time string (e.g., "2h ago", "5m ago").
  ///
  /// Returns:
  /// - "Just now" for messages less than a minute old
  /// - "Xm" for messages less than an hour old
  /// - "Xh" for messages less than a day old
  /// - "Xd" for messages older than a day
  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Just now';
    }
  }

  /// Formats a chat title based on participants and group status.
  ///
  /// Returns:
  /// - "Group Chat" for group chats
  /// - Participant names joined by commas for direct chats
  /// - "Chat" as fallback
  static String formatChatTitle(
    List<String> participants, {
    bool isGroup = false,
  }) {
    if (isGroup) return 'Group Chat';
    if (participants.isEmpty) return 'Chat';
    return participants.join(', ');
  }

  /// Gets the appropriate text style for a message timestamp based on whether
  /// the message is from the current user.
  static TextStyle getMessageTimeStyle(BuildContext context, bool isMe) {
    return TextStyle(
      fontSize: 12,
      color: isMe ? Colors.white.withOpacity(0.7) : Colors.grey,
    );
  }
}
