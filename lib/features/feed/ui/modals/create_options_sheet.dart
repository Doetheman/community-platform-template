import 'package:flutter/material.dart';

class CreateOptionsBottomSheet extends StatelessWidget {
  final Function(String) onCreatePost;
  final VoidCallback onCreatePoll;
  final VoidCallback onCreateAdminPoll;

  const CreateOptionsBottomSheet({
    super.key,
    required this.onCreatePost,
    required this.onCreatePoll,
    required this.onCreateAdminPoll,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text("New Post"),
            leading: const Icon(Icons.post_add),
            onTap: () {
              Navigator.pop(context);
              onCreatePost('text');
            },
          ),
          ListTile(
            title: const Text("New Poll"),
            leading: const Icon(Icons.poll),
            onTap: () {
              Navigator.pop(context);
              onCreatePoll();
            },
          ),
          // Admin Poll Option with a visual indicator that it's for admins
          ListTile(
            title: const Row(
              children: [
                Text("Create Admin Poll"),
                SizedBox(width: 8),
                Chip(
                  label: Text(
                    "Admin",
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.zero,
                  labelPadding: EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 0,
                  ),
                ),
              ],
            ),
            leading: const Icon(Icons.admin_panel_settings),
            onTap: () {
              Navigator.pop(context);
              onCreateAdminPoll();
            },
          ),
        ],
      ),
    );
  }

  static void show(
    BuildContext context, {
    required Function(String) onCreatePost,
    required VoidCallback onCreatePoll,
    required VoidCallback onCreateAdminPoll,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => CreateOptionsBottomSheet(
            onCreatePost: onCreatePost,
            onCreatePoll: onCreatePoll,
            onCreateAdminPoll: onCreateAdminPoll,
          ),
    );
  }
}
