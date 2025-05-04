import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class CreateProfile {
  final ProfileRepository repository;

  CreateProfile(this.repository);

  Future<void> call(UserProfile profile) => repository.createProfile(profile);
}
