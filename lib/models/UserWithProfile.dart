import 'User.dart';
import 'Image.dart';

/// Model class for handling user data with profile picture
class UserWithProfile {
  final User user;
  final Image? profilePic;

  UserWithProfile({
    required this.user,
    this.profilePic,
  });

  /// Create UserWithProfile from JSON
  factory UserWithProfile.fromJson(Map<String, dynamic> json) {
    return UserWithProfile(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      profilePic: json['profile_pic'] != null
          ? Image.fromJson({
              'contentType': json['profile_pic']['content_type'] as String,
              'base64': json['profile_pic']['base64'] as String,
            })
          : null,
    );
  }

  /// Convert UserWithProfile to JSON
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      if (profilePic != null)
        'profile_pic': {
          'base64': profilePic!.base64,
          'content_type': profilePic!.contentType, // Changed from 'content-type' to 'content_type'
        },
    };
  }

  /// Create a copy with updated fields
  UserWithProfile copyWith({
    User? user,
    Image? profilePic,
  }) {
    return UserWithProfile(
      user: user ?? this.user,
      profilePic: profilePic ?? this.profilePic,
    );
  }

  @override
  String toString() {
    return 'UserWithProfile(user: ${user.username}, hasProfilePic: ${profilePic != null})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserWithProfile &&
        other.user == user &&
        other.profilePic == profilePic;
  }

  @override
  int get hashCode => user.hashCode ^ profilePic.hashCode;
}
