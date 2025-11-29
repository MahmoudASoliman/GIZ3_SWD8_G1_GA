import 'package:equatable/equatable.dart';

/// Notification entity (domain layer)
class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type; // new_request, request_accepted, request_completed, system
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    this.isRead = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    body,
    type,
    data,
    isRead,
    createdAt,
  ];

  NotificationEntity copyWith({
    String? title,
    String? body,
    String? type,
    Map<String, dynamic>? data,
    bool? isRead,
  }) {
    return NotificationEntity(
      id: id,
      userId: userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
