import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:white_label_community_app/features/profile/domain/entities/user_profile.dart';

class ProfileForm extends StatefulWidget {
  final UserProfile initial;
  final Future<void> Function(UserProfile) onSubmit;

  const ProfileForm({super.key, required this.initial, required this.onSubmit});

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  late final TextEditingController nameController;
  late final TextEditingController bioController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  List<String> selectedInterests = [];

  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<String?> _uploadImage(File file, String uid) async {
    final filename = 'users/$uid/avatar.jpg';
    final ref = FirebaseStorage.instance.ref().child(filename);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initial.name);
    bioController = TextEditingController(text: widget.initial.bio ?? '');
    selectedInterests = [...widget.initial.interests];
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        String? imageUrl = widget.initial.profileImageUrl;

        if (_imageFile != null) {
          imageUrl = await _uploadImage(_imageFile!, widget.initial.uid);
        }

        final updated = UserProfile(
          uid: widget.initial.uid,
          name: nameController.text.trim(),
          bio: bioController.text.trim(),
          interests: selectedInterests,
          profileImageUrl: imageUrl,
        );

        await widget.onSubmit(updated);
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final interestsList = ['Tech', 'Design', 'Fitness', 'Music', 'Crypto'];

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage:
                    _imageFile != null
                        ? FileImage(_imageFile!)
                        : (widget.initial.profileImageUrl != null
                            ? NetworkImage(widget.initial.profileImageUrl!)
                                as ImageProvider
                            : const AssetImage('assets/default_avatar.png')),
              ),
              TextButton.icon(
                onPressed: _isLoading ? null : _pickImage,
                icon: const Icon(Icons.photo),
                label: const Text('Change Profile Picture'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Name',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _isLoading ? null : () => nameController.clear(),
                  ),
                ),
                validator:
                    (val) => val == null || val.isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: bioController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _isLoading ? null : () => bioController.clear(),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children:
                    interestsList.map((interest) {
                      final isSelected = selectedInterests.contains(interest);
                      return FilterChip(
                        label: Text(interest),
                        selected: isSelected,
                        onSelected:
                            _isLoading
                                ? null
                                : (selected) {
                                  setState(() {
                                    if (selected) {
                                      selectedInterests.add(interest);
                                    } else {
                                      selectedInterests.remove(interest);
                                    }
                                  });
                                },
                      );
                    }).toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.save),
                label: Text(_isLoading ? 'Saving...' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
