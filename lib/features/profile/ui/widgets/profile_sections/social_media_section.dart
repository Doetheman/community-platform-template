import 'package:flutter/material.dart';

class SocialMediaSection extends StatelessWidget {
  final Map<String, String> socialLinks;
  final Function() onEditPressed;
  final Function(String) onRemoveLink;
  final bool isLoading;

  const SocialMediaSection({
    super.key,
    required this.socialLinks,
    required this.onEditPressed,
    required this.onRemoveLink,
    this.isLoading = false,
  });

  // Helper for social icons
  IconData _getSocialIcon(String platform) {
    final platform0 = platform.toLowerCase();

    if (platform0.contains('twitter') || platform0.contains('x.com')) {
      return Icons.flutter_dash; // Placeholder for Twitter/X
    } else if (platform0.contains('facebook')) {
      return Icons.facebook;
    } else if (platform0.contains('instagram')) {
      return Icons.camera_alt;
    } else if (platform0.contains('linkedin')) {
      return Icons.work;
    } else if (platform0.contains('github')) {
      return Icons.code;
    } else if (platform0.contains('youtube')) {
      return Icons.play_arrow;
    } else if (platform0.contains('medium')) {
      return Icons.article;
    } else if (platform0.contains('tiktok')) {
      return Icons.music_note;
    } else {
      return Icons.public;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.link),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Social Media',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : onEditPressed,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              ],
            ),
            if (socialLinks.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children:
                    socialLinks.entries.map((entry) {
                      return Chip(
                        avatar: Icon(_getSocialIcon(entry.key), size: 18),
                        label: Text(entry.key),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted:
                            isLoading ? null : () => onRemoveLink(entry.key),
                      );
                    }).toList(),
              ),
            ] else ...[
              const SizedBox(height: 16),
              const Text(
                'Add your social media profiles to connect with others',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SocialMediaDialog extends StatefulWidget {
  final Map<String, String> initialLinks;
  final List<String> availablePlatforms;

  const SocialMediaDialog({
    super.key,
    required this.initialLinks,
    required this.availablePlatforms,
  });

  @override
  State<SocialMediaDialog> createState() => _SocialMediaDialogState();
}

class _SocialMediaDialogState extends State<SocialMediaDialog> {
  late final Map<String, TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each platform
    controllers = {};
    for (final platform in widget.availablePlatforms) {
      controllers[platform] = TextEditingController(
        text: widget.initialLinks[platform] ?? '',
      );
    }
  }

  @override
  void dispose() {
    // Important: Dispose controllers when the dialog state is disposed
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Helper for social icons
  IconData _getSocialIcon(String platform) {
    final platform0 = platform.toLowerCase();

    if (platform0.contains('twitter') || platform0.contains('x.com')) {
      return Icons.flutter_dash; // Placeholder for Twitter/X
    } else if (platform0.contains('facebook')) {
      return Icons.facebook;
    } else if (platform0.contains('instagram')) {
      return Icons.camera_alt;
    } else if (platform0.contains('linkedin')) {
      return Icons.work;
    } else if (platform0.contains('github')) {
      return Icons.code;
    } else if (platform0.contains('youtube')) {
      return Icons.play_arrow;
    } else if (platform0.contains('medium')) {
      return Icons.article;
    } else if (platform0.contains('tiktok')) {
      return Icons.music_note;
    } else {
      return Icons.public;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Social Media Links'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              widget.availablePlatforms.map((platform) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextField(
                    controller: controllers[platform],
                    decoration: InputDecoration(
                      labelText: platform,
                      hintText: 'Enter your $platform profile URL',
                      prefixIcon: Icon(_getSocialIcon(platform)),
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
            for (final platform in widget.availablePlatforms) {
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
    );
  }
}
