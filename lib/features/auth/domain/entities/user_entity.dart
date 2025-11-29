import 'package:equatable/equatable.dart';
import '../../../../core/constants/enums.dart';

/// User entity (domain layer)
class UserEntity extends Equatable {
  final String id;
  final String email;
  final UserType userType;
  final String? fcmToken;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.userType,
    this.fcmToken,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, userType, fcmToken, createdAt];
}
