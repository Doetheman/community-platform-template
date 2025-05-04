import 'package:flutter/material.dart';
import 'package:white_label_community_app/features/events/domain/entities/event.dart';

class EventForm extends StatefulWidget {
  final void Function(Event event) onSubmit;

  const EventForm({super.key, required this.onSubmit});

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  DateTime? selectedDate;

  void _submit() {
    if (_formKey.currentState!.validate() && selectedDate != null) {
      final event = Event(
        id: '', // Firestore will assign
        title: titleController.text.trim(),
        location: locationController.text.trim(),
        description: descriptionController.text.trim(),
        isPaid:
            double.tryParse(priceController.text.trim()) != null &&
            double.parse(priceController.text.trim()) > 0,
        dateTime: selectedDate!,
      );

      widget.onSubmit(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Event Title'),
            validator:
                (val) => val == null || val.isEmpty ? 'Enter a title' : null,
          ),
          TextFormField(
            controller: locationController,
            decoration: const InputDecoration(labelText: 'Location'),
            validator:
                (val) => val == null || val.isEmpty ? 'Enter a location' : null,
          ),
          TextFormField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 3,
          ),
          TextFormField(
            controller: priceController,
            decoration: const InputDecoration(
              labelText: 'Price (e.g. 0 or 10.00)',
            ),
            keyboardType: TextInputType.number,
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
                setState(() {
                  selectedDate = picked;
                });
              }
            },
            child: Text(
              selectedDate == null
                  ? 'Pick Event Date'
                  : 'Date: ${selectedDate!.toLocal().toString().split(' ')[0]}',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.save),
            label: const Text("Create Event"),
          ),
        ],
      ),
    );
  }
}
