import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_label_community_app/features/feed/domain/entities/comment.dart';
import 'package:white_label_community_app/features/feed/state/feed_provider.dart';
import 'package:white_label_community_app/features/auth/state/auth_provider.dart';
import 'package:white_label_community_app/features/feed/ui/widgets/comment_card.dart';

class CommentSection extends ConsumerStatefulWidget {
  final String postId;
  final String? parentCommentId;

  const CommentSection({super.key, required this.postId, this.parentCommentId});

  @override
  ConsumerState<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends ConsumerState<CommentSection> {
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final currentUser = ref.read(authStateProvider).value;
      if (currentUser == null) return;

      final comment = Comment(
        id: '', // Will be set by Firestore
        postId: widget.postId,
        authorId: currentUser.uid,
        content: _commentController.text.trim(),
        createdAt: DateTime.now(),
        likes: [],
        replies: [],
        parentCommentId: widget.parentCommentId,
      );

      await ref.read(feedRepositoryProvider).addComment(widget.postId, comment);

      _commentController.clear();
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(commentsProvider(widget.postId));
    final currentUser = ref.watch(authStateProvider).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (currentUser != null) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Write a comment...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon:
                      _isSubmitting
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(),
                          )
                          : const Icon(Icons.send),
                  onPressed: _isSubmitting ? null : _submitComment,
                ),
              ],
            ),
          ),
          const Divider(),
        ],
        comments.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (error, stack) =>
                  Center(child: Text('Error loading comments: $error')),
          data: (comments) {
            if (comments.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No comments yet. Be the first to comment!'),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return CommentCard(
                  comment: comment,
                  postId: widget.postId,
                  onReply:
                      widget.parentCommentId == null
                          ? () {
                            showModalBottomSheet(
                              context: context,
                              builder:
                                  (context) => CommentSection(
                                    postId: widget.postId,
                                    parentCommentId: comment.id,
                                  ),
                            );
                          }
                          : null,
                );
              },
            );
          },
        ),
      ],
    );
  }
}
