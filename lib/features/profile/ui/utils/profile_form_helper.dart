import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// A helper class for common profile form functions
class ProfileFormHelper {
  /// Pick a profile image from camera or gallery
  static Future<File?> pickProfileImage(BuildContext context) async {
    final picker = ImagePicker();

    // Allow user to choose between camera and gallery
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) {
      return null;
    }

    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }

    return null;
  }

  /// Pick a cover image from camera or gallery
  static Future<File?> pickCoverImage(BuildContext context) async {
    final picker = ImagePicker();

    // Allow user to choose between camera and gallery
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) {
      return null;
    }

    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 900,
      imageQuality: 75,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }

    return null;
  }

  /// Show a confirmation dialog for discarding changes
  static Future<bool> showDiscardChangesDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Discard Changes?'),
            content: const Text(
              'You have unsaved changes. Are you sure you want to discard them?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('DISCARD'),
              ),
            ],
          ),
    );

    return result ?? false;
  }

  /// Show a social media dialog
  static Future<Map<String, String>?> showSocialMediaDialog({
    required BuildContext context,
    required Map<String, String> current,
  }) async {
    final platforms = [
      'Facebook',
      'Twitter',
      'Instagram',
      'LinkedIn',
      'GitHub',
      'YouTube',
      'TikTok',
      'Medium',
    ];

    final controllers = <String, TextEditingController>{};

    // Initialize controllers
    for (final platform in platforms) {
      controllers[platform] = TextEditingController(
        text: current[platform] ?? '',
      );
    }

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Social Media Links'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    platforms.map((platform) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: TextField(
                          controller: controllers[platform],
                          decoration: InputDecoration(
                            labelText: platform,
                            hintText: 'Enter your $platform profile URL',
                            prefixIcon: _getSocialIcon(platform),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () {
                  final newLinks = <String, String>{};
                  for (final platform in platforms) {
                    final value = controllers[platform]!.text.trim();
                    if (value.isNotEmpty) {
                      newLinks[platform] = value;
                    }
                  }
                  Navigator.pop(context, newLinks);
                },
                child: const Text('SAVE'),
              ),
            ],
          ),
    );

    // Dispose all controllers
    for (final controller in controllers.values) {
      controller.dispose();
    }

    return result;
  }

  /// Show interests selection dialog
  static Future<List<String>?> showInterestsDialog({
    required BuildContext context,
    required List<String> selected,
    required List<String> available,
  }) async {
    List<String> currentSelection = [...selected];

    return showDialog<List<String>>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Select Interests'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children:
                          available.map((interest) {
                            final isSelected = currentSelection.contains(
                              interest,
                            );
                            return FilterChip(
                              label: Text(interest),
                              selected: isSelected,
                              onSelected: (bool selected) {
                                setState(() {
                                  if (selected) {
                                    currentSelection.add(interest);
                                  } else {
                                    currentSelection.remove(interest);
                                  }
                                });
                              },
                            );
                          }).toList(),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CANCEL'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, currentSelection),
                    child: const Text('SAVE'),
                  ),
                ],
              );
            },
          ),
    );
  }

  // Helper for social icons
  static Widget _getSocialIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return const Icon(Icons.facebook);
      case 'twitter':
        return const Icon(Icons.flutter_dash); // Placeholder for Twitter
      case 'instagram':
        return const Icon(Icons.camera_alt);
      case 'linkedin':
        return const Icon(Icons.work);
      case 'github':
        return const Icon(Icons.code);
      case 'youtube':
        return const Icon(Icons.play_arrow);
      case 'tiktok':
        return const Icon(Icons.music_note);
      case 'medium':
        return const Icon(Icons.article);
      default:
        return const Icon(Icons.link);
    }
  }
}
