import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile?> getProfile(String uid);
  Future<void> createProfile(UserProfile profile);
  Future<void> updateProfile(UserProfile profile);
  Future<List<UserProfile>> getAllProfiles();
}
