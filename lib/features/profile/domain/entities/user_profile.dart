class UserProfile {
  final String uid;
  final String name;
  final String? bio;
  final List<String> interests;
  final String? profileImageUrl;
  final String? coverImageUrl;
  final Map<String, dynamic> customFields;
  final List<String> badges;
  final Map<String, List<String>> categories;
  final String? location;
  final Map<String, String> socialLinks;

  const UserProfile({
    required this.uid,
    required this.name,
    this.bio,
    this.interests = const [],
    this.profileImageUrl,
    this.coverImageUrl,
    this.customFields = const {},
    this.badges = const [],
    this.categories = const {},
    this.location,
    this.socialLinks = const {},
  });

  UserProfile copyWith({
    String? uid,
    String? name,
    String? bio,
    List<String>? interests,
    String? profileImageUrl,
    String? coverImageUrl,
    Map<String, dynamic>? customFields,
    List<String>? badges,
    Map<String, List<String>>? categories,
    String? location,
    Map<String, String>? socialLinks,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      customFields: customFields ?? this.customFields,
      badges: badges ?? this.badges,
      categories: categories ?? this.categories,
      location: location ?? this.location,
      socialLinks: socialLinks ?? this.socialLinks,
    );
  }

  static const empty = UserProfile(uid: '', name: '');
}
