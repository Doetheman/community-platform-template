import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfile {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  Future<void> call(UserProfile profile) => repository.updateProfile(profile);
}
