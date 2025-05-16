import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/event_provider.dart';
import '../domain/entities/event.dart';
import 'widgets/events_list.dart';
import 'widgets/events_calendar.dart';
import 'package:white_label_community_app/features/auth/state/user_role_provider.dart';
import '../state/event_controller.dart';
import 'widgets/event_category_filter.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  bool _isCalendarView = false;
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final eventState = ref.watch(eventControllerProvider);
    final eventController = ref.read(eventControllerProvider.notifier);
    final userRole = ref.watch(userRoleProvider);
    final isAdmin = userRole.value == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          // Toggle between list and calendar views
          IconButton(
            icon: Icon(
              _isCalendarView ? Icons.view_list : Icons.calendar_month,
            ),
            tooltip: _isCalendarView ? 'List View' : 'Calendar View',
            onPressed: () {
              setState(() {
                _isCalendarView = !_isCalendarView;
              });
            },
          ),

          // Add event button (visible to admin and event hosts)
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Create Event',
              onPressed: () => context.push('/create-event'),
            ),
        ],
      ),
      body: eventState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (List<Event> events) {
          if (events.isEmpty) {
            return _buildEmptyState(isAdmin);
          }

          return Column(
            children: [
              // Category Filter at the top
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: EventCategoryFilter(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                ),
              ),

              // Main content area
              Expanded(
                child:
                    _isCalendarView
                        ? EventsCalendar(
                          events: _filterEvents(events),
                          onDaySelected: (selectedDay) {
                            // Handle day selection if needed
                          },
                          onEventSelected:
                              (event) => context.push(
                                '/event/${event.id}',
                                extra: event,
                              ),
                        )
                        : EventsList(
                          events: _filterEvents(events),
                          onEventSelected:
                              (event) => context.push(
                                '/event/${event.id}',
                                extra: event,
                              ),
                          onEditEvent:
                              isAdmin
                                  ? (event) => context.push(
                                    '/edit-event/${event.id}',
                                    extra: event,
                                  )
                                  : null,
                          onDeleteEvent:
                              isAdmin
                                  ? (eventId) => _showDeleteConfirmation(
                                    eventId,
                                    eventController,
                                  )
                                  : null,
                        ),
              ),
            ],
          );
        },
      ),
      floatingActionButton:
          isAdmin
              ? FloatingActionButton(
                onPressed: () => context.push('/create-event'),
                tooltip: 'Create Event',
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  List<Event> _filterEvents(List<Event> allEvents) {
    if (_selectedCategory == 'All') {
      return allEvents;
    }

    return allEvents.where((event) {
      final title = event.title.toLowerCase();
      final description = event.description.toLowerCase();

      switch (_selectedCategory) {
        case 'Workshops':
          return title.contains('workshop') ||
              title.contains('class') ||
              description.contains('workshop') ||
              description.contains('learn');
        case 'Social':
          return title.contains('social') ||
              title.contains('meetup') ||
              title.contains('party') ||
              description.contains('social');
        case 'Music':
          return title.contains('music') ||
              title.contains('concert') ||
              title.contains('band') ||
              description.contains('music');
        case 'Food':
          return title.contains('food') ||
              title.contains('dinner') ||
              title.contains('lunch') ||
              description.contains('food');
        case 'Fitness':
          return title.contains('fitness') ||
              title.contains('workout') ||
              title.contains('exercise') ||
              description.contains('fitness');
        case 'Business':
          return title.contains('business') ||
              title.contains('networking') ||
              title.contains('career') ||
              description.contains('business');
        default:
          return true;
      }
    }).toList();
  }

  Widget _buildEmptyState(bool isAdmin) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No events scheduled',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for upcoming events',
            style: TextStyle(color: Colors.grey[600]),
          ),
          if (isAdmin) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/create-event'),
              icon: const Icon(Icons.add),
              label: const Text('Create an Event'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    String eventId,
    EventController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Event'),
            content: const Text(
              'Are you sure you want to delete this event? This action cannot be undone.',
            ),
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
      controller.removeEvent(eventId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
