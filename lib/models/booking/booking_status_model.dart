// models/booking/booking_status_model.dart

import 'package:flutter/material.dart';

/// Enhanced booking status with display properties and business logic
class BookingStatusInfo {
  final BookingStatus status;
  final String displayName;
  final String displayNameArabic;
  final String description;
  final String descriptionArabic;
  final Color color;
  final IconData icon;
  final bool isActive;
  final bool isCompleted;
  final bool isCancellable;
  final bool isModifiable;
  final int order;

  const BookingStatusInfo({
    required this.status,
    required this.displayName,
    required this.displayNameArabic,
    required this.description,
    required this.descriptionArabic,
    required this.color,
    required this.icon,
    required this.isActive,
    required this.isCompleted,
    required this.isCancellable,
    required this.isModifiable,
    required this.order,
  });

  /// Get localized display name
  String getDisplayName(String languageCode) {
    return languageCode == 'ar' ? displayNameArabic : displayName;
  }

  /// Get localized description
  String getDescription(String languageCode) {
    return languageCode == 'ar' ? descriptionArabic : description;
  }

  /// Check if status allows certain actions
  bool allowsAction(BookingAction action) {
    switch (action) {
      case BookingAction.cancel:
        return isCancellable;
      case BookingAction.modify:
        return isModifiable;
      case BookingAction.pay:
        return status == BookingStatus.confirmed || status == BookingStatus.paymentPending;
      case BookingAction.review:
        return status == BookingStatus.completed;
      case BookingAction.contact:
        return isActive;
    }
  }
}

/// Booking actions enum
enum BookingAction {
  cancel,
  modify,
  pay,
  review,
  contact,
}

/// Extended booking status enum with all possible states
enum BookingStatus {
  pending,
  confirmed,
  paymentPending,
  completed,
  cancelled,
  expired,
  refunded,
}

/// Extended payment status enum
enum PaymentStatus {
  pending,
  firstPaid,
  fullyPaid,
  failed,
  refunded,
  expired,
}

/// Owner approval status enum
enum ApprovalStatus {
  pending,
  approved,
  rejected,
  expired,
}

/// Booking status registry with all status information
class BookingStatusRegistry {
  static const Map<BookingStatus, BookingStatusInfo> _statusInfo = {
    BookingStatus.pending: BookingStatusInfo(
      status: BookingStatus.pending,
      displayName: 'Pending Approval',
      displayNameArabic: 'في انتظار الموافقة',
      description: 'Your booking request is pending hall owner approval',
      descriptionArabic: 'طلب الحجز في انتظار موافقة صاحب القاعة',
      color: Colors.orange,
      icon: Icons.hourglass_empty,
      isActive: true,
      isCompleted: false,
      isCancellable: true,
      isModifiable: true,
      order: 1,
    ),
    BookingStatus.confirmed: BookingStatusInfo(
      status: BookingStatus.confirmed,
      displayName: 'Confirmed',
      displayNameArabic: 'مؤكد',
      description: 'Your booking has been confirmed',
      descriptionArabic: 'تم تأكيد حجزك',
      color: Colors.green,
      icon: Icons.check_circle,
      isActive: true,
      isCompleted: false,
      isCancellable: true,
      isModifiable: false,
      order: 2,
    ),
    BookingStatus.paymentPending: BookingStatusInfo(
      status: BookingStatus.paymentPending,
      displayName: 'Payment Pending',
      displayNameArabic: 'في انتظار الدفع',
      description: 'Payment is required to complete your booking',
      descriptionArabic: 'مطلوب الدفع لإتمام حجزك',
      color: Colors.amber,
      icon: Icons.payment,
      isActive: true,
      isCompleted: false,
      isCancellable: true,
      isModifiable: false,
      order: 3,
    ),
    BookingStatus.completed: BookingStatusInfo(
      status: BookingStatus.completed,
      displayName: 'Completed',
      displayNameArabic: 'مكتمل',
      description: 'Your event has been completed successfully',
      descriptionArabic: 'تم إنجاز مناسبتك بنجاح',
      color: Colors.blue,
      icon: Icons.event_available,
      isActive: false,
      isCompleted: true,
      isCancellable: false,
      isModifiable: false,
      order: 4,
    ),
    BookingStatus.cancelled: BookingStatusInfo(
      status: BookingStatus.cancelled,
      displayName: 'Cancelled',
      displayNameArabic: 'ملغي',
      description: 'This booking has been cancelled',
      descriptionArabic: 'تم إلغاء هذا الحجز',
      color: Colors.red,
      icon: Icons.cancel,
      isActive: false,
      isCompleted: true,
      isCancellable: false,
      isModifiable: false,
      order: 5,
    ),
    BookingStatus.expired: BookingStatusInfo(
      status: BookingStatus.expired,
      displayName: 'Expired',
      displayNameArabic: 'منتهي الصلاحية',
      description: 'This booking has expired',
      descriptionArabic: 'انتهت صلاحية هذا الحجز',
      color: Colors.grey,
      icon: Icons.schedule,
      isActive: false,
      isCompleted: true,
      isCancellable: false,
      isModifiable: false,
      order: 6,
    ),
    BookingStatus.refunded: BookingStatusInfo(
      status: BookingStatus.refunded,
      displayName: 'Refunded',
      displayNameArabic: 'مُسترد',
      description: 'Payment has been refunded for this booking',
      descriptionArabic: 'تم استرداد المبلغ المدفوع لهذا الحجز',
      color: Colors.teal,
      icon: Icons.money_off,
      isActive: false,
      isCompleted: true,
      isCancellable: false,
      isModifiable: false,
      order: 7,
    ),
  };

  /// Get status information
  static BookingStatusInfo getStatusInfo(BookingStatus status) {
    return _statusInfo[status] ?? _statusInfo[BookingStatus.pending]!;
  }

  /// Get all statuses ordered
  static List<BookingStatusInfo> getAllStatuses() {
    final statuses = _statusInfo.values.toList();
    statuses.sort((a, b) => a.order.compareTo(b.order));
    return statuses;
  }

  /// Get active statuses only
  static List<BookingStatusInfo> getActiveStatuses() {
    return getAllStatuses().where((s) => s.isActive).toList();
  }

  /// Get completed statuses only
  static List<BookingStatusInfo> getCompletedStatuses() {
    return getAllStatuses().where((s) => s.isCompleted).toList();
  }
}

/// Payment status information
class PaymentStatusInfo {
  final PaymentStatus status;
  final String displayName;
  final String displayNameArabic;
  final String description;
  final String descriptionArabic;
  final Color color;
  final IconData icon;
  final bool requiresAction;

  const PaymentStatusInfo({
    required this.status,
    required this.displayName,
    required this.displayNameArabic,
    required this.description,
    required this.descriptionArabic,
    required this.color,
    required this.icon,
    required this.requiresAction,
  });

  /// Get localized display name
  String getDisplayName(String languageCode) {
    return languageCode == 'ar' ? displayNameArabic : displayName;
  }

  /// Get localized description
  String getDescription(String languageCode) {
    return languageCode == 'ar' ? descriptionArabic : description;
  }
}

/// Payment status registry
class PaymentStatusRegistry {
  static const Map<PaymentStatus, PaymentStatusInfo> _statusInfo = {
    PaymentStatus.pending: PaymentStatusInfo(
      status: PaymentStatus.pending,
      displayName: 'Payment Pending',
      displayNameArabic: 'في انتظار الدفع',
      description: 'Payment is required',
      descriptionArabic: 'مطلوب الدفع',
      color: Colors.orange,
      icon: Icons.payment,
      requiresAction: true,
    ),
    PaymentStatus.firstPaid: PaymentStatusInfo(
      status: PaymentStatus.firstPaid,
      displayName: 'Partially Paid',
      displayNameArabic: 'مدفوع جزئياً',
      description: 'First payment completed, second payment pending',
      descriptionArabic: 'تم الدفع الأول، الدفع الثاني في انتظار',
      color: Colors.amber,
      icon: Icons.payments,
      requiresAction: true,
    ),
    PaymentStatus.fullyPaid: PaymentStatusInfo(
      status: PaymentStatus.fullyPaid,
      displayName: 'Fully Paid',
      displayNameArabic: 'مدفوع بالكامل',
      description: 'All payments completed',
      descriptionArabic: 'تم إتمام جميع المدفوعات',
      color: Colors.green,
      icon: Icons.check_circle,
      requiresAction: false,
    ),
    PaymentStatus.failed: PaymentStatusInfo(
      status: PaymentStatus.failed,
      displayName: 'Payment Failed',
      displayNameArabic: 'فشل الدفع',
      description: 'Payment processing failed',
      descriptionArabic: 'فشلت عملية الدفع',
      color: Colors.red,
      icon: Icons.error,
      requiresAction: true,
    ),
    PaymentStatus.refunded: PaymentStatusInfo(
      status: PaymentStatus.refunded,
      displayName: 'Refunded',
      displayNameArabic: 'مُسترد',
      description: 'Payment has been refunded',
      descriptionArabic: 'تم استرداد المبلغ',
      color: Colors.teal,
      icon: Icons.money_off,
      requiresAction: false,
    ),
    PaymentStatus.expired: PaymentStatusInfo(
      status: PaymentStatus.expired,
      displayName: 'Payment Expired',
      displayNameArabic: 'انتهت صلاحية الدفع',
      description: 'Payment deadline has passed',
      descriptionArabic: 'انتهى الموعد النهائي للدفع',
      color: Colors.grey,
      icon: Icons.schedule,
      requiresAction: false,
    ),
  };

  /// Get payment status information
  static PaymentStatusInfo getStatusInfo(PaymentStatus status) {
    return _statusInfo[status] ?? _statusInfo[PaymentStatus.pending]!;
  }

  /// Get all payment statuses
  static List<PaymentStatusInfo> getAllStatuses() {
    return _statusInfo.values.toList();
  }

  /// Get statuses that require action
  static List<PaymentStatusInfo> getActionRequiredStatuses() {
    return getAllStatuses().where((s) => s.requiresAction).toList();
  }
}

/// Approval status information
class ApprovalStatusInfo {
  final ApprovalStatus status;
  final String displayName;
  final String displayNameArabic;
  final Color color;
  final IconData icon;

  const ApprovalStatusInfo({
    required this.status,
    required this.displayName,
    required this.displayNameArabic,
    required this.color,
    required this.icon,
  });

  /// Get localized display name
  String getDisplayName(String languageCode) {
    return languageCode == 'ar' ? displayNameArabic : displayName;
  }
}

/// Approval status registry
class ApprovalStatusRegistry {
  static const Map<ApprovalStatus, ApprovalStatusInfo> _statusInfo = {
    ApprovalStatus.pending: ApprovalStatusInfo(
      status: ApprovalStatus.pending,
      displayName: 'Pending',
      displayNameArabic: 'في الانتظار',
      color: Colors.orange,
      icon: Icons.hourglass_empty,
    ),
    ApprovalStatus.approved: ApprovalStatusInfo(
      status: ApprovalStatus.approved,
      displayName: 'Approved',
      displayNameArabic: 'موافق عليه',
      color: Colors.green,
      icon: Icons.check_circle,
    ),
    ApprovalStatus.rejected: ApprovalStatusInfo(
      status: ApprovalStatus.rejected,
      displayName: 'Rejected',
      displayNameArabic: 'مرفوض',
      color: Colors.red,
      icon: Icons.cancel,
    ),
    ApprovalStatus.expired: ApprovalStatusInfo(
      status: ApprovalStatus.expired,
      displayName: 'Expired',
      displayNameArabic: 'منتهي الصلاحية',
      color: Colors.grey,
      icon: Icons.schedule,
    ),
  };

  /// Get approval status information
  static ApprovalStatusInfo getStatusInfo(ApprovalStatus status) {
    return _statusInfo[status] ?? _statusInfo[ApprovalStatus.pending]!;
  }
}

/// Booking progress tracker
class BookingProgress {
  final List<BookingProgressStep> steps;
  final int currentStepIndex;

  BookingProgress({
    required this.steps,
    required this.currentStepIndex,
  });

  /// Create progress from booking status
  factory BookingProgress.fromBookingStatus({
    required BookingStatus status,
    required PaymentStatus paymentStatus,
    required ApprovalStatus approvalStatus,
  }) {
    final steps = <BookingProgressStep>[];
    int currentIndex = 0;

    // Step 1: Booking Request
    steps.add(BookingProgressStep(
      title: 'Booking Request',
      titleArabic: 'طلب الحجز',
      isCompleted: true,
      isActive: status == BookingStatus.pending,
    ));

    // Step 2: Owner Approval
    final approvalCompleted = approvalStatus == ApprovalStatus.approved;
    if (approvalCompleted && currentIndex == 0) currentIndex = 1;

    steps.add(BookingProgressStep(
      title: 'Owner Approval',
      titleArabic: 'موافقة المالك',
      isCompleted: approvalCompleted,
      isActive: status == BookingStatus.pending && approvalStatus == ApprovalStatus.pending,
      isFailed: approvalStatus == ApprovalStatus.rejected,
    ));

    // Step 3: Payment
    final paymentCompleted = paymentStatus == PaymentStatus.fullyPaid;
    if (paymentCompleted && currentIndex == 1) currentIndex = 2;

    steps.add(BookingProgressStep(
      title: 'Payment',
      titleArabic: 'الدفع',
      isCompleted: paymentCompleted,
      isActive: status == BookingStatus.confirmed || status == BookingStatus.paymentPending,
      isFailed: paymentStatus == PaymentStatus.failed,
    ));

    // Step 4: Confirmation
    final confirmationCompleted = status == BookingStatus.completed;
    if (confirmationCompleted && currentIndex == 2) currentIndex = 3;

    steps.add(BookingProgressStep(
      title: 'Event Day',
      titleArabic: 'يوم المناسبة',
      isCompleted: confirmationCompleted,
      isActive: status == BookingStatus.confirmed && paymentStatus == PaymentStatus.fullyPaid,
    ));

    return BookingProgress(
      steps: steps,
      currentStepIndex: currentIndex,
    );
  }

  /// Get progress percentage
  double getProgressPercentage() {
    if (steps.isEmpty) return 0.0;
    final completedSteps = steps.where((s) => s.isCompleted).length;
    return completedSteps / steps.length;
  }

  /// Check if any step failed
  bool hasFailedStep() {
    return steps.any((s) => s.isFailed);
  }
}

/// Booking progress step
class BookingProgressStep {
  final String title;
  final String titleArabic;
  final bool isCompleted;
  final bool isActive;
  final bool isFailed;

  BookingProgressStep({
    required this.title,
    required this.titleArabic,
    required this.isCompleted,
    this.isActive = false,
    this.isFailed = false,
  });

  /// Get localized title
  String getTitle(String languageCode) {
    return languageCode == 'ar' ? titleArabic : title;
  }

  /// Get step color
  Color getColor() {
    if (isFailed) return Colors.red;
    if (isCompleted) return Colors.green;
    if (isActive) return Colors.blue;
    return Colors.grey;
  }

  /// Get step icon
  IconData getIcon() {
    if (isFailed) return Icons.error;
    if (isCompleted) return Icons.check_circle;
    if (isActive) return Icons.radio_button_checked;
    return Icons.radio_button_unchecked;
  }
}