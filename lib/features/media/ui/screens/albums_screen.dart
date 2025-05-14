import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:white_label_community_app/features/media/domain/entities/media_album.dart'
    as domain;
import 'package:white_label_community_app/features/media/state/media_provider.dart';
import 'package:white_label_community_app/features/profile/state/profile_provider.dart';

class AlbumsScreen extends ConsumerStatefulWidget {
  final String userId;
  final bool isCurrentUser;

  const AlbumsScreen({
    super.key,
    required this.userId,
    required this.isCurrentUser,
  });

  @override
  ConsumerState<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends ConsumerState<AlbumsScreen> {
  @override
  Widget build(BuildContext context) {
    final albumsAsync = ref.watch(userAlbumsProvider(widget.userId));

    return Scaffold(
      appBar: AppBar(title: const Text('Albums')),
      floatingActionButton:
          widget.isCurrentUser
              ? FloatingActionButton(
                onPressed: () => _showCreateAlbumDialog(context),
                child: const Icon(Icons.add),
              )
              : null,
      body: albumsAsync.when(
        data: (albums) {
          if (albums.isEmpty) {
            return _buildEmptyState();
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: albums.length,
            itemBuilder: (context, index) {
              final album = albums[index];
              return _buildAlbumCard(album);
            },
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
                  Text('Error loading albums: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.refresh(userAlbumsProvider(widget.userId));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.photo_album_outlined,
            size: 72,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            widget.isCurrentUser
                ? 'You don\'t have any albums yet'
                : 'This user doesn\'t have any albums',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (widget.isCurrentUser) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showCreateAlbumDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Album'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAlbumCard(domain.MediaAlbum album) {
    return GestureDetector(
      onTap: () {
        // Navigate to album details screen
        context.push('/albums/${album.id}');
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child:
                  album.coverUrl.isNotEmpty
                      ? Image.network(album.coverUrl, fit: BoxFit.cover)
                      : Container(
                        color: Colors.grey.shade300,
                        child: const Icon(
                          Icons.photo_album,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${album.mediaCount} items',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (widget.isCurrentUser) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          album.isPublic ? Icons.public : Icons.lock_outline,
                          size: 16,
                          color: Colors.grey,
                        ),
                        if (widget.isCurrentUser)
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 20),
                            itemBuilder:
                                (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditAlbumDialog(context, album);
                              } else if (value == 'delete') {
                                _showDeleteAlbumDialog(context, album);
                              }
                            },
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateAlbumDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isPublic = true;
    File? coverImage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create Album'),
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
                            coverImage = File(pickedFile.path);
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
                              coverImage != null
                                  ? DecorationImage(
                                    image: FileImage(coverImage!),
                                    fit: BoxFit.cover,
                                  )
                                  : null,
                        ),
                        child:
                            coverImage == null
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
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        hintText: 'Enter a description',
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
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter an album name'),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context);

                    final user = ref.read(firebaseAuthProvider).currentUser;
                    if (user != null) {
                      ref
                          .read(userAlbumsProvider(user.uid).notifier)
                          .createAlbum(
                            name: nameController.text.trim(),
                            description: descriptionController.text.trim(),
                            isPublic: isPublic,
                            coverFile: coverImage,
                          );
                    }
                  },
                  child: const Text('CREATE'),
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

  void _showEditAlbumDialog(BuildContext context, domain.MediaAlbum album) {
    final nameController = TextEditingController(text: album.name);
    final descriptionController = TextEditingController(
      text: album.description,
    );
    bool isPublic = album.isPublic;
    File? coverImage;

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
                            coverImage = File(pickedFile.path);
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
                              coverImage != null
                                  ? DecorationImage(
                                    image: FileImage(coverImage!),
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
                            coverImage == null && album.coverUrl.isEmpty
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
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        hintText: 'Enter a description',
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
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter an album name'),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context);

                    final user = ref.read(firebaseAuthProvider).currentUser;
                    if (user != null) {
                      ref
                          .read(userAlbumsProvider(user.uid).notifier)
                          .updateAlbum(
                            albumId: album.id,
                            name: nameController.text.trim(),
                            description: descriptionController.text.trim(),
                            isPublic: isPublic,
                            coverFile: coverImage,
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

  void _showDeleteAlbumDialog(BuildContext context, domain.MediaAlbum album) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Album'),
          content: Text(
            'Are you sure you want to delete "${album.name}"? This will not delete the media in the album but will remove the album itself.',
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
                      .read(userAlbumsProvider(user.uid).notifier)
                      .deleteAlbum(album.id);
                }
              },
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );
  }
}
