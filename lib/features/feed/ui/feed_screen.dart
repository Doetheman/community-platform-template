import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/feed_provider.dart';
import 'widgets/feed_post_card.dart';
import 'package:go_router/go_router.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(feedStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment),
            onPressed: () => context.push('/create-post'),
          ),
        ],
      ),
      body: feed.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data:
            (posts) => ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return FeedPostCard(post: posts[index]);
              },
            ),
      ),
    );
  }
}
