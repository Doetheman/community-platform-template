import 'package:white_label_community_app/features/profile/domain/entities/user_profile.dart';

class ProfileModel {
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

  const ProfileModel({
    required this.uid,
    required this.name,
    this.bio,
    required this.interests,
    this.profileImageUrl,
    this.coverImageUrl,
    this.customFields = const {},
    this.badges = const [],
    this.categories = const {},
    this.location,
    this.socialLinks = const {},
  });

  factory ProfileModel.fromEntity(UserProfile profile) => ProfileModel(
    uid: profile.uid,
    name: profile.name,
    bio: profile.bio,
    interests: profile.interests,
    profileImageUrl: profile.profileImageUrl,
    coverImageUrl: profile.coverImageUrl,
    customFields: profile.customFields,
    badges: profile.badges,
    categories: profile.categories,
    location: profile.location,
    socialLinks: profile.socialLinks,
  );

  UserProfile toEntity() => UserProfile(
    uid: uid,
    name: name,
    bio: bio,
    interests: interests,
    profileImageUrl: profileImageUrl,
    coverImageUrl: coverImageUrl,
    customFields: customFields,
    badges: badges,
    categories: categories,
    location: location,
    socialLinks: socialLinks,
  );

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    uid: json['uid'] as String,
    name: json['name'] ?? '',
    bio: json['bio'],
    interests: List<String>.from(json['interests'] ?? []),
    profileImageUrl: json['profileImageUrl'],
    coverImageUrl: json['coverImageUrl'],
    customFields: Map<String, dynamic>.from(json['customFields'] ?? {}),
    badges: List<String>.from(json['badges'] ?? []),
    categories:
        (json['categories'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ) ??
        {},
    location: json['location'],
    socialLinks:
        (json['socialLinks'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, value.toString()),
        ) ??
        {},
  );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'bio': bio,
    'interests': interests,
    'profileImageUrl': profileImageUrl,
    'coverImageUrl': coverImageUrl,
    'customFields': customFields,
    'badges': badges,
    'categories': categories,
    'location': location,
    'socialLinks': socialLinks,
  };
}
