import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:white_label_community_app/features/media/domain/entities/media_item.dart';
import 'package:white_label_community_app/features/media/state/media_provider.dart';
import 'package:white_label_community_app/features/media/ui/utils/media_dialog_utils.dart';
import 'package:white_label_community_app/features/media/ui/utils/media_picker_utils.dart';
import 'package:white_label_community_app/features/media/ui/widgets/media_card.dart';
import 'package:white_label_community_app/features/media/ui/widgets/media_grid.dart';
import 'package:white_label_community_app/features/profile/state/profile_provider.dart';

class MediaGalleryScreen extends ConsumerStatefulWidget {
  final String userId;
  final bool isCurrentUser;

  const MediaGalleryScreen({
    super.key,
    required this.userId,
    this.isCurrentUser = false,
  });

  @override
  ConsumerState<MediaGalleryScreen> createState() => _MediaGalleryScreenState();
}

class _MediaGalleryScreenState extends ConsumerState<MediaGalleryScreen> {
  @override
  Widget build(BuildContext context) {
    final mediaState = ref.watch(userMediaProvider(widget.userId));
    final currentUser = ref.watch(firebaseAuthProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCurrentUser ? 'My Gallery' : 'User Gallery'),
        actions: [
          if (widget.isCurrentUser)
            IconButton(
              icon: const Icon(Icons.photo_album),
              onPressed: _navigateToAlbums,
              tooltip: 'Albums',
            ),
        ],
      ),
      body: mediaState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error),
        data: (mediaItems) {
          if (mediaItems.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              final _ = ref.refresh(userMediaProvider(widget.userId));
              return;
            },
            child: MediaGrid(
              mediaItems: mediaItems,
              onTap: (mediaItem) => context.push('/media/${mediaItem.id}'),
              itemBuilder: (context, mediaItem, index) {
                return MediaCard(
                  mediaItem: mediaItem,
                  currentUserId: currentUser?.uid ?? '',
                  showComments: true,
                  onDelete: widget.isCurrentUser ? _handleDeleteMedia : null,
                  onEdit:
                      widget.isCurrentUser
                          ? () => _handleEditMedia(mediaItem)
                          : null,
                );
              },
            ),
          );
        },
      ),
      floatingActionButton:
          widget.isCurrentUser
              ? FloatingActionButton(
                onPressed: _showAddMediaOptions,
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final _ = ref.refresh(userMediaProvider(widget.userId));
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            widget.isCurrentUser
                ? 'You haven\'t added any media yet'
                : 'This user hasn\'t added any media yet',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (widget.isCurrentUser)
            ElevatedButton.icon(
              onPressed: _showAddMediaOptions,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add Media'),
            ),
        ],
      ),
    );
  }

  void _navigateToAlbums() {
    context.push('/albums/${widget.userId}');
  }

  void _showAddMediaOptions() {
    MediaDialogUtils.showMediaSourceDialog(
      context: context,
      onImageSelected: _handleImageSelected,
      onVideoSelected: _handleVideoSelected,
    );
  }

  Future<void> _handleImageSelected(ImageSource source, MediaType type) async {
    final mediaFile = await MediaPickerUtils.pickImage(
      source: source,
      context: context,
    );

    if (mediaFile != null && mounted) {
      _showMediaUploadDialog(mediaFile, type);
    }
  }

  Future<void> _handleVideoSelected(ImageSource source) async {
    final mediaFile = await MediaPickerUtils.pickVideo(
      source: source,
      context: context,
    );

    if (mediaFile != null && mounted) {
      _showMediaUploadDialog(mediaFile, MediaType.video);
    }
  }

  void _showMediaUploadDialog(File mediaFile, MediaType type) {
    MediaDialogUtils.showMediaUploadDialog(
      context: context,
      mediaFile: mediaFile,
      mediaType: type,
      onUpload: ({
        required File mediaFile,
        required MediaType mediaType,
        required String caption,
        required List<String> tags,
        required bool isPublic,
        String? albumId,
      }) {
        _uploadMedia(
          mediaFile: mediaFile,
          type: mediaType,
          caption: caption,
          tags: tags,
          isPublic: isPublic,
          albumId: albumId,
        );
      },
    );
  }

  Future<void> _uploadMedia({
    required File mediaFile,
    required MediaType type,
    required String caption,
    required List<String> tags,
    required bool isPublic,
    String? albumId,
  }) async {
    try {
      final userProfile = ref.read(profileControllerProvider).value;
      if (userProfile == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User profile not found')),
          );
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Uploading media...')));
      }

      await ref
          .read(currentUserMediaProvider.notifier)
          .createMediaItem(
            mediaFile: mediaFile,
            type: type,
            caption: caption,
            thumbnailFile: null, // We would generate a thumbnail for videos
            tags: tags,
            location: null,
            albumId: albumId,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Media uploaded successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading media: $e')));
      }
    }
  }

  void _handleDeleteMedia(String mediaId) async {
    final shouldDelete = await MediaDialogUtils.showDeleteMediaDialog(
      context: context,
      mediaTitle: '',
    );

    if (shouldDelete && mounted) {
      try {
        await ref
            .read(currentUserMediaProvider.notifier)
            .deleteMediaItem(mediaId);

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Media deleted')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting media: $e')));
        }
      }
    }
  }

  void _handleEditMedia(MediaItem mediaItem) {
    MediaDialogUtils.showMediaEditDialog(
      context: context,
      mediaItem: mediaItem,
      onEdit: ({
        required String caption,
        required List<String> tags,
        required bool isPublic,
      }) {
        final updatedMedia = mediaItem.copyWith(
          caption: caption,
          tags: tags,
          isPublic: isPublic,
        );

        ref
            .read(currentUserMediaProvider.notifier)
            .updateMediaItem(updatedMedia);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Media updated')));
      },
    );
  }
}

/// Helper widget for media gallery tab
class MediaGalleryTab extends ConsumerWidget {
  const MediaGalleryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(firebaseAuthProvider).currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Please sign in to view your media'));
    }

    return MediaGalleryScreen(userId: currentUser.uid, isCurrentUser: true);
  }
}
