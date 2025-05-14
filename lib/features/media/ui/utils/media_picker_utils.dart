import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:white_label_community_app/features/media/domain/entities/media_item.dart';

/// Utility class for media picker operations
class MediaPickerUtils {
  static final ImagePicker _picker = ImagePicker();

  /// Pick an image from camera or gallery
  static Future<File?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality = 80,
    BuildContext? context,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      if (context != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }

    return null;
  }

  /// Pick a video from camera or gallery
  static Future<File?> pickVideo({
    required ImageSource source,
    Duration? maxDuration = const Duration(minutes: 1),
    BuildContext? context,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickVideo(
        source: source,
        maxDuration: maxDuration,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      if (context != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking video: $e')));
      }
    }

    return null;
  }

  /// Generate a thumbnail for a video file (placeholder implementation)
  /// In a real app, you would use a package like video_thumbnail
  static Future<File?> generateVideoThumbnail(File videoFile) async {
    // This is a placeholder. In a real app, you would use video_thumbnail
    // or another package to generate a real thumbnail
    return null;
  }

  /// Process a selected media file (for example, resize or optimize it)
  static Future<File> processMediaFile(File file, MediaType type) async {
    // This is a placeholder. In a real app, you might resize images
    // or compress videos here before uploading
    return file;
  }

  /// Check if a file is a valid media file
  static bool isValidMediaFile(File file, MediaType type) {
    final extension = file.path.split('.').last.toLowerCase();

    if (type == MediaType.image) {
      return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'].contains(extension);
    } else if (type == MediaType.video) {
      return ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension);
    }

    return false;
  }

  /// Get file size in a human readable format
  static String getFileSizeString(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Check if file size is within allowed limits
  static bool isFileSizeAllowed(File file, {int maxSizeMB = 50}) {
    final bytes = file.lengthSync();
    final mb = bytes / (1024 * 1024);
    return mb <= maxSizeMB;
  }
}
