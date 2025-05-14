import 'package:flutter/material.dart';

class InterestsSection extends StatelessWidget {
  final List<String> selectedInterests;
  final String interestsLabel;
  final Function() onEditPressed;
  final Function(String) onRemoveInterest;
  final bool isLoading;

  const InterestsSection({
    super.key,
    required this.selectedInterests,
    required this.interestsLabel,
    required this.onEditPressed,
    required this.onRemoveInterest,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    interestsLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : onEditPressed,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              ],
            ),
            if (selectedInterests.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    selectedInterests.map((interest) {
                      return Chip(
                        label: Text(interest),
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.1,
                        ),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted:
                            isLoading ? null : () => onRemoveInterest(interest),
                      );
                    }).toList(),
              ),
            ] else ...[
              const SizedBox(height: 16),
              Text(
                'Add some ${interestsLabel.toLowerCase()} to help others get to know you better',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class InterestsDialog extends StatefulWidget {
  final List<String> initialSelected;
  final String title;
  final List<String> availableInterests;

  const InterestsDialog({
    super.key,
    required this.initialSelected,
    required this.title,
    required this.availableInterests,
  });

  @override
  State<InterestsDialog> createState() => _InterestsDialogState();
}

class _InterestsDialogState extends State<InterestsDialog> {
  late List<String> tempSelected;

  @override
  void initState() {
    super.initState();
    tempSelected = List.from(widget.initialSelected);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Wrap(
          spacing: 8,
          children:
              widget.availableInterests.map((interest) {
                final isSelected = tempSelected.contains(interest);
                return FilterChip(
                  label: Text(interest),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        tempSelected.add(interest);
                      } else {
                        tempSelected.remove(interest);
                      }
                    });
                  },
                );
              }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, tempSelected);
          },
          child: const Text('SAVE'),
        ),
      ],
    );
  }
}
