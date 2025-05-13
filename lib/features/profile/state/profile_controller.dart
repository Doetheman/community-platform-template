import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_label_community_app/features/profile/domain/entities/user_profile.dart';
import 'package:white_label_community_app/features/profile/domain/usecases/get_profile.dart';
import 'package:white_label_community_app/features/profile/domain/usecases/create_profile.dart';
import 'package:white_label_community_app/features/profile/domain/usecases/update_profile.dart';
import 'profile_provider.dart';

class ProfileController extends AsyncNotifier<UserProfile?> {
  late final GetProfile _getProfile;
  late final CreateProfile _createProfile;
  late final UpdateProfile _updateProfile;

  @override
  FutureOr<UserProfile?> build() async {
    _getProfile = ref.read(getProfileProvider);
    _createProfile = ref.read(createProfileProvider);
    _updateProfile = ref.read(updateProfileProvider);

    // Load initial profile for current user
    final auth = ref.read(firebaseAuthProvider);
    final uid = auth.currentUser?.uid;
    if (uid == null) return null;

    // Try to get existing profile
    final profile = await _getProfile(uid);

    // If no profile exists, create one
    if (profile == null) {
      final user = auth.currentUser!;
      final newProfile = UserProfile(
        uid: user.uid,
        name: user.email?.split('@')[0] ?? 'User',
        interests: [],
      );
      await _createProfile(newProfile);
      return newProfile;
    }

    return profile;
  }

  Future<void> refreshProfile() async {
    final uid = ref.read(firebaseAuthProvider).currentUser?.uid;
    if (uid == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _getProfile(uid));
  }

  Future<void> create(UserProfile profile) async {
    await _createProfile(profile);
    await refreshProfile();
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _updateProfile(profile);
    await refreshProfile();
  }
}
