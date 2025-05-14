import 'package:flutter/material.dart';
import 'package:white_label_community_app/features/profile/config/profile_config.dart';
import 'package:white_label_community_app/features/profile/domain/entities/user_profile.dart';

class ProfileSection extends StatefulWidget {
  final ProfileCategory category;
  final List<ProfileFieldConfig> fields;
  final UserProfile profile;
  final bool initiallyExpanded;
  final bool isOwnProfile;
  final Function(String)? onFieldTap;

  const ProfileSection({
    super.key,
    required this.category,
    required this.fields,
    required this.profile,
    this.initiallyExpanded = false,
    this.isOwnProfile = false,
    this.onFieldTap,
  });

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  dynamic _getFieldValue(String fieldId) {
    // Check common fields
    switch (fieldId) {
      case 'name':
        return widget.profile.name;
      case 'bio':
        return widget.profile.bio;
      case 'location':
        return widget.profile.location;
      default:
        // Check custom fields
        return widget.profile.customFields[fieldId];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFields = widget.fields.isNotEmpty;

    if (!hasFields) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with expand/collapse functionality
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(widget.category.icon),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.category.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.category.description!,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),

          // Content (only visible when expanded)
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    widget.fields.map((field) {
                      final value = _getFieldValue(field.id);

                      // Don't show empty fields
                      if (value == null ||
                          (value is String && value.isEmpty) ||
                          (value is List && value.isEmpty)) {
                        return widget.isOwnProfile
                            ? _buildEmptyFieldPrompt(field)
                            : const SizedBox.shrink();
                      }

                      return _buildFieldDisplay(field, value);
                    }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyFieldPrompt(ProfileFieldConfig field) {
    return ListTile(
      leading: Icon(field.icon, color: Colors.grey),
      title: Text(
        'Add your ${field.label}',
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: const Icon(Icons.add_circle_outline, color: Colors.grey),
      onTap:
          widget.onFieldTap != null ? () => widget.onFieldTap!(field.id) : null,
    );
  }

  Widget _buildFieldDisplay(ProfileFieldConfig field, dynamic value) {
    switch (field.fieldType) {
      case 'toggle':
        return SwitchListTile(
          value: value as bool? ?? false,
          onChanged: null,
          title: Text(field.label),
          secondary: Icon(field.icon),
        );

      case 'multiSelect':
        final values = value is List<String> ? value : <String>[];
        if (values.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Icon(field.icon),
                title: Text(field.label),
                contentPadding: EdgeInsets.zero,
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    values.map((item) => Chip(label: Text(item))).toList(),
              ),
            ],
          ),
        );

      default:
        return ListTile(
          leading: Icon(field.icon),
          title: Text(field.label),
          subtitle: Text(value.toString()),
          contentPadding: EdgeInsets.zero,
          onTap:
              widget.onFieldTap != null
                  ? () => widget.onFieldTap!(field.id)
                  : null,
        );
    }
  }
}
