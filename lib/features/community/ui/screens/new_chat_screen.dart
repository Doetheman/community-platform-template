import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_label_community_app/features/community/data/models/chat_model.dart';
import 'package:white_label_community_app/features/community/state/providers/chat_provider.dart';
import 'package:white_label_community_app/features/profile/domain/entities/user_profile.dart';
import 'package:white_label_community_app/features/profile/state/profile_provider.dart';
import 'package:white_label_community_app/features/auth/state/auth_provider.dart'
    as auth;

class NewChatScreen extends ConsumerStatefulWidget {
  const NewChatScreen({super.key});

  @override
  ConsumerState<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends ConsumerState<NewChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final Set<String> _selectedUserUids = {};
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
    _messageController.dispose();
    super.dispose();
  }

  void _toggleUserSelection(String uid) {
    setState(() {
      if (_selectedUserUids.contains(uid)) {
        _selectedUserUids.remove(uid);
      } else {
        _selectedUserUids.add(uid);
      }
      _messageController.clear();
    });
  }

  void _sendInitialMessage() async {
    if (_selectedUserUids.isEmpty || _messageController.text.trim().isEmpty)
      return;

    final selectedUsers =
        ref
            .read(allUserProfilesProvider)
            .valueOrNull
            ?.where((u) => _selectedUserUids.contains(u.uid))
            .toList() ??
        [];
    final chatTitle =
        selectedUsers.length == 1
            ? selectedUsers.first.name
            : selectedUsers.map((u) => u.name).join(', ');
    final message = _messageController.text.trim();

    final allParticipants = [..._selectedUserUids];
    final currentUser = ref.watch(auth.firebaseAuthProvider).currentUser;
    if (currentUser?.uid != null) {
      allParticipants.add(currentUser!.uid);
    }

    try {
      await ref
          .read(chatProvider.notifier)
          .createChat(allParticipants.first, initialMessage: message);

      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Chat started with: $chatTitle\nMessage: $message'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating chat: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allUsersAsync = ref.watch(allUserProfilesProvider);
    final currentUser = ref.watch(auth.firebaseAuthProvider).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Start New Chat')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (_selectedUserUids.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.group, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedUserUids.length > 1
                          ? 'Group chat with: ${_selectedUserUids.length} users'
                          : 'Chat with: ${allUsersAsync.valueOrNull?.firstWhere((u) => u.uid == _selectedUserUids.first, orElse: () => UserProfile.empty).name ?? ''}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed:
                        () => setState(() {
                          _selectedUserUids.clear();
                          _messageController.clear();
                        }),
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: allUsersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error loading users: $e')),
              data: (users) {
                final filteredUsers =
                    users
                        .where((u) => u.uid != currentUser?.uid)
                        .where(
                          (u) => u.name.toLowerCase().contains(_searchQuery),
                        )
                        .toList();
                if (filteredUsers.isEmpty) {
                  return const Center(child: Text('No users found.'));
                }
                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final isSelected = _selectedUserUids.contains(user.uid);
                    return ListTile(
                      leading:
                          user.profileImageUrl != null
                              ? CircleAvatar(
                                backgroundImage: NetworkImage(
                                  user.profileImageUrl!,
                                ),
                              )
                              : const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(user.name),
                      subtitle: user.bio != null ? Text(user.bio!) : null,
                      trailing: Checkbox(
                        value: isSelected,
                        onChanged: (_) => _toggleUserSelection(user.uid),
                      ),
                      onTap: () => _toggleUserSelection(user.uid),
                    );
                  },
                );
              },
            ),
          ),
          if (_selectedUserUids.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                    minLines: 1,
                    maxLines: 3,
                    onChanged:
                        (value) => setState(
                          () {},
                        ), // Trigger rebuild to update button state
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _messageController.text.trim().isNotEmpty
                              ? _sendInitialMessage
                              : null,
                      child: const Text('Send & Start Chat'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
