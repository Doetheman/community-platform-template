import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:white_label_community_app/features/profile/domain/entities/user_profile.dart';
import 'package:white_label_community_app/features/profile/services/profile_config_service.dart';
import '../widgets/profile_sections/profile_image_section.dart';
import '../widgets/profile_sections/cover_image_section.dart';
import '../widgets/profile_sections/basic_info_section.dart';
import '../widgets/profile_sections/interests_section.dart';
import '../widgets/profile_sections/social_media_section.dart';
import '../utils/profile_dialog_utils.dart';

class EnhancedProfileForm extends StatefulWidget {
  final UserProfile initial;
  final ProfileConfigService configService;
  final Future<void> Function(UserProfile) onSubmit;

  const EnhancedProfileForm({
    super.key,
    required this.initial,
    required this.configService,
    required this.onSubmit,
  });

  @override
  State<EnhancedProfileForm> createState() => _EnhancedProfileFormState();
}

class _EnhancedProfileFormState extends State<EnhancedProfileForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isFormDirty = false;

  // Basic profile fields
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _locationController;

  // Dynamic field controllers and values
  final Map<String, dynamic> _fieldValues = {};
  final Map<String, TextEditingController> _textControllers = {};

  // Photos
  File? _profileImageFile;
  File? _coverImageFile;

  // Interests and social links
  late List<String> _selectedInterests;
  late Map<String, String> _socialLinks;

  // Available interests for the dialog
  late List<String> _availableInterests;

  @override
  void initState() {
    super.initState();

    // Initialize basic controllers
    _nameController = TextEditingController(text: widget.initial.name);
    _bioController = TextEditingController(text: widget.initial.bio ?? '');
    _locationController = TextEditingController(
      text: widget.initial.location ?? '',
    );

    // Initialize dynamic field values and controllers
    for (final field in widget.configService.getEditableFields()) {
      final value = widget.configService.getFieldValue(
        widget.initial,
        field.id,
      );
      _fieldValues[field.id] = value;

      if (field.fieldType == 'text' || field.fieldType == 'number') {
        _textControllers[field.id] = TextEditingController(
          text: value != null ? value.toString() : '',
        );
      }
    }

    // Initialize interests and social links - ensure socialLinks is never null
    _selectedInterests = [...widget.initial.interests];
    _socialLinks = {...widget.initial.socialLinks};

    // Initialize available interests
    _availableInterests = [
      'Art',
      'Music',
      'Travel',
      'Food',
      'Technology',
      'Sports',
      'Reading',
      'Gaming',
      'Photography',
      'Fitness',
      'Fashion',
      'Movies',
      'Hiking',
      'Cooking',
      'Dance',
    ];
  }

  @override
  void dispose() {
    // Dispose all controllers
    _nameController.dispose();
    _bioController.dispose();
    _locationController.dispose();

    for (final controller in _textControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<String?> _uploadImage(File file, String uid, String type) async {
    final filename = 'users/$uid/$type.jpg';
    final ref = FirebaseStorage.instance.ref().child(filename);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // Current image URLs
        String? profileImageUrl = widget.initial.profileImageUrl;
        String? coverImageUrl = widget.initial.coverImageUrl;

        // Upload new images if selected
        if (_profileImageFile != null) {
          profileImageUrl = await _uploadImage(
            _profileImageFile!,
            widget.initial.uid,
            'profile',
          );
        }

        if (_coverImageFile != null) {
          coverImageUrl = await _uploadImage(
            _coverImageFile!,
            widget.initial.uid,
            'cover',
          );
        }

        // Build custom fields map
        final customFields = <String, dynamic>{};
        for (final entry in _fieldValues.entries) {
          // Skip standard fields that are stored directly in the profile
          if (entry.key != 'name' &&
              entry.key != 'bio' &&
              entry.key != 'location') {
            customFields[entry.key] = entry.value;
          }
        }

        // Create updated profile
        final updated = widget.initial.copyWith(
          name: _nameController.text.trim(),
          bio: _bioController.text.trim(),
          location: _locationController.text.trim(),
          interests: _selectedInterests,
          profileImageUrl: profileImageUrl,
          coverImageUrl: coverImageUrl,
          customFields: customFields,
          socialLinks: _socialLinks,
        );

        await widget.onSubmit(updated);
        if (mounted) {
          setState(() => _isFormDirty = false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  // Helper for social icons
  IconData _getSocialIcon(String platform) {
    final platform0 = platform.toLowerCase();

    if (platform0.contains('twitter') || platform0.contains('x.com')) {
      return Icons.flutter_dash; // Placeholder for Twitter/X
    } else if (platform0.contains('facebook')) {
      return Icons.facebook;
    } else if (platform0.contains('instagram')) {
      return Icons.camera_alt;
    } else if (platform0.contains('linkedin')) {
      return Icons.work;
    } else if (platform0.contains('github')) {
      return Icons.code;
    } else if (platform0.contains('youtube')) {
      return Icons.play_arrow;
    } else if (platform0.contains('medium')) {
      return Icons.article;
    } else if (platform0.contains('tiktok')) {
      return Icons.music_note;
    } else {
      return Icons.public;
    }
  }

  void _handleInterestsEdit() async {
    final result = await ProfileDialogUtils.showInterestsDialog(
      context: context,
      selectedInterests: _selectedInterests,
      availableInterests: _availableInterests,
    );

    if (result != null && mounted) {
      setState(() {
        _selectedInterests = result;
        _isFormDirty = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            // Profile Image Section
            ProfileImageSection(
              imageUrl: widget.initial.profileImageUrl,
              imageFile: _profileImageFile,
              onImageSelected: (file) {
                setState(() {
                  _profileImageFile = file;
                  _isFormDirty = true;
                });
              },
              isLoading: _isLoading,
            ),

            const SizedBox(height: 24),

            // Cover Image Section (if enabled)
            if (widget.configService.config.enableCoverPhoto) ...[
              CoverImageSection(
                coverImageUrl: widget.initial.coverImageUrl,
                coverImageFile: _coverImageFile,
                onImageSelected: (file) {
                  setState(() {
                    _coverImageFile = file;
                    _isFormDirty = true;
                  });
                },
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),
            ],

            // Basic Information Section
            BasicInfoSection(
              nameController: _nameController,
              bioController: _bioController,
              locationController: _locationController,
              isLoading: _isLoading,
            ),

            const SizedBox(height: 16),

            // Interests Section
            InterestsSection(
              selectedInterests: _selectedInterests,
              interestsLabel: widget.configService.interestsLabel,
              onEditPressed: _handleInterestsEdit,
              onRemoveInterest: (interest) {
                setState(() {
                  _selectedInterests.remove(interest);
                  _isFormDirty = true;
                });
              },
              isLoading: _isLoading,
            ),

            const SizedBox(height: 16),

            // Social Media Links Section
            if (widget.configService.config.showSocialLinks)
              SocialMediaSection(
                socialLinks: _socialLinks,
                onEditPressed: () async {
                  final result = await ProfileDialogUtils.showSocialMediaDialog(
                    context: context,
                    initialLinks: _socialLinks,
                    availablePlatforms:
                        widget.configService.config.availableSocialPlatforms,
                  );

                  if (result != null && mounted) {
                    setState(() {
                      _socialLinks = result;
                      _isFormDirty = true;
                    });
                  }
                },
                onRemoveLink: (platform) {
                  setState(() {
                    _socialLinks.remove(platform);
                    _isFormDirty = true;
                  });
                },
                isLoading: _isLoading,
              ),

            const SizedBox(height: 16),

            // Dynamic Custom Fields
            ...widget.configService
                .getVisibleCategoriesForOwnProfile()
                .where(
                  (cat) =>
                      cat.id != 'basic' &&
                      cat.id != 'interests' &&
                      cat.id != 'social',
                )
                .map((category) {
                  final fields =
                      widget.configService
                          .getFieldsForCategory(category.id)
                          .where((field) => field.editable)
                          .toList();

                  if (fields.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(category.icon),
                                  const SizedBox(width: 16),
                                  Text(
                                    category.title,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ...fields.map((field) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: widget.configService.buildInputWidget(
                                    field: field,
                                    currentValue: _fieldValues[field.id],
                                    onChanged: (value) {
                                      setState(() {
                                        _fieldValues[field.id] = value;
                                        _isFormDirty = true;
                                      });
                                    },
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.save),
                label: Text(_isLoading ? 'Saving...' : 'Save Profile'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
