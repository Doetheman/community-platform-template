import 'package:white_label_community_app/features/profile/domain/entities/user_profile.dart';

class ProfileModel {
  final String uid;
  final String name;
  final String? bio;
  final List<String> interests;
  final String? profileImageUrl;

  const ProfileModel({
    required this.uid,
    required this.name,
    this.bio,
    required this.interests,
    this.profileImageUrl,
  });

  factory ProfileModel.fromEntity(UserProfile profile) => ProfileModel(
    uid: profile.uid,
    name: profile.name,
    bio: profile.bio,
    interests: profile.interests,
    profileImageUrl: profile.profileImageUrl,
  );

  UserProfile toEntity() => UserProfile(
    uid: uid,
    name: name,
    bio: bio,
    interests: interests,
    profileImageUrl: profileImageUrl,
  );

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    uid: json['uid'] as String,
    name: json['name'] ?? '',
    bio: json['bio'],
    interests: List<String>.from(json['interests'] ?? []),
    profileImageUrl: json['profileImageUrl'],
  );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'bio': bio,
    'interests': interests,
    'profileImageUrl': profileImageUrl,
  };
}
