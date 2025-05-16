import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:white_label_community_app/features/feed/domain/entities/feed_post.dart';
import 'package:white_label_community_app/features/feed/state/feed_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  final String mediaType;
  final String? space;
  final Map<String, dynamic>? spaceDetails;

  const CreatePostScreen({
    super.key,
    this.mediaType = 'text',
    this.space,
    this.spaceDetails,
  });

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final contentController = TextEditingController();
  File? _mediaFile;
  VideoPlayerController? _videoController;
  bool _isLoading = false;
  bool _processingMedia = false;

  @override
  void initState() {
    super.initState();
    // Automatically open media picker if type is not text
    if (widget.mediaType != 'text') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pickMedia(widget.mediaType);
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickMedia(String mediaType) async {
    setState(() => _processingMedia = true);

    try {
      if (mediaType == 'image') {
        await showModalBottomSheet(
          context: context,
          builder:
              (context) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Choose from gallery'),
                      onTap: () {
                        Navigator.pop(context);
                        _pickImageFromGallery();
                      },
                    ),
                    if (MediaQuery.of(context).size.width <
                        600) // Only show on mobile
                      ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: const Text('Take a photo'),
                        onTap: () {
                          Navigator.pop(context);
                          _takeNewPhoto();
                        },
                      ),
                  ],
                ),
              ),
        );
      } else if (mediaType == 'video') {
        await showModalBottomSheet(
          context: context,
          builder:
              (context) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Choose from gallery'),
                      onTap: () {
                        Navigator.pop(context);
                        _pickVideoFromGallery();
                      },
                    ),
                    if (MediaQuery.of(context).size.width <
                        600) // Only show on mobile
                      ListTile(
                        leading: const Icon(Icons.videocam),
                        title: const Text('Record video'),
                        onTap: () {
                          Navigator.pop(context);
                          _recordNewVideo();
                        },
                      ),
                  ],
                ),
              ),
        );
      } else if (mediaType == 'audio') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio recording coming soon')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _processingMedia = false);
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85, // Increased quality
    );

    if (picked != null) {
      setState(() {
        _mediaFile = File(picked.path);
      });
    }
  }

  Future<void> _takeNewPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (picked != null) {
      setState(() {
        _mediaFile = File(picked.path);
      });
    }
  }

  Future<void> _pickVideoFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 5), // Limited to 5 minutes
    );

    _processPickedVideo(picked);
  }

  Future<void> _recordNewVideo() async {
    final picker = ImagePicker();
    final picked = await picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 5), // Limited to 5 minutes
    );

    _processPickedVideo(picked);
  }

  Future<void> _processPickedVideo(XFile? picked) async {
    if (picked != null) {
      final file = File(picked.path);

      // Check file size - limit to 100MB for web compatibility
      final fileSize = await file.length();
      final fileSizeInMB = fileSize / (1024 * 1024);

      if (fileSizeInMB > 100) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Video is too large. Please select a video under 100MB.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() {
        _mediaFile = file;
      });

      // Initialize video player for preview
      _videoController = VideoPlayerController.file(file)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
          }
        });
    }
  }

  Future<String?> _uploadMedia(File file) async {
    final filename = '${const Uuid().v4()}${p.extension(file.path)}';
    final ref = FirebaseStorage.instance.ref().child('feed_media/$filename');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> _submitPost() async {
    final text = contentController.text.trim();
    if (text.isEmpty && _mediaFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add some content to your post')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      String? mediaUrl;

      if (_mediaFile != null) {
        mediaUrl = await _uploadMedia(_mediaFile!);
      }

      final post = FeedPost(
        id: '',
        authorId: userId,
        content: text,
        mediaUrl: mediaUrl,
        createdAt: DateTime.now(),
        likes: [],
        visibility: widget.space != null ? 'space:${widget.space}' : 'public',
      );

      await ref.read(feedControllerProvider.notifier).addPost(post);

      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.space != null
                  ? 'Post added to ${widget.space} space'
                  : 'Post added to feed',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating post: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.space != null ? 'New Post in ${widget.space}' : 'New Post',
        ),
        actions: [
          TextButton.icon(
            onPressed: !_isLoading ? _submitPost : null,
            icon: const Icon(Icons.send),
            label: const Text('Post'),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Space indicator if posting to a space
                    if (widget.space != null) _buildSpaceIndicator(),

                    // Content text field
                    TextField(
                      controller: contentController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'What\'s on your mind?',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Media preview and picker
                    if (_processingMedia)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_mediaFile != null)
                      _buildMediaPreview()
                    else
                      _buildMediaPicker(),
                  ],
                ),
              ),
    );
  }

  Widget _buildSpaceIndicator() {
    if (widget.spaceDetails != null) {
      final space = widget.spaceDetails!;
      final color =
          space['color'] as Color? ?? Theme.of(context).colorScheme.primary;

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                radius: 20,
                child: Text(
                  space['name'].toString().substring(0, 1),
                  style: TextStyle(color: color),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Posting to ${space['name']}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (space['members'] != null)
                      Text(
                        '${space['members']} members',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Chip(
          label: Text(widget.space!),
          avatar: const Icon(Icons.people),
        ),
      );
    }
  }

  Widget _buildMediaPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.mediaType == 'image'
              ? 'Image Preview'
              : widget.mediaType == 'video'
              ? 'Video Preview'
              : 'Media Preview',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_processingMedia)
                Container(
                  width: double.infinity,
                  height: 300,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Processing media...'),
                      ],
                    ),
                  ),
                )
              else if (widget.mediaType == 'image')
                GestureDetector(
                  onTap: () => _showFullScreenImage(context),
                  child: Hero(
                    tag: 'image_preview',
                    child: Image.file(
                      _mediaFile!,
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else if (widget.mediaType == 'video' && _videoController != null)
                AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(_videoController!),
                      if (!_videoController!.value.isPlaying)
                        IconButton(
                          icon: const Icon(
                            Icons.play_arrow,
                            size: 50,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _videoController!.play();
                            });
                          },
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (widget.mediaType == 'video' && _videoController != null) ...[
          const SizedBox(height: 8),
          ValueListenableBuilder(
            valueListenable: _videoController!,
            builder: (context, VideoPlayerValue value, child) {
              return Column(
                children: [
                  Slider(
                    value: value.position.inMilliseconds.toDouble(),
                    min: 0,
                    max: value.duration.inMilliseconds.toDouble(),
                    onChanged: (newValue) {
                      _videoController!.seekTo(
                        Duration(milliseconds: newValue.toInt()),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(value.position),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          _formatDuration(value.duration),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () => _showMediaTypePicker(),
              icon: const Icon(Icons.refresh),
              label: const Text('Change Media'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _mediaFile = null;
                  _videoController?.dispose();
                  _videoController = null;
                });
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remove'),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _showFullScreenImage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              body: Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Hero(
                    tag: 'image_preview',
                    child: Image.file(_mediaFile!, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildMediaPicker() {
    return InkWell(
      onTap: () => _showMediaTypePicker(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'Add photos or videos to your post',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _showMediaTypePicker(),
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add Media'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMediaTypePicker() async {
    await showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text('Add Photo'),
                  subtitle: const Text(
                    'Choose from gallery or take a new photo',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickMedia('image');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.videocam),
                  title: const Text('Add Video'),
                  subtitle: const Text(
                    'Choose from gallery or record a new video (up to 5 min)',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickMedia('video');
                  },
                ),
                if (widget.mediaType == 'audio') // Only show for admin
                  ListTile(
                    leading: const Icon(Icons.mic),
                    title: const Text('Record Audio'),
                    subtitle: const Text('Coming soon'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Audio recording coming soon'),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
    );
  }
}
