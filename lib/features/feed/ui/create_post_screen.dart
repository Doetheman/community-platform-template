import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:white_label_community_app/features/feed/domain/entities/feed_post.dart';
import 'package:white_label_community_app/features/feed/state/feed_provider.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final contentController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<String?> _uploadImage(File file) async {
    final filename = '${const Uuid().v4()}${p.extension(file.path)}';
    final ref = FirebaseStorage.instance.ref().child('feed_media/$filename');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> _submitPost() async {
    final text = contentController.text.trim();
    if (text.isEmpty && _imageFile == null) return;

    setState(() => _isLoading = true);

    final userId = const Uuid().v4(); // Replace with Firebase Auth UID
    String? mediaUrl;

    if (_imageFile != null) {
      mediaUrl = await _uploadImage(_imageFile!);
    }

    final post = FeedPost(
      id: '',
      authorId: userId,
      content: text,
      mediaUrl: mediaUrl,
      createdAt: DateTime.now(),
      likes: [],
      visibility: 'public',
    );

    await ref.read(feedControllerProvider.notifier).addPost(post);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Post')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: contentController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'What’s on your mind?',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_imageFile != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_imageFile!, height: 160),
                      ),
                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Add Image'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _submitPost,
                      icon: const Icon(Icons.send),
                      label: const Text('Post'),
                    ),
                  ],
                ),
              ),
    );
  }
}
