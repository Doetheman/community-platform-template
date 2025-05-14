import 'package:flutter/material.dart';
import 'package:white_label_community_app/features/profile/domain/entities/user_profile.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final bool isOwnProfile;
  final VoidCallback? onEditPressed;
  final VoidCallback? onCoverPhotoPressed;
  final VoidCallback? onProfilePhotoPressed;

  const ProfileHeader({
    super.key,
    required this.profile,
    this.isOwnProfile = false,
    this.onEditPressed,
    this.onCoverPhotoPressed,
    this.onProfilePhotoPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultCoverImage =
        'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?q=80&w=1000&fit=crop';

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Cover image
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
          child:
              profile.coverImageUrl != null || isOwnProfile
                  ? Stack(
                    fit: StackFit.expand,
                    children: [
                      // Cover photo
                      if (profile.coverImageUrl != null)
                        Image.network(profile.coverImageUrl!, fit: BoxFit.cover)
                      else
                        Image.network(defaultCoverImage, fit: BoxFit.cover),

                      // Edit cover photo button (only for own profile)
                      if (isOwnProfile && onCoverPhotoPressed != null)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: IconButton(
                            onPressed: onCoverPhotoPressed,
                            icon: const Icon(Icons.camera_alt),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black.withOpacity(0.5),
                              foregroundColor: Colors.white,
                            ),
                            tooltip: 'Change cover photo',
                          ),
                        ),
                    ],
                  )
                  : null,
        ),

        // Profile image
        Positioned(
          bottom: -50,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 4,
                  ),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      profile.profileImageUrl != null
                          ? NetworkImage(profile.profileImageUrl!)
                          : null,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child:
                      profile.profileImageUrl == null
                          ? Icon(
                            Icons.person,
                            size: 50,
                            color: theme.colorScheme.primary,
                          )
                          : null,
                ),
              ),

              // Edit profile photo button (only for own profile)
              if (isOwnProfile && onProfilePhotoPressed != null)
                Positioned(
                  right: -8,
                  bottom: 0,
                  child: IconButton(
                    onPressed: onProfilePhotoPressed,
                    icon: const Icon(Icons.camera_alt),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    tooltip: 'Change profile photo',
                  ),
                ),
            ],
          ),
        ),

        // Edit profile button (only for own profile)
        if (isOwnProfile && onEditPressed != null)
          Positioned(
            right: 8,
            bottom: 8,
            child: ElevatedButton.icon(
              onPressed: onEditPressed,
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}
