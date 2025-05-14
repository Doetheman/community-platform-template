import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImageSection extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;
  final Function(File) onImageSelected;
  final bool isLoading;

  const ProfileImageSection({
    super.key,
    this.imageUrl,
    this.imageFile,
    required this.onImageSelected,
    this.isLoading = false,
  });

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    // Allow user to choose between camera and gallery
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? photo = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 800,
                    maxHeight: 800,
                    imageQuality: 80,
                  );
                  if (photo != null) {
                    onImageSelected(File(photo.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 800,
                    maxHeight: 800,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    onImageSelected(File(image.path));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[200],
            backgroundImage: _getProfileImage(),
            child:
                _showPlaceholder()
                    ? const Icon(Icons.person, size: 60, color: Colors.grey)
                    : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child:
                  isLoading
                      ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                      : IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: () => _pickImage(context),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  bool _showPlaceholder() {
    return imageUrl == null && imageFile == null;
  }

  ImageProvider? _getProfileImage() {
    if (imageFile != null) {
      return FileImage(imageFile!);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      return NetworkImage(imageUrl!);
    }
    return null;
  }
}
