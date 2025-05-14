import 'package:flutter/material.dart';
import 'package:white_label_community_app/features/profile/domain/entities/user_profile.dart';

class InterestsSection extends StatelessWidget {
  final UserProfile profile;
  final String label;
  final VoidCallback? onEditPressed;
  final bool isOwnProfile;

  const InterestsSection({
    super.key,
    required this.profile,
    this.label = 'Interests',
    this.onEditPressed,
    this.isOwnProfile = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasInterests = profile.interests.isNotEmpty;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(hasInterests ? Icons.favorite : Icons.favorite_border),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isOwnProfile && onEditPressed != null)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onEditPressed,
                    tooltip: 'Edit $label',
                  ),
              ],
            ),
            if (hasInterests) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    profile.interests.map((interest) {
                      return Chip(
                        label: Text(interest),
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.1,
                        ),
                        side: BorderSide(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                        ),
                      );
                    }).toList(),
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                isOwnProfile
                    ? 'Add your $label to help connect with others'
                    : 'No $label added yet',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              if (isOwnProfile && onEditPressed != null) ...[
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: onEditPressed,
                  icon: const Icon(Icons.add),
                  label: Text('Add $label'),
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
}
