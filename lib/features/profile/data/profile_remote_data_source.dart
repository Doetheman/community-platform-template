import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:white_label_community_app/features/profile/data/profile_model.dart';

class ProfileRemoteDataSource {
  final FirebaseFirestore firestore;

  ProfileRemoteDataSource(this.firestore);

  Future<ProfileModel?> getProfile(String uid) async {
    final doc = await firestore.collection('profiles').doc(uid).get();
    if (!doc.exists) return null;
    return ProfileModel.fromJson(doc.data()!);
  }

  Future<void> createProfile(ProfileModel model) async {
    await firestore.collection('profiles').doc(model.uid).set(model.toJson());
  }

  Future<void> updateProfile(ProfileModel model) async {
    await firestore
        .collection('profiles')
        .doc(model.uid)
        .update(model.toJson());
  }

  Future<List<ProfileModel>> getAllProfiles() async {
    final query = await firestore.collection('profiles').get();
    return query.docs.map((doc) => ProfileModel.fromJson(doc.data())).toList();
  }
}
