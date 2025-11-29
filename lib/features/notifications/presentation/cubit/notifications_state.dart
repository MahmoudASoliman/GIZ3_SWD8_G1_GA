import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';

/// Base state for notifications
abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class NotificationsInitial extends NotificationsState {}

/// Loading state
class NotificationsLoading extends NotificationsState {}

/// Loaded state with notifications list
class NotificationsLoaded extends NotificationsState {
  final List<NotificationEntity> notifications;
  final int unreadCount;

  const NotificationsLoaded({
    required this.notifications,
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];
}

/// Error state
class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Notification marked as read
class NotificationMarkedAsRead extends NotificationsState {}

/// All notifications marked as read
class AllNotificationsMarkedAsRead extends NotificationsState {}
