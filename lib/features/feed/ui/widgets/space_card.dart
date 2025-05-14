import 'package:flutter/material.dart';

class SpaceCard extends StatelessWidget {
  final Map<String, dynamic> space;
  final Function(Map<String, dynamic>) onTap;

  const SpaceCard({super.key, required this.space, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = space['color'] as Color;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => onTap(space),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with color
            Container(height: 24, color: color),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Space icon
                  CircleAvatar(
                    backgroundColor: color.withOpacity(0.2),
                    child: Text(
                      space['name'].substring(0, 1),
                      style: TextStyle(color: color),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Space details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          space['name'],
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          space['description'],
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Created by ${space['creator']}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const Spacer(),
                            Icon(
                              Icons.group,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${space['members']} members',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
