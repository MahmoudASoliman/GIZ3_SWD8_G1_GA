import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart' as app_exceptions;
import '../models/notification_model.dart';

/// Remote data source for notifications
abstract class NotificationsRemoteDataSource {
  /// Get all notifications for a user
  Future<List<NotificationModel>> getNotifications(String userId);

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId);

  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId);

  /// Delete a notification
  Future<void> deleteNotification(String notificationId);

  /// Get unread notifications count
  Future<int> getUnreadCount(String userId);
}

@LazySingleton(as: NotificationsRemoteDataSource)
class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  final SupabaseClient _supabase;

  NotificationsRemoteDataSourceImpl(this._supabase);

  @override
  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final data = await _supabase
          .from(ApiConstants.notificationsTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (data as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw app_exceptions.ServerException(
        'Failed to get notifications: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from(ApiConstants.notificationsTable)
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      throw app_exceptions.ServerException(
        'Failed to mark notification as read: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      await _supabase
          .from(ApiConstants.notificationsTable)
          .update({'is_read': true})
          .eq('user_id', userId);
    } catch (e) {
      throw app_exceptions.ServerException(
        'Failed to mark all notifications as read: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from(ApiConstants.notificationsTable)
          .delete()
          .eq('id', notificationId);
    } catch (e) {
      throw app_exceptions.ServerException(
        'Failed to delete notification: ${e.toString()}',
      );
    }
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    try {
      final result = await _supabase
          .from(ApiConstants.notificationsTable)
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);

      return (result as List).length;
    } catch (e) {
      throw app_exceptions.ServerException(
        'Failed to get unread count: ${e.toString()}',
      );
    }
  }
}
