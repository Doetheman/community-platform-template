import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:white_label_community_app/features/feed/domain/entities/feed_post.dart';

class FeedPostCard extends StatelessWidget {
  final FeedPost post;

  const FeedPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.yMMMd().add_jm().format(post.createdAt);
    final theme = Theme.of(context);

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
            contentPadding: const EdgeInsets.only(left: 16, right: 8),
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
              child: Text('@${post.authorId.substring(0, 1).toUpperCase()}'),
            ),
            title: Text(
              '@${post.authorId}',
              style: theme.textTheme.titleMedium,
            ),
            subtitle: Text(date, style: theme.textTheme.bodySmall),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ),

          // Post content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(post.content, style: theme.textTheme.bodyLarge),
          ),

          // Media content
          if (post.mediaUrl != null) ...[
            const SizedBox(height: 12),
            _buildMediaContent(post.mediaUrl!, theme),
          ],

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  Icons.favorite_border,
                  '${post.likes.length}',
                  theme,
                ),
                _buildActionButton(Icons.chat_bubble_outline, 'Comment', theme),
                _buildActionButton(Icons.repeat, 'Share', theme),
              ],
            ),
          ),

          // Reaction bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              children: [
                _buildReactionChip('❤️', 2, theme),
                _buildReactionChip('👍', 4, theme),
                _buildReactionChip('😂', 1, theme),
                _buildReactionChip('👏', 3, theme),
                IconButton(
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Thread indicator (if applicable)
          if (false) // Will be dynamically determined based on actual data
            InkWell(
              onTap: () {},
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                child: Text(
                  'View 5 replies',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMediaContent(String mediaUrl, ThemeData theme) {
    final mediaType = _determineMediaType(mediaUrl);

    return Container(
      constraints: const BoxConstraints(maxHeight: 350),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Media content (image, video thumbnail, etc.)
          _buildMediaContentByType(mediaUrl, mediaType, theme),

          // Play button for videos or audio
          if (mediaType == 'video' || mediaType == 'audio')
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                mediaType == 'video' ? Icons.play_arrow : Icons.headphones,
                color: Colors.white,
                size: 40,
              ),
            ),

          // Duration indicator (for video/audio)
          if (mediaType == 'video' || mediaType == 'audio')
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '0:30', // Placeholder duration
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaContentByType(
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
        return Icons.videocam;
      case 'audio':
        return Icons.audiotrack;
      case 'image':
      default:
        return Icons.image;
    }
  }

  String _determineMediaType(String url) {
    // In a real app, determine based on URL extension or metadata
    if (url.contains('youtube') || url.contains('mp4')) {
      return 'video';
    } else if (url.contains('mp3') || url.contains('audio')) {
      return 'audio';
    } else {
      return 'image';
    }
  }

  Widget _buildActionButton(IconData icon, String label, ThemeData theme) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionChip(String emoji, int count, ThemeData theme) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(count.toString(), style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
