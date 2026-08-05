/// User model for DigiKhata Clone per agents.md.
/// Represents an authenticated user — Business User or Super Admin.
class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final bool isSuperAdmin;
  final bool isProfileSetupComplete;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.isSuperAdmin = false,
    this.isProfileSetupComplete = false,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: (json['email'] as String?) ?? '',
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isSuperAdmin: json['is_super_admin'] as bool? ?? false,
      isProfileSetupComplete:
          json['is_profile_setup_complete'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'is_super_admin': isSuperAdmin,
      'is_profile_setup_complete': isProfileSetupComplete,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    bool? isSuperAdmin,
    bool? isProfileSetupComplete,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isSuperAdmin: isSuperAdmin ?? this.isSuperAdmin,
      isProfileSetupComplete:
          isProfileSetupComplete ?? this.isProfileSetupComplete,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
