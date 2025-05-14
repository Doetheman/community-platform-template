import 'package:flutter/material.dart';
// Placeholder imports for navigation targets
import 'chat_screen.dart';
import 'new_chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  void _openChat(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(title: title)),
    );
  }

  void _startNewChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewChatScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
            tooltip: 'Search messages',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Contact Admin Shortcut
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () => _openChat(context, 'Creator/Admin'),
              icon: const Icon(Icons.star),
              label: const Text('Contact Admin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          // Section: Groups
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.group, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Groups',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          // Example Group Chat
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.group, color: Colors.white),
              ),
              title: const Text('VIP Fans Group'),
              subtitle: const Text('Group chat for VIP fans'),
              trailing: ElevatedButton(
                onPressed: () => _openChat(context, 'VIP Fans Group'),
                child: const Text('Join Group Chat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () => _openChat(context, 'VIP Fans Group'),
            ),
          ),
          // Section: Direct Messages
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Direct Messages',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          // Example DMs
          _ConversationTile(
            avatar: const CircleAvatar(
              backgroundImage: NetworkImage(
                'https://randomuser.me/api/portraits/men/32.jpg',
              ),
            ),
            title: 'Alex Johnson',
            subtitle: 'Thanks for the reply!',
            time: '10m',
            unreadCount: 1,
            pinned: false,
            onTap: () => _openChat(context, 'Alex Johnson'),
          ),
          _ConversationTile(
            avatar: const CircleAvatar(
              backgroundImage: NetworkImage(
                'https://randomuser.me/api/portraits/women/44.jpg',
              ),
            ),
            title: 'Jamie Lee',
            subtitle: 'See you at the event!',
            time: '1h',
            unreadCount: 0,
            pinned: false,
            onTap: () => _openChat(context, 'Jamie Lee'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startNewChat(context),
        icon: const Icon(Icons.edit),
        label: const Text('New Chat'),
        tooltip: 'Start a new chat',
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Widget avatar;
  final String title;
  final String subtitle;
  final String time;
  final int unreadCount;
  final bool pinned;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.avatar,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.unreadCount,
    required this.pinned,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Stack(
        children: [
          avatar,
          if (pinned)
            Positioned(
              right: -2,
              top: -2,
              child: Icon(
                Icons.push_pin,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
      title: Text(
        title,
        style:
            pinned
                ? theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                )
                : null,
      ),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
