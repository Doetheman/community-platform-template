class UserProfile {
  final String uid;
  final String name;
  final String? bio;
  final List<String> interests;
  final String? profileImageUrl;

  const UserProfile({
    required this.uid,
    required this.name,
    this.bio,
    this.interests = const [],
    this.profileImageUrl,
  });

  static const empty = UserProfile(uid: '', name: '');
}
