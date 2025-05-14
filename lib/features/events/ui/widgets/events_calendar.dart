import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/event.dart';

class EventsCalendar extends StatefulWidget {
  final List<Event> events;
  final Function(DateTime) onDaySelected;
  final Function(Event) onEventSelected;

  const EventsCalendar({
    super.key,
    required this.events,
    required this.onDaySelected,
    required this.onEventSelected,
  });

  @override
  State<EventsCalendar> createState() => _EventsCalendarState();
}

class _EventsCalendarState extends State<EventsCalendar> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late Map<DateTime, List<Event>> _eventsByDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _updateEventsByDay();
  }

  @override
  void didUpdateWidget(EventsCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.events != oldWidget.events) {
      _updateEventsByDay();
    }
  }

  void _updateEventsByDay() {
    _eventsByDay = {};
    for (final event in widget.events) {
      final date = DateTime(
        event.dateTime.year,
        event.dateTime.month,
        event.dateTime.day,
      );
      if (_eventsByDay[date] == null) {
        _eventsByDay[date] = [];
      }
      _eventsByDay[date]!.add(event);
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _eventsByDay[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            widget.onDaySelected(selectedDay);
          },
          eventLoader: _getEventsForDay,
          calendarStyle: CalendarStyle(
            markersMaxCount: 3,
            markerDecoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            todayTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            selectedTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          calendarFormat: CalendarFormat.month,
          availableCalendarFormats: const {
            CalendarFormat.month: 'Month',
            CalendarFormat.week: 'Week',
          },
        ),

        const SizedBox(height: 16),

        // Events for selected day
        Expanded(child: _buildEventsList(_getEventsForDay(_selectedDay))),
      ],
    );
  }

  Widget _buildEventsList(List<Event> dayEvents) {
    if (dayEvents.isEmpty) {
      return const Center(child: Text('No events on this day'));
    }

    return ListView.builder(
      itemCount: dayEvents.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final event = dayEvents[index];
        return _buildEventListItem(event);
      },
    );
  }

  Widget _buildEventListItem(Event event) {
    final timeFormatter = DateFormat('h:mm a');
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isToday =
        event.dateTime.year == now.year &&
        event.dateTime.month == now.month &&
        event.dateTime.day == now.day;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isToday ? theme.colorScheme.primary : Colors.transparent,
          width: isToday ? 1 : 0,
        ),
      ),
      child: InkWell(
        onTap: () => widget.onEventSelected(event),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color:
                      isToday
                          ? theme.colorScheme.primary
                          : event.isPaid
                          ? Colors.amber.shade300
                          : Colors.green.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isToday
                                    ? theme.colorScheme.primaryContainer
                                    : theme.colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            timeFormatter.format(event.dateTime),
                            style: TextStyle(
                              color:
                                  isToday
                                      ? theme.colorScheme.onPrimaryContainer
                                      : theme.colorScheme.onSurfaceVariant,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Capacity: ${event.capacity}',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        // Price indicator if it's a paid event
                        if (event.isPaid && event.price != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '\$${event.price?.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.amber.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Free',
                              style: TextStyle(
                                color: Colors.green.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
