import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:white_label_community_app/features/media/domain/entities/media_album.dart'
    as domain;
import 'package:white_label_community_app/features/media/domain/entities/media_item.dart'
    hide MediaAlbum;
import 'package:white_label_community_app/features/media/state/media_provider.dart';
import 'package:white_label_community_app/features/media/ui/widgets/media_grid.dart';
import 'package:white_label_community_app/features/media/ui/widgets/media_thumbnail.dart';
import 'package:white_label_community_app/features/profile/state/profile_provider.dart';

class AlbumDetailScreen extends ConsumerStatefulWidget {
  final String albumId;

  const AlbumDetailScreen({super.key, required this.albumId});

  @override
  ConsumerState<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends ConsumerState<AlbumDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final albumAsync = ref.watch(singleAlbumProvider(widget.albumId));
    final mediaAsync = ref.watch(albumMediaProvider(widget.albumId));
    final currentUser = ref.watch(firebaseAuthProvider).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Album Details')),
      body: albumAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error),
        data: (album) {
          if (album == null) {
            return const Center(child: Text('Album not found'));
          }

          final isOwner =
              currentUser != null && album.authorId == currentUser.uid;

          return RefreshIndicator(
            onRefresh: () async {
              final _ = ref.refresh(singleAlbumProvider(widget.albumId));
              final _ = ref.refresh(albumMediaProvider(widget.albumId));
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildAlbumHeader(album, isOwner)),
                SliverToBoxAdapter(child: _buildAlbumDescription(album)),
                mediaAsync.when(
                  loading:
                      () => const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  error:
                      (error, stack) => SliverToBoxAdapter(
                        child: Center(
                          child: Text('Error loading media: $error'),
                        ),
                      ),
                  data: (mediaItems) {
                    if (mediaItems.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_library,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No media in this album yet',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              if (isOwner) const SizedBox(height: 16),
                              if (isOwner)
                                ElevatedButton.icon(
                                  onPressed:
                                      () => _showAddMediaToAlbumDialog(album),
                                  icon: const Icon(Icons.add_photo_alternate),
                                  label: const Text('Add Media'),
                                ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SliverMediaGrid(
                      mediaItems: mediaItems,
                      padding: const EdgeInsets.all(16.0),
                      onTap:
                          (mediaItem) => context.push('/media/${mediaItem.id}'),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: albumAsync.maybeWhen(
        data: (album) {
          if (album == null) return null;
          final isOwner =
              currentUser != null && album.authorId == currentUser.uid;
          return isOwner
              ? FloatingActionButton(
                onPressed: () => _showAddMediaToAlbumDialog(album),
                child: const Icon(Icons.add_photo_alternate),
              )
              : null;
        },
        orElse: () => null,
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error loading album: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final _ = ref.refresh(singleAlbumProvider(widget.albumId));
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumHeader(domain.MediaAlbum album, bool isOwner) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 100,
              height: 100,
              child:
                  album.coverUrl.isNotEmpty
                      ? MediaThumbnail(
                        url: album.coverUrl,
                        height: 100,
                        width: 100,
                        borderRadius: 0,
                        type: MediaType.image,
                      )
                      : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.photo_album, size: 48),
                      ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        album.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isOwner)
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditAlbumDialog(album),
                      ),
                  ],
                ),
                Text(
                  'Created by ${isOwner ? 'You' : 'User'}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '${album.mediaCount} item${album.mediaCount != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      album.isPublic ? Icons.public : Icons.lock,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      album.isPublic ? 'Public' : 'Private',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumDescription(domain.MediaAlbum album) {
    if (album.description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        album.description,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  void _showEditAlbumDialog(domain.MediaAlbum album) {
    final nameController = TextEditingController(text: album.name);
    final descriptionController = TextEditingController(
      text: album.description,
    );
    bool isPublic = album.isPublic;
    File? coverFile;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Album'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(
                          source: ImageSource.gallery,
                        );

                        if (pickedFile != null) {
                          setState(() {
                            coverFile = File(pickedFile.path);
                          });
                        }
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                          image:
                              coverFile != null
                                  ? DecorationImage(
                                    image: FileImage(coverFile!),
                                    fit: BoxFit.cover,
                                  )
                                  : album.coverUrl.isNotEmpty
                                  ? DecorationImage(
                                    image: NetworkImage(album.coverUrl),
                                    fit: BoxFit.cover,
                                  )
                                  : null,
                        ),
                        child:
                            coverFile == null && album.coverUrl.isEmpty
                                ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 48,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Add Cover Image',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                )
                                : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Album Name',
                        hintText: 'Enter a name for your album',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        hintText: 'Enter a description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Public'),
                      subtitle: const Text('Allow others to see this album'),
                      value: isPublic,
                      onChanged: (value) {
                        setState(() {
                          isPublic = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
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
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter an album name'),
                        ),
                      );
                      return;
                    }

                    final albumId = album.id;
                    final name = nameController.text.trim();
                    final description = descriptionController.text.trim();
                    final isAlbumPublic = isPublic;
                    final albumCoverFile = coverFile;

                    Navigator.pop(context);

                    try {
                      final currentUser =
                          ref.read(firebaseAuthProvider).currentUser;
                      if (currentUser == null) return;

                      await ref
                          .read(userAlbumsProvider(currentUser.uid).notifier)
                          .updateAlbum(
                            albumId: albumId,
                            name: name,
                            description: description,
                            isPublic: isAlbumPublic,
                            coverFile: albumCoverFile,
                          );

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Album updated successfully'),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update album: $e')),
                      );
                    }
                  },
                  child: const Text('UPDATE'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      nameController.dispose();
      descriptionController.dispose();
    });
  }

  void _showAddMediaToAlbumDialog(domain.MediaAlbum album) {
    final currentUser = ref.read(firebaseAuthProvider).currentUser;
    if (currentUser == null) return;

    ref.read(userMediaProvider(currentUser.uid)).whenData((userMedia) {
      final mediaNotInAlbum =
          userMedia
              .where((media) => !album.mediaIds.contains(media.id))
              .toList();

      if (mediaNotInAlbum.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You don\'t have any media to add to this album'),
          ),
        );
        return;
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.8,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(
                          'Add to ${album.name}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: mediaNotInAlbum.length,
                      itemBuilder: (context, index) {
                        final mediaItem = mediaNotInAlbum[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _addMediaToAlbum(album.id, mediaItem.id);
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              MediaThumbnail.fromMediaItem(
                                mediaItem,
                                height: 120,
                                width: 120,
                                borderRadius: 8,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.black26,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    });
  }

  void _addMediaToAlbum(String albumId, String mediaId) async {
    final currentUser = ref.read(firebaseAuthProvider).currentUser;
    if (currentUser == null) return;

    try {
      // Show loading indicator
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Adding media to album...')));

      await ref
          .read(userAlbumsProvider(currentUser.uid).notifier)
          .addMediaToAlbum(albumId, mediaId);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Media added to album')));

      // Refresh the album media
      final _ = ref.refresh(albumMediaProvider(albumId));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add media to album: $e')),
      );
    }
  }
}
