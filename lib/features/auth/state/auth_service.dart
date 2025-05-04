import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_label_community_app/features/profile/data/profile_model.dart';
import 'package:white_label_community_app/features/profile/data/profile_remote_data_source.dart';

final userRoleProvider = FutureProvider<String>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return 'guest';

  final doc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  return doc.data()?['role'] ?? 'user';
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProfileRemoteDataSource _profileDataSource;

  AuthService()
    : _profileDataSource = ProfileRemoteDataSource(FirebaseFirestore.instance);

  Future<void> _ensureProfileExists(User user) async {
    final profile = await _profileDataSource.getProfile(user.uid);
    if (profile == null) {
      final newProfile = ProfileModel(
        uid: user.uid,
        name:
            user.email?.split('@')[0] ??
            'User', // Use part of email as initial name
        interests: [],
      );
      await _profileDataSource.createProfile(newProfile);
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Check if profile exists, if not create one
    await _ensureProfileExists(result.user!);

    return result.user;
  }

  Future<User?> registerWithEmail(
    String email,
    String password, {
    String role = 'user',
  }) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = result.user!.uid;

    // Create user document
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Create initial profile
    await _ensureProfileExists(result.user!);

    return result.user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges =>
      _auth.authStateChanges().asyncMap((user) async {
        if (user != null) {
          await _ensureProfileExists(user);
        }
        return user;
      });
}
