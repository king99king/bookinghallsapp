// models/booking/booking_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/id_generator.dart';

/// Comprehensive booking model with integrated business logic
class BookingModel {
  final String bookingId;
  final String hallId;
  final String userId;
  final String ownerId;
  final BookingType bookingType;
  final DateTime eventDate;
  final TimeSlotWithId? timeSlot;
  final int guestCount;
  final String eventType;
  final String? eventDescription;
  final ContactInfo contactInfo;
  final PricingBreakdown pricing;
  final PaymentPlan paymentPlan;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? cancellationReason;
  final ApprovalStatus ownerApprovalStatus;
  final DateTime? ownerApprovedAt;
  final String? ownerRejectionReason;
  final List<BookingStatusHistory> statusHistory;
  final Map<String, dynamic>? metadata;

  BookingModel({
    required this.bookingId,
    required this.hallId,
    required this.userId,
    required this.ownerId,
    required this.bookingType,
    required this.eventDate,
    this.timeSlot,
    required this.guestCount,
    required this.eventType,
    this.eventDescription,
    required this.contactInfo,
    required this.pricing,
    required this.paymentPlan,
    required this.status,
    required this.paymentStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.cancellationReason,
    this.ownerApprovalStatus = ApprovalStatus.pending,
    this.ownerApprovedAt,
    this.ownerRejectionReason,
    this.statusHistory = const [],
    this.metadata,
  }) :
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // ========== Factory Constructors ==========

  /// Create from Firestore document
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    try {
      return BookingModel(
        bookingId: Validators.validateString(json[FirebaseConstants.bookingIdField], 'Booking ID'),
        hallId: Validators.validateString(json[FirebaseConstants.hallIdField], 'Hall ID'),
        userId: Validators.validateString(json[FirebaseConstants.userIdField], 'User ID'),
        ownerId: Validators.validateString(json[FirebaseConstants.ownerIdField], 'Owner ID'),
        bookingType: BookingType.values.firstWhere(
              (e) => e.name == json[FirebaseConstants.bookingTypeField],
          orElse: () => BookingType.daily,
        ),
        eventDate: DateUtils.parseISODate(json[FirebaseConstants.eventDateField]) ??
            DateTime.now().add(const Duration(days: 1)),
        timeSlot: json[FirebaseConstants.timeSlotField] != null
            ? TimeSlotWithId.fromJson(json[FirebaseConstants.timeSlotField] as Map<String, dynamic>)
            : null,
        guestCount: Validators.validatePositiveInt(json[FirebaseConstants.guestCountField], 'Guest count'),
        eventType: Validators.validateString(json[FirebaseConstants.eventTypeField], 'Event type'),
        eventDescription: json[FirebaseConstants.eventDescriptionField] as String?,
        contactInfo: ContactInfo.fromJson(json[FirebaseConstants.contactInfoField] as Map<String, dynamic>),
        pricing: PricingBreakdown.fromJson(json[FirebaseConstants.pricingField] as Map<String, dynamic>),
        paymentPlan: PaymentPlan.fromJson(json[FirebaseConstants.paymentPlanField] as Map<String, dynamic>),
        status: BookingStatus.values.firstWhere(
              (e) => e.name == json[FirebaseConstants.statusField],
          orElse: () => BookingStatus.pending,
        ),
        paymentStatus: PaymentStatus.values.firstWhere(
              (e) => e.name == json[FirebaseConstants.paymentStatusField],
          orElse: () => PaymentStatus.pending,
        ),
        createdAt: DateUtils.parseTimestamp(json[FirebaseConstants.createdAtField]) ?? DateTime.now(),
        updatedAt: DateUtils.parseTimestamp(json[FirebaseConstants.updatedAtField]) ?? DateTime.now(),
        cancellationReason: json[FirebaseConstants.cancellationReasonField] as String?,
        ownerApprovalStatus: ApprovalStatus.values.firstWhere(
              (e) => e.name == json[FirebaseConstants.ownerApprovalStatusField],
          orElse: () => ApprovalStatus.pending,
        ),
        ownerApprovedAt: DateUtils.parseTimestamp(json[FirebaseConstants.ownerApprovedAtField]),
        ownerRejectionReason: json['ownerRejectionReason'] as String?,
        statusHistory: (json['statusHistory'] as List<dynamic>?)
            ?.map((e) => BookingStatusHistory.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
        metadata: json['metadata'] as Map<String, dynamic>?,
      );
    } catch (e) {
      throw ModelParseException('Failed to parse BookingModel: $e');
    }
  }

  /// Create new booking
  static Future<BookingModel> create({
    required String hallId,
    required String userId,
    required String ownerId,
    required BookingType bookingType,
    required DateTime eventDate,
    TimeSlotWithId? timeSlot,
    required int guestCount,
    required String eventType,
    String? eventDescription,
    required ContactInfo contactInfo,
    required PricingBreakdown pricing,
    required PaymentPlan paymentPlan,
    Map<String, dynamic>? metadata,
  }) async {
    final bookingId = await IdGenerator.generateBookingId();
    final now = DateTime.now();

    return BookingModel(
      bookingId: bookingId,
      hallId: hallId,
      userId: userId,
      ownerId: ownerId,
      bookingType: bookingType,
      eventDate: eventDate,
      timeSlot: timeSlot,
      guestCount: guestCount,
      eventType: eventType,
      eventDescription: eventDescription,
      contactInfo: contactInfo,
      pricing: pricing,
      paymentPlan: paymentPlan,
      status: BookingStatus.pending,
      paymentStatus: PaymentStatus.pending,
      createdAt: now,
      updatedAt: now,
      ownerApprovalStatus: ApprovalStatus.pending,
      statusHistory: [
        BookingStatusHistory(
          status: BookingStatus.pending,
          timestamp: now,
          updatedBy: userId,
          notes: 'Booking created',
        ),
      ],
      metadata: metadata,
    );
  }

  // ========== Serialization ==========

  Map<String, dynamic> toJson() {
    return {
      FirebaseConstants.bookingIdField: bookingId,
      FirebaseConstants.hallIdField: hallId,
      FirebaseConstants.userIdField: userId,
      FirebaseConstants.ownerIdField: ownerId,
      FirebaseConstants.bookingTypeField: bookingType.name,
      FirebaseConstants.eventDateField: DateUtils.toISOString(eventDate),
      FirebaseConstants.timeSlotField: timeSlot?.toJson(),
      FirebaseConstants.guestCountField: guestCount,
      FirebaseConstants.eventTypeField: eventType,
      FirebaseConstants.eventDescriptionField: eventDescription,
      FirebaseConstants.contactInfoField: contactInfo.toJson(),
      FirebaseConstants.pricingField: pricing.toJson(),
      FirebaseConstants.paymentPlanField: paymentPlan.toJson(),
      FirebaseConstants.statusField: status.name,
      FirebaseConstants.paymentStatusField: paymentStatus.name,
      FirebaseConstants.createdAtField: FieldValue.serverTimestamp(),
      FirebaseConstants.updatedAtField: FieldValue.serverTimestamp(),
      FirebaseConstants.cancellationReasonField: cancellationReason,
      FirebaseConstants.ownerApprovalStatusField: ownerApprovalStatus.name,
      FirebaseConstants.ownerApprovedAtField: ownerApprovedAt != null
          ? Timestamp.fromDate(ownerApprovedAt!)
          : null,
      'ownerRejectionReason': ownerRejectionReason,
      'statusHistory': statusHistory.map((h) => h.toJson()).toList(),
      'metadata': metadata,
    };
  }

  // ========== Business Logic Methods ==========

  /// Check if booking can be cancelled
  bool canBeCancelled() {
    final now = DateTime.now();
    final hoursUntilEvent = eventDate.difference(now).inHours;

    return (status == BookingStatus.pending ||
        status == BookingStatus.confirmed) &&
        hoursUntilEvent >= AppConstants.minCancellationHours &&
        paymentStatus != PaymentStatus.fullyPaid;
  }

  /// Check if booking can be modified
  bool canBeModified() {
    final now = DateTime.now();
    final hoursUntilEvent = eventDate.difference(now).inHours;

    return status == BookingStatus.pending &&
        ownerApprovalStatus == ApprovalStatus.pending &&
        hoursUntilEvent >= AppConstants.minModificationHours;
  }

  /// Check if second payment is due
  bool isSecondPaymentDue() {
    if (paymentStatus == PaymentStatus.fullyPaid ||
        paymentStatus == PaymentStatus.failed) {
      return false;
    }

    final now = DateTime.now();
    final daysUntilEvent = eventDate.difference(now).inDays;

    return paymentStatus == PaymentStatus.firstPaid &&
        daysUntilEvent <= paymentPlan.daysBeforeEventForFinalPayment;
  }

  /// Check if booking is overdue for second payment
  bool isSecondPaymentOverdue() {
    if (!isSecondPaymentDue()) return false;

    final now = DateTime.now();
    final secondPaymentDueDate = eventDate.subtract(
        Duration(days: paymentPlan.daysBeforeEventForFinalPayment)
    );

    return now.isAfter(secondPaymentDueDate.add(const Duration(days: 1)));
  }

  /// Check if booking is expired
  bool isExpired() {
    final now = DateTime.now();
    return eventDate.add(const Duration(hours: 24)).isBefore(now);
  }

  /// Check if booking requires owner approval
  bool requiresOwnerApproval() {
    return status == BookingStatus.pending &&
        ownerApprovalStatus == ApprovalStatus.pending;
  }

  /// Get remaining payment amount
  double getRemainingPaymentAmount() {
    switch (paymentStatus) {
      case PaymentStatus.pending:
        return pricing.totalAmount;
      case PaymentStatus.firstPaid:
        return paymentPlan.secondPaymentAmount;
      case PaymentStatus.fullyPaid:
        return 0.0;
      case PaymentStatus.failed:
        return pricing.totalAmount;
    }
  }

  /// Get booking duration in hours (for hourly bookings)
  int? getDurationInHours() {
    if (bookingType != BookingType.hourly || timeSlot == null) {
      return null;
    }

    return timeSlot!.getDurationInHours();
  }

  /// Get localized event type
  String getLocalizedEventType(String languageCode) {
    // This would integrate with your localization system
    final eventTypeTranslations = {
      'wedding': {'en': 'Wedding', 'ar': 'حفل زفاف'},
      'birthday': {'en': 'Birthday Party', 'ar': 'حفلة عيد ميلاد'},
      'corporate': {'en': 'Corporate Event', 'ar': 'مناسبة شركة'},
      'graduation': {'en': 'Graduation', 'ar': 'حفل تخرج'},
      'conference': {'en': 'Conference', 'ar': 'مؤتمر'},
      'other': {'en': 'Other', 'ar': 'أخرى'},
    };

    return eventTypeTranslations[eventType]?[languageCode] ?? eventType;
  }

  /// Get status display text
  String getStatusDisplayText(String languageCode) {
    final statusTranslations = {
      'pending': {'en': 'Pending Approval', 'ar': 'في انتظار الموافقة'},
      'confirmed': {'en': 'Confirmed', 'ar': 'مؤكد'},
      'paymentPending': {'en': 'Payment Pending', 'ar': 'في انتظار الدفع'},
      'completed': {'en': 'Completed', 'ar': 'مكتمل'},
      'cancelled': {'en': 'Cancelled', 'ar': 'ملغي'},
    };

    return statusTranslations[status.name]?[languageCode] ?? status.name;
  }

  // ========== Update Methods ==========

  /// Approve booking by owner
  BookingModel approveByOwner(String approverId, {String? notes}) {
    final now = DateTime.now();
    final newHistory = List<BookingStatusHistory>.from(statusHistory)
      ..add(BookingStatusHistory(
        status: BookingStatus.confirmed,
        timestamp: now,
        updatedBy: approverId,
        notes: notes ?? 'Approved by hall owner',
      ));

    return copyWith(
      status: BookingStatus.confirmed,
      ownerApprovalStatus: ApprovalStatus.approved,
      ownerApprovedAt: now,
      updatedAt: now,
      statusHistory: newHistory,
    );
  }

  /// Reject booking by owner
  BookingModel rejectByOwner(String rejectorId, String reason) {
    final now = DateTime.now();
    final newHistory = List<BookingStatusHistory>.from(statusHistory)
      ..add(BookingStatusHistory(
        status: BookingStatus.cancelled,
        timestamp: now,
        updatedBy: rejectorId,
        notes: 'Rejected by hall owner: $reason',
      ));

    return copyWith(
      status: BookingStatus.cancelled,
      ownerApprovalStatus: ApprovalStatus.rejected,
      ownerRejectionReason: reason,
      cancellationReason: 'Rejected by hall owner: $reason',
      updatedAt: now,
      statusHistory: newHistory,
    );
  }

  /// Update payment status
  BookingModel updatePaymentStatus(PaymentStatus newPaymentStatus, {String? updatedBy}) {
    final now = DateTime.now();
    var newStatus = status;

    // Update booking status based on payment status
    if (newPaymentStatus == PaymentStatus.firstPaid && status == BookingStatus.pending) {
      newStatus = BookingStatus.paymentPending;
    } else if (newPaymentStatus == PaymentStatus.fullyPaid) {
      newStatus = BookingStatus.confirmed;
    }

    final newHistory = List<BookingStatusHistory>.from(statusHistory)
      ..add(BookingStatusHistory(
        status: newStatus,
        timestamp: now,
        updatedBy: updatedBy ?? userId,
        notes: 'Payment status updated to ${newPaymentStatus.name}',
      ));

    return copyWith(
      paymentStatus: newPaymentStatus,
      status: newStatus,
      updatedAt: now,
      statusHistory: newHistory,
    );
  }

  /// Cancel booking
  BookingModel cancel(String reason, {String? cancelledBy}) {
    final now = DateTime.now();
    final newHistory = List<BookingStatusHistory>.from(statusHistory)
      ..add(BookingStatusHistory(
        status: BookingStatus.cancelled,
        timestamp: now,
        updatedBy: cancelledBy ?? userId,
        notes: 'Booking cancelled: $reason',
      ));

    return copyWith(
      status: BookingStatus.cancelled,
      cancellationReason: reason,
      updatedAt: now,
      statusHistory: newHistory,
    );
  }

  /// Complete booking
  BookingModel complete({String? completedBy}) {
    final now = DateTime.now();
    final newHistory = List<BookingStatusHistory>.from(statusHistory)
      ..add(BookingStatusHistory(
        status: BookingStatus.completed,
        timestamp: now,
        updatedBy: completedBy ?? ownerId,
        notes: 'Booking completed successfully',
      ));

    return copyWith(
      status: BookingStatus.completed,
      updatedAt: now,
      statusHistory: newHistory,
    );
  }

  // ========== Copy With ==========

  BookingModel copyWith({
    String? bookingId,
    String? hallId,
    String? userId,
    String? ownerId,
    BookingType? bookingType,
    DateTime? eventDate,
    TimeSlotWithId? timeSlot,
    int? guestCount,
    String? eventType,
    String? eventDescription,
    ContactInfo? contactInfo,
    PricingBreakdown? pricing,
    PaymentPlan? paymentPlan,
    BookingStatus? status,
    PaymentStatus? paymentStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? cancellationReason,
    ApprovalStatus? ownerApprovalStatus,
    DateTime? ownerApprovedAt,
    String? ownerRejectionReason,
    List<BookingStatusHistory>? statusHistory,
    Map<String, dynamic>? metadata,
  }) {
    return BookingModel(
      bookingId: bookingId ?? this.bookingId,
      hallId: hallId ?? this.hallId,
      userId: userId ?? this.userId,
      ownerId: ownerId ?? this.ownerId,
      bookingType: bookingType ?? this.bookingType,
      eventDate: eventDate ?? this.eventDate,
      timeSlot: timeSlot ?? this.timeSlot,
      guestCount: guestCount ?? this.guestCount,
      eventType: eventType ?? this.eventType,
      eventDescription: eventDescription ?? this.eventDescription,
      contactInfo: contactInfo ?? this.contactInfo,
      pricing: pricing ?? this.pricing,
      paymentPlan: paymentPlan ?? this.paymentPlan,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      ownerApprovalStatus: ownerApprovalStatus ?? this.ownerApprovalStatus,
      ownerApprovedAt: ownerApprovedAt ?? this.ownerApprovedAt,
      ownerRejectionReason: ownerRejectionReason ?? this.ownerRejectionReason,
      statusHistory: statusHistory ?? this.statusHistory,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookingModel && other.bookingId == bookingId;
  }

  @override
  int get hashCode => bookingId.hashCode;

  @override
  String toString() => 'BookingModel(id: $bookingId, hall: $hallId, status: $status)';
}

// ========== Supporting Models ==========

/// Booking type enum
enum BookingType { daily, hourly }

/// Booking status enum
enum BookingStatus {
  pending,
  confirmed,
  paymentPending,
  completed,
  cancelled
}

/// Payment status enum
enum PaymentStatus {
  pending,
  firstPaid,
  fullyPaid,
  failed
}

/// Approval status enum
enum ApprovalStatus {
  pending,
  approved,
  rejected
}

/// Time slot with ID for hourly bookings
class TimeSlotWithId {
  final String id;
  final String startTime; // Format: "HH:mm"
  final String endTime;   // Format: "HH:mm"
  final bool isFullDay;
  final double? customRate;

  TimeSlotWithId({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.isFullDay = false,
    this.customRate,
  });

  factory TimeSlotWithId.fromJson(Map<String, dynamic> json) {
    return TimeSlotWithId(
      id: json['id'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      isFullDay: json['isFullDay'] as bool? ?? false,
      customRate: (json['customRate'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime,
      'endTime': endTime,
      'isFullDay': isFullDay,
      'customRate': customRate,
    };
  }

  /// Get duration in hours
  int getDurationInHours() {
    if (isFullDay) return 24;

    final start = _parseTime(startTime);
    final end = _parseTime(endTime);

    if (end.isBefore(start)) {
      // Handle overnight slots
      final nextDay = DateTime(end.year, end.month, end.day + 1, end.hour, end.minute);
      return nextDay.difference(start).inHours;
    }

    return end.difference(start).inHours;
  }

  DateTime _parseTime(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  @override
  String toString() => isFullDay ? 'Full Day' : '$startTime - $endTime';
}

/// Contact information for booking
class ContactInfo {
  final String name;
  final String phone;
  final String? email;
  final String? alternativePhone;

  ContactInfo({
    required this.name,
    required this.phone,
    this.email,
    this.alternativePhone,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      name: Validators.validateString(json['name'], 'Contact name'),
      phone: Validators.validatePhoneNumber(json['phone']) ?? '',
      email: json['email'] as String?,
      alternativePhone: json['alternativePhone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'alternativePhone': alternativePhone,
    };
  }
}

/// Pricing breakdown for booking
class PricingBreakdown {
  final double basePrice;
  final List<AppliedDiscount> appliedDiscounts;
  final double subtotal;
  final double customerCommission;
  final double ownerCommission;
  final double totalAmount;
  final double ownerEarnings;
  final double adminEarnings;

  PricingBreakdown({
    required this.basePrice,
    this.appliedDiscounts = const [],
    required this.subtotal,
    required this.customerCommission,
    required this.ownerCommission,
    required this.totalAmount,
    required this.ownerEarnings,
    required this.adminEarnings,
  });

  factory PricingBreakdown.fromJson(Map<String, dynamic> json) {
    return PricingBreakdown(
      basePrice: (json['basePrice'] as num).toDouble(),
      appliedDiscounts: (json['appliedDiscounts'] as List<dynamic>?)
          ?.map((e) => AppliedDiscount.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      subtotal: (json['subtotal'] as num).toDouble(),
      customerCommission: (json['customerCommission'] as num).toDouble(),
      ownerCommission: (json['ownerCommission'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      ownerEarnings: (json['ownerEarnings'] as num).toDouble(),
      adminEarnings: (json['adminEarnings'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'basePrice': basePrice,
      'appliedDiscounts': appliedDiscounts.map((d) => d.toJson()).toList(),
      'subtotal': subtotal,
      'customerCommission': customerCommission,
      'ownerCommission': ownerCommission,
      'totalAmount': totalAmount,
      'ownerEarnings': ownerEarnings,
      'adminEarnings': adminEarnings,
    };
  }
}

/// Applied discount information
class AppliedDiscount {
  final String discountId;
  final String name;
  final double discountPercent;
  final double discountAmount;

  AppliedDiscount({
    required this.discountId,
    required this.name,
    required this.discountPercent,
    required this.discountAmount,
  });

  factory AppliedDiscount.fromJson(Map<String, dynamic> json) {
    return AppliedDiscount(
      discountId: json['discountId'] as String,
      name: json['name'] as String,
      discountPercent: (json['discountPercent'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'discountId': discountId,
      'name': name,
      'discountPercent': discountPercent,
      'discountAmount': discountAmount,
    };
  }
}

/// Payment plan for booking
class PaymentPlan {
  final bool enabled;
  final double firstPaymentPercent;
  final double firstPaymentAmount;
  final double secondPaymentAmount;
  final int daysBeforeEventForFinalPayment;
  final DateTime? firstPaymentDueDate;
  final DateTime? secondPaymentDueDate;

  PaymentPlan({
    required this.enabled,
    required this.firstPaymentPercent,
    required this.firstPaymentAmount,
    required this.secondPaymentAmount,
    required this.daysBeforeEventForFinalPayment,
    this.firstPaymentDueDate,
    this.secondPaymentDueDate,
  });

  factory PaymentPlan.fromJson(Map<String, dynamic> json) {
    return PaymentPlan(
      enabled: json['enabled'] as bool? ?? false,
      firstPaymentPercent: (json['firstPaymentPercent'] as num).toDouble(),
      firstPaymentAmount: (json['firstPaymentAmount'] as num).toDouble(),
      secondPaymentAmount: (json['secondPaymentAmount'] as num).toDouble(),
      daysBeforeEventForFinalPayment: json['daysBeforeEventForFinalPayment'] as int,
      firstPaymentDueDate: DateUtils.parseTimestamp(json['firstPaymentDueDate']),
      secondPaymentDueDate: DateUtils.parseTimestamp(json['secondPaymentDueDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'firstPaymentPercent': firstPaymentPercent,
      'firstPaymentAmount': firstPaymentAmount,
      'secondPaymentAmount': secondPaymentAmount,
      'daysBeforeEventForFinalPayment': daysBeforeEventForFinalPayment,
      'firstPaymentDueDate': firstPaymentDueDate != null
          ? Timestamp.fromDate(firstPaymentDueDate!)
          : null,
      'secondPaymentDueDate': secondPaymentDueDate != null
          ? Timestamp.fromDate(secondPaymentDueDate!)
          : null,
    };
  }
}

/// Booking status history tracking
class BookingStatusHistory {
  final BookingStatus status;
  final DateTime timestamp;
  final String updatedBy;
  final String? notes;

  BookingStatusHistory({
    required this.status,
    required this.timestamp,
    required this.updatedBy,
    this.notes,
  });

  factory BookingStatusHistory.fromJson(Map<String, dynamic> json) {
    return BookingStatusHistory(
      status: BookingStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      timestamp: DateUtils.parseTimestamp(json['timestamp']) ?? DateTime.now(),
      updatedBy: json['updatedBy'] as String,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'updatedBy': updatedBy,
      'notes': notes,
    };
  }
}

/// Custom exception for model parsing errors
class ModelParseException implements Exception {
  final String message;
  ModelParseException(this.message);

  @override
  String toString() => 'ModelParseException: $message';
}