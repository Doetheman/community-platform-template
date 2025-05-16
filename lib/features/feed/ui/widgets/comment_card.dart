import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_label_community_app/features/feed/domain/entities/comment.dart';
import 'package:white_label_community_app/features/feed/state/feed_provider.dart';
import 'package:white_label_community_app/features/profile/state/profile_provider.dart';
import 'package:white_label_community_app/features/auth/state/auth_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentCard extends ConsumerWidget {
  final Comment comment;
  final String postId;
  final VoidCallback? onReply;

  const CommentCard({
    super.key,
    required this.comment,
    required this.postId,
    this.onReply,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authorProfile = ref.watch(userProfileByUidProvider(comment.authorId));
    final currentUser = ref.watch(authStateProvider).value;
    final isLiked =
        currentUser != null && comment.likes.contains(currentUser.uid);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: authorProfile.when(
                    data:
                        (profile) =>
                            profile?.profileImageUrl != null
                                ? NetworkImage(profile!.profileImageUrl!)
                                : null,
                    loading: () => null,
                    error: (_, __) => null,
                  ),
                  child: authorProfile.when(
                    data:
                        (profile) =>
                            profile?.profileImageUrl == null
                                ? Text(profile?.name[0].toUpperCase() ?? '?')
                                : null,
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Icon(Icons.error),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authorProfile.when(
                          data: (profile) => profile?.name ?? 'Unknown User',
                          loading: () => 'Loading...',
                          error: (_, __) => 'Error loading user',
                        ),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        timeago.format(comment.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (currentUser?.uid == comment.authorId)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      ref
                          .read(feedRepositoryProvider)
                          .deleteComment(postId, comment.id);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment.content),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : null,
                  ),
                  label: Text('${comment.likes.length}'),
                  onPressed:
                      currentUser == null
                          ? null
                          : () {
                            ref
                                .read(feedRepositoryProvider)
                                .toggleCommentLike(
                                  postId,
                                  comment.id,
                                  currentUser.uid,
                                );
                          },
                ),
                if (onReply != null)
                  TextButton.icon(
                    icon: const Icon(Icons.reply),
                    label: const Text('Reply'),
                    onPressed: onReply,
                  ),
              ],
            ),
            if (comment.replies.isNotEmpty) ...[
              const Divider(),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comment.replies.length,
                itemBuilder: (context, index) {
                  return CommentCard(
                    comment: comment.replies[index],
                    postId: postId,
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
