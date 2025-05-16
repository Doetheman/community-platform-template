import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/feed_provider.dart';
import 'widgets/feed_post_card.dart';
import 'create_post_screen.dart';
import 'package:white_label_community_app/features/community/ui/screens/chat_screen.dart';

class SpaceViewScreen extends ConsumerWidget {
  final Map<String, dynamic> space;

  const SpaceViewScreen({super.key, required this.space});

  void _openGroupChat(BuildContext context) {
    final groupTitle = space['name'] ?? 'Group Chat';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(title: groupTitle, chatId: ''),
      ),
    );
  }

  void _contactAdmin(BuildContext context) {
    final adminTitle = 'Admin of ${space['name'] ?? 'Space'}';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(title: adminTitle, chatId: ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(feedStreamProvider);
    final color = space['color'] as Color;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  space['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            color.withOpacity(0.8),
                            color.withOpacity(0.4),
                          ],
                        ),
                      ),
                    ),

                    // Space details
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 60,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.white24,
                            child: Text(
                              space['name'].substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    size: 16,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Created by ${space['creator']}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.group,
                                    size: 16,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${space['members']} members',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                PopupMenuButton(
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'join',
                          child: Text('Join Space'),
                        ),
                        const PopupMenuItem(
                          value: 'invite',
                          child: Text('Invite Members'),
                        ),
                        const PopupMenuItem(
                          value: 'about',
                          child: Text('About this Space'),
                        ),
                      ],
                  onSelected: (value) {
                    // Handle menu item selection
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Selected: $value')));
                  },
                ),
              ],
            ),
          ];
        },
        body: Column(
          children: [
            // Group Chat and Contact Admin buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openGroupChat(context),
                    icon: const Icon(Icons.group),
                    label: const Text('Join Group Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _contactAdmin(context),
                    icon: const Icon(Icons.star),
                    label: const Text('Contact Admin'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Space description
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    space['description'],
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Divider(height: 24),
                ],
              ),
            ),

            // Post list
            Expanded(
              child: feed.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (posts) {
                  // Filter posts for this space (in a real app, this would be a server query)
                  final spacePosts =
                      posts
                          .where(
                            (post) =>
                                post.visibility.contains(
                                  'space:${space['name']}',
                                ) ||
                                post.visibility == 'public',
                          )
                          .toList();

                  return spacePosts.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.forum_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No posts in this space yet',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => _createPost(context),
                              child: const Text('Create the first post'),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: spacePosts.length,
                        itemBuilder: (context, index) {
                          return FeedPostCard(post: spacePosts[index]);
                        },
                      );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createPost(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _createPost(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) =>
                CreatePostScreen(space: space['name'], spaceDetails: space),
      ),
    );
  }
}
