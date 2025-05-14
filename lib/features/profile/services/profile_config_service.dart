import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_label_community_app/features/profile/config/profile_config.dart';
import 'package:white_label_community_app/features/profile/domain/entities/user_profile.dart';

/// Service for managing profile configuration and dynamic fields
class ProfileConfigService {
  final ProfileConfig config;

  ProfileConfigService({required this.config});

  /// Get the configuration for a specific field
  ProfileFieldConfig? getFieldConfig(String fieldId) {
    return config.fields.firstWhere(
      (field) => field.id == fieldId,
      orElse:
          () =>
              throw Exception(
                'Field $fieldId not found in profile configuration',
              ),
    );
  }

  /// Get all fields for a specific category
  List<ProfileFieldConfig> getFieldsForCategory(String categoryId) {
    return config.fields
        .where((field) => field.category == categoryId)
        .toList();
  }

  /// Get a specific category configuration
  ProfileCategory? getCategoryConfig(String categoryId) {
    return config.categories.firstWhere(
      (category) => category.id == categoryId,
      orElse:
          () =>
              throw Exception(
                'Category $categoryId not found in profile configuration',
              ),
    );
  }

  /// Get default value for a field
  dynamic getDefaultValue(String fieldId) {
    return config.defaultValues[fieldId];
  }

  /// Get field value from a user profile
  dynamic getFieldValue(UserProfile profile, String fieldId) {
    // Handle standard fields
    switch (fieldId) {
      case 'name':
        return profile.name;
      case 'bio':
        return profile.bio;
      case 'location':
        return profile.location;
      default:
        // Check in custom fields
        return profile.customFields[fieldId];
    }
  }

  /// Build categories and fields that should be visible on own profile
  List<ProfileCategory> getVisibleCategoriesForOwnProfile() {
    return config.categories
        .where((category) => category.visibleOnOwnProfile)
        .toList();
  }

  /// Build categories and fields that should be visible on other profiles
  List<ProfileCategory> getVisibleCategoriesForOtherProfile() {
    return config.categories
        .where((category) => category.visibleOnOtherProfiles)
        .toList();
  }

  /// Get all visible fields for own profile
  List<ProfileFieldConfig> getVisibleFieldsForOwnProfile() {
    return config.fields.where((field) => field.visibleOnOwnProfile).toList();
  }

  /// Get all visible fields for other profiles
  List<ProfileFieldConfig> getVisibleFieldsForOtherProfile() {
    return config.fields
        .where((field) => field.visibleOnOtherProfiles)
        .toList();
  }

  /// Get all editable fields
  List<ProfileFieldConfig> getEditableFields() {
    return config.fields.where((field) => field.editable).toList();
  }

  /// Check if a field is required
  bool isFieldRequired(String fieldId) {
    final field = getFieldConfig(fieldId);
    return field?.required ?? false;
  }

  /// Get the label for interests based on the app configuration
  String get interestsLabel => config.interestsLabel;

  /// Create an input widget for a specific field type
  Widget buildInputWidget({
    required ProfileFieldConfig field,
    required dynamic currentValue,
    required Function(dynamic) onChanged,
  }) {
    switch (field.fieldType) {
      case 'text':
        return TextFormField(
          initialValue: currentValue?.toString() ?? '',
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.placeholder,
            helperText: field.helperText,
            prefixIcon: Icon(field.icon),
          ),
          maxLength: field.maxLength,
          onChanged: onChanged,
          validator:
              field.required
                  ? (value) =>
                      (value == null || value.isEmpty)
                          ? 'This field is required'
                          : null
                  : null,
        );

      case 'number':
        return TextFormField(
          initialValue: currentValue?.toString() ?? '',
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.placeholder,
            helperText: field.helperText,
            prefixIcon: Icon(field.icon),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) => onChanged(int.tryParse(value) ?? 0),
          validator:
              field.required
                  ? (value) =>
                      (value == null || value.isEmpty)
                          ? 'This field is required'
                          : null
                  : null,
        );

      case 'toggle':
        return SwitchListTile(
          title: Text(field.label),
          subtitle: field.helperText != null ? Text(field.helperText!) : null,
          secondary: Icon(field.icon),
          value: currentValue ?? false,
          onChanged: onChanged,
        );

      case 'singleSelect':
        if (field.options == null || field.options!.isEmpty) {
          return const Text('No options available');
        }

        return DropdownButtonFormField<String>(
          value: currentValue,
          decoration: InputDecoration(
            labelText: field.label,
            helperText: field.helperText,
            prefixIcon: Icon(field.icon),
          ),
          items:
              field.options!.map((option) {
                return DropdownMenuItem(value: option, child: Text(option));
              }).toList(),
          onChanged: (value) => onChanged(value),
          validator:
              field.required
                  ? (value) =>
                      (value == null || value.isEmpty)
                          ? 'This field is required'
                          : null
                  : null,
        );

      case 'multiSelect':
        if (field.options == null || field.options!.isEmpty) {
          return const Text('No options available');
        }

        final selectedValues = (currentValue as List<String>?) ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(field.icon),
              title: Text(field.label),
              subtitle:
                  field.helperText != null ? Text(field.helperText!) : null,
            ),
            Wrap(
              spacing: 8,
              children:
                  field.options!.map((option) {
                    final isSelected = selectedValues.contains(option);
                    return FilterChip(
                      label: Text(option),
                      selected: isSelected,
                      onSelected: (selected) {
                        final newList = List<String>.from(selectedValues);
                        if (selected) {
                          newList.add(option);
                        } else {
                          newList.remove(option);
                        }
                        onChanged(newList);
                      },
                    );
                  }).toList(),
            ),
            if (field.required && selectedValues.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Please select at least one option',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );

      default:
        return Text('Unsupported field type: ${field.fieldType}');
    }
  }
}

/// Provider for the profile configuration service
final profileConfigServiceProvider = Provider<ProfileConfigService>((ref) {
  return ProfileConfigService(config: ProfileConfigs.activeConfig);
});
