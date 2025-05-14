import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:white_label_community_app/features/auth/state/auth_provider.dart';

final userRoleProvider = FutureProvider<String>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return 'guest';

  final uid = user.uid;
  final role = await ref.read(userRoleByUidProvider(uid).future);
  return role ?? 'user';
});

final userRoleByUidProvider = FutureProvider.family<String?, String>((
  ref,
  uid,
) async {
  final role = ref.read(userRemoteDataSourceProvider).getUserRole(uid);
  return role;
});
