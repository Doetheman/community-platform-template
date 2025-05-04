import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:white_label_community_app/features/feed/domain/entities/feed_post.dart';

class FeedPostCard extends StatelessWidget {
  final FeedPost post;

  const FeedPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.yMMMd().add_jm().format(post.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '@${post.authorId}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 4),
            Text(post.content, style: Theme.of(context).textTheme.bodyLarge),
            if (post.mediaUrl != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(post.mediaUrl!, fit: BoxFit.cover),
              ),
            ],
            const SizedBox(height: 8),
            Text(date, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
