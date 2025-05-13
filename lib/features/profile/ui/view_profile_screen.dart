import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_label_community_app/features/auth/state/user_role_provider.dart';
import 'package:white_label_community_app/features/profile/state/profile_provider.dart';

class ViewProfileScreen extends ConsumerWidget {
  final String uid;

  const ViewProfileScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileByUidProvider(uid));
    final role = ref.watch(userRoleByUidProvider(uid));

    return Scaffold(
      appBar: AppBar(title: const Text("User Profile")),
      body: profile.when(
        data:
            (p) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundImage:
                        p?.profileImageUrl != null
                            ? NetworkImage(p!.profileImageUrl!)
                            : null,
                    child:
                        p?.profileImageUrl == null
                            ? const Icon(Icons.person, size: 40)
                            : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    p?.name ?? "Unknown",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  if (role.value != null)
                    Chip(
                      label: Text(role.value!),
                      backgroundColor: Colors.grey.shade300,
                    ),
                  const SizedBox(height: 16),
                  Text(p?.bio ?? "No bio available"),
                  const SizedBox(height: 16),
                  if (p != null && p.interests.isNotEmpty) ...[
                    const Text("Interests"),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children:
                          p.interests.map((i) => Chip(label: Text(i))).toList(),
                    ),
                  ],
                ],
              ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Could not load profile')),
      ),
    );
  }
}
