import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:white_label_community_app/core/services/stripe_service.dart';
import 'package:white_label_community_app/features/auth/state/user_role_provider.dart';
import 'package:white_label_community_app/features/events/domain/entities/event.dart';
import 'package:white_label_community_app/features/events/state/event_provider.dart';
import 'package:white_label_community_app/features/profile/state/profile_provider.dart';

class EventDetailScreen extends ConsumerWidget {
  final Event event;
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final isHost = user?.uid == event.hostId;
    final userRole = ref.watch(userRoleByUidProvider(user?.uid ?? ''));
    final canEdit = isHost || userRole.value == 'admin';
    final rsvp = ref.watch(rsvpControllerProvider(event.id));
    final rsvpController = ref.read(rsvpControllerProvider(event.id).notifier);
    final hostProfile = ref.watch(userProfileByUidProvider(event.hostId));
    final hostRole = ref.watch(userRoleByUidProvider(event.hostId));
    final isLoadingStripeCheckout = ref.watch(eventPageLoaderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          if (canEdit)
            IconButton(
              onPressed:
                  () => context.push('/edit-event/${event.id}', extra: event),
              icon: const Icon(Icons.edit),
            ),
          if (canEdit)
            IconButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Delete Event'),
                        content: const Text(
                          'Are you sure you want to delete this event?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                );
                if (confirmed == true) {
                  ref
                      .read(eventControllerProvider.notifier)
                      .removeEvent(event.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Event deleted')),
                    );
                    context.pop();
                  }
                }
              },
              icon: const Icon(Icons.delete),
            ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('MMM d, yyyy h:mm a').format(event.dateTime),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  event.location,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                if (event.isPaid)
                  Text(
                    'This event is paid',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                const SizedBox(height: 16),
                Text(
                  event.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ref
                    .watch(rsvpCountsProvider(event.id))
                    .when(
                      data:
                          (counts) => Text(
                            'RSVPs: ✅ ${counts['yes']} • ❓ ${counts['interested']} • ❌ ${counts['no']}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                      loading: () => const CircularProgressIndicator(),
                      error: (e, _) => const Text('Could not load RSVPs'),
                    ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      ['yes', 'interested', 'no'].map((option) {
                        return ChoiceChip(
                          label: Text(option),
                          selected: rsvp?.response == option,
                          onSelected: (selected) async {
                            if (!selected || rsvp?.response == option) {
                              return;
                            }
                            await rsvpController.submitRSVP(option);
                            ref.invalidate(rsvpCountsProvider(event.id));
                            ref.invalidate(rsvpListProvider(event.id));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('RSVP updated to "$option"'),
                                ),
                              );
                            }
                          },
                        );
                      }).toList(),
                ),
                const SizedBox(height: 24),
                hostProfile.when(
                  data: (profile) {
                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage:
                              profile?.profileImageUrl != null
                                  ? NetworkImage(profile!.profileImageUrl!)
                                  : null,
                          child:
                              profile?.profileImageUrl == null
                                  ? const Icon(Icons.person)
                                  : null,
                        ),
                        const SizedBox(width: 8),
                        Text(profile?.name ?? 'Unknown'),
                        const SizedBox(width: 8),
                        Chip(
                          label: const Text('Host'),
                          backgroundColor: Colors.green.shade100,
                        ),
                        if (hostRole.value == 'admin') ...[
                          const SizedBox(width: 4),
                          const Chip(
                            label: Text('Admin'),
                            backgroundColor: Colors.orangeAccent,
                          ),
                        ],
                      ],
                    );
                  },
                  loading: () => const Text('Loading host...'),
                  error: (_, __) => const Text('Host info unavailable'),
                ),
                const SizedBox(height: 24),
                if (event.isPaid && rsvp?.paid != true)
                  ElevatedButton.icon(
                    onPressed: () async {
                      ref.read(eventPageLoaderProvider.notifier).state = true;
                      try {
                        final sessionUrl = await createStripeCheckoutSession(
                          eventId: event.id,
                          title: event.title,
                          amount: event.price ?? 1000,
                        );
                        if (context.mounted) {
                          await launchUrlString(
                            sessionUrl,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      } finally {
                        ref.read(eventPageLoaderProvider.notifier).state =
                            false;
                      }
                    },
                    label: const Text('Pay'),
                    icon: const Icon(Icons.payment),
                  ),
                ref
                    .watch(rsvpListProvider(event.id))
                    .when(
                      data: (rsvps) {
                        return Column(
                          children: [
                            Text('RSVPs'),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: rsvps.length,
                              itemBuilder: (context, index) {
                                final rsvp = rsvps[index];
                                final userProfile =
                                    ref
                                        .watch(
                                          userProfileByUidProvider(rsvp.uid),
                                        )
                                        .value;
                                final profileImageUrl =
                                    userProfile?.profileImageUrl;
                                final role =
                                    ref
                                        .watch(userRoleByUidProvider(rsvp.uid))
                                        .value;

                                return ListTile(
                                  onTap:
                                      () => context.push(
                                        '/profile/${rsvp.uid}',
                                        extra: rsvp.uid,
                                      ),
                                  leading: CircleAvatar(
                                    radius: 24,
                                    backgroundImage:
                                        profileImageUrl != null
                                            ? NetworkImage(profileImageUrl)
                                            : null,
                                    child:
                                        profileImageUrl == null
                                            ? const Icon(Icons.person)
                                            : null,
                                  ),
                                  title: Text(userProfile?.name ?? 'Unknown'),
                                  subtitle: Text(rsvp.response),
                                  trailing:
                                      role == 'admin'
                                          ? const Text('Admin')
                                          : null,
                                );
                              },
                            ),
                          ],
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (e, _) => const Text('Could not load RSVPs'),
                    ),
                // TODO: Add map
                // TODO: Add comments
                // TODO: Add images
                // TODO: Add videos
                // TODO: Add documents
                // TODO: Add links
                // TODO: Add host details
              ],
            ),
          ),
          if (ref.watch(eventPageLoaderProvider))
            Container(
              color: Color(0x33000000),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
