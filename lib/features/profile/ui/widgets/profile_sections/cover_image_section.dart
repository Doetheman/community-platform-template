import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CoverImageSection extends StatelessWidget {
  final String? coverImageUrl;
  final File? coverImageFile;
  final Function(File) onImageSelected;
  final bool isLoading;

  const CoverImageSection({
    super.key,
    this.coverImageUrl,
    this.coverImageFile,
    required this.onImageSelected,
    this.isLoading = false,
  });

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (picked != null) {
      onImageSelected(File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.image),
                const SizedBox(width: 16),
                const Text(
                  'Cover Photo',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : _pickCoverImage,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Change'),
                ),
              ],
            ),
          ),
          if (coverImageFile != null || coverImageUrl != null)
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
              ),
              child:
                  coverImageFile != null
                      ? Image.file(coverImageFile!, fit: BoxFit.cover)
                      : Image.network(coverImageUrl!, fit: BoxFit.cover),
            ),
        ],
      ),
    );
  }
}
