import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/event.dart';
import 'event_card.dart';

class EventsList extends StatefulWidget {
  final List<Event> events;
  final Function(Event) onEventSelected;
  final Function(Event)? onEditEvent;
  final Function(String)? onDeleteEvent;

  const EventsList({
    super.key,
    required this.events,
    required this.onEventSelected,
    this.onEditEvent,
    this.onDeleteEvent,
  });

  @override
  State<EventsList> createState() => _EventsListState();
}

class _EventsListState extends State<EventsList> {
  String _filterOption = 'All';
  List<Event> _filteredEvents = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredEvents = widget.events;
    _searchController.addListener(_handleSearch);
  }

  @override
  void didUpdateWidget(EventsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.events != oldWidget.events) {
      _applyFilters();
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearch);
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch() {
    _applyFilters();
  }

  void _applyFilters() {
    final searchQuery = _searchController.text.toLowerCase();

    setState(() {
      _filteredEvents =
          widget.events.where((event) {
            // Apply category filter if not 'All'
            if (_filterOption != 'All') {
              bool matchesFilter = false;

              switch (_filterOption) {
                case 'Free':
                  matchesFilter = !event.isPaid;
                  break;
                case 'Paid':
                  matchesFilter = event.isPaid;
                  break;
                case 'Today':
                  final today = DateTime.now();
                  final eventDate = event.dateTime;
                  matchesFilter =
                      eventDate.year == today.year &&
                      eventDate.month == today.month &&
                      eventDate.day == today.day;
                  break;
                case 'This Week':
                  final today = DateTime.now();
                  final weekEnd = today.add(const Duration(days: 7));
                  matchesFilter =
                      event.dateTime.isAfter(today) &&
                      event.dateTime.isBefore(weekEnd);
                  break;
              }

              if (!matchesFilter) return false;
            }

            // Apply search filter if query exists
            if (searchQuery.isNotEmpty) {
              return event.title.toLowerCase().contains(searchQuery) ||
                  event.location.toLowerCase().contains(searchQuery) ||
                  event.description.toLowerCase().contains(searchQuery);
            }

            return true;
          }).toList();

      // Sort by date (soonest first)
      _filteredEvents.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterBar(),

        const SizedBox(height: 16),

        Expanded(
          child:
              _filteredEvents.isEmpty ? _buildEmptyState() : _buildEventsList(),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search events',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),

        const SizedBox(height: 12),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildFilterChip('All'),
              _buildFilterChip('Today'),
              _buildFilterChip('This Week'),
              _buildFilterChip('Free'),
              _buildFilterChip('Paid'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filterOption == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _filterOption = selected ? label : 'All';
            _applyFilters();
          });
        },
        backgroundColor: Colors.grey.shade200,
        selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        checkmarkColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No events found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Try a different search term'
                : _filterOption != 'All'
                ? 'Try a different filter'
                : 'Check back later for new events',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    final formatter = DateFormat('EEEE, MMM d');
    final todayString = formatter.format(DateTime.now());

    // Group events by date
    final groupedEvents = <String, List<Event>>{};

    for (final event in _filteredEvents) {
      final date = formatter.format(event.dateTime);
      if (groupedEvents[date] == null) {
        groupedEvents[date] = [];
      }
      groupedEvents[date]!.add(event);
    }

    // Create sections
    final sections =
        groupedEvents.entries.toList()..sort((a, b) {
          final dateA = DateFormat('EEEE, MMM d').parse(a.key);
          final dateB = DateFormat('EEEE, MMM d').parse(b.key);
          return dateA.compareTo(dateB);
        });

    return ListView.builder(
      itemCount: sections.length,
      padding: const EdgeInsets.only(bottom: 16),
      itemBuilder: (context, index) {
        final section = sections[index];
        final isToday = section.key == todayString;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    isToday ? 'Today' : section.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Today',
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(
              height:
                  MediaQuery.of(context).size.height *
                  0.28, // Dynamic height based on screen size
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: section.value.length,
                itemBuilder: (context, eventIndex) {
                  final event = section.value[eventIndex];
                  final canEdit = widget.onEditEvent != null;
                  final canDelete = widget.onDeleteEvent != null;

                  return EventCard(
                    event: event,
                    onTap: () => widget.onEventSelected(event),
                    onEdit: canEdit ? () => widget.onEditEvent!(event) : null,
                    onDelete:
                        canDelete
                            ? () => widget.onDeleteEvent!(event.id)
                            : null,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
