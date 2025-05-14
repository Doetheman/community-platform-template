import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_label_community_app/features/auth/state/auth_provider.dart'
    as auth;
import 'package:white_label_community_app/features/auth/state/user_role_provider.dart';
import 'package:white_label_community_app/features/events/domain/entities/event.dart';
import '../state/event_provider.dart';
import 'widgets/event_card.dart';
import 'package:go_router/go_router.dart';

// TODO: Filter/search bar
// TODO: Toggle between grid and list layout
// TODO: Featured banners or categories
// TODO: Pagination or infinite scroll
class EventListScreen extends ConsumerWidget {
  const EventListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventState = ref.watch(eventControllerProvider);
    final currentUser = ref.watch(auth.firebaseAuthProvider).currentUser;
    final eventController = ref.read(eventControllerProvider.notifier);
    final userRole = ref.watch(userRoleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/create-event'),
          ),
        ],
      ),
      body: eventState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (List<Event> events) {
          if (events.isEmpty) {
            return const Center(child: Text('No events yet.'));
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Upcoming Events",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      final isHost = currentUser?.uid == event.hostId;
                      final canEdit = isHost || userRole.value == 'admin';

                      return EventCard(
                        event: event,
                        onTap:
                            () => context.push(
                              '/event/${event.id}',
                              extra: event,
                            ),
                        onEdit:
                            canEdit
                                ? () => context.push(
                                  '/edit-event/${event.id}',
                                  extra: event,
                                )
                                : null,
                        onDelete:
                            canEdit
                                ? () => eventController.removeEvent(event.id)
                                : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
