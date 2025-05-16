import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:white_label_community_app/features/feed/domain/entities/feed_post.dart';
import 'package:white_label_community_app/features/profile/state/profile_provider.dart'
    as profile;
import 'package:white_label_community_app/features/feed/state/feed_provider.dart';
import 'package:white_label_community_app/features/auth/state/auth_provider.dart';
import 'package:white_label_community_app/features/feed/ui/widgets/comment_section.dart';

class FeedPostCard extends ConsumerWidget {
  final FeedPost post;
  final List<String> availableEmojis = [
    '❤️',
    '👍',
    '😂',
    '👏',
    '🎉',
    '🔥',
    '🙌',
    '💯',
  ];

  FeedPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = DateFormat.yMMMd().add_jm().format(post.createdAt);
    final theme = Theme.of(context);
    final currentUser = ref.watch(firebaseAuthProvider).currentUser;
    final isLiked = currentUser != null && post.likes.contains(currentUser.uid);

    // Fetch author profile
    final authorProfile = ref.watch(
      profile.userProfileByUidProvider(post.authorId),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author header
          ListTile(
            contentPadding: const EdgeInsets.only(left: 0, right: 8),
            leading: GestureDetector(
              onTap: () => _openProfile(context),
              child: authorProfile.when(
                data: (profile) {
                  if (profile == null) {
                    return CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withOpacity(
                        0.2,
                      ),
                      child: const Icon(Icons.person),
                    );
                  }
                  return CircleAvatar(
                    backgroundImage:
                        profile.profileImageUrl != null
                            ? NetworkImage(profile.profileImageUrl!)
                            : null,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                    child:
                        profile.profileImageUrl == null
                            ? Text(profile.name.substring(0, 1).toUpperCase())
                            : null,
                  );
                },
                loading:
                    () => CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withOpacity(
                        0.2,
                      ),
                      child: const CircularProgressIndicator(),
                    ),
                error:
                    (_, __) => CircleAvatar(
                      backgroundColor: theme.colorScheme.error.withOpacity(0.2),
                      child: const Icon(Icons.error_outline),
                    ),
              ),
            ),
            title: GestureDetector(
              onTap: () => _openProfile(context),
              child: authorProfile.when(
                data:
                    (profile) => Text(
                      profile?.name ?? 'Unknown User',
                      style: theme.textTheme.titleMedium,
                    ),
                loading: () => const Text('Loading...'),
                error: (_, __) => const Text('Error loading profile'),
              ),
            ),
            subtitle: Text(date, style: theme.textTheme.bodySmall),
          ),

          // Post content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(post.content, style: theme.textTheme.bodyLarge),
          ),

          // Tags
          if (post.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children:
                    post.tags.map((tag) {
                      return Chip(
                        label: Text('#$tag'),
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.1,
                        ),
                        labelStyle: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 12,
                        ),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
              ),
            ),
          ],

          // Media content
          if (post.mediaUrl != null) ...[
            const SizedBox(height: 12),
            _buildMediaContent(post.mediaUrl!, post.mediaType, theme),
          ],

          // Reactions
          if (post.reactions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children:
                    post.reactions.entries.map((entry) {
                      final emoji = entry.key;
                      final count = entry.value.length;
                      final hasReacted =
                          currentUser != null &&
                          entry.value.contains(currentUser.uid);
                      return _buildReactionChip(
                        emoji: emoji,
                        count: count,
                        theme: theme,
                        isSelected: hasReacted,
                        onTap: () {
                          if (currentUser != null) {
                            ref
                                .read(feedRepositoryProvider)
                                .toggleReaction(
                                  post.id,
                                  currentUser.uid,
                                  emoji,
                                );
                          }
                        },
                      );
                    }).toList(),
              ),
            ),
          ],

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : null,
                  ),
                  label: Text('${post.likes.length}'),
                  onPressed:
                      currentUser == null
                          ? null
                          : () {
                            ref
                                .read(feedRepositoryProvider)
                                .toggleLike(post.id, currentUser.uid);
                          },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.emoji_emotions_outlined),
                  label: const Text('React'),
                  onPressed:
                      currentUser == null
                          ? null
                          : () => _showReactionPicker(context, ref),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.comment_outlined),
                  label: Text('${post.commentsCount}'),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder:
                          (context) => DraggableScrollableSheet(
                            initialChildSize: 0.7,
                            minChildSize: 0.5,
                            maxChildSize: 0.95,
                            expand: false,
                            builder:
                                (context, scrollController) => Column(
                                  children: [
                                    AppBar(
                                      title: const Text('Comments'),
                                      leading: IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ),
                                    Expanded(
                                      child: CommentSection(postId: post.id),
                                    ),
                                  ],
                                ),
                          ),
                    );
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share'),
                  onPressed: () => _sharePost(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionChip({
    required String emoji,
    required int count,
    required ThemeData theme,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected ? theme.colorScheme.primary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReactionPicker(BuildContext context, WidgetRef ref) {
    final currentUser = ref.read(firebaseAuthProvider).currentUser;
    if (currentUser == null) return;

    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Reaction',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      availableEmojis.map((emoji) {
                        final hasReacted =
                            post.reactions[emoji]?.contains(currentUser.uid) ??
                            false;
                        return InkWell(
                          onTap: () {
                            ref
                                .read(feedRepositoryProvider)
                                .toggleReaction(
                                  post.id,
                                  currentUser.uid,
                                  emoji,
                                );
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  hasReacted
                                      ? Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.1)
                                      : null,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaContent(
    String mediaUrl,
    String mediaType,
    ThemeData theme,
  ) {
    // Check if the URL is from placeholder.com which might fail
    final isPlaceholder = mediaUrl.contains('placeholder.com');

    // If it's a placeholder or unreliable URL, use a local fallback
    if (isPlaceholder) {
      // Generate a colored container based on the media type
      return Container(
        height: 200,
        width: double.infinity,
        color: _getColorForMediaType(mediaType, theme),
        child: Center(
          child: Icon(
            _getIconForMediaType(mediaType),
            size: 64,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      );
    }

    // If it's a reliable URL, use the Image.network with fallbacks
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(0)),
      child: Image.network(
        mediaUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        // Loading placeholder
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 200,
            color: _getColorForMediaType(mediaType, theme),
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        // Error placeholder
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: _getColorForMediaType(mediaType, theme),
            child: Center(
              child: Icon(
                _getIconForMediaType(mediaType),
                size: 64,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getColorForMediaType(String mediaType, ThemeData theme) {
    switch (mediaType) {
      case 'video':
        return Colors.blueGrey;
      case 'audio':
        return Colors.deepPurple;
      case 'image':
      default:
        return theme.colorScheme.primary.withOpacity(0.3);
    }
  }

  IconData _getIconForMediaType(String mediaType) {
    switch (mediaType) {
      case 'video':
        return Icons.play_circle_outline;
      case 'audio':
        return Icons.audio_file;
      case 'image':
      default:
        return Icons.image;
    }
  }

  void _openProfile(BuildContext context) {
    // Implement the logic to open the user's profile
    final creatorUid = post.authorId;
    context.push('/profile/$creatorUid', extra: creatorUid);
  }

  void _sharePost(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(sharePostProvider(post));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to share post'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
