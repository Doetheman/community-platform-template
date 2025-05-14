import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/feed_post.dart';
import '../widgets/feed_post_card.dart';
import '../../state/feed_provider.dart';

class FeedTab extends ConsumerWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        final feedAsyncValue = ref.watch(feedStreamProvider);

        return feedAsyncValue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data:
              (posts) =>
                  posts.isEmpty ? _buildEmptyState() : _buildFeedList(posts),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No posts yet'),
          SizedBox(height: 8),
          Text(
            'Be the first to share something with the community',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedList(List<FeedPost> posts) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return FeedPostCard(post: posts[index]);
      },
    );
  }
}
