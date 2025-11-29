import '../../domain/entities/user_entity.dart';
import '../../../../core/constants/enums.dart';

/// User model for API responses
class UserModel {
  final String id;
  final String email;
  final UserType userType;
  final String? fcmToken;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.userType,
    this.fcmToken,
    required this.createdAt,
  });

  /// Convert from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      userType: UserType.fromString(json['user_type'] as String),
      fcmToken: json['fcm_token'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'user_type': userType.value,
      'fcm_token': fcmToken,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convert to Entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      userType: userType,
      fcmToken: fcmToken,
      createdAt: createdAt,
    );
  }

  /// Convert from Entity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      userType: entity.userType,
      fcmToken: entity.fcmToken,
      createdAt: entity.createdAt,
    );
  }
}
