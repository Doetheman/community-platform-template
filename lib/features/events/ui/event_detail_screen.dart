import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
    final dateFormatter = DateFormat('EEEE, MMMM d, y');
    final timeFormatter = DateFormat('h:mm a');
    final theme = Theme.of(context);

    // Generate a placeholder image URL if none is provided
    final headerImageUrl =
        event.imageUrl ??
        'https://images.unsplash.com/photo-1523580494863-6f3031224c94?q=80&w=1000';

    // Default image URLs for gallery if none provided
    final galleryImages =
        event.galleryImageUrls?.isNotEmpty == true
            ? event.galleryImageUrls!
            : [
              'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?q=80&w=1000',
              'https://images.unsplash.com/photo-1505373877841-8d25f7d46678?q=80&w=1000',
            ];

    return Scaffold(
      body: Stack(
        children: [
          // Main content with CustomScrollView for flexible header
          CustomScrollView(
            slivers: [
              // App bar with event image
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Hero image
                      Image.network(headerImageUrl, fit: BoxFit.cover),
                      // Gradient overlay for better text visibility
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                            stops: const [0.6, 1.0],
                          ),
                        ),
                      ),
                      // Event title and date info at the bottom of the image
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Event category chip
                            if (event.category != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  event.category!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            // Event title
                            Text(
                              event.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                shadows: [
                                  Shadow(color: Colors.black54, blurRadius: 2),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  // Share button
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Share feature coming soon'),
                        ),
                      );
                    },
                  ),
                  if (canEdit)
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed:
                          () => context.push(
                            '/edit-event/${event.id}',
                            extra: event,
                          ),
                    ),
                  if (canEdit)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed:
                          () => _showDeleteConfirmation(context, ref, event.id),
                    ),
                ],
              ),

              // Main content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date and time section
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.calendar_today),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dateFormatter.format(event.dateTime),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  timeFormatter.format(event.dateTime),
                                  style: TextStyle(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 32),

                      // Location section
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.location_on),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Location',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  event.location,
                                  style: TextStyle(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.map, size: 16),
                                  label: const Text('View on Map'),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Map feature coming soon',
                                        ),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 32),

                      // Price information
                      if (event.isPaid) ...[
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.attach_money,
                                color: Colors.amber.shade800,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Paid Event',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${event.price?.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.amber.shade800,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                      ],

                      // Host information
                      hostProfile.when(
                        data: (profile) {
                          return Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.person),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Host',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundImage:
                                              profile?.profileImageUrl != null
                                                  ? NetworkImage(
                                                    profile!.profileImageUrl!,
                                                  )
                                                  : null,
                                          child:
                                              profile?.profileImageUrl == null
                                                  ? const Icon(
                                                    Icons.person,
                                                    size: 16,
                                                  )
                                                  : null,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          profile?.name ?? 'Unknown',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (hostRole.value == 'admin') ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orangeAccent,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'Admin',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => context.push(
                                            '/profile/${event.hostId}',
                                            extra: event.hostId,
                                          ),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        alignment: Alignment.centerLeft,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text('View Profile'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                        loading:
                            () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        error: (_, __) => const Text('Host info unavailable'),
                      ),

                      const Divider(height: 32),

                      // About section
                      const Text(
                        'About this event',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.description,
                        style: const TextStyle(height: 1.5),
                      ),

                      const SizedBox(height: 24),

                      // Photo gallery
                      if (galleryImages.isNotEmpty) ...[
                        const Text(
                          'Photos',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: galleryImages.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    galleryImages[index],
                                    width: 200,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Additional information
                      if (event.additionalInfo != null &&
                          event.additionalInfo!.isNotEmpty) ...[
                        const Text(
                          'Additional Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...event.additionalInfo!.entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_capitalizeFirst(entry.key)}: ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    entry.value.toString(),
                                    style: const TextStyle(height: 1.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // RSVPs section
                      const Text(
                        'RSVPs',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ref
                          .watch(rsvpCountsProvider(event.id))
                          .when(
                            data: (counts) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildRsvpStat(
                                    'Going',
                                    counts['yes'] ?? 0,
                                    Colors.green,
                                  ),
                                  _buildRsvpStat(
                                    'Interested',
                                    counts['interested'] ?? 0,
                                    Colors.orange,
                                  ),
                                  _buildRsvpStat(
                                    'Not Going',
                                    counts['no'] ?? 0,
                                    Colors.red,
                                  ),
                                ],
                              );
                            },
                            loading:
                                () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                            error: (e, _) => const Text('Could not load RSVPs'),
                          ),

                      const SizedBox(height: 24),

                      // RSVP buttons
                      const Text(
                        'Your RSVP',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildRsvpButton(
                            context,
                            'Going',
                            'yes',
                            Icons.check,
                            Colors.green,
                            rsvp?.response == 'yes',
                            () => _updateRsvp(
                              context,
                              rsvpController,
                              ref,
                              event.id,
                              'yes',
                            ),
                          ),
                          _buildRsvpButton(
                            context,
                            'Interested',
                            'interested',
                            Icons.star_outline,
                            Colors.orange,
                            rsvp?.response == 'interested',
                            () => _updateRsvp(
                              context,
                              rsvpController,
                              ref,
                              event.id,
                              'interested',
                            ),
                          ),
                          _buildRsvpButton(
                            context,
                            'Not Going',
                            'no',
                            Icons.close,
                            Colors.red,
                            rsvp?.response == 'no',
                            () => _updateRsvp(
                              context,
                              rsvpController,
                              ref,
                              event.id,
                              'no',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Payment button for paid events
                      if (event.isPaid &&
                          rsvp?.paid != true &&
                          rsvp?.response == 'yes')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed:
                                () => _handlePayment(context, ref, event),
                            icon: const Icon(Icons.payment),
                            label: const Text('Pay Now'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Attendees list
                      const Text(
                        'People Attending',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ref
                          .watch(rsvpListProvider(event.id))
                          .when(
                            data: (rsvps) {
                              if (rsvps.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: Text(
                                      'No one has RSVP\'d yet. Be the first!',
                                    ),
                                  ),
                                );
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
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
                                          .watch(
                                            userRoleByUidProvider(rsvp.uid),
                                          )
                                          .value;

                                  return ListTile(
                                    onTap:
                                        () => context.push(
                                          '/profile/${rsvp.uid}',
                                          extra: rsvp.uid,
                                        ),
                                    leading: CircleAvatar(
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
                                    trailing:
                                        role == 'admin'
                                            ? Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.orangeAccent,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'Admin',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            )
                                            : null,
                                  );
                                },
                              );
                            },
                            loading:
                                () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                            error:
                                (e, _) =>
                                    const Text('Could not load attendees'),
                          ),

                      const SizedBox(height: 60), // Extra space for FAB
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Loading overlay
          if (isLoadingStripeCheckout)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      // Share floating action button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invite feature coming soon')),
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Invite'),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildRsvpStat(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w500, color: color),
        ),
      ],
    );
  }

  Widget _buildRsvpButton(
    BuildContext context,
    String label,
    String response,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: isSelected ? Colors.white : color),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : color.withOpacity(0.1),
        foregroundColor: isSelected ? Colors.white : color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Future<void> _updateRsvp(
    BuildContext context,
    dynamic rsvpController,
    WidgetRef ref,
    String eventId,
    String response,
  ) async {
    await rsvpController.submitRSVP(response);
    ref.invalidate(rsvpCountsProvider(eventId));
    ref.invalidate(rsvpListProvider(eventId));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your RSVP is updated to "$response"')),
      );
    }
  }

  Future<void> _handlePayment(
    BuildContext context,
    WidgetRef ref,
    Event event,
  ) async {
    ref.read(eventPageLoaderProvider.notifier).state = true;
    try {
      final sessionUrl = await StripeService.createStripeCheckoutSession(
        eventId: event.id,
        title: event.title,
        amount: event.price ?? 0,
        context: context,
      );
      if (context.mounted) {
        await launchUrlString(sessionUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      ref.read(eventPageLoaderProvider.notifier).state = false;
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    String eventId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Event'),
            content: const Text('Are you sure you want to delete this event?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      ref.read(eventControllerProvider.notifier).removeEvent(eventId);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Event deleted')));
        context.pop();
      }
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
