import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_label_community_app/features/events/domain/entities/event.dart';
import 'package:white_label_community_app/features/events/state/create_form_controller.dart';

class EventForm extends ConsumerWidget {
  final void Function(Event event) onSubmit;

  const EventForm({super.key, required this.onSubmit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(eventFormControllerProvider);
    final controller = ref.read(eventFormControllerProvider.notifier);
    final currentUser = FirebaseAuth.instance.currentUser;

    return Form(
      child: Column(
        children: [
          TextFormField(
            initialValue: form.title,
            onChanged: controller.updateTitle,
            decoration: const InputDecoration(labelText: 'Event Title'),
          ),
          TextFormField(
            initialValue: form.location,
            onChanged: controller.updateLocation,
            decoration: const InputDecoration(labelText: 'Location'),
          ),
          TextFormField(
            initialValue: form.description,
            onChanged: controller.updateDescription,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 3,
          ),
          SwitchListTile(
            value: form.isPaid,
            onChanged: controller.toggleIsPaid,
            title: const Text('Is this a paid event?'),
          ),
          if (form.isPaid)
            TextFormField(
              initialValue: form.price,
              onChanged: controller.updatePrice,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Price (USD)',
                prefixText: '\$',
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                controller.updateDate(picked);
              }
            },
            child: Text(
              form.date == null
                  ? 'Pick Event Date'
                  : 'Date: ${form.date!.toLocal().toString().split(' ')[0]}',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              if (form.date == null) return;
              final price = form.isPaid ? double.tryParse(form.price) : null;

              final event = Event(
                id: '',
                title: form.title,
                location: form.location,
                description: form.description,
                isPaid: form.isPaid,
                dateTime: form.date!,
                price: price,
                hostId: currentUser?.uid ?? '',
                capacity: 20,
              );

              onSubmit(event);
            },
            icon: const Icon(Icons.save),
            label: const Text("Create Event"),
          ),
        ],
      ),
    );
  }
}
