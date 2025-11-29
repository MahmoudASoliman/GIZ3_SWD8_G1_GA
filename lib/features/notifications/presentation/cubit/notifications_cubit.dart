import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import 'notifications_state.dart';

@injectable
class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository _repository;
  List<NotificationEntity> _notifications = [];

  NotificationsCubit(this._repository) : super(NotificationsInitial());

  /// Load all notifications for a user
  Future<void> loadNotifications(String userId) async {
    emit(NotificationsLoading());

    final result = await _repository.getNotifications(userId);

    result.fold((failure) => emit(NotificationsError(failure.message)), (
      notifications,
    ) {
      _notifications = notifications;
      final unreadCount = notifications.where((n) => !n.isRead).length;
      emit(
        NotificationsLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ),
      );
    });
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    final result = await _repository.markAsRead(notificationId);

    result.fold((failure) => emit(NotificationsError(failure.message)), (_) {
      // Update local list
      _notifications = _notifications.map((n) {
        if (n.id == notificationId) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();

      final unreadCount = _notifications.where((n) => !n.isRead).length;
      emit(
        NotificationsLoaded(
          notifications: _notifications,
          unreadCount: unreadCount,
        ),
      );
    });
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    final result = await _repository.markAllAsRead(userId);

    result.fold((failure) => emit(NotificationsError(failure.message)), (_) {
      // Update local list
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();

      emit(NotificationsLoaded(notifications: _notifications, unreadCount: 0));
    });
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    final result = await _repository.deleteNotification(notificationId);

    result.fold((failure) => emit(NotificationsError(failure.message)), (_) {
      // Update local list
      _notifications.removeWhere((n) => n.id == notificationId);
      final unreadCount = _notifications.where((n) => !n.isRead).length;
      emit(
        NotificationsLoaded(
          notifications: List.from(_notifications),
          unreadCount: unreadCount,
        ),
      );
    });
  }

  /// Get unread count only
  Future<void> loadUnreadCount(String userId) async {
    final result = await _repository.getUnreadCount(userId);

    result.fold(
      (failure) => null, // Silent failure for badge count
      (count) {
        if (state is NotificationsLoaded) {
          emit(
            NotificationsLoaded(
              notifications: (state as NotificationsLoaded).notifications,
              unreadCount: count,
            ),
          );
        }
      },
    );
  }
}
