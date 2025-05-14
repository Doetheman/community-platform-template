import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:white_label_community_app/features/media/domain/entities/media_item.dart';
import 'package:white_label_community_app/features/media/state/media_provider.dart';
import 'package:white_label_community_app/features/profile/state/profile_provider.dart';

class MediaCard extends ConsumerStatefulWidget {
  final MediaItem mediaItem;
  final String currentUserId;
  final bool showComments;
  final bool isDetailView;
  final Function(String)? onDelete;
  final VoidCallback? onEdit;

  const MediaCard({
    super.key,
    required this.mediaItem,
    required this.currentUserId,
    this.showComments = false,
    this.isDetailView = false,
    this.onDelete,
    this.onEdit,
  });

  @override
  ConsumerState<MediaCard> createState() => _MediaCardState();
}

class _MediaCardState extends ConsumerState<MediaCard> {
  VideoPlayerController? _videoController;
  bool _isPlaying = false;
  final TextEditingController _commentController = TextEditingController();
  bool _isCommenting = false;
  bool _showAllComments = false;

  @override
  void initState() {
    super.initState();
    if (widget.mediaItem.isVideo) {
      _initializeVideoPlayer();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MediaCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaItem.url != widget.mediaItem.url &&
        widget.mediaItem.isVideo) {
      _videoController?.dispose();
      _initializeVideoPlayer();
    }
  }

  Future<void> _initializeVideoPlayer() async {
    _videoController = VideoPlayerController.network(widget.mediaItem.url);
    await _videoController!.initialize();
    setState(() {});
  }

  void _toggleVideoPlay() {
    if (_videoController == null) return;

    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
        _isPlaying = false;
      } else {
        _videoController!.play();
        _isPlaying = true;
      }
    });
  }

  void _toggleLike() {
    if (widget.isDetailView) {
      // If we're in the detail view, we need to use a different provider
      // This is handled by the detail screen
      return;
    }

    ref
        .read(userMediaProvider(widget.mediaItem.authorId).notifier)
        .toggleLike(widget.mediaItem.id);
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    final text = _commentController.text.trim();
    _commentController.clear();

    if (widget.isDetailView) {
      // If we're in the detail view, we need to use a different provider
      // This is handled by the detail screen
      return;
    }

    final userProfile =
        ref.read(singleUserProfileProvider(widget.currentUserId)).value;

    ref
        .read(userMediaProvider(widget.mediaItem.authorId).notifier)
        .addComment(
          mediaId: widget.mediaItem.id,
          text: text,
          authorName: userProfile?.name ?? 'Anonymous',
          authorProfileImageUrl: userProfile?.profileImageUrl,
        );
  }

  void _deleteComment(String commentId) {
    if (widget.isDetailView) {
      // If we're in the detail view, we need to use a different provider
      // This is handled by the detail screen
      return;
    }

    ref
        .read(userMediaProvider(widget.mediaItem.authorId).notifier)
        .deleteComment(mediaId: widget.mediaItem.id, commentId: commentId);
  }

  void _navigateToUserProfile() {
    context.push('/profile/${widget.mediaItem.authorId}');
  }

  void _navigateToMediaDetail() {
    if (!widget.isDetailView) {
      context.push('/media/${widget.mediaItem.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLiked = widget.mediaItem.isLikedBy(widget.currentUserId);
    final mediaAge = DateTime.now().difference(widget.mediaItem.createdAt);
    final formattedDate =
        mediaAge.inDays > 2
            ? DateFormat.yMMMd().format(widget.mediaItem.createdAt)
            : mediaAge.inHours > 24
            ? '${mediaAge.inDays}d ago'
            : mediaAge.inHours > 0
            ? '${mediaAge.inHours}h ago'
            : '${mediaAge.inMinutes}m ago';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info
          ListTile(
            leading: GestureDetector(
              onTap: _navigateToUserProfile,
              child: CircleAvatar(
                backgroundImage:
                    widget.mediaItem.authorProfileImageUrl != null
                        ? NetworkImage(widget.mediaItem.authorProfileImageUrl!)
                        : null,
                child:
                    widget.mediaItem.authorProfileImageUrl == null
                        ? const Icon(Icons.person)
                        : null,
              ),
            ),
            title: GestureDetector(
              onTap: _navigateToUserProfile,
              child: Text(
                widget.mediaItem.authorName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            subtitle: Text(formattedDate),
            trailing:
                widget.mediaItem.authorId == widget.currentUserId
                    ? PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit' && widget.onEdit != null) {
                          widget.onEdit!();
                        } else if (value == 'delete' &&
                            widget.onDelete != null) {
                          widget.onDelete!(widget.mediaItem.id);
                        }
                      },
                      itemBuilder:
                          (context) => [
                            if (widget.onEdit != null)
                              const PopupMenuItem(
                                value: 'edit',
                                child: ListTile(
                                  leading: Icon(Icons.edit),
                                  title: Text('Edit'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            if (widget.onDelete != null)
                              const PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(Icons.delete),
                                  title: Text('Delete'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                          ],
                    )
                    : null,
          ),

          // Media content
          GestureDetector(
            onTap:
                widget.mediaItem.isVideo
                    ? _toggleVideoPlay
                    : _navigateToMediaDetail,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (widget.mediaItem.isImage)
                  Image.network(
                    widget.mediaItem.url,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 300,
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.error, size: 40)),
                      );
                    },
                  )
                else if (widget.mediaItem.isVideo && _videoController != null)
                  AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 300,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),

                if (widget.mediaItem.isVideo)
                  IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause_circle : Icons.play_circle,
                      size: 50,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    onPressed: _toggleVideoPlay,
                  ),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : null,
                  ),
                  onPressed: _toggleLike,
                ),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () {
                    setState(() {
                      _isCommenting = !_isCommenting;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {
                    // Share functionality will be implemented later
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sharing coming soon!')),
                    );
                  },
                ),
                const Spacer(),
                if (widget.mediaItem.albumId != null)
                  Tooltip(
                    message: 'In album',
                    child: IconButton(
                      icon: const Icon(Icons.photo_album_outlined),
                      onPressed: () {
                        // Navigate to album
                        context.push('/albums/${widget.mediaItem.albumId}');
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Like count
          if (widget.mediaItem.likeCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '${widget.mediaItem.likeCount} ${widget.mediaItem.likeCount == 1 ? 'like' : 'likes'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

          // Caption
          if (widget.mediaItem.caption != null &&
              widget.mediaItem.caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                      text: '${widget.mediaItem.authorName} ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: widget.mediaItem.caption!),
                  ],
                ),
              ),
            ),

          // Tags
          if (widget.mediaItem.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8,
                children:
                    widget.mediaItem.tags.map((tag) {
                      return Chip(
                        label: Text('#$tag'),
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.1,
                        ),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
              ),
            ),

          // Comments section
          if (widget.showComments && widget.mediaItem.comments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // View all comments button
                  if (widget.mediaItem.comments.length > 2 && !_showAllComments)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showAllComments = true;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'View all ${widget.mediaItem.comments.length} comments',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),

                  // Comments list
                  ..._buildComments(),
                ],
              ),
            ),

          // Comment input
          if (_isCommenting || widget.isDetailView)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    // Use current user profile image
                    backgroundImage:
                        ref
                                    .watch(
                                      singleUserProfileProvider(
                                        widget.currentUserId,
                                      ),
                                    )
                                    .value
                                    ?.profileImageUrl !=
                                null
                            ? NetworkImage(
                              ref
                                  .watch(
                                    singleUserProfileProvider(
                                      widget.currentUserId,
                                    ),
                                  )
                                  .value!
                                  .profileImageUrl!,
                            )
                            : null,
                    child:
                        ref
                                    .watch(
                                      singleUserProfileProvider(
                                        widget.currentUserId,
                                      ),
                                    )
                                    .value
                                    ?.profileImageUrl ==
                                null
                            ? const Icon(Icons.person, size: 16)
                            : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                      onSubmitted: (_) => _addComment(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _addComment,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildComments() {
    final comments = widget.mediaItem.comments;
    final commentsToShow =
        _showAllComments
            ? comments
            : comments.length > 2
            ? comments.sublist(comments.length - 2)
            : comments;

    return commentsToShow.map((comment) {
      final isCommentLiked = comment.likes.contains(widget.currentUserId);
      final commentAge = DateTime.now().difference(comment.createdAt);
      final formattedCommentDate =
          commentAge.inDays > 2
              ? DateFormat.yMMMd().format(comment.createdAt)
              : commentAge.inHours > 24
              ? '${commentAge.inDays}d'
              : commentAge.inHours > 0
              ? '${commentAge.inHours}h'
              : '${commentAge.inMinutes}m';

      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage:
                  comment.authorProfileImageUrl != null
                      ? NetworkImage(comment.authorProfileImageUrl!)
                      : null,
              child:
                  comment.authorProfileImageUrl == null
                      ? const Icon(Icons.person, size: 16)
                      : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(
                          text: comment.authorName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ' ${comment.text}'),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        formattedCommentDate,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(width: 16),
                      if (comment.likes.isNotEmpty)
                        Text(
                          '${comment.likes.length} ${comment.likes.length == 1 ? 'like' : 'likes'}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          // Reply to comment
                          setState(() {
                            _isCommenting = true;
                            _commentController.text = '@${comment.authorName} ';
                          });
                        },
                        child: Text(
                          'Reply',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    isCommentLiked ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: isCommentLiked ? Colors.red : Colors.grey[600],
                  ),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    // Like comment logic
                  },
                ),
                if (comment.authorId == widget.currentUserId ||
                    widget.mediaItem.authorId == widget.currentUserId)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    onPressed: () => _deleteComment(comment.id),
                  ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }
}

// Function to get a provider for a single user profile (used for comment author info)
final singleUserProfileProvider = Provider.autoDispose.family((
  ref,
  String userId,
) {
  return ref.watch(userProfileByUidProvider(userId));
});
