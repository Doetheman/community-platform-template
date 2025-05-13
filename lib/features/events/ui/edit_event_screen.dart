import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_label_community_app/features/events/domain/entities/event.dart';
import 'package:white_label_community_app/features/events/state/event_provider.dart';
import 'package:white_label_community_app/features/events/ui/widgets/event_form.dart';

class EditEventScreen extends ConsumerWidget {
  final Event event;

  const EditEventScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formController = ref.read(eventControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Event')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: EventForm(
          onSubmit: (updatedEvent) async {
            final updated = updatedEvent.copyWith(id: event.id);
            await formController.updateEvent(updated);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Event updated successfully')),
            );
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }
}
