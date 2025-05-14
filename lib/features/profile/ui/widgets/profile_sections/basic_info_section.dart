import 'package:flutter/material.dart';

class BasicInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController bioController;
  final TextEditingController locationController;
  final bool isLoading;

  const BasicInfoSection({
    super.key,
    required this.nameController,
    required this.bioController,
    required this.locationController,
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
                const Icon(Icons.person),
                const SizedBox(width: 16),
                Text(
                  'Basic Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.badge),
              ),
              enabled: !isLoading,
              validator:
                  (val) =>
                      val == null || val.isEmpty
                          ? 'Please enter your name'
                          : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                prefixIcon: Icon(Icons.description),
                hintText: 'Tell others about yourself',
              ),
              enabled: !isLoading,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                prefixIcon: Icon(Icons.location_on),
                hintText: 'Where are you based?',
              ),
              enabled: !isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
