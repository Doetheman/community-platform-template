import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:white_label_community_app/features/media/domain/entities/media_album.dart'
    as domain;
import 'package:white_label_community_app/features/media/domain/entities/media_item.dart';
import 'package:white_label_community_app/features/media/ui/widgets/media_thumbnail.dart';
import 'package:white_label_community_app/features/media/ui/widgets/media_upload_form.dart';

/// Utility class for displaying media-related dialogs
class MediaDialogUtils {
  /// Show a dialog to pick a media source (camera or gallery)
  static Future<void> showMediaSourceDialog({
    required BuildContext context,
    required Function(ImageSource source, MediaType type) onImageSelected,
    required Function(ImageSource source) onVideoSelected,
  }) async {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  onImageSelected(ImageSource.camera, MediaType.image);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  onImageSelected(ImageSource.gallery, MediaType.image);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Take Video'),
                onTap: () {
                  Navigator.pop(context);
                  onVideoSelected(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text('Choose Video from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  onVideoSelected(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Show a dialog to upload media with caption, tags, and visibility options
  static Future<void> showMediaUploadDialog({
    required BuildContext context,
    required File mediaFile,
    required MediaType mediaType,
    required Function({
      required File mediaFile,
      required MediaType mediaType,
      required String caption,
      required List<String> tags,
      required bool isPublic,
      String? albumId,
    })
    onUpload,
    String? albumId,
  }) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            mediaType == MediaType.image ? 'Upload Image' : 'Upload Video',
          ),
          content: MediaUploadForm(
            mediaFile: mediaFile,
            mediaType: mediaType,
            onSubmit: ({
              required File mediaFile,
              required MediaType mediaType,
              required String caption,
              required List<String> tags,
              required bool isPublic,
            }) {
              Navigator.pop(context);
              onUpload(
                mediaFile: mediaFile,
                mediaType: mediaType,
                caption: caption,
                tags: tags,
                isPublic: isPublic,
                albumId: albumId,
              );
            },
            onCancel: () => Navigator.pop(context),
          ),
          contentPadding: const EdgeInsets.all(16),
          // Remove default actions since they're included in the form
          actions: null,
        );
      },
    );
  }

  /// Show a dialog to edit an existing media item
  static Future<void> showMediaEditDialog({
    required BuildContext context,
    required MediaItem mediaItem,
    required Function({
      required String caption,
      required List<String> tags,
      required bool isPublic,
    })
    onEdit,
  }) async {
    final captionController = TextEditingController(text: mediaItem.caption);
    final tagsController = TextEditingController(
      text: mediaItem.tags.isEmpty ? '' : mediaItem.tags.join(', '),
    );
    bool isPublic = mediaItem.isPublic;

    return showDialog(
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
                    MediaThumbnail.fromMediaItem(
                      mediaItem,
                      height: 200,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: captionController,
                      decoration: const InputDecoration(
                        labelText: 'Caption',
                        hintText: 'Add a caption...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags',
                        hintText: 'Separated by commas (e.g., tag1, tag2)',
                        border: OutlineInputBorder(),
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
                    Navigator.pop(context);

                    final tags =
                        tagsController.text
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();

                    onEdit(
                      caption: captionController.text.trim(),
                      tags: tags,
                      isPublic: isPublic,
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

  /// Show a confirmation dialog for deleting media
  static Future<bool> showDeleteMediaDialog({
    required BuildContext context,
    required String mediaTitle,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Media'),
          content: Text(
            'Are you sure you want to delete ${mediaTitle.isNotEmpty ? '"$mediaTitle"' : 'this media'}? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  /// Show a dialog for creating a new album
  static Future<void> showCreateAlbumDialog({
    required BuildContext context,
    required Function({
      required String name,
      required String description,
      required bool isPublic,
      required File? coverFile,
    })
    onCreate,
  }) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isPublic = true;
    File? coverImage;

    return showDialog(
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
                    onCreate(
                      name: nameController.text.trim(),
                      description: descriptionController.text.trim(),
                      isPublic: isPublic,
                      coverFile: coverImage,
                    );
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

  /// Show a dialog for selecting media to add to an album
  static Future<void> showAddMediaToAlbumDialog({
    required BuildContext context,
    required domain.MediaAlbum album,
    required List<MediaItem> availableMedia,
    required Function(String mediaId) onMediaSelected,
  }) async {
    if (availableMedia.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You don\'t have any media to add to this album'),
        ),
      );
      return;
    }

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
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
                    itemCount: availableMedia.length,
                    itemBuilder: (context, index) {
                      final mediaItem = availableMedia[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          onMediaSelected(mediaItem.id);
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            MediaThumbnail.fromMediaItem(
                              mediaItem,
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
  }

  /// Show a confirmation dialog for removing media from an album
  static Future<bool> showRemoveFromAlbumDialog({
    required BuildContext context,
    required domain.MediaAlbum album,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove from Album'),
          content: Text(
            'Are you sure you want to remove this media from "${album.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('REMOVE'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}
