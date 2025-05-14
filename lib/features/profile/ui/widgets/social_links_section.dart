import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:white_label_community_app/features/profile/domain/entities/user_profile.dart';

class SocialLinksSection extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback? onEditPressed;
  final bool isOwnProfile;

  const SocialLinksSection({
    super.key,
    required this.profile,
    this.onEditPressed,
    this.isOwnProfile = false,
  });

  @override
  Widget build(BuildContext context) {
    // Safely handle socialLinks which might be null in some cases - provide an empty map fallback
    final Map<String, String> socialLinks = profile.socialLinks;
    final hasSocialLinks = socialLinks.isNotEmpty;
    final theme = Theme.of(context);

    // Exit early if no social links and not own profile
    if (!hasSocialLinks && !isOwnProfile) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.link),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Social Media',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isOwnProfile && onEditPressed != null)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onEditPressed,
                    tooltip: 'Edit social links',
                  ),
              ],
            ),
            if (hasSocialLinks) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                children:
                    socialLinks.entries.map((entry) {
                      return IconButton(
                        icon: _getSocialIcon(entry.key),
                        onPressed: () => _launchUrl(entry.value),
                        tooltip: _capitalizeFirstLetter(entry.key),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary
                              .withOpacity(0.1),
                        ),
                      );
                    }).toList(),
              ),
            ] else if (isOwnProfile) ...[
              const SizedBox(height: 8),
              Text(
                'Add your social media links',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              if (onEditPressed != null) ...[
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: onEditPressed,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Social Links'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      String processedUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        processedUrl = 'https://$url';
      }

      await launchUrlString(processedUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  Icon _getSocialIcon(String platform) {
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

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
