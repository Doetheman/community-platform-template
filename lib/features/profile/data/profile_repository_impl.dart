import 'package:white_label_community_app/features/profile/domain/entities/user_profile.dart';
import 'package:white_label_community_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:white_label_community_app/features/profile/data/profile_model.dart';
import 'package:white_label_community_app/features/profile/data/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserProfile?> getProfile(String uid) async {
    final model = await remoteDataSource.getProfile(uid);
    return model?.toEntity();
  }

  @override
  Future<void> createProfile(UserProfile profile) async {
    final model = ProfileModel.fromEntity(profile);
    await remoteDataSource.createProfile(model);
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    final model = ProfileModel.fromEntity(profile);
    await remoteDataSource.updateProfile(model);
  }

  @override
  Future<List<UserProfile>> getAllProfiles() async {
    final models = await remoteDataSource.getAllProfiles();
    return models.map((m) => m.toEntity()).toList();
  }
}
