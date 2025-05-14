import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_label_community_app/features/media/domain/entities/media_item.dart';
import 'package:white_label_community_app/features/media/state/media_provider.dart';
import 'package:white_label_community_app/features/media/ui/widgets/media_card.dart';
import 'package:white_label_community_app/features/profile/state/profile_provider.dart';

class MediaDetailScreen extends ConsumerWidget {
  final String mediaId;

  const MediaDetailScreen({super.key, required this.mediaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaState = ref.watch(singleMediaProvider(mediaId));
    final currentUser = ref.watch(firebaseAuthProvider).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Media Detail')),
      body: mediaState.when(
        data: (media) {
          if (media == null) {
            return const Center(child: Text('Media not found'));
          }

          final isOwner = currentUser?.uid == media.authorId;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                MediaCard(
                  mediaItem: media,
                  currentUserId: currentUser?.uid ?? '',
                  showComments: true,
                  isDetailView: true,
                  onDelete:
                      isOwner ? _deleteMedia(ref, context, media.id) : null,
                  onEdit:
                      isOwner ? () => _editMedia(ref, context, media) : null,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading media: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.refresh(singleMediaProvider(mediaId));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Function(String) _deleteMedia(
    WidgetRef ref,
    BuildContext context,
    String mediaId,
  ) {
    return (String id) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Delete Media'),
            content: const Text(
              'Are you sure you want to delete this media? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  final user = ref.read(firebaseAuthProvider).currentUser;
                  if (user != null) {
                    ref
                        .read(userMediaProvider(user.uid).notifier)
                        .deleteMediaItem(mediaId);
                    Navigator.pop(context); // Go back to previous screen
                  }
                },
                child: const Text('DELETE'),
              ),
            ],
          );
        },
      );
    };
  }

  void _editMedia(WidgetRef ref, BuildContext context, MediaItem mediaItem) {
    final captionController = TextEditingController(text: mediaItem.caption);
    final tagsController = TextEditingController(
      text: mediaItem.tags.isEmpty ? '' : mediaItem.tags.join(', '),
    );
    bool isPublic = mediaItem.isPublic;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Media'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (mediaItem.isImage)
                      Image.network(
                        mediaItem.url,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    else
                      Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.black,
                        child: const Icon(
                          Icons.play_circle_outline,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: captionController,
                      decoration: const InputDecoration(
                        labelText: 'Caption',
                        hintText: 'Add a caption...',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags',
                        hintText: 'Separated by commas (e.g., tag1, tag2)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Public'),
                      subtitle: const Text('Allow others to see this media'),
                      value: isPublic,
                      onChanged: (value) {
                        setState(() {
                          isPublic = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);

                    final tags =
                        tagsController.text
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();

                    final updatedMedia = mediaItem.copyWith(
                      caption: captionController.text.trim(),
                      tags: tags,
                      isPublic: isPublic,
                    );

                    final user = ref.read(firebaseAuthProvider).currentUser;
                    if (user != null) {
                      ref
                          .read(userMediaProvider(user.uid).notifier)
                          .updateMediaItem(updatedMedia);

                      // Refresh the single media provider
                      ref.refresh(singleMediaProvider(mediaItem.id));
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Media updated')),
                    );
                  },
                  child: const Text('UPDATE'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      captionController.dispose();
      tagsController.dispose();
    });
  }
}
