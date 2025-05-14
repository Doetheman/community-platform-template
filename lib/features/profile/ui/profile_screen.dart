import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:white_label_community_app/features/profile/services/profile_config_service.dart';
import 'package:white_label_community_app/features/profile/state/profile_provider.dart';
import 'package:white_label_community_app/features/profile/ui/widgets/profile_header.dart';
import 'package:white_label_community_app/features/profile/ui/widgets/profile_section.dart';
import 'package:white_label_community_app/features/profile/ui/widgets/interests_section.dart';
import 'package:white_label_community_app/features/profile/ui/widgets/social_links_section.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final controller = ref.read(profileControllerProvider.notifier);
    final configService = ref.watch(profileConfigServiceProvider);

    return Scaffold(
      body: profileState.when(
        loading:
            () => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading profile...'),
                ],
              ),
            ),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => controller.refreshProfile(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            ),
        data: (profile) {
          if (profile == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No profile found'),
                ],
              ),
            );
          }

          final visibleCategories =
              configService.getVisibleCategoriesForOwnProfile();

          return CustomScrollView(
            slivers: [
              // App bar with profile header
              SliverAppBar(
                expandedHeight:
                    240, // Accommodate header with profile image overlap
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: ProfileHeader(
                    profile: profile,
                    isOwnProfile: true,
                    onEditPressed: () => context.push('/edit-profile'),
                    onCoverPhotoPressed: () {
                      // TODO: Implement cover photo changing
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Change cover photo feature coming soon',
                          ),
                        ),
                      );
                    },
                    onProfilePhotoPressed: () {
                      // TODO: Implement profile photo changing
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Change profile photo feature coming soon',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => controller.refreshProfile(),
                    tooltip: 'Refresh profile',
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => context.push('/settings'),
                    tooltip: 'Settings',
                  ),
                ],
              ),

              // Add extra space to account for the profile picture overlap
              const SliverToBoxAdapter(child: SizedBox(height: 60)),

              // User name and basic info section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        profile.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          profile.bio!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                      if (profile.location != null &&
                          profile.location!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on, size: 16),
                            const SizedBox(width: 4),
                            Text(profile.location!),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Interests section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: InterestsSection(
                    profile: profile,
                    label: configService.interestsLabel,
                    isOwnProfile: true,
                    onEditPressed: () => context.push('/edit-profile'),
                  ),
                ),
              ),

              // Add the Media Gallery and Albums buttons
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Media & Albums',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                final currentUser =
                                    ref.read(firebaseAuthProvider).currentUser;
                                if (currentUser != null) {
                                  context.push(
                                    '/media-gallery/${currentUser.uid}?isCurrentUser=true',
                                  );
                                }
                              },
                              icon: const Icon(Icons.photo_library),
                              label: const Text('My Gallery'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                final currentUser =
                                    ref.read(firebaseAuthProvider).currentUser;
                                if (currentUser != null) {
                                  context.push(
                                    '/albums/${currentUser.uid}?isCurrentUser=true',
                                  );
                                }
                              },
                              icon: const Icon(Icons.photo_album),
                              label: const Text('My Albums'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Social links section (if enabled in config)
              if (configService.config.showSocialLinks)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SocialLinksSection(
                      profile: profile,
                      isOwnProfile: true,
                      onEditPressed: () => context.push('/edit-profile'),
                    ),
                  ),
                ),

              // Dynamic profile sections based on configuration
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final category = visibleCategories[index];
                  final fields = configService.getFieldsForCategory(
                    category.id,
                  );

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ProfileSection(
                      category: category,
                      fields: fields,
                      profile: profile,
                      initiallyExpanded: category.expandedByDefault,
                      isOwnProfile: true,
                      onFieldTap: (_) => context.push('/edit-profile'),
                    ),
                  );
                }, childCount: visibleCategories.length),
              ),

              // Account settings section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const Icon(Icons.settings),
                              const SizedBox(width: 16),
                              Text(
                                'Account Settings',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.notifications),
                          title: const Text('Notifications'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/settings/notifications'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.security),
                          title: const Text('Privacy'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/settings/privacy'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.help),
                          title: const Text('Help & Support'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/settings/help'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Add some bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }
}
