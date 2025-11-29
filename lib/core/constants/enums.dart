/// User type enum
enum UserType {
  donor,
  hospital;

  String get value => name;

  static UserType fromString(String value) {
    return UserType.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => UserType.donor,
    );
  }
}

/// Blood request status
enum RequestStatus {
  pending,
  accepted,
  completed,
  cancelled;

  String get value => name;

  static RequestStatus fromString(String value) {
    return RequestStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => RequestStatus.pending,
    );
  }
}

/// Notification type
enum NotificationType {
  newRequest,
  requestAccepted,
  requestCompleted,
  thankYou,
  general;

  String get value {
    switch (this) {
      case NotificationType.newRequest:
        return 'new_request';
      case NotificationType.requestAccepted:
        return 'request_accepted';
      case NotificationType.requestCompleted:
        return 'request_completed';
      case NotificationType.thankYou:
        return 'thank_you';
      case NotificationType.general:
        return 'general';
    }
  }

  static NotificationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'new_request':
        return NotificationType.newRequest;
      case 'request_accepted':
        return NotificationType.requestAccepted;
      case 'request_completed':
        return NotificationType.requestCompleted;
      case 'thank_you':
        return NotificationType.thankYou;
      default:
        return NotificationType.general;
    }
  }
}
