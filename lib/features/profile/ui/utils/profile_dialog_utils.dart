import 'package:flutter/material.dart';
import '../widgets/profile_sections/dynamic_fields_section.dart';

class ProfileDialogUtils {
  /// Shows a dialog to add/edit/remove interests
  static Future<List<String>?> showInterestsDialog({
    required BuildContext context,
    required List<String> selectedInterests,
    required List<String> availableInterests,
  }) async {
    return showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Your Interests',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          availableInterests.map((interest) {
                            final isSelected = selectedInterests.contains(
                              interest,
                            );
                            return FilterChip(
                              label: Text(interest),
                              selected: isSelected,
                              onSelected: (bool selected) {
                                selectedInterests = List.from(
                                  selectedInterests,
                                );
                                if (selected) {
                                  selectedInterests.add(interest);
                                } else {
                                  selectedInterests.remove(interest);
                                }
                              },
                            );
                          }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('CANCEL'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, selectedInterests);
                      },
                      child: const Text('SAVE'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Shows a dialog to edit social media links
  static Future<Map<String, String>?> showSocialMediaDialog({
    required BuildContext context,
    required Map<String, String> initialLinks,
    required List<String> availablePlatforms,
  }) async {
    return showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        final controllers = <String, TextEditingController>{};

        // Initialize controllers for each platform
        for (final platform in availablePlatforms) {
          controllers[platform] = TextEditingController(
            text: initialLinks[platform] ?? '',
          );
        }

        return AlertDialog(
          title: const Text('Social Media Links'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  availablePlatforms.map((platform) {
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
                // Update links with non-empty values
                final newLinks = <String, String>{};
                for (final platform in availablePlatforms) {
                  final value = controllers[platform]!.text.trim();
                  if (value.isNotEmpty) {
                    newLinks[platform] = value;
                  }
                }

                // Dispose controllers before closing dialog
                for (final controller in controllers.values) {
                  controller.dispose();
                }

                Navigator.pop(context, newLinks);
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );
  }

  /// Shows a dialog to edit dynamic fields
  static Future<List<ProfileDynamicField>?> showDynamicFieldsDialog({
    required BuildContext context,
    required List<ProfileDynamicField> initialFields,
  }) async {
    return showDialog<List<ProfileDynamicField>>(
      context: context,
      builder: (BuildContext context) {
        return DynamicFieldsDialog(initialFields: initialFields);
      },
    );
  }

  /// Shows a confirmation dialog for unsaved changes
  static Future<bool> showUnsavedChangesDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Unsaved Changes'),
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
            );
          },
        ) ??
        false;
  }

  /// Shows error dialog when profile update fails
  static Future<void> showProfileErrorDialog(
    BuildContext context,
    String message,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Helper for social icons
  static Widget _getSocialIcon(String platform) {
    final platform0 = platform.toLowerCase();

    if (platform0.contains('twitter') || platform0.contains('x.com')) {
      return const Icon(Icons.flutter_dash); // Placeholder for Twitter/X
    } else if (platform0.contains('facebook')) {
      return const Icon(Icons.facebook);
    } else if (platform0.contains('instagram')) {
      return const Icon(Icons.camera_alt);
    } else if (platform0.contains('linkedin')) {
      return const Icon(Icons.work);
    } else if (platform0.contains('github')) {
      return const Icon(Icons.code);
    } else if (platform0.contains('youtube')) {
      return const Icon(Icons.play_arrow);
    } else if (platform0.contains('medium')) {
      return const Icon(Icons.article);
    } else if (platform0.contains('tiktok')) {
      return const Icon(Icons.music_note);
    } else {
      return const Icon(Icons.public);
    }
  }
}
