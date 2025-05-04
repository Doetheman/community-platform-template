import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:white_label_community_app/features/profile/data/profile_remote_data_source.dart';
import 'package:white_label_community_app/features/profile/data/profile_repository_impl.dart';
import 'package:white_label_community_app/features/profile/domain/entities/user_profile.dart';
import 'package:white_label_community_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:white_label_community_app/features/profile/domain/usecases/create_profile.dart';
import 'package:white_label_community_app/features/profile/domain/usecases/get_profile.dart';
import 'package:white_label_community_app/features/profile/domain/usecases/update_profile.dart';
import 'profile_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase Auth provider (for current UID)
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Firestore
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Data Source
final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((
  ref,
) {
  final firestore = ref.watch(firestoreProvider);
  return ProfileRemoteDataSource(firestore);
});

/// Repository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final dataSource = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(dataSource);
});

/// Use Cases
final getProfileProvider = Provider<GetProfile>((ref) {
  return GetProfile(ref.watch(profileRepositoryProvider));
});

final createProfileProvider = Provider<CreateProfile>((ref) {
  return CreateProfile(ref.watch(profileRepositoryProvider));
});

final updateProfileProvider = Provider<UpdateProfile>((ref) {
  return UpdateProfile(ref.watch(profileRepositoryProvider));
});

/// Controller
final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, UserProfile?>(
      ProfileController.new,
    );
