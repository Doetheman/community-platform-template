import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:white_label_community_app/features/auth/state/user_role_provider.dart';
import 'package:white_label_community_app/features/profile/config/profile_config.dart';
import 'package:white_label_community_app/features/profile/domain/entities/user_profile.dart';
import 'package:white_label_community_app/features/profile/services/profile_config_service.dart';
import 'package:white_label_community_app/features/profile/state/profile_provider.dart';
import 'package:white_label_community_app/features/profile/ui/widgets/profile_header.dart';
import 'package:white_label_community_app/features/profile/ui/widgets/profile_section.dart';
import 'package:white_label_community_app/features/profile/ui/widgets/interests_section.dart';
import 'package:white_label_community_app/features/profile/ui/widgets/social_links_section.dart';

class ViewProfileScreen extends ConsumerWidget {
  final String uid;

  const ViewProfileScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileByUidProvider(uid));
    final role = ref.watch(userRoleByUidProvider(uid));
    final configService = ref.watch(profileConfigServiceProvider);

    return Scaffold(
      body: profile.when(
        data: (p) {
          if (p == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Profile not found'),
                ],
              ),
            );
          }

          final visibleCategories =
              configService.getVisibleCategoriesForOtherProfile();

          return CustomScrollView(
            slivers: [
              // App bar with profile header
              SliverAppBar(
                expandedHeight:
                    240, // Accommodate header with profile image overlap
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: ProfileHeader(profile: p, isOwnProfile: false),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder:
                            (context) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.share),
                                  title: const Text('Share Profile'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Share feature coming soon',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.flag),
                                  title: const Text('Report User'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Report feature coming soon',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.block),
                                  title: const Text('Block User'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Block feature coming soon',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                      );
                    },
                    tooltip: 'More options',
                  ),
                ],
              ),

              // Add extra space to account for the profile picture overlap
              const SliverToBoxAdapter(child: SizedBox(height: 60)),

              // User name, role and basic info section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        p.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      if (role.value != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getRoleColor(role.value!),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _formatRoleName(role.value!),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      // Prominent Message Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => context.go('/messages'),
                          icon: const Icon(Icons.message),
                          label: const Text('Message'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (p.bio != null && p.bio!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          p.bio!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                      if (p.location != null && p.location!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on, size: 16),
                            const SizedBox(width: 4),
                            Text(p.location!),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Action buttons (connect, message, etc.)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Connect feature coming soon'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('Connect'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Message feature coming soon'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.message),
                        label: const Text('Message'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Interests section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: InterestsSection(
                    profile: p,
                    label: configService.interestsLabel,
                    isOwnProfile: false,
                  ),
                ),
              ),

              // Social links section (if not empty and enabled in config)
              if (configService.config.showSocialLinks &&
                  p.socialLinks.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SocialLinksSection(profile: p, isOwnProfile: false),
                  ),
                ),

              // Dynamic profile sections based on configuration
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final category = visibleCategories[index];
                  final fields =
                      configService
                          .getFieldsForCategory(category.id)
                          .where((field) => field.visibleOnOtherProfiles)
                          .toList();

                  if (fields.isEmpty) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ProfileSection(
                      category: category,
                      fields: fields,
                      profile: p,
                      initiallyExpanded: category.expandedByDefault,
                      isOwnProfile: false,
                    ),
                  );
                }, childCount: visibleCategories.length),
              ),

              // Add some bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Could not load profile')),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.redAccent;
      case 'moderator':
        return Colors.orangeAccent;
      case 'premium':
        return Colors.purpleAccent;
      case 'verified':
        return Colors.blueAccent;
      default:
        return Colors.grey;
    }
  }

  String _formatRoleName(String role) {
    return role.substring(0, 1).toUpperCase() + role.substring(1);
  }
}
