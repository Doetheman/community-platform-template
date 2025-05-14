import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImageUtils {
  /// Pick an image from gallery or camera
  static Future<File?> pickImage({
    required BuildContext context,
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? quality,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: quality ?? 80,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }

    return null;
  }

  /// Show a modal bottom sheet to choose image source
  static Future<File?> showImageSourceDialog({
    required BuildContext context,
    double? maxWidth,
    double? maxHeight,
    int? quality,
  }) async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      return pickImage(
        context: context,
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        quality: quality,
      );
    }

    return null;
  }

  /// Determine if the image size is valid (less than maxSizeInMB)
  static bool isValidImageSize(File file, {double maxSizeInMB = 5.0}) {
    final bytes = file.lengthSync();
    final sizeInMB = bytes / (1024 * 1024);
    return sizeInMB <= maxSizeInMB;
  }

  /// Get a human-readable file size string
  static String getFileSizeString(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Create a profile image placeholder widget
  static Widget createProfileImagePlaceholder({
    double size = 120.0,
    Color? backgroundColor,
    Color? iconColor,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);

    return CircleAvatar(
      radius: size / 2,
      backgroundColor:
          backgroundColor ?? theme.colorScheme.primary.withOpacity(0.1),
      child: Icon(
        Icons.person,
        size: size / 2,
        color: iconColor ?? theme.colorScheme.primary,
      ),
    );
  }
}
