// models/notification/notification_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/date_utils.dart';

/// Comprehensive notification model for managing app notifications
class NotificationModel {
  final String notificationId;
  final String? userId;
  final List<String> targetUserIds;
  final NotificationType type;
  final NotificationCategory category;
  final String title;
  final String titleArabic;
  final String body;
  final String bodyArabic;
  final String? imageUrl;
  final String? iconUrl;
  final NotificationPriority priority;
  final Map<String, dynamic> data;
  final List<NotificationAction> actions;
  final NotificationStatus status;
  final bool isRead;
  final bool isSent;
  final DateTime? readAt;
  final DateTime? sentAt;
  final DateTime? scheduledAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final NotificationSettings? settings;
  final Map<String, dynamic>? fcmData;
  final List<NotificationDeliveryLog> deliveryLog;
  final Map<String, dynamic>? metadata;

  NotificationModel({
    required this.notificationId,
    this.userId,
    this.targetUserIds = const [],
    required this.type,
    required this.category,
    required this.title,
    required this.titleArabic,
    required this.body,
    required this.bodyArabic,
    this.imageUrl,
    this.iconUrl,
    this.priority = NotificationPriority.normal,
    this.data = const {},
    this.actions = const [],
    this.status = NotificationStatus.pending,
    this.isRead = false,
    this.isSent = false,
    this.readAt,
    this.sentAt,
    this.scheduledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.createdBy,
    this.settings,
    this.fcmData,
    this.deliveryLog = const [],
    this.metadata,
  }) :
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // ========== Factory Constructors ==========

  /// Create from Firestore document
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    try {
      return NotificationModel(
        notificationId: Validators.validateString(json[FirebaseConstants.notificationIdField], 'Notification ID'),
        userId: json[FirebaseConstants.userIdField] as String?,
        targetUserIds: List<String>.from(json['targetUserIds'] as List<dynamic>? ?? []),
        type: NotificationType.values.firstWhere(
              (e) => e.name == json[FirebaseConstants.typeField],
          orElse: () => NotificationType.general,
        ),
        category: NotificationCategory.values.firstWhere(
              (e) => e.name == json['category'],
          orElse: () => NotificationCategory.general,
        ),
        title: Validators.validateString(json[FirebaseConstants.titleField], 'Title'),
        titleArabic: Validators.validateString(json[FirebaseConstants.titleArabicField], 'Title Arabic'),
        body: Validators.validateString(json[FirebaseConstants.bodyField], 'Body'),
        bodyArabic: Validators.validateString(json[FirebaseConstants.bodyArabicField], 'Body Arabic'),
        imageUrl: json['imageUrl'] as String?,
        iconUrl: json['iconUrl'] as String?,
        priority: NotificationPriority.values.firstWhere(
              (e) => e.name == json['priority'],
          orElse: () => NotificationPriority.normal,
        ),
        data: Map<String, dynamic>.from(json[FirebaseConstants.dataField] as Map<dynamic, dynamic>? ?? {}),
        actions: (json['actions'] as List<dynamic>?)
            ?.map((e) => NotificationAction.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
        status: NotificationStatus.values.firstWhere(
              (e) => e.name == json[FirebaseConstants.statusField],
          orElse: () => NotificationStatus.pending,
        ),
        isRead: json[FirebaseConstants.isReadField] as bool? ?? false,
        isSent: json['isSent'] as bool? ?? false,
        readAt: DateUtils.parseTimestamp(json['readAt']),
        sentAt: DateUtils.parseTimestamp(json[FirebaseConstants.sentAtField]),
        scheduledAt: DateUtils.parseTimestamp(json['scheduledAt']),
        createdAt: DateUtils.parseTimestamp(json[FirebaseConstants.createdAtField]) ?? DateTime.now(),
        updatedAt: DateUtils.parseTimestamp(json[FirebaseConstants.updatedAtField]) ?? DateTime.now(),
        createdBy: json['createdBy'] as String?,
        settings: json['settings'] != null
            ? NotificationSettings.fromJson(json['settings'] as Map<String, dynamic>)
            : null,
        fcmData: json['fcmData'] as Map<String, dynamic>?,
        deliveryLog: (json['deliveryLog'] as List<dynamic>?)
            ?.map((e) => NotificationDeliveryLog.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
        metadata: json['metadata'] as Map<String, dynamic>?,
      );
    } catch (e) {
      throw ModelParseException('Failed to parse NotificationModel: $e');
    }
  }

  /// Create new notification
  factory NotificationModel.create({
    String? userId,
    List<String>? targetUserIds,
    required NotificationType type,
    NotificationCategory? category,
    required String title,
    required String titleArabic,
    required String body,
    required String bodyArabic,
    String? imageUrl,
    String? iconUrl,
    NotificationPriority priority = NotificationPriority.normal,
    Map<String, dynamic>? data,
    List<NotificationAction>? actions,
    DateTime? scheduledAt,
    String? createdBy,
    NotificationSettings? settings,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();

    return NotificationModel(
      notificationId: '', // Will be generated by service
      userId: userId,
      targetUserIds: targetUserIds ?? [],
      type: type,
      category: category ?? _getCategoryFromType(type),
      title: title,
      titleArabic: titleArabic,
      body: body,
      bodyArabic: bodyArabic,
      imageUrl: imageUrl,
      iconUrl: iconUrl,
      priority: priority,
      data: data ?? {},
      actions: actions ?? [],
      status: scheduledAt != null ? NotificationStatus.scheduled : NotificationStatus.pending,
      scheduledAt: scheduledAt,
      createdAt: now,
      updatedAt: now,
      createdBy: createdBy,
      settings: settings,
      metadata: metadata,
    );
  }

  /// Create booking notification
  factory NotificationModel.bookingNotification({
    required String userId,
    required NotificationType type,
    required String bookingId,
    required String hallName,
    String? additionalData,
    DateTime? scheduledAt,
  }) {
    final titles = _getBookingNotificationTitles(type, hallName);
    final bodies = _getBookingNotificationBodies(type, hallName, additionalData);

    return NotificationModel.create(
      userId: userId,
      type: type,
      category: NotificationCategory.booking,
      title: titles['en']!,
      titleArabic: titles['ar']!,
      body: bodies['en']!,
      bodyArabic: bodies['ar']!,
      priority: _getBookingNotificationPriority(type),
      data: {
        'bookingId': bookingId,
        'hallName': hallName,
        'action': _getBookingNotificationAction(type),
      },
      actions: _getBookingNotificationActions(type, bookingId),
      scheduledAt: scheduledAt,
    );
  }

  /// Create payment notification
  factory NotificationModel.paymentNotification({
    required String userId,
    required NotificationType type,
    required String bookingId,
    required double amount,
    String? dueDate,
    DateTime? scheduledAt,
  }) {
    final titles = _getPaymentNotificationTitles(type);
    final bodies = _getPaymentNotificationBodies(type, amount, dueDate);

    return NotificationModel.create(
      userId: userId,
      type: type,
      category: NotificationCategory.payment,
      title: titles['en']!,
      titleArabic: titles['ar']!,
      body: bodies['en']!,
      bodyArabic: bodies['ar']!,
      priority: NotificationPriority.high,
      data: {
        'bookingId': bookingId,
        'amount': amount,
        'dueDate': dueDate,
        'action': 'make_payment',
      },
      actions: [
        NotificationAction(
          id: 'pay_now',
          title: 'Pay Now',
          titleArabic: 'ادفع الآن',
          action: 'navigate',
          data: {'route': '/payment', 'bookingId': bookingId},
        ),
      ],
      scheduledAt: scheduledAt,
    );
  }

  /// Create promotional notification
  factory NotificationModel.promotionalNotification({
    List<String>? targetUserIds,
    required String title,
    required String titleArabic,
    required String body,
    required String bodyArabic,
    String? imageUrl,
    Map<String, dynamic>? data,
    List<NotificationAction>? actions,
    DateTime? scheduledAt,
    String? createdBy,
  }) {
    return NotificationModel.create(
      targetUserIds: targetUserIds,
      type: NotificationType.promotional,
      category: NotificationCategory.marketing,
      title: title,
      titleArabic: titleArabic,
      body: body,
      bodyArabic: bodyArabic,
      imageUrl: imageUrl,
      priority: NotificationPriority.low,
      data: data ?? {},
      actions: actions ?? [],
      scheduledAt: scheduledAt,
      createdBy: createdBy,
    );
  }

  // ========== Serialization ==========

  Map<String, dynamic> toJson() {
    return {
      FirebaseConstants.notificationIdField: notificationId,
      FirebaseConstants.userIdField: userId,
      'targetUserIds': targetUserIds,
      FirebaseConstants.typeField: type.name,
      'category': category.name,
      FirebaseConstants.titleField: title,
      FirebaseConstants.titleArabicField: titleArabic,
      FirebaseConstants.bodyField: body,
      FirebaseConstants.bodyArabicField: bodyArabic,
      'imageUrl': imageUrl,
      'iconUrl': iconUrl,
      'priority': priority.name,
      FirebaseConstants.dataField: data,
      'actions': actions.map((a) => a.toJson()).toList(),
      FirebaseConstants.statusField: status.name,
      FirebaseConstants.isReadField: isRead,
      'isSent': isSent,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      FirebaseConstants.sentAtField: sentAt != null ? Timestamp.fromDate(sentAt!) : null,
      'scheduledAt': scheduledAt != null ? Timestamp.fromDate(scheduledAt!) : null,
      FirebaseConstants.createdAtField: FieldValue.serverTimestamp(),
      FirebaseConstants.updatedAtField: FieldValue.serverTimestamp(),
      'createdBy': createdBy,
      'settings': settings?.toJson(),
      'fcmData': fcmData,
      'deliveryLog': deliveryLog.map((d) => d.toJson()).toList(),
      'metadata': metadata,
    };
  }

  // ========== Business Logic Methods ==========

  /// Check if notification is pending
  bool isPending() => status == NotificationStatus.pending;

  /// Check if notification is scheduled
  bool isScheduled() => status == NotificationStatus.scheduled;

  /// Check if notification is sent
  bool isNotificationSent() => isSent && status == NotificationStatus.sent;

  /// Check if notification is failed
  bool isFailed() => status == NotificationStatus.failed;

  /// Check if notification is cancelled
  bool isCancelled() => status == NotificationStatus.cancelled;

  /// Check if notification is expired
  bool isExpired() {
    if (scheduledAt == null) return false;
    return DateTime.now().isAfter(scheduledAt!.add(const Duration(days: 7)));
  }

  /// Check if notification should be sent now
  bool shouldBeSentNow() {
    if (isSent || status != NotificationStatus.scheduled) return false;
    if (scheduledAt == null) return true;
    return DateTime.now().isAfter(scheduledAt!);
  }

  /// Check if notification can be cancelled
  bool canBeCancelled() {
    return !isSent && (status == NotificationStatus.pending || status == NotificationStatus.scheduled);
  }

  /// Check if notification can be rescheduled
  bool canBeRescheduled() {
    return status == NotificationStatus.scheduled && !isSent;
  }

  /// Check if notification is targeted to specific user
  bool isTargetedToUser(String userId) {
    return this.userId == userId || targetUserIds.contains(userId);
  }

  /// Check if notification is bulk notification
  bool isBulkNotification() {
    return targetUserIds.isNotEmpty;
  }

  /// Get localized title
  String getLocalizedTitle(String languageCode) {
    return languageCode == 'ar' ? titleArabic : title;
  }

  /// Get localized body
  String getLocalizedBody(String languageCode) {
    return languageCode == 'ar' ? bodyArabic : body;
  }

  /// Get notification age in minutes
  int getAgeInMinutes() {
    return DateTime.now().difference(createdAt).inMinutes;
  }

  /// Get time until scheduled delivery
  Duration? getTimeUntilDelivery() {
    if (scheduledAt == null) return null;
    final now = DateTime.now();
    return scheduledAt!.isAfter(now) ? scheduledAt!.difference(now) : null;
  }

  /// Get priority display text
  String getPriorityDisplayText(String languageCode) {
    final priorityTranslations = {
      'low': {'en': 'Low', 'ar': 'منخفض'},
      'normal': {'en': 'Normal', 'ar': 'عادي'},
      'high': {'en': 'High', 'ar': 'عالي'},
      'urgent': {'en': 'Urgent', 'ar': 'عاجل'},
    };

    return priorityTranslations[priority.name]?[languageCode] ?? priority.name;
  }

  /// Get status display text
  String getStatusDisplayText(String languageCode) {
    final statusTranslations = {
      'pending': {'en': 'Pending', 'ar': 'في الانتظار'},
      'scheduled': {'en': 'Scheduled', 'ar': 'مجدول'},
      'sent': {'en': 'Sent', 'ar': 'مُرسل'},
      'delivered': {'en': 'Delivered', 'ar': 'تم التسليم'},
      'read': {'en': 'Read', 'ar': 'مقروء'},
      'failed': {'en': 'Failed', 'ar': 'فشل'},
      'cancelled': {'en': 'Cancelled', 'ar': 'ملغي'},
    };

    return statusTranslations[status.name]?[languageCode] ?? status.name;
  }

  /// Get formatted delivery time
  String getFormattedDeliveryTime(String languageCode) {
    final deliveryTime = sentAt ?? createdAt;
    return DateUtils.formatDateTime(deliveryTime, languageCode: languageCode);
  }

  /// Get delivery success rate
  double getDeliverySuccessRate() {
    if (deliveryLog.isEmpty) return 0.0;
    final successfulDeliveries = deliveryLog.where((log) => log.isSuccessful).length;
    return successfulDeliveries / deliveryLog.length;
  }

  // ========== Update Methods ==========

  /// Mark as read
  NotificationModel markAsRead({String? readBy}) {
    final now = DateTime.now();
    return copyWith(
      isRead: true,
      readAt: now,
      status: NotificationStatus.read,
      updatedAt: now,
    );
  }

  /// Mark as sent
  NotificationModel markAsSent({Map<String, dynamic>? fcmResponse}) {
    final now = DateTime.now();
    final newLog = List<NotificationDeliveryLog>.from(deliveryLog)
      ..add(NotificationDeliveryLog(
        timestamp: now,
        platform: 'fcm',
        isSuccessful: true,
        response: fcmResponse,
      ));

    return copyWith(
      isSent: true,
      sentAt: now,
      status: NotificationStatus.sent,
      fcmData: fcmResponse,
      deliveryLog: newLog,
      updatedAt: now,
    );
  }

  /// Mark as delivered
  NotificationModel markAsDelivered({Map<String, dynamic>? deliveryResponse}) {
    final now = DateTime.now();
    final newLog = List<NotificationDeliveryLog>.from(deliveryLog)
      ..add(NotificationDeliveryLog(
        timestamp: now,
        platform: 'fcm',
        isSuccessful: true,
        isDelivered: true,
        response: deliveryResponse,
      ));

    return copyWith(
      status: NotificationStatus.delivered,
      deliveryLog: newLog,
      updatedAt: now,
    );
  }

  /// Mark as failed
  NotificationModel markAsFailed({
    required String reason,
    Map<String, dynamic>? errorData,
  }) {
    final now = DateTime.now();
    final newLog = List<NotificationDeliveryLog>.from(deliveryLog)
      ..add(NotificationDeliveryLog(
        timestamp: now,
        platform: 'fcm',
        isSuccessful: false,
        errorMessage: reason,
        response: errorData,
      ));

    return copyWith(
      status: NotificationStatus.failed,
      deliveryLog: newLog,
      updatedAt: now,
    );
  }

  /// Cancel notification
  NotificationModel cancel({String? reason}) {
    return copyWith(
      status: NotificationStatus.cancelled,
      updatedAt: DateTime.now(),
      metadata: {
        ...?metadata,
        'cancellationReason': reason,
        'cancelledAt': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Reschedule notification
  NotificationModel reschedule(DateTime newScheduledAt) {
    return copyWith(
      scheduledAt: newScheduledAt,
      status: NotificationStatus.scheduled,
      updatedAt: DateTime.now(),
    );
  }

  /// Update content
  NotificationModel updateContent({
    String? newTitle,
    String? newTitleArabic,
    String? newBody,
    String? newBodyArabic,
    String? newImageUrl,
    Map<String, dynamic>? newData,
    List<NotificationAction>? newActions,
  }) {
    return copyWith(
      title: newTitle ?? title,
      titleArabic: newTitleArabic ?? titleArabic,
      body: newBody ?? body,
      bodyArabic: newBodyArabic ?? bodyArabic,
      imageUrl: newImageUrl ?? imageUrl,
      data: newData ?? data,
      actions: newActions ?? actions,
      updatedAt: DateTime.now(),
    );
  }

  // ========== Copy With ==========

  NotificationModel copyWith({
    String? notificationId,
    String? userId,
    List<String>? targetUserIds,
    NotificationType? type,
    NotificationCategory? category,
    String? title,
    String? titleArabic,
    String? body,
    String? bodyArabic,
    String? imageUrl,
    String? iconUrl,
    NotificationPriority? priority,
    Map<String, dynamic>? data,
    List<NotificationAction>? actions,
    NotificationStatus? status,
    bool? isRead,
    bool? isSent,
    DateTime? readAt,
    DateTime? sentAt,
    DateTime? scheduledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    NotificationSettings? settings,
    Map<String, dynamic>? fcmData,
    List<NotificationDeliveryLog>? deliveryLog,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      targetUserIds: targetUserIds ?? this.targetUserIds,
      type: type ?? this.type,
      category: category ?? this.category,
      title: title ?? this.title,
      titleArabic: titleArabic ?? this.titleArabic,
      body: body ?? this.body,
      bodyArabic: bodyArabic ?? this.bodyArabic,
      imageUrl: imageUrl ?? this.imageUrl,
      iconUrl: iconUrl ?? this.iconUrl,
      priority: priority ?? this.priority,
      data: data ?? this.data,
      actions: actions ?? this.actions,
      status: status ?? this.status,
      isRead: isRead ?? this.isRead,
      isSent: isSent ?? this.isSent,
      readAt: readAt ?? this.readAt,
      sentAt: sentAt ?? this.sentAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      settings: settings ?? this.settings,
      fcmData: fcmData ?? this.fcmData,
      deliveryLog: deliveryLog ?? this.deliveryLog,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.notificationId == notificationId;
  }

  @override
  int get hashCode => notificationId.hashCode;

  @override
  String toString() => 'NotificationModel(id: $notificationId, type: $type, status: $status)';

  // ========== Private Helper Methods ==========

  static NotificationCategory _getCategoryFromType(NotificationType type) {
    switch (type) {
      case NotificationType.bookingConfirmed:
      case NotificationType.bookingCancelled:
      case NotificationType.bookingUpdated:
        return NotificationCategory.booking;
      case NotificationType.paymentReminder:
      case NotificationType.paymentReceived:
      case NotificationType.paymentFailed:
        return NotificationCategory.payment;
      case NotificationType.promotional:
        return NotificationCategory.marketing;
      case NotificationType.systemUpdate:
      case NotificationType.maintenance:
        return NotificationCategory.system;
      default:
        return NotificationCategory.general;
    }
  }

  static Map<String, String> _getBookingNotificationTitles(NotificationType type, String hallName) {
    switch (type) {
      case NotificationType.bookingConfirmed:
        return {
          'en': 'Booking Confirmed',
          'ar': 'تم تأكيد الحجز',
        };
      case NotificationType.bookingCancelled:
        return {
          'en': 'Booking Cancelled',
          'ar': 'تم إلغاء الحجز',
        };
      case NotificationType.bookingUpdated:
        return {
          'en': 'Booking Updated',
          'ar': 'تم تحديث الحجز',
        };
      default:
        return {
          'en': 'Booking Notification',
          'ar': 'إشعار الحجز',
        };
    }
  }

  static Map<String, String> _getBookingNotificationBodies(NotificationType type, String hallName, String? additionalData) {
    switch (type) {
      case NotificationType.bookingConfirmed:
        return {
          'en': 'Your booking for $hallName has been confirmed.',
          'ar': 'تم تأكيد حجزك لـ $hallName.',
        };
      case NotificationType.bookingCancelled:
        return {
          'en': 'Your booking for $hallName has been cancelled.',
          'ar': 'تم إلغاء حجزك لـ $hallName.',
        };
      case NotificationType.bookingUpdated:
        return {
          'en': 'Your booking for $hallName has been updated. ${additionalData ?? ''}',
          'ar': 'تم تحديث حجزك لـ $hallName. ${additionalData ?? ''}',
        };
      default:
        return {
          'en': 'Booking notification for $hallName',
          'ar': 'إشعار حجز لـ $hallName',
        };
    }
  }

  static NotificationPriority _getBookingNotificationPriority(NotificationType type) {
    switch (type) {
      case NotificationType.bookingConfirmed:
        return NotificationPriority.high;
      case NotificationType.bookingCancelled:
        return NotificationPriority.urgent;
      default:
        return NotificationPriority.normal;
    }
  }

  static String _getBookingNotificationAction(NotificationType type) {
    switch (type) {
      case NotificationType.bookingConfirmed:
        return 'view_booking';
      case NotificationType.bookingCancelled:
        return 'view_booking';
      case NotificationType.bookingUpdated:
        return 'view_booking';
      default:
        return 'view_booking';
    }
  }

  static List<NotificationAction> _getBookingNotificationActions(NotificationType type, String bookingId) {
    switch (type) {
      case NotificationType.bookingConfirmed:
        return [
          NotificationAction(
            id: 'view_details',
            title: 'View Details',
            titleArabic: 'عرض التفاصيل',
            action: 'navigate',
            data: {'route': '/booking-details', 'bookingId': bookingId},
          ),
        ];
      case NotificationType.bookingCancelled:
        return [
          NotificationAction(
            id: 'view_details',
            title: 'View Details',
            titleArabic: 'عرض التفاصيل',
            action: 'navigate',
            data: {'route': '/booking-details', 'bookingId': bookingId},
          ),
          NotificationAction(
            id: 'book_again',
            title: 'Book Again',
            titleArabic: 'احجز مرة أخرى',
            action: 'navigate',
            data: {'route': '/halls'},
          ),
        ];
      default:
        return [];
    }
  }

  static Map<String, String> _getPaymentNotificationTitles(NotificationType type) {
    switch (type) {
      case NotificationType.paymentReminder:
        return {
          'en': 'Payment Reminder',
          'ar': 'تذكير بالدفع',
        };
      case NotificationType.paymentReceived:
        return {
          'en': 'Payment Received',
          'ar': 'تم استلام الدفعة',
        };
      case NotificationType.paymentFailed:
        return {
          'en': 'Payment Failed',
          'ar': 'فشل في الدفع',
        };
      default:
        return {
          'en': 'Payment Notification',
          'ar': 'إشعار الدفع',
        };
    }
  }

  static Map<String, String> _getPaymentNotificationBodies(NotificationType type, double amount, String? dueDate) {
    final formattedAmount = '${amount.toStringAsFixed(3)} ${AppConstants.currencySymbol}';

    switch (type) {
      case NotificationType.paymentReminder:
        return {
          'en': 'Payment of $formattedAmount is due${dueDate != null ? ' on $dueDate' : ''}.',
          'ar': 'دفعة بقيمة $formattedAmount مستحقة${dueDate != null ? ' في $dueDate' : ''}.',
        };
      case NotificationType.paymentReceived:
        return {
          'en': 'We have received your payment of $formattedAmount.',
          'ar': 'تم استلام دفعتك بقيمة $formattedAmount.',
        };
      case NotificationType.paymentFailed:
        return {
          'en': 'Your payment of $formattedAmount could not be processed.',
          'ar': 'لم يتم معالجة دفعتك بقيمة $formattedAmount.',
        };
      default:
        return {
          'en': 'Payment notification for $formattedAmount',
          'ar': 'إشعار دفع لـ $formattedAmount',
        };
    }
  }
}

// ========== Supporting Enums ==========

/// Notification type enum
enum NotificationType {
  general,
  bookingConfirmed,
  bookingCancelled,
  bookingUpdated,
  bookingReminder,
  paymentReminder,
  paymentReceived,
  paymentFailed,
  reviewRequest,
  promotional,
  systemUpdate,
  maintenance,
  newMessage,
  accountUpdate,
}

/// Notification category enum
enum NotificationCategory {
  general,
  booking,
  payment,
  marketing,
  system,
  social,
  account,
}

/// Notification priority enum
enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

/// Notification status enum
enum NotificationStatus {
  pending,
  scheduled,
  sent,
  delivered,
  read,
  failed,
  cancelled,
}

// ========== Supporting Models ==========

/// Notification action for interactive notifications
class NotificationAction {
  final String id;
  final String title;
  final String titleArabic;
  final String action; // navigate, call_api, share, etc.
  final Map<String, dynamic> data;
  final bool destructive;

  NotificationAction({
    required this.id,
    required this.title,
    required this.titleArabic,
    required this.action,
    this.data = const {},
    this.destructive = false,
  });

  factory NotificationAction.fromJson(Map<String, dynamic> json) {
    return NotificationAction(
      id: json['id'] as String,
      title: json['title'] as String,
      titleArabic: json['titleArabic'] as String,
      action: json['action'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map<dynamic, dynamic>? ?? {}),
      destructive: json['destructive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'titleArabic': titleArabic,
      'action': action,
      'data': data,
      'destructive': destructive,
    };
  }

  /// Get localized title
  String getLocalizedTitle(String languageCode) {
    return languageCode == 'ar' ? titleArabic : title;
  }
}

/// Notification settings for user preferences
class NotificationSettings {
  final bool enablePush;
  final bool enableEmail;
  final bool enableSMS;
  final Map<NotificationType, bool> typePreferences;
  final Map<NotificationPriority, bool> priorityPreferences;
  final TimeOfDay? quietHoursStart;
  final TimeOfDay? quietHoursEnd;
  final bool respectQuietHours;

  NotificationSettings({
    this.enablePush = true,
    this.enableEmail = true,
    this.enableSMS = false,
    this.typePreferences = const {},
    this.priorityPreferences = const {},
    this.quietHoursStart,
    this.quietHoursEnd,
    this.respectQuietHours = true,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enablePush: json['enablePush'] as bool? ?? true,
      enableEmail: json['enableEmail'] as bool? ?? true,
      enableSMS: json['enableSMS'] as bool? ?? false,
      typePreferences: Map<NotificationType, bool>.fromEntries(
        (json['typePreferences'] as Map<String, dynamic>? ?? {}).entries.map(
              (e) => MapEntry(
            NotificationType.values.firstWhere((t) => t.name == e.key),
            e.value as bool,
          ),
        ),
      ),
      priorityPreferences: Map<NotificationPriority, bool>.fromEntries(
        (json['priorityPreferences'] as Map<String, dynamic>? ?? {}).entries.map(
              (e) => MapEntry(
            NotificationPriority.values.firstWhere((p) => p.name == e.key),
            e.value as bool,
          ),
        ),
      ),
      quietHoursStart: json['quietHoursStart'] != null
          ? TimeOfDay.fromDateTime(DateTime.parse(json['quietHoursStart']))
          : null,
      quietHoursEnd: json['quietHoursEnd'] != null
          ? TimeOfDay.fromDateTime(DateTime.parse(json['quietHoursEnd']))
          : null,
      respectQuietHours: json['respectQuietHours'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enablePush': enablePush,
      'enableEmail': enableEmail,
      'enableSMS': enableSMS,
      'typePreferences': typePreferences.map((k, v) => MapEntry(k.name, v)),
      'priorityPreferences': priorityPreferences.map((k, v) => MapEntry(k.name, v)),
      'quietHoursStart': quietHoursStart?.toString(),
      'quietHoursEnd': quietHoursEnd?.toString(),
      'respectQuietHours': respectQuietHours,
    };
  }

  /// Check if notification type is enabled
  bool isTypeEnabled(NotificationType type) {
    return typePreferences[type] ?? true;
  }

  /// Check if priority is enabled
  bool isPriorityEnabled(NotificationPriority priority) {
    return priorityPreferences[priority] ?? true;
  }

  /// Check if notification should be sent during quiet hours
  bool shouldSendDuringQuietHours(NotificationPriority priority) {
    if (!respectQuietHours) return true;
    if (priority == NotificationPriority.urgent) return true;
    return false;
  }
}

/// Notification delivery log for tracking
class NotificationDeliveryLog {
  final DateTime timestamp;
  final String platform; // fcm, email, sms
  final bool isSuccessful;
  final bool isDelivered;
  final String? errorMessage;
  final Map<String, dynamic>? response;

  NotificationDeliveryLog({
    required this.timestamp,
    required this.platform,
    required this.isSuccessful,
    this.isDelivered = false,
    this.errorMessage,
    this.response,
  });

  factory NotificationDeliveryLog.fromJson(Map<String, dynamic> json) {
    return NotificationDeliveryLog(
      timestamp: DateUtils.parseTimestamp(json['timestamp']) ?? DateTime.now(),
      platform: json['platform'] as String,
      isSuccessful: json['isSuccessful'] as bool,
      isDelivered: json['isDelivered'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
      response: json['response'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': Timestamp.fromDate(timestamp),
      'platform': platform,
      'isSuccessful': isSuccessful,
      'isDelivered': isDelivered,
      'errorMessage': errorMessage,
      'response': response,
    };
  }
}

/// Time of day helper class
class TimeOfDay {
  final int hour;
  final int minute;

  TimeOfDay({required this.hour, required this.minute});

  factory TimeOfDay.fromDateTime(DateTime dateTime) {
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  @override
  String toString() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

/// Custom exception for notification model parsing errors
class ModelParseException implements Exception {
  final String message;
  ModelParseException(this.message);

  @override
  String toString() => 'ModelParseException: $message';
}