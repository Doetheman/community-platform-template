import 'package:flutter/material.dart';

/// Defines a dynamic profile field configuration
class ProfileFieldConfig {
  final String id;
  final String label;
  final IconData icon;
  final bool required;
  final bool visibleOnOwnProfile;
  final bool visibleOnOtherProfiles;
  final bool editable;
  final String
  fieldType; // text, number, date, toggle, multiSelect, singleSelect
  final List<String>? options; // for select fields
  final String? placeholder;
  final int? maxLength;
  final String? helperText;
  final String? category; // Optional grouping category

  const ProfileFieldConfig({
    required this.id,
    required this.label,
    required this.icon,
    this.required = false,
    this.visibleOnOwnProfile = true,
    this.visibleOnOtherProfiles = true,
    this.editable = true,
    required this.fieldType,
    this.options,
    this.placeholder,
    this.maxLength,
    this.helperText,
    this.category,
  });
}

/// Defines a category for grouping profile fields
class ProfileCategory {
  final String id;
  final String title;
  final IconData icon;
  final String? description;
  final bool expandedByDefault;
  final bool visibleOnOwnProfile;
  final bool visibleOnOtherProfiles;

  const ProfileCategory({
    required this.id,
    required this.title,
    required this.icon,
    this.description,
    this.expandedByDefault = false,
    this.visibleOnOwnProfile = true,
    this.visibleOnOtherProfiles = true,
  });
}

/// App-specific profile configuration
class ProfileConfig {
  final String appName;
  final List<ProfileFieldConfig> fields;
  final List<ProfileCategory> categories;
  final String interestsLabel; // "Interests", "Kinks", "Experiences", etc.
  final bool showBadges;
  final bool showLocation;
  final bool showSocialLinks;
  final List<String> availableSocialPlatforms;
  final Map<String, String> defaultValues;
  final bool enableCoverPhoto;

  const ProfileConfig({
    required this.appName,
    required this.fields,
    required this.categories,
    this.interestsLabel = 'Interests',
    this.showBadges = true,
    this.showLocation = true,
    this.showSocialLinks = true,
    this.availableSocialPlatforms = const [
      'Twitter',
      'Instagram',
      'LinkedIn',
      'GitHub',
    ],
    this.defaultValues = const {},
    this.enableCoverPhoto = true,
  });
}

/// Sample configurations for different app types
class ProfileConfigs {
  // Default configuration
  static final ProfileConfig defaultConfig = ProfileConfig(
    appName: 'Community App',
    interestsLabel: 'Interests',
    categories: [
      ProfileCategory(
        id: 'basic',
        title: 'Basic Information',
        icon: Icons.person,
        expandedByDefault: true,
      ),
      ProfileCategory(
        id: 'interests',
        title: 'Interests',
        icon: Icons.favorite,
      ),
      ProfileCategory(id: 'social', title: 'Social', icon: Icons.share),
    ],
    fields: [
      ProfileFieldConfig(
        id: 'bio',
        label: 'Bio',
        icon: Icons.description,
        fieldType: 'text',
        maxLength: 250,
        placeholder: 'Tell us about yourself',
        category: 'basic',
      ),
      ProfileFieldConfig(
        id: 'location',
        label: 'Location',
        icon: Icons.location_on,
        fieldType: 'text',
        placeholder: 'Where are you based?',
        category: 'basic',
      ),
    ],
  );

  // Dating app configuration
  static final ProfileConfig datingConfig = ProfileConfig(
    appName: 'Dating Community',
    interestsLabel: 'Interests & Hobbies',
    categories: [
      ProfileCategory(
        id: 'basic',
        title: 'Basic Information',
        icon: Icons.person,
        expandedByDefault: true,
      ),
      ProfileCategory(
        id: 'preferences',
        title: 'Preferences',
        icon: Icons.favorite,
      ),
      ProfileCategory(
        id: 'lifestyle',
        title: 'Lifestyle',
        icon: Icons.wine_bar,
      ),
    ],
    fields: [
      ProfileFieldConfig(
        id: 'bio',
        label: 'About Me',
        icon: Icons.description,
        fieldType: 'text',
        maxLength: 500,
        placeholder: 'Share what makes you unique',
        category: 'basic',
      ),
      ProfileFieldConfig(
        id: 'age',
        label: 'Age',
        icon: Icons.cake,
        fieldType: 'number',
        category: 'basic',
      ),
      ProfileFieldConfig(
        id: 'height',
        label: 'Height',
        icon: Icons.height,
        fieldType: 'text',
        category: 'basic',
      ),
      ProfileFieldConfig(
        id: 'lookingFor',
        label: 'Looking For',
        icon: Icons.search,
        fieldType: 'multiSelect',
        options: ['Relationship', 'Friendship', 'Casual', 'Networking'],
        category: 'preferences',
      ),
      ProfileFieldConfig(
        id: 'drinking',
        label: 'Drinking',
        icon: Icons.local_bar,
        fieldType: 'singleSelect',
        options: ['Never', 'Rarely', 'Sometimes', 'Often'],
        category: 'lifestyle',
      ),
      ProfileFieldConfig(
        id: 'smoking',
        label: 'Smoking',
        icon: Icons.smoking_rooms,
        fieldType: 'singleSelect',
        options: ['Never', 'Rarely', 'Sometimes', 'Often'],
        category: 'lifestyle',
      ),
    ],
  );

  // Professional networking configuration
  static final ProfileConfig professionalConfig = ProfileConfig(
    appName: 'Professional Network',
    interestsLabel: 'Professional Interests',
    categories: [
      ProfileCategory(
        id: 'basic',
        title: 'Basic Information',
        icon: Icons.person,
        expandedByDefault: true,
      ),
      ProfileCategory(id: 'experience', title: 'Experience', icon: Icons.work),
      ProfileCategory(id: 'education', title: 'Education', icon: Icons.school),
      ProfileCategory(id: 'skills', title: 'Skills', icon: Icons.build),
    ],
    fields: [
      ProfileFieldConfig(
        id: 'headline',
        label: 'Headline',
        icon: Icons.short_text,
        fieldType: 'text',
        maxLength: 150,
        placeholder: 'Your professional headline',
        category: 'basic',
      ),
      ProfileFieldConfig(
        id: 'company',
        label: 'Current Company',
        icon: Icons.business,
        fieldType: 'text',
        category: 'experience',
      ),
      ProfileFieldConfig(
        id: 'position',
        label: 'Current Position',
        icon: Icons.work,
        fieldType: 'text',
        category: 'experience',
      ),
      ProfileFieldConfig(
        id: 'education',
        label: 'Education',
        icon: Icons.school,
        fieldType: 'text',
        category: 'education',
      ),
      ProfileFieldConfig(
        id: 'openToWork',
        label: 'Open to Job Opportunities',
        icon: Icons.search,
        fieldType: 'toggle',
        category: 'basic',
      ),
    ],
  );

  // Current active configuration
  static ProfileConfig get activeConfig => defaultConfig;
}
