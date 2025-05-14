import 'package:flutter/material.dart';

/// Represents a dynamic field in the profile form
class ProfileDynamicField {
  final String id;
  final String label;
  final String value;
  final String fieldType;
  final List<String>? options;

  const ProfileDynamicField({
    required this.id,
    required this.label,
    required this.value,
    required this.fieldType,
    this.options,
  });

  ProfileDynamicField copyWith({
    String? label,
    String? value,
    String? fieldType,
    List<String>? options,
  }) {
    return ProfileDynamicField(
      id: id,
      label: label ?? this.label,
      value: value ?? this.value,
      fieldType: fieldType ?? this.fieldType,
      options: options ?? this.options,
    );
  }
}

class DynamicFieldsSection extends StatelessWidget {
  final List<ProfileDynamicField> fields;
  final Function(String id, String value) onFieldChanged;
  final Function() onEditFieldsPressed;
  final bool isLoading;

  const DynamicFieldsSection({
    super.key,
    required this.fields,
    required this.onFieldChanged,
    required this.onEditFieldsPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (fields.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.category),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Additional Information',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : onEditFieldsPressed,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...fields.map((field) => _buildDynamicField(context, field)),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicField(BuildContext context, ProfileDynamicField field) {
    switch (field.fieldType) {
      case 'text':
        return _buildTextField(field);
      case 'dropdown':
        return _buildDropdownField(field);
      case 'checkbox':
        return _buildCheckboxField(field);
      case 'radio':
        return _buildRadioField(field);
      default:
        return _buildTextField(field);
    }
  }

  Widget _buildTextField(ProfileDynamicField field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        enabled: !isLoading,
        decoration: InputDecoration(
          labelText: field.label,
          border: const OutlineInputBorder(),
        ),
        controller: TextEditingController(text: field.value)
          ..selection = TextSelection.fromPosition(
            TextPosition(offset: field.value.length),
          ),
        onChanged: (value) => onFieldChanged(field.id, value),
      ),
    );
  }

  Widget _buildDropdownField(ProfileDynamicField field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: field.label,
          border: const OutlineInputBorder(),
        ),
        value: field.value.isEmpty ? null : field.value,
        items:
            field.options?.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList() ??
            [],
        onChanged:
            isLoading
                ? null
                : (value) {
                  if (value != null) {
                    onFieldChanged(field.id, value);
                  }
                },
      ),
    );
  }

  Widget _buildCheckboxField(ProfileDynamicField field) {
    final isChecked = field.value.toLowerCase() == 'true';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Checkbox(
            value: isChecked,
            onChanged:
                isLoading
                    ? null
                    : (bool? value) {
                      onFieldChanged(field.id, (value ?? false).toString());
                    },
          ),
          Text(field.label),
        ],
      ),
    );
  }

  Widget _buildRadioField(ProfileDynamicField field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...?field.options?.map(
            (option) => RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: field.value,
              onChanged:
                  isLoading
                      ? null
                      : (value) {
                        if (value != null) {
                          onFieldChanged(field.id, value);
                        }
                      },
            ),
          ),
        ],
      ),
    );
  }
}

class DynamicFieldsDialog extends StatefulWidget {
  final List<ProfileDynamicField> initialFields;
  final List<String> availableFieldTypes;

  const DynamicFieldsDialog({
    super.key,
    required this.initialFields,
    this.availableFieldTypes = const ['text', 'dropdown', 'checkbox', 'radio'],
  });

  @override
  State<DynamicFieldsDialog> createState() => _DynamicFieldsDialogState();
}

class _DynamicFieldsDialogState extends State<DynamicFieldsDialog> {
  late List<ProfileDynamicField> _fields;

  @override
  void initState() {
    super.initState();
    _fields = List.from(widget.initialFields);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Custom Fields'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ..._fields.map((field) => _buildFieldEditor(field)),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Field'),
              onPressed: _addNewField,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _fields),
          child: const Text('SAVE'),
        ),
      ],
    );
  }

  Widget _buildFieldEditor(ProfileDynamicField field) {
    final index = _fields.indexWhere((f) => f.id == field.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Field ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeField(field.id),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Label',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: field.label),
              onChanged:
                  (value) =>
                      _updateField(field.id, field.copyWith(label: value)),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Field Type',
                border: OutlineInputBorder(),
              ),
              value: field.fieldType,
              items:
                  widget.availableFieldTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type.capitalize()),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _updateField(field.id, field.copyWith(fieldType: value));
                }
              },
            ),
            if (field.fieldType == 'dropdown' ||
                field.fieldType == 'radio') ...[
              const SizedBox(height: 16),
              const Text('Options (one per line):'),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(border: OutlineInputBorder()),
                maxLines: 3,
                controller: TextEditingController(
                  text: field.options?.join('\n') ?? '',
                ),
                onChanged: (value) {
                  final options =
                      value
                          .split('\n')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();
                  _updateField(field.id, field.copyWith(options: options));
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _updateField(String id, ProfileDynamicField newField) {
    setState(() {
      final index = _fields.indexWhere((field) => field.id == id);
      if (index != -1) {
        _fields[index] = newField;
      }
    });
  }

  void _removeField(String id) {
    setState(() {
      _fields.removeWhere((field) => field.id == id);
    });
  }

  void _addNewField() {
    setState(() {
      _fields.add(
        ProfileDynamicField(
          id: 'field_${DateTime.now().millisecondsSinceEpoch}',
          label: 'New Field',
          value: '',
          fieldType: 'text',
        ),
      );
    });
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
