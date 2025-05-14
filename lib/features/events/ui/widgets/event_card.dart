import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:white_label_community_app/features/events/domain/entities/event.dart';
import 'package:white_label_community_app/features/events/ui/widgets/event_category_filter.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.event,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('MMM d');
    final timeFormatter = DateFormat('h:mm a');
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isToday =
        event.dateTime.year == now.year &&
        event.dateTime.month == now.month &&
        event.dateTime.day == now.day;
    final isTomorrow =
        event.dateTime.year == now.add(const Duration(days: 1)).year &&
        event.dateTime.month == now.add(const Duration(days: 1)).month &&
        event.dateTime.day == now.add(const Duration(days: 1)).day;
    final isUpcoming = event.dateTime.isAfter(now);
    final isPast = event.dateTime.isBefore(now);

    // Determine event category based on title keywords
    final category = _determineCategory(event.title);
    final categoryIcon = EventCategoryFilter.getCategoryIcon(category);

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 220,
        minHeight: 100, // Minimum height
      ),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isToday
                    ? theme.colorScheme.primary.withOpacity(0.5)
                    : theme.colorScheme.outline.withOpacity(0.2),
            width: isToday ? 1.5 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event header with date and background
                  AspectRatio(
                    aspectRatio:
                        16 / 9, // Use aspect ratio instead of fixed height
                    child: Stack(
                      children: [
                        // Background color or gradient
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.colorScheme.primary.withOpacity(0.8),
                                theme.colorScheme.primary.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),

                        // Date badge
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.calendar_today, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  isToday
                                      ? 'Today'
                                      : isTomorrow
                                      ? 'Tomorrow'
                                      : dateFormatter.format(event.dateTime),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Category icon
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              categoryIcon,
                              color: theme.colorScheme.primary,
                              size: 14,
                            ),
                          ),
                        ),

                        // Time badge
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  timeFormatter.format(event.dateTime),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Event details
                  Flexible(
                    fit: FlexFit.loose,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      color: theme.colorScheme.surface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          Text(
                            event.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          // Location
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  event.location,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Price and status row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Price indicator
                              if (event.isPaid && event.price != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
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
                                      fontSize: 10,
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
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
                                      fontSize: 10,
                                    ),
                                  ),
                                ),

                              // Status chip
                              _buildCompactStatusChip(
                                context,
                                isToday,
                                isUpcoming,
                                isPast,
                              ),
                            ],
                          ),

                          // Admin actions if available
                          if (onEdit != null || onDelete != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (onEdit != null)
                                    InkWell(
                                      onTap: onEdit,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Icon(
                                          Icons.edit_outlined,
                                          color: theme.colorScheme.primary,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  if (onEdit != null && onDelete != null)
                                    const SizedBox(width: 8),
                                  if (onDelete != null)
                                    InkWell(
                                      onTap:
                                          () =>
                                              _showDeleteConfirmation(context),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Icon(
                                          Icons.delete_outline,
                                          color: theme.colorScheme.error,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactStatusChip(
    BuildContext context,
    bool isToday,
    bool isUpcoming,
    bool isPast,
  ) {
    if (isPast) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Past',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (isToday) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Today',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Upcoming',
          style: TextStyle(
            color: Colors.green.shade800,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  Widget _buildStatusChip(
    BuildContext context,
    bool isToday,
    bool isUpcoming,
    bool isPast,
  ) {
    final theme = Theme.of(context);

    if (isPast) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Past',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (isToday) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Today',
          style: TextStyle(
            color: theme.colorScheme.onPrimaryContainer,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Upcoming',
          style: TextStyle(
            color: Colors.green.shade800,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
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

    if (confirmed == true && onDelete != null) {
      onDelete!();
    }
  }

  String _determineCategory(String title) {
    final lowerTitle = title.toLowerCase();

    if (lowerTitle.contains('workshop') || lowerTitle.contains('class')) {
      return 'Workshops';
    } else if (lowerTitle.contains('social') ||
        lowerTitle.contains('meetup') ||
        lowerTitle.contains('party')) {
      return 'Social';
    } else if (lowerTitle.contains('music') || lowerTitle.contains('concert')) {
      return 'Music';
    } else if (lowerTitle.contains('food') ||
        lowerTitle.contains('dinner') ||
        lowerTitle.contains('lunch')) {
      return 'Food';
    } else if (lowerTitle.contains('fitness') ||
        lowerTitle.contains('yoga') ||
        lowerTitle.contains('workout')) {
      return 'Fitness';
    } else if (lowerTitle.contains('business') ||
        lowerTitle.contains('networking')) {
      return 'Business';
    } else {
      return 'All';
    }
  }
}
