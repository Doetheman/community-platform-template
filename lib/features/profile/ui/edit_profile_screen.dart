import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_label_community_app/features/profile/domain/entities/user_profile.dart';
import 'package:white_label_community_app/features/profile/services/profile_config_service.dart';
import 'package:white_label_community_app/features/profile/state/profile_provider.dart';
import 'package:white_label_community_app/features/auth/state/auth_provider.dart'
    as auth;
import 'widgets/enhanced_profile_form.dart';

class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileControllerProvider);
    final controller = ref.read(profileControllerProvider.notifier);
    final currentUser = ref.watch(auth.firebaseAuthProvider).currentUser;
    final configService = ref.watch(profileConfigServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Profile Information'),
                      content: const Text(
                        'Your profile information helps others in the community get to know you '
                        'better. You can control which information is visible to others.\n\n'
                        'The more complete your profile, the better your experience will be!',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('GOT IT'),
                        ),
                      ],
                    ),
              );
            },
            tooltip: 'Profile information',
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading profile: $e')),
        data: (profile) {
          if (currentUser == null) {
            return const Center(child: Text('No user logged in'));
          }

          // If no profile exists, create one with the current user's UID
          final initialProfile =
              profile ??
              UserProfile(
                uid: currentUser.uid,
                name: currentUser.email?.split('@')[0] ?? 'User',
              );

          return Padding(
            padding: const EdgeInsets.all(16),
            child: EnhancedProfileForm(
              initial: initialProfile,
              configService: configService,
              onSubmit: (updated) async {
                await controller.updateProfile(updated);
                if (context.mounted) Navigator.pop(context);
              },
            ),
          );
        },
      ),
    );
  }
}
